function props = connectionPortProperties(block)
% CONNECTIONPORTPROPERTIES Inspects connection ports of a Simulink/Simscape block
% Returns struct array with fields: PortName, Type, Handle, PortNumber

    if ischar(block) || isstring(block)
        block = get_param(block, 'Handle');
    end
    
    ph = get_param(block, 'PortHandles');
    
    props = struct('PortName', {}, 'Type', {}, 'Handle', {}, 'PortNumber', {});
    
    % LConn ports (physical connection left)
    for i = 1:length(ph.LConn)
        props(end+1) = struct('PortName', sprintf('LConn%d', i), ...
                              'Type', 'LConn', ...
                              'Handle', ph.LConn(i), ...
                              'PortNumber', i); %#ok<AGROW>
    end
    
    % RConn ports (physical connection right)
    for i = 1:length(ph.RConn)
        props(end+1) = struct('PortName', sprintf('RConn%d', i), ...
                              'Type', 'RConn', ...
                              'Handle', ph.RConn(i), ...
                              'PortNumber', i); %#ok<AGROW>
    end
    
    % Standard Inports
    for i = 1:length(ph.Inport)
        props(end+1) = struct('PortName', sprintf('In%d', i), ...
                              'Type', 'Inport', ...
                              'Handle', ph.Inport(i), ...
                              'PortNumber', i); %#ok<AGROW>
    end
    
    % Standard Outports
    for i = 1:length(ph.Outport)
        props(end+1) = struct('PortName', sprintf('Out%d', i), ...
                              'Type', 'Outport', ...
                              'Handle', ph.Outport(i), ...
                              'PortNumber', i); %#ok<AGROW>
    end
end
