% check_output_vectors.m
fprintf('pos_out start: %s\n', mat2str(simOut.pos_out(1,:), 4));
fprintf('pos_out end:   %s\n', mat2str(simOut.pos_out(end,:), 4));
fprintf('rot_out start: %s\n', mat2str(simOut.rot_out(1,:), 4));
fprintf('rot_out end:   %s\n', mat2str(simOut.rot_out(end,:), 4));
