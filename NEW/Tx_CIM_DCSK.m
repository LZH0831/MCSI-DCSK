function [Bits, Symbols0] = Tx_CIM_DCSK(m, theta, Block_Num)
    P = 2^m;             % Walsh码长度
    R = theta / P;       % 每段的长度 (beta = P * R)
    bits = m + 1; 
    Bits = randi([0, 1], bits, Block_Num);
    
    a_arr = (2.^((m-1):-1:0)) * Bits(1:m, :); % Walsh码索引
    q_arr = 2 * Bits(end, :) - 1;             % 极性符号
    
    H = hadamard(P);     % 生成哈达玛矩阵 (Walsh码集)
    Symbols0 = zeros(2*theta, Block_Num);
    
    for i = 1:Block_Num
        % 1. 生成参考信号
        c = rand(1, theta) - 0.5; 
        c = (c - mean(c)) / std(c); 
        
        % 2. 取出对应的 Walsh 码，并扩展到每个码片对应 R 个样本
        w_a = H(a_arr(i) + 1, :);
        w_exp = kron(w_a, ones(1, R)); 
        
        % 3. CIM调制 (公式 2-25：乘以Walsh对应位，再乘极性)
        info = q_arr(i) * (w_exp .* c); 
        
        Symbols0(:, i) = [c, info].';
    end
end