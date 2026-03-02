clear; clc; close all;

beta = 256;         
theta = beta / 2; 
m_c_arr = [1, 2, 3, 3, 3];
m_s_arr = [3, 3, 3, 5, 7];

C = 2;              
Block_Num = 500000; 
L_arr = [1, 2];                   
total = zeros(2,4,25);

for l = 1:length(L_arr)
    L = L_arr(l);
    for m = 1:length(m_c_arr)
        m_c = m_c_arr(m);
        m_s = m_s_arr(m);
        P = 2^m_c; 
        for dB = 0:1:24 
            disp(dB);
            SNR = 10^(dB/10); 
            [Bits, Symbols0] = Transmitter(m_c, m_s, theta, Block_Num, C);
            Symbols1 = Channel(Symbols0, L, m_c, m_s, SNR);
            Bitsre = Receiver(m_c, m_s, theta, Block_Num, Symbols1, C);
            total(l, m, dB+1) = sum(Bits ~= Bitsre) / ((m_c + m_s + 1) * Block_Num);
            if total(l, m, dB+1) == 0
                fprintf('  >>> 误码率为 0,提前跳过当前参数的后续高信噪比点\n');
                break;
            end
        end
    end
end


figure();
box on; hold on; 
colors = {'b', 'm', 'r', 'k', 'g'};     
markers = {'o', 's', 'd', '^', '*'}; 

for l = 1:length(L_arr)
    L = L_arr(l);
    for m = 1:length(m_c_arr)
        m_c = m_c_arr(m);
        m_s = m_s_arr(m);
        
        style = [colors{m}, '-', markers{m}]; 
        display_name = sprintf('m_c = %d, m_s = %d, Sim', m_c, m_s);
        if L == 1
            plot(0:1:24, squeeze(total(l, m, :)), style, ...
                'LineWidth', 1.5, ...
                'MarkerSize', 7, ...
                'MarkerFaceColor', 'none', ... 
                'DisplayName', display_name);
        else
            plot(0:1:24, squeeze(total(l, m, :)), style, ...
                'LineWidth', 1.5, ...
                'MarkerSize', 7, ...
                'MarkerFaceColor', 'none', ... 
                'HandleVisibility', 'off');
        end
    end
end

set(gca, 'YScale', 'log');
ylim([1e-5 1]);
xlim([0 24]);
set(gca, 'XTick', 0:2:24); 
xlabel('E_b/N_0 (dB)', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
legend('Location', 'SouthWest', 'FontSize', 10);
grid on;