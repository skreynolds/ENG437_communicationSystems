% Clear the worspace and variables
clear; clc;

% Set important parameters
snr_vec = [0 1 2 3 4 5 6 6.5 7 7.5 8 8.5 9 9.25 9.5]; % Signal to noise ratio (in dB)
n = 7;
k = 4;
str_len = 100; % Length of the message.
no_blk = str_len/k; % Number of blocks with length k.
no_try_vec = [100 1000 1000 1000 2000 2000 2000 5000 10000 ...
                20000 30000 40000 50000 100000 100000];

% Defining the generator matrix
g = [1 1 0 1]; % Generator definition g(x) = x^3+x^2+1

for itr = 1:15
    
    snr = snr_vec(itr);
    no_try = no_try_vec(itr);
    fprintf('SNR: %d  Tries: %d',snr,no_try)
    
for ii = 1:no_try
    % Generate binary bitstreams with length k.
    bit_str = randi([0 1],no_blk,k);

    % A 7-bit cyclic code is generated for each of the 25 4-bit words
    for i = 1:no_blk
        msg(1,:) = bit_str(i,:);
        c(i,:) = encode(msg,n,k,'cyclic',g);
    end

    % The 25 7-bit cyclic codewords are placed into a single string
    % and BPSK modulation is applied to them
    for i = 1:no_blk
        for j = 1:n
            mux_code((i-1)*n + j) = 2*c(i,j) - 1;
        end
    end

    % The modulated signal is ready for transmission. AWGN is put
    % on the bitstream to simulate the effects of transmission
    ucode = real(awgn(mux_code,snr,'measured'));

    % Demux and a two level Quantization is undertaken on the
    % noisy 'recieved' signal
    for i = 1:no_blk
        for j = 1:n
            demux_code(i,j) = ucode((i-1)*n + j) > 0;
        end
    end

    % Decoding of 25 binary 7-bit received words after Quantization
    for i = 1:no_blk
        decoded(i,:) = decode(demux_code(i,:),n,k,'cyclic',g);
    end

    % Reordering of the decoded bitstreams
    for i = 1:no_blk
        for j = 1:k
            decoded1(i,k-(j-1)) = decoded(i,j);
        end
    end
    
    % We record the number of errors for each for each step in the
    % number of tries loop
    [n1,ber1] = biterr(decoded,bit_str);
    no_error(ii) = n1;
    BER(ii) = ber1;
end

% Calculate the average BER for the given parameters no_try and str_len
sum = 0;
for ii = 1:no_try
    sum = sum + no_error(ii);
end
overall_error = sum;
BER_overall = overall_error/(str_len*no_try)

clear bit_str msg c mux_code ucode demux_code no_error BER
clear decoded decoded1

end