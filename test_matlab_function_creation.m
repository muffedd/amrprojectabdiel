% test_matlab_function_creation.m
clear; clc;
sys = 'test_mf_sys';
new_system(sys);

mf_blk = add_block('simulink/User-Defined Functions/MATLAB Function', [sys, '/MyFunc']);
sf = sfroot;
m_chart = sf.find('Path', [sys, '/MyFunc'], '-isa', 'Stateflow.EMChart');
m_chart.Script = sprintf('function [y1, y2] = MyFunc(u1, u2)\ny1 = u1 + u2;\ny2 = u1 - u2;\n');

disp('MATLAB Function block created and script populated successfully!');
close_system(sys, 0);
