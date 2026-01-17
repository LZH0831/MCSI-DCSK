function tx_signal = transmitter(bits, N, M, theta, chaos_seq)
    bits_per_subblock = M + 1;
    bits_per_symbol = N * bits_per_subblock;
    
    num_bits = length(bits);
    num_symbols = num_bits / bits_per_symbol;
    bits_reshaped = reshape(bits, bits_per_symbol, num_symbols).';
    tx_signal = zeros(num_symbols, 2 * theta);
    
    for i = 1:num_symbols
        current_bits = bits_reshaped(i, :);
        info_bearing_signal = zeros(1, theta);
        for n = 1:N
            group_bits = current_bits( (n-1)*bits_per_subblock + 1 : n*bits_per_subblock );
            map_bits = group_bits(1:M);
            local_idx = 0;
            for b = 1:M
                local_idx = local_idx + map_bits(b) * 2^(M-b); 
            end
            % --- 计算全局移位量 ---
            % 关键修改：必须 +1，使移位范围变为 [1, theta]
            % 这样接收机检查 k=1 时，才能对应上 local_idx=0
            block_size = theta / N;
            global_shift = (n-1) * block_size + local_idx + 1; 
            
            mod_bit = group_bits(end);
            q_n = 2 * mod_bit - 1; 
            
            shifted_seq = circshift(chaos_seq, global_shift);
            info_bearing_signal = info_bearing_signal + q_n * shifted_seq;
        end
        tx_signal(i, :) = [chaos_seq, info_bearing_signal];
    end

end