% Clear the workspace and any variables
clc; clear;

% Create file name
file_stem = ['C:\Users\Shane Reynolds\Google Drive\'...
                'University\Charles Darwin University\'...
                    'Communication Systems\Assignment 1\'];
file = 'Peppers.tiff';
file_name = strcat(file_stem,file);

% Read an image from the graphical file.
[data,map] = imread(file_name);
str3 = sprintf('Read an image from the graphical file...');
disp(str3);

% Return the size of read image file.
[a,b,c]=size(data);

% The overall number of 'data'
sz_data=a*b*c;
str4 = sprintf('Size of file is: %2.2d', sz_data);
disp(str4);

% The 'data' obtained from ‘imread’ is a three dimensional matrix.
% Use reshape to convert it into a two dimensional matrix based on
% only one row. we call this reshaped matrix as 'T' matrix
T = reshape(data,1,a*b*c); 

SNR_vec = [0.1 0.5 1.0 1.0 1.25 1.25 1.5 1.5 1.5 2.0 2.0 2.0 2.0 ...
       2.5 2.5 2.5 3.0 3.0 3.0 3.0 3.25 3.25 3.25 3.25 ...
       3.5 3.5 3.5 3.5 3.75 3.75 3.75 3.75 4.0 4.0 4.0 4.0];

inst_vect = [1 1 1 2 1 2 1 2 3 1 2 3 1 2 3 4 1 2 3 4 ...
                1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 ];
qty_img = [];

for j=1:length(SNR_vec)
    
    % Initialise udp sender and reciever
    hudps = dsp.UDPSender('RemoteIPPort',25000); 
    hudpr = dsp.UDPReceiver('LocalIPPort',25000);
    str1 = sprintf('Succesfully initialise udp sender and reciever...');
    disp(str1);

    % Set a value as signal to noise ratio (in dB)
    SNR = SNR_vec(j);
    inst = inst_vect(j);
    str2 = sprintf('Set signal to noise ratio to: %2.2d', SNR);
    disp(str2);

    % Make a loop for transmitting 'data' with size of
    % sz_data, one by one
    fprintf('Processing')
    for i=1:sz_data
        % this 'if' command types value of i and helps you to
        % understand execution steps of your program
        if rem(i-1,100000)==0
            fprintf('.')
        end
    
        % awgn adds noise to 'T'.
        T_dmg(i)=awgn(T(i),SNR);
    
        % 'Noisy formed 'T' (T_dmg) is converted to 8-bit unsigned integer
        dataSent = uint8(T_dmg(i));
    
        % Obtained '8-bit unsigned integer (dataSent)' is transmitted by
        % udp protocol.
        step(hudps, dataSent);
    
        % transmitted data is received by udp protocol
        dataReceived = step(hudpr)';
    
        % This and following three lines help us to save valid received
        % data in an array. We check validity of the data by isempty command.
        % If this command returns a value (recognised by 'flg') except zero,
        % it means that received data is valid.
        flg = isempty(dataReceived);
        if flg~=1 
            % Received data is saved in an array. This is the received image.
            d_rec(i) = dataReceived;
        end
    end
    
    fprintf('\n')
    % terminate udp transmitter and the udp receiver
    release(hudps);
    release(hudpr);

    % reshape received data to three dimensional array matched with the
    % structure of the image read.
    A = reshape(d_rec,a,b,c); 

    % write the received image to a graphical file. The name of this file is
    % ‘Peppers_new_SNR_0.1_1.tiff. Again, type the correct path for saving this
    % image file on you your computer.
    new_file = strcat('Peppers_new_SNR_',num2str(SNR),'_', ...
                    num2str(inst),'.tiff');
    new_file_name = strcat(file_stem,new_file);
    imwrite(A,new_file_name);

    % Compares quality of the received image with original one
    qty_img(j) = psnr(A,data);
    str6 = sprintf('Quality of recieve image compared to original: %2.2d', ...
            qty_img(j));
    disp(str6);
    disp('***************************************************************')
end