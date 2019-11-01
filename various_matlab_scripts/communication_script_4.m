%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BCH Turbo Code(15,11) Simulation & Code Generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace and variables that are stored
clear, clc;

% Set the parameters for the Turbo BCH(15,11)
n = 15;
k = 11;
L = 22;

% Set up BCH encoder and decoder
enc = comm.BCHEncoder(n,k,'x4+x+1');
%dec = comm.BCHDecoder(n,k,'x3+x+1');

for dec_num = 0:(2^L - 1)
    
    % Convert the decimal number to the 22-bit word in matrix form
    x = dec2bin(dec_num,L+2);
    for i = 1:L
        X(i) = str2num(x(i));
    end

    % Break up input into 2 11-bit words
    codepart_1 = X(1:11);
    codepart_2 = X(12:22);
    
    % Pad with extra zero at end for interleving
    codepart_1_int = [codepart_1 0];
    codepart_2_int = [codepart_2 0];
    
    % Create ro-column interleaved input
    X_intr_1 = matintrlv(codepart_1_int,3,4);
    X_intr_2 = matintrlv(codepart_2_int,3,4);
    
    % Strip off the extra 0
    X_intr_1 = X_intr_1(1:end-1);
    X_intr_2 = X_intr_2(1:end-1);
    
    % Encode with BCH1 first 11 and second 11 
    codeword_cp_1 = step(enc,codepart_1'); % First 11
    codeword_cp_2 = step(enc,codepart_2'); % Second 11
    
    % Encode with BCH2 using first interleaved and second interleaved 
    codeword_int_cp_1 = step(enc,X_intr_1');
    codeword_int_cp_2 = step(enc,X_intr_2');
    
    par_cp_1 = [];
    par_cp_2 = [];
    
    % Put together actual codewords
    for i = (k+1):length(codeword_cp_1)
        par_cp_1 = [par_cp_1;codeword_cp_1(i);codeword_int_cp_1(i)];
        par_cp_2 = [par_cp_2;codeword_cp_2(i);codeword_int_cp_2(i)];
    end
    
    % Piece codewords together
    codeword_1 = [codeword_cp_1(1:k);par_cp_1];
    codeword_2 = [codeword_cp_2(1:k);par_cp_2];
    
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

dmin = dmincalc2(codeword_mat);
fprintf('Min distance: %d\n', dmin);