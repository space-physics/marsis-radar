function TimeAv = InitialPlot(sD,fPanel,hGo,hPtxt,flipbook,compType,linearUnits,cStruct)
year=sD.year; month = sD.month; day1 = sD.day; hour=sD.hour; minute=sD.minute; sec=sD.second;
aisNumber = sD.aisNumber; 

c = 299792458; % [m/s]

%[aisNumber hour] = LookupOrbit(month,day1,year,hour); moved to UserGUI 27
%OCT 2011
filename = ['frm_ais_rdr_', num2str(aisNumber)]; 
aisTextNum = num2str(aisNumber);
%%check computer type (Windoze, Linux, Mac)
switch compType(1:4)
 case 'PCWI', folder = [pwd '\selectedmarsisdata\DATA\RDR' aisTextNum(1:3) 'X\'];
 case 'GLNX', folder = [pwd '/selectedmarsisdata/DATA/RDR' aisTextNum(1:3) 'X/'];
   otherwise, error(['Your computer type: ' compType ' is not known to this program. Contact mhirsch@bu.edu for help.'])
end


%% load data from frm_ais_rdr_'aisNumber' mat file

[year, day, time_x, frequency_y, band, receiverAtt, powerLevel, signal_z] = ...
    ReadAisFile(folder, filename,hGo,sD.download,hPtxt,compType);

%set(hGo,'String','Searching in Time')
% locates exact time moment
secIndex = ConvertTimeToSecIndex(hour, minute, sec);
a = find( (time_x > secIndex - 1 ) & (time_x < secIndex + 1));

%trap case where user picked a time when AIS was not on, and find nearby
%time
if isempty(a)
    warning(['Could not find AIS data at ' num2str([hour minute sec]) 'UT.'])
    a = findnearest(secIndex,time_x);
    [hour, minute, sec] = ConvertSecIndexToTime(time_x(a(1)));
    display(['Using ' num2str(hour,'%02.0f') ':' num2str(minute,'%02.0f'),':' num2str(sec,'%06.3f') 'UT instead.'])
    UpdateProgDisp(hPtxt,['Substituted data from: ' num2str(year),num2str(month,'%02.0f'),num2str(day,'%02.0f'),'T',num2str(hour,'%02.0f') ':' num2str(minute,'%02.0f'),':' num2str(sec,'%06.3f') 'UT.'])
end

TimeAv.t = time_x;
TimeAv.folder = folder;
TimeAv.filename = filename;
TimeAv.aisNumber = aisNumber;
TimeAv.hour = hour;
TimeAv.minute = minute;
TimeAv.sec = sec;

%{
timeDelay = linspace(0.25,7.5,80); %ms
freq = frequency_y(a)/1e3; % MHz
freqLin = linspace(freq(1),freq(end),1e3);
% att = ones(80,1)*receiverAtt(a);
%im = log10(signal_z(:,a).*(10.^att));

im = signal_z(:,a);
imC = zeros(size(im));
for i = 1:length(freqLin)
    % take i-th row, its frequency is freqLin(i)
    t = find(freq>=freqLin(i));
    imC(:,i) = im(:,t(1));
end

if ~linearUnits, imC = log10(imC); end
%}

[timeDelay,freqMHz,freqLin,imC] = dataMangle(cStruct,frequency_y,a,signal_z);

%% setup big panel figure

%set(hImg,'YData',timeDelay,'CData',imC)
if ~cStruct.origFreqScale
    %set(hD,'XLim',[freqLin(1) freqLin(end)])
    %set(hImg,'XData',freqLin)
    iXdata = freqLin;
else
    %set(hD,  'XLim', [freqMHz(1) freqMHz(end)])    
    %set(hImg,'XData',freqMHz)
    iXdata = freqMHz;
end



hD = axes('Parent',fPanel,'Units','pixels','Pos',[50 45 490 490]);
hImg = imagesc(iXdata,timeDelay,imC,'Parent',hD,...
    cStruct.CaxLim);%'xlimmode','manual','ylimmode','manual','zlimmode','manual');

if cStruct.origFreqScale, set(hD,'xtick',[freqMHz(1),freqMHz(end)]); end %don't want inaccurate labels

hD2 = axes('Parent',fPanel,'Units','pixels','Pos',get(hD,'Position'),...
             'YAxisLocation','right','YDir','reverse',...
            'Color','none',...
            'XColor',get(fPanel,'BackGroundColor'),'xtick',[] ,'YColor','k');
ylabel('\Deltat, Time delay (ms)','Parent',hD);
xlabel('f, Frequency (MHz)','Parent',hD);
ylabel('c\Deltat/2, Apparent Range (km)','Parent',hD2);

a2 = 'Electric field spectral density (V^2 m^{-2} Hz^{-1})';
text(128,590, a2,'Parent',hD,'Units','pixels','HandleVisibility','off')
if ~cStruct.linearUnits
text(-25,560,'10^','Parent',hD,'Units','pixels','Interpreter','none','HandleVisibility','off');
end
hTitle=title(hD,'');


%% update figure
set(hD2,'YLim',c/2*[timeDelay(1) timeDelay(end)]/1e3/1e3 );
set(hD,'YLim',[timeDelay(1) timeDelay(end)])

a1 = (['frm\_ais\_rdr' num2str(aisNumber) '    ' num2str(month,'%02.0f') '/' num2str(day1,'%02.0f') '/' num2str(year,'%4.0f') '   ' ...
    num2str(hour,'%02.0f') ':' num2str(minute,'%02.0f') ':' num2str(sec,'%02.0f') ' UT']);

%title(a1,'Parent',hD);
set(hTitle,'String',a1)

Temp = get(hD,'Pos');
try %to get rid of old colorbar while preserving axes position
    delete(findobj(fPanel,'tag','Colorbar'))
     
end
colormap(jet)
 colorbar('peer',hD,'Location','NorthOutside');

%fix axes 2, since colorbar only pushes its peer axes down
%set(hD2,'Position',get(hD,'Position'))
set(hD,'Pos',Temp) %puts the axes back where they were, for new colorbar
set(hGo,'String','Complete !','BackgroundColor','green')

end