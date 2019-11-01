%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear the workspace, and any stored variables
clc; clear; clf;


M = 16; % Size of signal constellation
k = log2(M); % Number of bits per sample
nsamp = 1; % Oversampling rate
gx = [1 0 0 0 1 0 0 1]; % Number of bits per symbol
k_cyc = 120;
n_cyc = 127;
Nsamp = 4;

EbNo_vec = [0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4.0 4.5 5.0 5.5 6.0 6.5 7.5 8.0 ...
                8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 13.5 14.0];

no_try = 1000;


for itr1 = 1:length(EbNo_vec)

sum_error = 0;

EbNo = EbNo_vec(itr1); % In db

coderate = k_cyc/n_cyc;
snr = EbNo + 10*log10(k*coderate) - 10*log10(nsamp);

no_blk_cyc = 1;

hMod = modem.qammod(M);
hDemod = modem.qamdemod(hMod);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Encoding the binary data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for lop = 1:no_try
    % Signal source
    % Create blocks of binary data stram with length k_cyc=120
    
    % Random binary data stream
    xx = randint(no_blk_cyc,k_cyc);
    
    % Cyclic (127,120 encoding)
    code = encode(xx,n_cyc,k_cyc,'cyclic',gx);
    
    % Streams with length 128
    code(:,n_cyc+1) = 1;
    
    hBitToInt = comm.BitToInteger(k);
    xsym = step(hBitToInt,code');
    
    % Transmitted signal
    y = modulate(modem.qammod(M),xsym);
    
    ynoisy = awgn(y,snr,'measured');
    
    zsym = demodulate(modem.qamdemod(M),ynoisy);
    
    % Conversion of symbols to bits is done by the following commands
    hIntToBit = comm.IntegerToBit(k);
    zz = step(hIntToBit,zsym);
    
    % To create bitstreams we transform the code
    z2 = zz'; % Transposing
    z1(:,1:n_cyc) = z2(:,1:n_cyc); % Remove one bit that was added
    
    decoded = decode(z1,n_cyc,k_cyc,'cyclic',gx);
    
    [n1,ber1] = biterr(decoded,xx);
    no_error(lop) = n1;
    BER(lop) = ber1;
end

sum=0;
for ii=1:no_try
    sum = sum + no_error(ii);
end

overall_error = sum;
BER_overall(itr1) = overall_error/(no_blk_cyc*no_try);
SNR(itr1) = snr;
end