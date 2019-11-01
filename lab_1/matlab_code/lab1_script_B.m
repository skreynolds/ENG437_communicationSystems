% Initialising - Clearing variables and workspace
clear; clc;

% Initialising - Setting initial variables
n1 = 7;
k1 = 4;
n2 = 7;
k2 = 4;
no_try_vec = [100 1000 1000 10000 10000 10000 10000 10000 10000 20000 50000 50000 100000 100000];
snr_vec = [0 1 2 3 4 4.5 5 5.5 6 6.5 7.0 7.5 8.0 8.5];
gx1 = [1 1 0 1];
gx2 = [1 1 0 1];
str_len = 112;
no_blk = str_len/(k1*k2);


for itr = 1:14
    
    no_try = no_try_vec(itr);
    snr = snr_vec(itr);
    fprintf('SNR: %d  Tries: %d',snr,no_try)
    
    bit_str = randi([0 1],no_try,no_blk*k1*k2);
    
for jj = 1:no_try
    uu(1,:) = bit_str(jj,:);
    u_u = reshape(uu,k1*k2,no_blk);
    u = u_u';
    
    % Encoding Process (Start)
    for i = 1:no_blk
        M(1,:) = u(i,:);
        A = reshape(M,k1,k2);
        MM = A';
        for ii = 1:k2
            msg(1,:) = MM(ii,:);
            c(1,:) = encode(msg,n1,k1,'cyclic',gx2);
            code(ii,:) = c(1,:);
        end
        
        in_encoder2 = code';
        
        for ii = 1:n1
            msg2(1,:) = in_encoder2(ii,:);
            c2(1,:) = encode(msg2,n2,k2,'cyclic',gx2);
            code2(ii,:) = c2(1,:);
        end
        % Encoding Process (End)
        
        % Modulation & Passing through AWGN channel (Start)
        for ii = 1:n1
            ucode(ii,:) = real(awgn(2*code2(ii,:)-1,snr,'measured'))>0;
        end
        % Modulation & Passing through AWGN channel (End)
        
        % Decoding (Start)
        for ii = 1:n1
            decoded(ii,:) = decode(ucode(ii,:),n2,k2,'cyclic',gx2);
        end
        
        % Transposing to dcode each column of the codeword
        deint_codeword = decoded';
        
        for ii = 1:k2
            decoded2(ii,:) = decode(deint_codeword(ii,:),n1,k1,'cyclic',gx1);
        end
        
        % Returning the codeword to its original shape (Start)
        A = decoded2';
        B = reshape(A,1,k1*k2);
        decoded3(i,:) = B(1,:);
    end
    % Returning the codeword to its original shape (End)
    % Decoding (End)
    
    % Making decoded bitstreams with size of no_try x str_len (Start)
    A = decoded3';
    B = reshape(A,1,no_blk*k1*k2);
    decoded4(1,:) = B;
    
    bit_str2(1,:) = bit_str(jj,:);
    [n_err,ber1] = biterr(decoded4(1,:),bit_str2(1,:));
    no_error(jj) = n_err;
    BER(jj) = ber1;
end
% Making decoded bitstreams with size of no_try x str_len (End)

% Calculate Bit Error Rate (BER)
sum = 0;
for jj = 1:no_try
    sum = sum + no_error(jj);
end
overall_error = sum;
BER_overall = overall_error/(str_len*no_try)

clear uu ucode u_u u no_error msg msg2 MM M in_encoder2
clear deint_codeword decoded4 decoded3 decoded2 decoded
clear code2 code c2 c bit_str2 bit_str A B

end
