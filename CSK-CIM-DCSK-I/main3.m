clear; clc; close all;

m_c = 1;                      
m_s = 2;                     
beta_arr = [100, 200, 300, 400]; 
L_arr = [1, 2];                                
Block_Num = 500000;           
SNR_dB = 0:1:24;              

num_L = length(L_arr);
num_beta = length(beta_arr);
num_snr = length(SNR_dB);
total_BER = zeros(num_L, num_beta, num_snr);

for l_idx = 1:num_L
    L = L_arr(l_idx);
    if L == 1
        C=0;
    else
        C=2;
    end
    for b_idx = 1:num_beta
        beta = beta_arr(b_idx);
        P = 2^(m_c + 1);
        theta = beta / P; 
        bits = m_c + m_s + 1;
        for snr_idx = 1:num_snr
            dB = SNR_dB(snr_idx);
            disp(dB);
            SNR = 10^(dB/10);
            [Bits, Symbols0] = Transmitter(m_c, m_s, theta, Block_Num, C);
            Symbols1 = Channel(Symbols0, L, m_c, m_s, SNR);
            Bitsre = Receiver(m_c, m_s, theta, Block_Num, Symbols1, C);
            err_num = sum(Bits ~= Bitsre);
            total_BER(l_idx, b_idx, snr_idx) = err_num / (bits * Block_Num);
            if total_BER(l_idx, b_idx, snr_idx) == 0
                fprintf('    Eb/N0 = %2d dB | 误码率为0,跳过后续点\n', dB);
                break;
            end
        end
    end
end

figure('Color', [0.94 0.94 0.94]);
box on; hold on; 
colors = {'b', 'm', 'r', 'k'};       
markers = {'o', 's', 'd', '^'};      
for l_idx = 1:num_L
    L = L_arr(l_idx);
    for b_idx = 1:num_beta
        beta = beta_arr(b_idx);  
        style = [colors{b_idx}, '-', markers{b_idx}]; 
        display_name = sprintf('\\beta=%d, Sim', beta);
        if L == 1
            visibility = 'on';
        else
            visibility = 'off';
        end
        plot(SNR_dB, squeeze(total_BER(l_idx, b_idx, :)), style, ...
            'LineWidth', 1.5, ...
            'MarkerSize', 7, ...
            'MarkerFaceColor', 'none', ... 
            'DisplayName', display_name, ...
            'HandleVisibility', visibility); 
    end
end

set(gca, 'YScale', 'log');
ylim([1e-5 1]); 
xlim([0 max(SNR_dB)]);
set(gca, 'XTick', 0:2:24);
xlabel('E_b/N_0 (dB)', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('BER', 'FontSize', 12, 'FontWeight', 'bold');
title(sprintf('AWGN与Rayleigh信道下 \\beta 对性能的影响 (m_c=%d, m_s=%d)', m_c, m_s), 'FontSize', 12);
legend('Location', 'SouthWest', 'FontSize', 10);
grid on;
set(gca, 'GridLineStyle', '--');