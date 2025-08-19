classdef Channel < handle
    properties
        r_k;  % Received symbols
    end

    methods
        function obj = Channel()
            % Constructor
        end

        function rx_symbols = add_noise(obj, params, tx_symbols)
            % Add AWGN noise to transmitted symbols
            snr_linear = 10^(params.get_param('current_SNR') / 10);
            power = mean(abs(tx_symbols).^2);

            % Handle edge cases
            if isempty(tx_symbols) || power == 0
                noise_std = 0;
            else
                noise_std = sqrt(power / (2 * snr_linear));
            end

            % Generate complex noise
            noise = noise_std * (randn(size(tx_symbols)) + 1j * randn(size(tx_symbols)));

            % Add noise to symbols
            rx_symbols = tx_symbols + noise;

            % Store in object property and parameters
            obj.r_k = rx_symbols;
            params.set_param('r_k', rx_symbols);
        end
    end
end
