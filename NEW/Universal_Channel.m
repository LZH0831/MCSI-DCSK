function Symbols1 = Universal_Channel(Symbols0, L, SNR, bits_per_sym)
    % Symbols0: 输入的时域发送信号矩阵 [帧长 x 数据块数]
    % L: 多径数量 (1为AWGN, 3为三径Rayleigh)
    % SNR: 线性信噪比, 由 10^(dB/10) 计算得来
    % bits_per_sym: 每个发送符号携带的信息比特数
    
    [frame_len, Block_Num] = size(Symbols0);
    Symbols1 = zeros(frame_len, Block_Num);
    pre_alpha = zeros(1, L); 
    
    for b = 1:Block_Num
        % 1. 生成各径的衰落系数
        if L == 1
            cur_alpha = 1; % AWGN信道直达径
        else
            % 多径Rayleigh衰落，各径等功率分布，期望 E[alpha^2] = 1/L
            cur_alpha = sqrt(1/(2*L)) * sqrt(randn(1, L).^2 + randn(1, L).^2);
        end
        
        cur_block = zeros(frame_len, 1);
        
        % 2. 当前数据块的多径时延叠加
        for l = 1:L
            Tau = l - 1; % 论文设定第 l 径延迟 l-1 个码片
            shifted = [zeros(Tau, 1); Symbols0(1:end-Tau, b)];
            cur_block = cur_block + cur_alpha(l) * shifted;
        end
        
        pre_block = zeros(frame_len, 1);
        
        % 3. 符号间干扰 (ISI): 将前一个数据块受时延影响的尾部叠加到当前块的头部
        if b > 1
            for l = 2:L
                Tau = l - 1;
                tail = Symbols0(end-Tau+1:end, b-1);
                pre_block(1:Tau) = pre_block(1:Tau) + pre_alpha(l) * tail;
            end
        end
        
        % 当前时刻实际接收到的无噪多径叠加信号
        Symbols1(:, b) = cur_block + pre_block;
        pre_alpha = cur_alpha; % 更新系数供下一个块产生ISI使用
    end

    % 4. 计算比特能量并添加高斯白噪声
    % 按照当前系统的实际携带比特数统一标准计算 Eb
    Eb = mean(sum(abs(Symbols0).^2)) / bits_per_sym;
    nr = randn(frame_len, Block_Num);
    
    % 噪声标准差
    Noise = sqrt(Eb / (2 * SNR)) * nr;
    
    % 最终接收信号
    Symbols1 = Symbols1 + Noise;
end