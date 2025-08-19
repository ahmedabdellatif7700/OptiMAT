classdef Orchestrator
    properties
        params
        configETx
        txDSP
        channel
        configERx
        rxDSP
    end
    methods
        function obj = Orchestrator()
            obj.params = Parameters();
            obj.configETx = ConfigETx();
            obj.txDSP = TxDSP();
            obj.channel = Channel();
            obj.configERx = ConfigERx();
            obj.rxDSP = RxDSP();
        end
        function run(obj)
            % Configure Tx
            obj.configETx.configure_tx(obj.params);
            SNR_dB = obj.params.get_param('SNR');
            bit_count = obj.params.get_param('BitCount');
            BER = zeros(size(SNR_dB));

            for idx = 1:length(SNR_dB)
                snr_db = SNR_dB(idx);
                T_Errors = 0;
                T_bits = 0;
                while T_Errors < 100
                    % Generate Tx signal
                    obj.txDSP.generate_signal(obj.params);
                    % Add noise for the current SNR
                    obj.channel.add_noise(obj.params, snr_db);
                    % Process Rx signal and calculate errors
                    errors = obj.rxDSP.process_signal(obj.params);
                    T_Errors = T_Errors + errors;
                    T_bits = T_bits + bit_count;
                end
                BER(idx) = T_Errors / T_bits;
                fprintf('SNR = %.1f dB, Bit Error Rate = %.6e\n', snr_db, BER(idx));
                % Plot constellation
                rx = obj.params.get_param('RxSignal');
                figure;
                plot(real(rx), imag(rx), 'x');
                grid on;
                xlabel('Inphase Component');
                ylabel('Quadrature Component');
                title(sprintf('Constellation of Transmitted Symbols at SNR = %.1f dB', snr_db));
            end
            % Plot BER vs SNR curve (log scale)
            figure;
            semilogy(SNR_dB, BER, 'or', 'DisplayName', 'Simulated');
            grid on;
            title('BER Vs SNR Curve for 16-QAM Modulation Scheme in AWGN');
            xlabel('SNR (dB)');
            ylabel('BER');
            % Theoretical BER (approximate)
            Eb_No_dB = SNR_dB - 10 * log10(4);
            theory_ber = (1/4) * (3/2) * erfc(sqrt(4 * 0.1 * (10.^(Eb_No_dB / 10))));
            hold on;
            semilogy(SNR_dB, theory_ber, 'DisplayName', 'Theoretical');
            legend show;
        end
    end
end
