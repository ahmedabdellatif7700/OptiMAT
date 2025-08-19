classdef RxDSP
    methods
        function errors = process_signal(~, params)
            % Get received symbols and original bits
            rx = params.get_param('r_k');  % Received QPSK symbols
            original_bits = params.get_param('OriginalBits');

            % QPSK demodulation (Gray coding)
            % Decision boundaries (normalized for unit power)
            B1 = (real(rx) > 0);  % First bit (I channel)
            B2 = (imag(rx) > 0);  % Second bit (Q channel)

            % Combine demodulated bits into a 2xN matrix
            temp = [B1; B2];
            B_hat = temp(:);  % Flatten in column-major order

            % Reshape original bits into a 2xN matrix and flatten
            B_orig = reshape(original_bits, 2, []);
            B_orig_flat = B_orig(:);

            % Calculate and return number of bit errors
            errors = sum(abs(B_orig_flat - B_hat));
        end
    end
end
