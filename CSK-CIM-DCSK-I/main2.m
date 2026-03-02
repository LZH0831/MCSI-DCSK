clear; clc; close all;

beta = 1024;                 
dB = 10;                      
SNR = 10^(dB/10);             
L = 1;                        
C = 0;                        
Block_Num = 100000;         
m_c_arr = [1, 2, 3, 4, 5];   
m_s_arr = 1:4;              
total_BER = zeros(5, 4);

for i = 1:length(m_c_arr)
    m_c = m_c_arr(i);
    P = 2^(m_c + 1);
    theta = beta / P;
    for j = 1:length(m_s_arr)
        m_s = m_s_arr(j);
        bits = m_c + m_s + 1;
        [Bits, Symbols0] = Transmitter(m_c, m_s, theta, Block_Num, C);
        Symbols1 = Channel(Symbols0, L, m_c, m_s, SNR);
        Bitsre = Receiver(m_c, m_s, theta, Block_Num, Symbols1, C);
        total_BER(i, j) = sum(Bits ~= Bitsre) / (bits * Block_Num);
    end
end

figure('Color',[0.94 0.94 0.94]);  
[M_S, M_C] = meshgrid(m_s_arr, m_c_arr);
h = surf(M_S, M_C, total_BER);
set(h, ...
    'FaceColor', [0.80 0.78 0.55], ...   
    'EdgeColor', 'k', ...                
    'LineWidth', 0.8, ...
    'FaceAlpha', 0.85);                  
colormap([0.80 0.78 0.55]);
shading faceted;     
set(gca, 'ZScale', 'log');
zlim([1e-4 1]);
set(gca, 'XTick', m_s_arr);
set(gca, 'YTick', m_c_arr);
set(gca, 'XDir', 'reverse');
xlabel('m_s','FontSize',12,'FontWeight','bold');
ylabel('m_c','FontSize',12,'FontWeight','bold');
zlabel('BER','FontSize',12,'FontWeight','bold');
view(-40, 28);
grid on;
set(gca, ...
    'GridLineStyle','--', ...
    'LineWidth',1.0, ...
    'FontSize',11);
box on;

