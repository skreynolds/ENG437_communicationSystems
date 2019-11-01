%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear the workspace, and any stored variables
clc; clear; clf;

M = 16; % Size of signal constellation
k = log2(M); % Number of bits per symbol
n = 3e4; % Number of bits to process = 30,000
Fd = 1; Fs = 1;

% Input message sampling frequency, ouput message sampling frequency
nsamp = 1; % Oversampling rate

% Create 16-QAM modulation
hmod = comm.RectangularQAMModulator(M);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create binary data stream
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% A string of random bits representing the binary data stream
x = randint(n,1);

% The first 50 bits in a stem format
stem(x(1:50),'filled');
title('Random Bits');
xlabel('Bit Index');
ylabel('Binary Value');

% Conversion of the datastream to 4-bit symbols
hBitToInt = comm.BitToInteger(k);
xsym = step(hBitToInt,x);

% Stem plot of symbols - plot the first 10 symbols in a stem plot
figure; % Create a new figure window
stem(xsym(1:10));
title('Random Symbols');
xlabel('Symbol Index');
ylabel('Integer Value');

% Modulate xsym under 16-QAM
y = modulate(modem.qammod(M),xsym);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Channel modelling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Modelling of transmission channel as AWGN
EbNo = 10; % In db
snr = EbNo + 10*log10(k) - 10*log10(nsamp);
ynoisy = awgn(y,snr,'measured');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create a scatter plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = scatterplot(ynoisy(1:nsamp*5e3),nsamp,0,'g.');
hold on
scatterplot(y(1:5e3),1,0,'k*',h);
title('Received Signal');
legend('Received Signal','Signal Constellation');
axis([-5 5 -5 5]); % Set axis range

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

[number_of_errors,bit_error_rate] = biterr(x,z)


