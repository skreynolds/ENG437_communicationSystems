%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Turbo BCH(7,4) code simulation and codeword generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace and any stored variables
clear, clc;

n = 7;
k = 4;

% Set up BCH encoder and decoder
enc = comm.BCHEncoder(n,k,'x3+x+1');
%dec = comm.BCHDecoder(n,k,'x3+x+1');

for dec_num = 0:(2^k - 1)
    
    % Convert the decimal number to the 4-bit word in matrix form
    x = dec2bin(dec_num,k);
    for i = 1:length(x)
        X(i) = str2num(x(i));
    end
    
    % Create interleaved input
    X_intr = matintrlv(X,2,2);
    
    % Encode first stream with BCH
    codeword_1 = step(enc,X');
    
    % Encode second (interleaved) stream with BCH
    codeword_2 = step(enc,X_intr');
    
    % Specify empty partiy code storage
    par = [];
    
    % Create turbo BCH partiy codeword
    for i = (k+1):length(codeword_1)
        par = [par;codeword_1(i);codeword_2(i)];
    end
    
    % Create the actual codeword
    codeword = [codeword_1(1:k);par];
    codeword_mat(:,dec_num+1) = codeword;
    % Determine the weight of the BCH code
    weight = sum(codeword);
    
    %fprintf('*************************************\n')
    fprintf(['The message: ',x]); fprintf('\n');
    codeword'
    weight
    fprintf('*************************************\n')

end

% Find the min Hamming distance
dmin = dmincalc(codeword_mat);
fprintf('Min distance: %d\n', dmin);