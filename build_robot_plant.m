%% BUILD_ROBOT_PLANT.M
% Builds a clean Simscape Multibody model: AGV_Robot_Plant.slx
%
% Workflow:
% 1. Inspect all individual part .STEP files and parse AGV.xml
% 2. Setup Solver (World Frame, Mechanism Config, Solver Config)
% 3. Group static parts into Robot_Chassis subsystem and attach 4 wheels via Revolute Joints
% 4. Wire ports using simscape.addConnection & arrange layout
% 5. Run 1-second verification simulation

clear; clc;
fprintf('=== Starting AGV Robot Plant Build ===\n\n');

%% Step 1: Inspect .STEP files and AGV.xml
fprintf('--- Step 1: Inspecting CAD files in current workspace ---\n');
stepFiles = dir(fullfile(pwd, '*.STEP'));
fprintf('Found %d .STEP files:\n', length(stepFiles));
for k = 1:length(stepFiles)
    fprintf('  [%2d] %s (%.1f KB)\n', k, stepFiles(k).name, stepFiles(k).bytes/1024);
end
fprintf('\n');

xmlFile = fullfile(pwd, 'AGV.xml');
staticParts = struct('name', {}, 'file', {}, 'pos_m', {}, 'R', {}, 'mass', {});
wheels = struct('name', {}, 'file', {}, 'pos_m', {}, 'R_joint', {}, 'R_fw', {}, 'mass', {});

if exist(xmlFile, 'file')
    fprintf('Checking AGV.xml: Found "%s"\n', xmlFile);
    xDoc = xmlread(xmlFile);
    
    % Read static parts from Assembly "Robot_Chassis"
    partNodes = xDoc.getElementsByTagName('Part');
    for k = 0:partNodes.getLength()-1
        pNode = partNodes.item(k);
        pName = char(pNode.getAttribute('name'));
        pFile = char(pNode.getAttribute('file'));
        
        % Read Mass
        mass = 5.0;
        mNodes = pNode.getElementsByTagName('Mass');
        if mNodes.getLength() > 0
            mass = str2double(char(mNodes.item(0).getAttribute('value')));
        end
        
        % Read Translation
        pos = [0, 0, 0];
        tNodes = pNode.getElementsByTagName('Translation');
        if tNodes.getLength() > 0
            pos = [str2double(char(tNodes.item(0).getAttribute('x'))), ...
                   str2double(char(tNodes.item(0).getAttribute('y'))), ...
                   str2double(char(tNodes.item(0).getAttribute('z')))];
        end
        
        % Read RotationMatrix
        R = eye(3);
        rNodes = pNode.getElementsByTagName('RotationMatrix');
        if rNodes.getLength() > 0
            R = str2num(char(rNodes.item(0).getAttribute('matrix'))); %#ok<ST2NM>
        end
        
        staticParts(end+1) = struct('name', pName, 'file', pFile, 'pos_m', pos, 'R', R, 'mass', mass); %#ok<AGROW>
    end
    
    % Read wheels from Assembly "Wheels"
    wheelNodes = xDoc.getElementsByTagName('Wheel');
    for k = 0:wheelNodes.getLength()-1
        wNode = wheelNodes.item(k);
        wName = char(wNode.getAttribute('name'));
        wFile = char(wNode.getAttribute('file'));
        
        mass = 3.0;
        mNodes = wNode.getElementsByTagName('Mass');
        if mNodes.getLength() > 0
            mass = str2double(char(mNodes.item(0).getAttribute('value')));
        end
        
        pos = [0, 0, 0];
        tNodes = wNode.getElementsByTagName('Translation');
        if tNodes.getLength() > 0
            pos = [str2double(char(tNodes.item(0).getAttribute('x'))), ...
                   str2double(char(tNodes.item(0).getAttribute('y'))), ...
                   str2double(char(tNodes.item(0).getAttribute('z')))];
        end
        
        R_joint = eye(3);
        rjNodes = wNode.getElementsByTagName('JointRotationMatrix');
        if rjNodes.getLength() > 0
            R_joint = str2num(char(rjNodes.item(0).getAttribute('matrix'))); %#ok<ST2NM>
        end
        
        R_fw = eye(3);
        rfwNodes = wNode.getElementsByTagName('FollowerRotationMatrix');
        if rfwNodes.getLength() > 0
            R_fw = str2num(char(rfwNodes.item(0).getAttribute('matrix'))); %#ok<ST2NM>
        end
        
        wheels(end+1) = struct('name', wName, 'file', wFile, 'pos_m', pos, ...
                               'R_joint', R_joint, 'R_fw', R_fw, 'mass', mass); %#ok<AGROW>
    end
    fprintf('Loaded %d static parts and %d wheels from AGV.xml.\n\n', length(staticParts), length(wheels));
else
    error('AGV.xml not found! Please ensure AGV.xml is present.');
end

%% Step 2: Initialize Model and Setup Solvers
modelName = 'AGV_Robot_Plant';
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end
new_system(modelName);
open_system(modelName);

load_system('sm_lib');
load_system('nesl_utility');

fprintf('--- Step 2: Adding Solver & Environment Blocks ---\n');
wfPath = [modelName '/World_Frame'];
mcPath = [modelName '/Mechanism_Configuration'];
scPath = [modelName '/Solver_Configuration'];

add_block('sm_lib/Frames and Transforms/World Frame', wfPath);
add_block('sm_lib/Utilities/Mechanism Configuration', mcPath);
add_block('nesl_utility/Solver Configuration', scPath);

% Inspect ports via simscape.connectionPortProperties
wfProps = simscape.connectionPortProperties(wfPath);
mcProps = simscape.connectionPortProperties(mcPath);
scProps = simscape.connectionPortProperties(scPath);

fprintf('Inspected Solver ports:\n');
fprintf('  World_Frame: %s (%s)\n', wfProps(1).PortName, wfProps(1).Type);
fprintf('  Mechanism_Config: %s (%s)\n', mcProps(1).PortName, mcProps(1).Type);
fprintf('  Solver_Config: %s (%s)\n', scProps(1).PortName, scProps(1).Type);

% Connect World Frame to Mechanism Configuration & Solver Configuration
simscape.addConnection(modelName, 'World_Frame/RConn1', 'Mechanism_Configuration/RConn1');
simscape.addConnection(modelName, 'World_Frame/RConn1', 'Solver_Configuration/RConn1');
fprintf('Connected World Frame, Mechanism Config, and Solver Config.\n\n');

%% Step 3: Create Robot_Chassis Subsystem & Wheels
fprintf('--- Step 3: Building Robot_Chassis Subsystem & Wheels ---\n');
subChassis = [modelName '/Robot_Chassis'];
add_block('built-in/Subsystem', subChassis);
Simulink.SubSystem.deleteContents(subChassis);

% Base Connection Port on left side of Robot_Chassis
cpBase = [subChassis '/Port_Base'];
add_block('nesl_utility/Connection Port', cpBase, 'Port', '1', 'Side', 'Left');

% Group static body parts into Robot_Chassis
fprintf('Adding %d static body parts to Robot_Chassis:\n', length(staticParts));
for k = 1:length(staticParts)
    p = staticParts(k);
    rtName = ['RT_' p.name];
    solidName = ['Solid_' p.name];
    rtPath = [subChassis '/' rtName];
    solidPath = [subChassis '/' solidName];
    
    % Rigid Transform
    add_block('sm_lib/Frames and Transforms/Rigid Transform', rtPath);
    set_param(rtPath, ...
        'TranslationMethod', 'Cartesian', ...
        'TranslationCartesianOffset', mat2str(p.pos_m, 6), ...
        'TranslationCartesianOffsetUnits', 'm', ...
        'RotationMethod', 'RotationMatrix', ...
        'RotationMatrix', mat2str(p.R, 6));
        
    % File Solid with Inertia set to Calculate from Geometry
    add_block('sm_lib/Body Elements/File Solid', solidPath);
    set_param(solidPath, ...
        'ExtGeomFileName', p.file, ...
        'ExtGeomFileUnits', 'm', ...
        'InertiaType', 'CalculateFromGeometry', ...
        'BasedOnType', 'Density', ...
        'Density', '1000', ...
        'DensityUnits', 'kg/m^3');
        
    % Inspect ports
    rtProps = simscape.connectionPortProperties(rtPath);
    sProps = simscape.connectionPortProperties(solidPath);
    
    % Connect Port_Base -> RT -> Solid
    simscape.addConnection(subChassis, 'Port_Base/RConn1', [rtName '/LConn1']);
    simscape.addConnection(subChassis, [rtName '/RConn1'], [solidName '/RConn1']);
    fprintf('  [+] Part %s (%s) connected.\n', p.name, p.file);
end

% Inside Robot_Chassis, add joint attachment transforms and export connection ports for 4 wheels
fprintf('Adding 4 wheel attachment mount ports in Robot_Chassis:\n');
for i = 1:length(wheels)
    w = wheels(i);
    rtMountName = sprintf('RT_Mount_%s', w.name);
    cpWheelName = sprintf('Port_%s', w.name);
    rtMountPath = [subChassis '/' rtMountName];
    cpWheelPath = [subChassis '/' cpWheelName];
    
    % Rigid Transform from chassis base to wheel joint center & orientation
    add_block('sm_lib/Frames and Transforms/Rigid Transform', rtMountPath);
    set_param(rtMountPath, ...
        'TranslationMethod', 'Cartesian', ...
        'TranslationCartesianOffset', mat2str(w.pos_m, 6), ...
        'TranslationCartesianOffsetUnits', 'm', ...
        'RotationMethod', 'RotationMatrix', ...
        'RotationMatrix', mat2str(w.R_joint, 6));
        
    % Connection Port exported to right side of subsystem
    add_block('nesl_utility/Connection Port', cpWheelPath, ...
        'Port', num2str(i + 1), 'Side', 'Right');
        
    % Connect Port_Base -> RT_Mount -> Port_Wheel
    simscape.addConnection(subChassis, 'Port_Base/RConn1', [rtMountName '/LConn1']);
    simscape.addConnection(subChassis, [rtMountName '/RConn1'], [cpWheelName '/RConn1']);
    fprintf('  [+] Wheel Mount %d (%s) at [%.3f, %.3f, %.3f] m.\n', ...
        i, w.name, w.pos_m(1), w.pos_m(2), w.pos_m(3));
end

%% Step 4: Top-Level Wiring & Revolute Joints
fprintf('\n--- Step 4: Connecting Chassis and Wheel Revolute Joints ---\n');

% Connect World Frame to Robot_Chassis Base (LConn1)
simscape.addConnection(modelName, 'World_Frame/RConn1', 'Robot_Chassis/LConn1');
fprintf('Connected World Frame to Robot_Chassis.\n');

for i = 1:length(wheels)
    w = wheels(i);
    rjName = sprintf('Revolute_Joint_%d', i);
    rtAlignName = sprintf('RT_Align_%s', w.name);
    solidWheelName = sprintf('Solid_%s', w.name);
    
    rjPath = [modelName '/' rjName];
    rtAlignPath = [modelName '/' rtAlignName];
    solidWheelPath = [modelName '/' solidWheelName];
    
    % Revolute Joint with torque actuation and velocity sensing
    add_block('sm_lib/Joints/Revolute Joint', rjPath);
    set_param(rjPath, ...
        'TorqueActuationMode', 'InputTorque', ...
        'SenseVelocity', 'on');
        
    % Rigid Transform aligning joint revolution Z-axis with wheel CAD geometry
    add_block('sm_lib/Frames and Transforms/Rigid Transform', rtAlignPath);
    set_param(rtAlignPath, ...
        'RotationMethod', 'RotationMatrix', ...
        'RotationMatrix', mat2str(w.R_fw, 6), ...
        'TranslationMethod', 'None');
        
    % File Solid for Wheel
    add_block('sm_lib/Body Elements/File Solid', solidWheelPath);
    set_param(solidWheelPath, ...
        'ExtGeomFileName', w.file, ...
        'ExtGeomFileUnits', 'm', ...
        'InertiaType', 'CalculateFromGeometry', ...
        'BasedOnType', 'Density', ...
        'Density', '1000', ...
        'DensityUnits', 'kg/m^3');
        
    % Inspect ports via simscape.connectionPortProperties
    rjProps = simscape.connectionPortProperties(rjPath);
    rtProps = simscape.connectionPortProperties(rtAlignPath);
    wProps = simscape.connectionPortProperties(solidWheelPath);
    
    % Connect Robot_Chassis (RConn i) -> Revolute Joint (LConn1: Base)
    chassisPort = sprintf('Robot_Chassis/RConn%d', i);
    simscape.addConnection(modelName, chassisPort, [rjName '/LConn1']);
    
    % Connect Revolute Joint (RConn1: Follower) -> RT_Align (LConn1)
    simscape.addConnection(modelName, [rjName '/RConn1'], [rtAlignName '/LConn1']);
    
    % Connect RT_Align (RConn1) -> Solid_Wheel (RConn1)
    simscape.addConnection(modelName, [rtAlignName '/RConn1'], [solidWheelName '/RConn1']);
    
    fprintf('  [+] Attached %s to chassis via %s (TorqueActuationMode=InputTorque, SenseVelocity=on)\n', ...
        w.name, rjName);
end

%% Clean up layout and save model
fprintf('\n--- Cleaning layout and saving model ---\n');
Simulink.BlockDiagram.arrangeSystem(subChassis);
Simulink.BlockDiagram.arrangeSystem(modelName);

save_system(modelName, fullfile(pwd, [modelName '.slx']));
fprintf('Model saved successfully as: %s.slx\n', fullfile(pwd, modelName));

%% Step 5: Verification Simulation
fprintf('\n--- Step 5: Running 1-second Test Simulation ---\n');
set_param(modelName, 'StopTime', '1.0');
try
    simOut = sim(modelName);
    fprintf('SUCCESS: 1-second test simulation completed cleanly!\n');
    try
        stopTime = simOut.SimulationMetadata.ModelInfo.StopTime;
        fprintf('Simulation stop time: %.2f s. No missing frames or algebraic loop errors.\n', stopTime);
    catch
        fprintf('Simulation completed cleanly without missing frames or algebraic loop errors.\n');
    end
    save_system(modelName);
catch ME
    fprintf('ERROR during simulation:\n%s\n', getReport(ME));
    rethrow(ME);
end

fprintf('\n=== AGV Robot Plant Build Finished Successfully ===\n');
