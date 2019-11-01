% This code is for the server side of our UDP transsion

% Clear the workspace and any variables
clear; clc; close all;
hudps = dsp.UDPSender('LocalIPPortSource','Auto', 'RemoteIPAddress',...
                        '127.0.0.1','RemoteIPPort',25000);
%hudps = dsp.UDPSender;


% Store the transmission string in an appropriate variable
transmission_string = ['This is the first project of ENG 473 ' ...
                         'relevant to UDP transmission ' ...
                            'of some characters...!'];

% Convert the string to uint8
data = uint8(transmission_string);

for i=1:size(data,2)
    step(hudps,data(i))%send the elements 1 by 1
end

release(hudps)
