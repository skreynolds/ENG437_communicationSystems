% Clear the workspace and any stored variables
clear; clc; close all;
hudpr = dsp.UDPReceiver('RemoteIPAddress','0.0.0.0','LocalIPPort',...
            25000,'MessageDataType','uint8');
%hudpr = dsp.UDPReceiver;

string=[];
count=1;
eof=0;

while(~eof)
    %disp('in loop')
    dataReceived = step(hudpr);
    if strcmp(char(dataReceived),'!')
        eof=1; % ! signified the end
    else
        string = [string char(dataReceived)]; %fill the string
        count=count+1;
    end
end

disp(string) %display the string
release(hudpr)
