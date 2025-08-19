classdef Channel
    methods
        function add_noise(~, params, snr_db)
            tx = params.get_param('TxSignal');
            N0 = 1 / (10^(snr_db / 10));
            noise = sqrt(N0/2) * (randn(size(tx)) + 1j * randn(size(tx)));
            rx = tx + noise;
            params.set_param('RxSignal', rx);
        end
    end
end
