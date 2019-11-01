%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% BCH (7,4) Code Simulation and Code Generation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Clear the workspace and any variables
clear, clc;

% Set teh BCH code parameters
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

    % Encode with BCH
    codeword = step(enc,X');
    codeword_mat(:,dec_num+1) = codeword;
    % Determine the weight of the BCH code
    weight = sum(codeword);
    
    %fprintf('*************************************\n')
    fprintf(['The message: ',x]); fprintf('\n');
    codeword'
    weight
    fprintf('*************************************\n')

end

dmin = dmincalc(codeword_mat);
fprintf('Min distance: %d\n', dmin);