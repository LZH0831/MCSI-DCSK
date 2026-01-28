function Bitsre=Receiver(M,N,Block_Num,C,Symbols1)
    theta=N*(2^M);
    Bitsre=zeros(1,N*(M+1)*Block_Num);
    for b=1:Block_Num
        cur_block=Symbols1(:,b);
        ref=cur_block(C+1:C+theta);
        start=(theta+C)+C+1;
        final=start+theta-1;
        info=cur_block(start:final);

        I_m=zeros(1,theta);
        for m=1:theta
            ref2=circshift(ref,m);
            I_m(m)=real(sum(conj(ref2).*info));
        end

        cur_bits=zeros(1,N*(M+1));
        for n=1:N
            idx_start=(n-1)*(2^M)+1;
            idx_end=n*(2^M);
            I_m1=I_m(idx_start:idx_end);
            [~,max_pos]=max(abs(I_m1));
            local_idx=max_pos-1;
            bin_str=dec2bin(local_idx,M);
            map_bits=zeros(1,M);
            for k=1:M
                map_bits(k)=str2double(bin_str(k));
            end
            peak_val=I_m1(max_pos);
            if peak_val>=0
                mod_bit=1;
            else
                mod_bit=0;
            end
            bits=[map_bits,mod_bit];
            bitidx_start=(n-1)*(M+1)+1;
            bitidx_end=n*(M+1);
            cur_bits(bitidx_start:bitidx_end)=bits;
        end
        blockidx_start=(b-1)*N*(M+1)+1;
        blockidx_end=b*N*(M+1);
        Bitsre(blockidx_start:blockidx_end)=cur_bits;
    end
end
