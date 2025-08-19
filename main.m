clc;
close all;


% Parameters
bit_count = 4 * 1000; % Must be multiple of 4
Eb_No_dB = -6:1:10;   % Eb/No range in dB
SNR_dB = Eb_No_dB + 10 * log10(4); % Convert Eb/No to SNR for 4 bits/symbol
BER = zeros(size(SNR_dB));

for idx = 1:length(SNR_dB)
    snr_db = SNR_dB(idx);
    T_Errors = 0;
    T_bits = 0;

    while T_Errors < 100
        % Generate random bits
        uncoded_bits = randi([0 1], 1, bit_count);
        % Reshape into 4 rows, columns = number of symbols
        B = reshape(uncoded_bits, 4, []);
        B1 = B(1, :);
        B2 = B(2, :);
        B3 = B(3, :);
        B4 = B(4, :);

        % 16-QAM modulator
        a = sqrt(1/10);
        tx = a * (-2 * (B3 - 0.5) .* (3 - 2 * B4) - 1j * 2 * (B1 - 0.5) .* (3 - 2 * B2));

        % Noise variance
        N0 = 1 / (10^(snr_db / 10));
        % AWGN noise
        noise = sqrt(N0/2) * (randn(size(tx)) + 1j * randn(size(tx)));
        % Received symbols
        rx = tx + noise;

        % 16-QAM demodulator
        a_demod = 1 / sqrt(10);
        B5 = (imag(rx) < 0);
        B6 = (imag(rx) < 2 * a_demod) & (imag(rx) > -2 * a_demod);
        B7 = (real(rx) < 0);
        B8 = (real(rx) < 2 * a_demod) & (real(rx) > -2 * a_demod);

        % Merge bits into 4xN matrix and flatten in column-major order
        temp = [B5; B6; B7; B8];
        B_hat = temp(:);
        B_orig_flat = B(:);

        % Count bit errors
        errors = sum(abs(B_orig_flat - B_hat));
        T_Errors = T_Errors + errors;
        T_bits = T_bits + length(uncoded_bits);
    end

    BER(idx) = T_Errors / T_bits;
    fprintf('SNR = %.1f dB, Bit Error Rate = %.6e\n', snr_db, BER(idx));

    % Plot constellation
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
theory_ber = (1/4) * (3/2) * erfc(sqrt(4 * 0.1 * (10.^(Eb_No_dB / 10))));
hold on;
semilogy(SNR_dB, theory_ber, 'DisplayName', 'Theoretical');
legend show;
