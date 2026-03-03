function [Bits, Symbols0] = Tx_PI_DCSK(m, theta, Block_Num)
    M = 2^m;               % 置换索引的数量
    bits = m + 1;          % 携带的总比特数 (m个索引位 + 1个极性位)
    Bits = randi([0, 1], bits, Block_Num);
    
    b_arr = (2.^((m-1):-1:0)) * Bits(1:m, :); % 映射为置换索引 (0 ~ M-1)
    q_arr = 2 * Bits(end, :) - 1;             % 极性调制 (-1 或 +1)
    
    % --- 生成论文中提到的 M 个置换操作规则 (Permutation) ---
    % 使用固定种子，确保发送端和接收端的置换规则 P_j 完全一致
    rng(42); 
    Perms = zeros(M, theta);
    for i = 1:M
        Perms(i, :) = randperm(theta); % 生成长度为 theta 的随机打乱索引
    end
    rng('shuffle'); % 恢复随机状态，以免影响后续混沌信号生成
    
    Symbols0 = zeros(2*theta, Block_Num);
    for i = 1:Block_Num
        % 1. 生成第一个时隙的混沌参考信号
        c = rand(1, theta) - 0.5;
        c = (c - mean(c)) / std(c); 
        
        % 2. 按照对应的索引 b_arr(i) 选取第 j 个置换规则 P_j
        p_idx = b_arr(i) + 1; % MATLAB 索引从 1 开始
        c_perm = c(Perms(p_idx, :)); % 对混沌信号进行位置置换(打乱)
        
        % 3. 乘以符号极性
        info = q_arr(i) * c_perm;
        
        % 4. 组成一帧 (参考时隙 + 数据时隙)
        Symbols0(:, i) = [c, info].';
    end
end