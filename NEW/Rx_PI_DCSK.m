function Bitsre = Rx_PI_DCSK(m, theta, Block_Num, Symbols1)
    M = 2^m;
    bits = m + 1;
    Bitsre_mat = zeros(bits, Block_Num);
    
    % --- 重建与发送端相同的置换规则 ---
    rng(42);
    Perms = zeros(M, theta);
    for i = 1:M
        Perms(i, :) = randperm(theta);
    end
    rng('shuffle');
    
    for i = 1:Block_Num
        % 提取接收到的参考时隙和信息时隙
        r_ref = Symbols1(1:theta, i).';
        r_inf = Symbols1(theta+1:end, i).';
        
        D_m = zeros(1, M);
        for j = 1:M
            % 对接收到的参考信号应用第 j 个置换规则 P_j
            r_ref_perm = r_ref(Perms(j, :));
            % 相关运算 (公式 2-21, 2-22)
            D_m(j) = sum(r_ref_perm .* r_inf); 
        end
        
        % 找最大绝对值，完成解映射与极性判决
        [~, max_idx] = max(abs(D_m));
        b_hat = max_idx - 1;           % 恢复出的置换索引
        q_hat = sign(D_m(max_idx));    % 恢复出的极性
        
        b_bits = bitget(b_hat, m:-1:1);
        q_bit = (q_hat + 1) / 2;
        Bitsre_mat(:, i) = [b_bits, q_bit].';
    end
    Bitsre = Bitsre_mat(:).';
end