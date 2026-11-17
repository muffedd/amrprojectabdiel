% search_xml_wheels.m
clear; clc;
xml = fileread('AGV.xml');
matches = regexp(xml, '<(Instance|Part|Assembly)[^>]*name="[^"]*[Ww]heel[^"]*"[^>]*>', 'match');
for i = 1:min(20, length(matches))
    disp(matches{i});
end
