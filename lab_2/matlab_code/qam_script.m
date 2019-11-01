%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear the workspace, and any stored variables
clc; clear; clf;

M = 16; % Size of signal constellation
k = log2(M); % Number of bits per symbol
n = 3e4; % Number of bits to process = 30,000
Fd = 1; Fs = 1;
EbNo_vec = [0.0 0.5 1.0 1.5 2.0 2.5 3.0 3.5 4 4.5 5.0 5.5 6.0 6.5 7.0 ...
                7.5 8.0 8.5 9.0 9.5 10.0 10.5 11.0 11.5 12.0 12.5 13.0 ...
                    13.5 14.0 14.5 15.0];

% Input message sampling frequency, ouput message sampling frequency
nsamp = 1; % Oversampling rate

% Create 16-QAM modulation
hmod = comm.RectangularQAMModulator(M);

for itr1 = 1:length(EbNo_vec)
% Reset the sumation of error
SUM_error = [];    
for itr2=1:300
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create binary data stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A string of random bits representing the binary data stream
x = randint(n,1);

% The first 50 bits in a stem format
% % stem(x(1:50),'filled');
% % title('Random Bits');
% % xlabel('Bit Index');
% % ylabel('Binary Value');

% Conversion of the datastream to 4-bit symbols
hBitToInt = comm.BitToInteger(k);
xsym = step(hBitToInt,x);

% Stem plot of symbols - plot the first 10 symbols in a stem plot
% % figure; % Create a new figure window
% % stem(xsym(1:10));
% % title('Random Symbols');
% % xlabel('Symbol Index');
% % ylabel('Integer Value');

% Modulate xsym under 16-QAM
y = modulate(modem.qammod(M),xsym);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel modelling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modelling of transmission channel as AWGN
EbNo = EbNo_vec(itr1); % In db
snr = EbNo + 10*log10(k) - 10*log10(nsamp);
ynoisy = awgn(y,snr,'measured');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a scatter plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % h = scatterplot(ynoisy(1:nsamp*5e3),nsamp,0,'g.');
% % hold on
% % scatterplot(y(1:5e3),1,0,'k*',h);
% % title('Received Signal');
% % legend('Received Signal','Signal Constellation');
% % axis([-5 5 -5 5]); % Set axis range

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Demodulation of 16-QAM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The output of this demodulation process is a vector
% containing integers between 0 and 15
zsym = demodulate(modem.qamdemod(M),ynoisy);

% Convert integers to bits
z = de2bi(zsym,'left-msb');

% Convert z from matrix to vector
hIntToBit = comm.IntegerToBit(k);
z = step(hIntToBit,zsym);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computation of BER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[number_of_errors,~] = biterr(x,z);
SUM_error(itr2) = number_of_errors;
end
SNR(itr1) = snr;
AVE_BER(itr1) = sum(SUM_error)/(n*300);
end