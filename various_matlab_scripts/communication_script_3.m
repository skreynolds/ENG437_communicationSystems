%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BCH(15,11) Simulation and Codeword Generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace and any stored variables
clear; clc;
% Set the the BCH(15,11) parameters
n = 15;
k = 11;
L = 22;

% Set up BCH encoder and decoder
enc = comm.BCHEncoder(n,k,'x4+x+1');
%dec = comm.BCHDecoder(n,k,'x3+x+1'); 


for dec_num = 0:(2^L - 1)
    % Convert the decimal number to the 22-bit word in matrix form
    x = dec2bin(dec_num,L);
    for i = 1:length(x)
        X(i) = str2num(x(i));
    end
    % Encode with BCH first 11
    codeword_1 = step(enc,X(1:11)');
    % Encode with BCH second 11
    codeword_2 = step(enc,X(12:22)');
    % Actual codeword
    codeword = [codeword_1;codeword_2];
    % Store codeword in matrix
    codeword_mat(:,dec_num+1) = codeword;
    % Determine the weight of the BCH code
    weight = sum(codeword);
    
    %fprintf('*************************************\n')
    %fprintf(['The message: ',x]); fprintf('\n');
    %codeword'
    %weight
    %fprintf('*************************************\n')
    if mod(dec_num,100000) == 0
        fprintf('*')
    end
end

% Find the minimum Hamming Distance
dmin = dmincalc2(codeword_mat);
fprintf('Min distance: %d\n', dmin);