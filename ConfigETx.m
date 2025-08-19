classdef ConfigETx
    methods
        function configure_tx(~, params)
            % Set default or user-defined parameters for Tx
            bit_count = 4 * 1000;
            Eb_No_dB = -6:1:10;
            SNR_dB = Eb_No_dB + 10 * log10(4);

            params.set_param('BitCount', bit_count);
            params.set_param('SNR', SNR_dB);
        end
    end
end
