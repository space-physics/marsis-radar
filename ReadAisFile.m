% to create ionograms from raw data
function [year, day, time_x, frequency_y, band, receiverAtt, powerLevel, signal_z] = ReadAisFile(folder, filename,hGo,hPtxt)
%% check if DATA folder exists, if not, you need to download the PDS data
if ~exist(folder,'dir')
    AISftp(folder,filename,hPtxt,hGo)
end
%% First look to see if PDS data has already been converted to MATLAB format
%old code: 
%{
d= dir(folder);

if strfind(filename,'.txt') 
   filename = filename(1:(end-4));
end
%}
[~,filename] = fileparts(filename); %strip extension

if exist([folder filename '.mat'],'file')
    disp(['Using existing .MAT file: ',folder, filename, '.mat'])
    load([folder filename '.mat'])
    return
end

%% if MATLAB formatted data not found, see if ASCII data exists
% if ASCII data doesn't exist, look for binary .dat file
if exist([folder filename '.txt'],'file')
    disp(['Converting existing ASCII file: ',folder, filename, '.txt'])
else

    if ~exist([folder filename '.dat'],'file')
        set(hGo,'String','FTP Downloading...')
        UpdateProgDisp(hPtxt,['Downloading ',filename,', this may take a few minutes...']), pause(0.1)
        tic
        AISftp(folder,filename,hPtxt,hGo)
        FTPtime = toc/60;
        UpdateProgDisp(hPtxt,['Download completed in ',num2str(FTPtime,'%3.1f'),' minutes.']), pause(0.1)
    end

    %set(hGo,'String','Converting DAT to TXT')

if ispc
    cmdTxt = 'read_ais ';
else
    cmdTxt = './read_ais ';
end

ReadAISstatus = system([cmdTxt folder filename '.dat > ' folder filename '.txt']) %#ok<NOPRT>
if ReadAISstatus
    UpdateProgDisp(hPtxt,['Error: Could not automatically convert binary ' folder filename '.dat to ASCII'])
    error(['Could not automatically convert binary ' folder filename '.dat to ASCII'])
end
end    

%set(hGo,'String','Converting TXT to MAT')
fid = fopen([folder filename '.txt']);
i = 1; iWait = 1;
isDateSet = 0;
tic
time_x = zeros(1,100000);
frequency_y = zeros(1,100000);
band = zeros(1,100000);
receiverAtt = zeros(1,100000);
powerLevel = zeros(1,100000);
signal_z = zeros(80,100000);
%% estimate size for waitbar
  
    %old code in brackets
    %{ 
bool = 1;
i = 0;
while bool
    i = i + 1;
    d(i).name
    if strfind(d(i).name,'.txt')%searches for text files
        bool = 0;
    end
end
    %}
d = dir([folder filename '.txt']);  %find filesize
num = round(d(1).bytes/881); %old code: num = round(d(i).bytes/881);
h = waitbar(0,'Please wait...');
%%
try
while ~feof(fid)
    iWait = iWait + 1;
    if iWait > 2000, waitbar(i/num,h); iWait = 0; end
    a = fgetl(fid);
    if size(a,2) < 1, continue, end
    switch a(1:11)
        case 'Frame Begin'     %if (strfind(a,'Frame Begin Time')~=0)
        time_x(i) = ConvertToTime(a);
        if (~isDateSet)
            [year, day] = SetDate(a);
            isDateSet = 1;
        end
                            % end
        case 'Transmit Fr'     %if (strfind(a,'Transmit Frequency')~=0)
        frequency_y(i) = ConvertToFrequency(a);        
                            %end
        case 'Band Number'     %if (strfind(a,'Band Number')~=0)
        band(i) = ConvertToBand(a);        
                            %end
        case 'Receiver At'     %if (strfind(a,'Receiver Attenuation')~=0)
        receiverAtt(i) = ConvertReceiverAtt(a);
                            %   end
        case 'Transmit Po' %if (strfind(a,'Transmit Power Level')~=0)
        powerLevel(i) = ConvertToPowerLevel(a);
        a = fgetl(fid);
        if size(a,2) < 1
            a = fgetl(fid);
        end   
        signal_z(:,i) = ConvertToSignal(a);
        i = i + 1;
    end                    %end
end
catch exception
    warning(['Error reading ' filename ' at file pointer: ' ftell(fid) ])
    throw(exception)
end
time_x = time_x(1:(i-1));
frequency_y = frequency_y(1:(i-1));
band = band(1:(i-1));
receiverAtt = receiverAtt(1:(i-1));
powerLevel = powerLevel(1:(i-1));
signal_z = signal_z( :, 1:(i-1) );

toc
fclose(fid);
close(h);
%set(hGo,'String','Saving MAT to HDD')
save([folder filename],'year', 'day', 'time_x', 'frequency_y', 'band', 'receiverAtt', 'powerLevel', 'signal_z');
end

function [year, day] = SetDate(a)
year = str2double(a(21:24));
temp = a(26:29);
day = str2double(temp(1:strfind(temp,'T')-1));
end

function time_x = ConvertToTime(a)
temp = a(size(a,2) - 11:size(a,2));
hour = str2double(temp(1:2));
min = str2double(temp(4:5));
sec = str2double(temp(7:end));
time_x = hour*3600 + min*60 + sec;
end

function freq = ConvertToFrequency(a)
freq = str2double(a(strfind(a,'=')+1:strfind(a,'KHz')-1)); %str2double(a(22:28)); 
end

function band = ConvertToBand(a)
band = str2double(a(strfind(a,'=')+1:size(a,2)));
end

function receiverAtt = ConvertReceiverAtt(a)
receiverAtt = str2double(a(strfind(a,'=')+1:size(a,2)));
end

function powerLevel = ConvertToPowerLevel(a)
powerLevel = str2double(a(strfind(a,'=')+1:size(a,2)));
end

function signal_z = ConvertToSignal(a)
signal_z = textscan(a,'%f');
signal_z = signal_z{1};
%signal_z(end+1:80) = 0; %correcting for short records
end

% function signal_z = ConvertToSignal(a)
% gaps = strfind(a,' ');
% signal_z = zeros(1,80);
% signal_z(1) = str2double(a(1:gaps(1)));
% for i = 2:size(gaps,2)
%     signal_z(i) = str2double( a(gaps(i-1):gaps(i)) );
% end
% end