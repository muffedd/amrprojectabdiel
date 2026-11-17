function lineHandle = addConnection(varargin)
% ADDCONNECTION Connects physical Simscape or Simulink ports in a diagram
% Syntax:
%   simscape.addConnection(sys, 'BlockA/RConn1', 'BlockB/LConn1')
%   simscape.addConnection('sys/BlockA/RConn1', 'sys/BlockB/LConn1')
%   simscape.addConnection(sys, portHandleA, portHandleB)
%   simscape.addConnection(portHandleA, portHandleB)

    if nargin == 2
        src = varargin{1};
        dst = varargin{2};
        if isnumeric(src)
            sys = get_param(get_param(src, 'Parent'), 'Parent');
        else
            parts = split(char(src), '/');
            sys = parts{1};
            % In case block is in a subsystem, sys is everything up to the block's parent:
            if length(parts) > 2
                sys = strjoin(parts(1:end-2), '/');
                src = strjoin(parts(end-1:end), '/');
                dstParts = split(char(dst), '/');
                dst = strjoin(dstParts(end-1:end), '/');
            end
        end
    elseif nargin >= 3
        sys = varargin{1};
        src = varargin{2};
        dst = varargin{3};
    else
        error('Not enough input arguments.');
    end

    if isnumeric(src) && isnumeric(dst)
        lineHandle = add_line(sys, src, dst, 'autorouting', 'on');
    else
        lineHandle = add_line(sys, char(src), char(dst), 'autorouting', 'on');
    end
end

