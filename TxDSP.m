classdef TxDSP
    methods
        function generate_signal(~, params)
            bit_count = params.get_param('BitCount');
            uncoded_bits = randi([0 1], 1, bit_count);
            B = reshape(uncoded_bits, 4, []);
            B1 = B(1, :);
            B2 = B(2, :);
            B3 = B(3, :);
            B4 = B(4, :);
            a = sqrt(1/10);
            tx = a * (-2 * (B3 - 0.5) .* (3 - 2 * B4) - 1j * 2 * (B1 - 0.5) .* (3 - 2 * B2));
            params.set_param('TxSignal', tx);
            params.set_param('OriginalBits', uncoded_bits);
        end
    end
end
