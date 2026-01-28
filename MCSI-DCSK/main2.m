clear; clc; close all;

N = 2;                     
C = 2;                    
M_arr=[5,6,7];
beta_arr=[128,256,512];
tau2_arr = [1,5:5:60];
Block_Num = 100000;  
total = zeros(3, length(tau2_arr));
dB = 22;               
SNR = 10^(dB/10);

for m=1:length(M_arr)
    M=M_arr(m);
    for t=1:length(tau2_arr)
        tau2=tau2_arr(t);
        disp(tau2);
        tau_vec = [0, tau2];
        [Bits, Symbols0] = Transmitter(M, N, Block_Num, C);
        Symbols1 = Channel2(Symbols0, tau_vec, N, M, SNR);
        Bitsre = Receiver(M, N, Block_Num, C, Symbols1);
        total(m,t)=sum(Bits~=Bitsre)/(N*(M+1)*Block_Num);
    end
end

figure();
box on; hold on; grid on;
styles = {'ro', 'bs', 'k^'};
for i = 1:3
    plot(tau2_arr, total(i, :), styles{i}, ...
        'LineWidth', 1.5, 'MarkerSize', 7, ...
        'DisplayName', ['\beta=', num2str(beta_arr(i)), ', M=', num2str(M_arr(i)), ', Simulation']);
end
set(gca, 'Yscale', 'log');
xlabel('\tau_2', 'FontSize', 12);
ylabel('BER', 'FontSize', 12);
legend('Location', 'SouthEast', 'FontSize', 10);
ylim([1e-5 1]); 