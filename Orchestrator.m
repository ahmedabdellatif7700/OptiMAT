classdef Orchestrator < handle
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
            % Initialize all components
            obj.params = Parameters();
            obj.configETx = ConfigETx(obj.params);
            obj.txDSP = TxDSP();
            obj.channel = Channel();
            obj.configERx = ConfigERx(obj.params);
            obj.rxDSP = RxDSP();
        end

        function run(obj)
            % Configure QPSK parameters
            obj.configETx.configure_modulation();

            % Get SNR range from Parameters
            SNR_dB = obj.params.DefaultSNRRange;
            bit_count = obj.params.get_param('Nbits');
            BER = zeros(size(SNR_dB));

            for idx = 1:length(SNR_dB)
                % Set current SNR value (scalar)
                obj.params.set_param('current_SNR', SNR_dB(idx));
                T_Errors = 0;
                T_bits = 0;

                while T_Errors < 100
                    % Generate random bits
                    bits = randi([0 1], 1, bit_count);
                    obj.params.set_param('OriginalBits', bits);

                    % Generate QPSK signal
                    [obj.txDSP, ~] = obj.txDSP.generate_signal(obj.params, bits);

                    % Add noise through channel
                    obj.channel.add_noise(obj.params, obj.params.get_param('t_k'));

                    % Process received signal and count errors
                    errors = obj.rxDSP.process_signal(obj.params);
                    T_Errors = T_Errors + errors;
                    T_bits = T_bits + bit_count;
                end

                % Calculate BER for this SNR
                BER(idx) = T_Errors / T_bits;
                fprintf('SNR = %.1f dB, Bit Error Rate = %.6e\n', SNR_dB(idx), BER(idx));

                % Plot constellation diagram
                rx = obj.params.get_param('r_k');
                figure;
                plot(real(rx), imag(rx), 'x');
                grid on;
                xlabel('Inphase Component');
                ylabel('Quadrature Component');
                title(sprintf('QPSK Constellation at SNR = %.1f dB', SNR_dB(idx)));
                axis([-1.5 1.5 -1.5 1.5]);
            end

            % Plot BER vs SNR curve
            figure;
            semilogy(SNR_dB, BER, 'or', 'DisplayName', 'Simulated QPSK');
            grid on;
            hold on;
            title('BER vs SNR for QPSK in AWGN Channel');
            xlabel('SNR (dB)');
            ylabel('BER');

            % Theoretical BER for QPSK
            Eb_No_dB = SNR_dB - 10*log10(2);
            theory_ber = 0.5 * erfc(sqrt(10.^(Eb_No_dB/10)));

            semilogy(SNR_dB, theory_ber, 'b-', 'LineWidth', 2, 'DisplayName', 'Theoretical QPSK');
            legend('Location', 'best');
        end
    end
end
