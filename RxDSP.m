classdef RxDSP
    methods
        function errors = process_signal(~, params)
            rx = params.get_param('RxSignal');
            a_demod = 1 / sqrt(10);

            % Demodulate the received signal
            B5 = (imag(rx) < 0);
            B6 = (imag(rx) < 2 * a_demod) & (imag(rx) > -2 * a_demod);
            B7 = (real(rx) < 0);
            B8 = (real(rx) < 2 * a_demod) & (real(rx) > -2 * a_demod);

            % Combine demodulated bits into a 4xN matrix
            temp = [B5; B6; B7; B8];
            B_hat = temp(:);

            % Get the original bits
            uncoded_bits = params.get_param('OriginalBits');

            % Reshape original bits into a 4xN matrix and flatten in column-major order
            B_orig = reshape(uncoded_bits, 4, []);
            B_orig_flat = B_orig(:);

            % Calculate errors
            errors = sum(abs(B_orig_flat - B_hat));
        end
    end
end
