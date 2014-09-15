% USERGUI is the main M-file the user directly runs to
% examine the MARSIS AIS data.
%
% Status: experimental 'alpha' code, not guaranteed to give desired results
% 
% Requirements: MATLAB R2010b or never to create movies
%
% August 2011
% mhirsch@bu.edu 
% Original code base for InitialPlot.m and its subroutines provided by jls@bu.edu

function UserGUI()
clc, clear, close all

cStruct.linearUnits = true;
cStruct.origFreqScale = true; %false to produce Gurnett plots

if cStruct.linearUnits
    cStruct.CaxLim = [1e-20,1e-15];
else
    cStruct.CaxLim = [-17 -9];
end

AISorbNum = load('orbnum.mat'); AISorbNum = AISorbNum.AISorbNum;
oldAis = [];
firstRun = true;
c = 299792458; % [m/s]
MovCmap = load('MovCmap.mat'); MovCmap=MovCmap.MovCmap;

host = 'pds-geosciences.wustl.edu/mex/';

FrameSp = {'1' '2' '5' '10' '15' '20' '25' '30' '35' '40' '45' '50' '60'};
pF = [50,220,1024,680];
fPanel = figure('Position',pF,'Toolbar','none',...
                'MenuBar','none','Name','AIS Data Viewer','NumberTitle','off');
            
pP = [15,12,400,663];
pD = [pP(1)+pP(3)+10, 10, pF(3)-pP(3)-25, pF(4)-10];

%user input panel
pUinput = uipanel('Parent',fPanel,'Title','Select AIS Data',....
                    'BackgroundColor','white','Units','pixels',...
                    'Position',pP,'FontSize',13);
%Data panel                
pData = uipanel('Parent',fPanel,'Title','AIS Measurement Data Plot',....
                    'BackgroundColor','white','Units','pixels',...
                    'Position',pD,'FontSize',13);
%% data axes
%{
hD = axes('Parent',pData,'Units','pixels','Pos',[50 45 490 490]);
hImg = uimagesc(NaN,NaN,NaN,'Parent',hD,...
    cStruct.CaxLim);%'xlimmode','manual','ylimmode','manual','zlimmode','manual');
hD2 = axes('Parent',pData,'Units','pixels','Pos',get(hD,'Position'),...
             'YAxisLocation','right','YDir','reverse',...
            'Color','none',...
            'XColor',get(pData,'BackGroundColor'),'xtick',[] ,'YColor','k');
ylabel('\Deltat, Time delay (ms)','Parent',hD);
xlabel('f, Frequency (MHz)','Parent',hD);
ylabel('c\Deltat/2, Apparent Range (km)','Parent',hD2);

a2 = 'Electric field spectral density (V^2 m^{-2} Hz^{-1})';
text(128,590, a2,'Parent',hD,'Units','pixels','HandleVisibility','off')
if ~cStruct.linearUnits
text(-25,560,'10^','Parent',hD,'Units','pixels','Interpreter','none','HandleVisibility','off');
end
hTitle=title(hD,'');
%}
[SelData L uRad hFBsel hPtxt cStruct] = GUIlistMaker(FrameSp,cStruct); %sets up initial GUI

hGo = uicontrol(pUinput,'Style','pushbutton',...
                        'Pos',[30,pP(4)-320,120,30],...
                        'String','Go !',...
                        'BackgroundColor','green',...
                        'Interruptible','on',...
                        'Callback',@getAISdata);
                    
hGoMovie = uicontrol(pUinput,'Style','pushbutton','Pos', [10,pP(4)-635,100,30],'String','MAKE Movie',...
                        'Interruptible','on','fontsize',9,...
                        'Callback',@flipB);
compType = computer;

hPlayMovie = uicontrol(pUinput,'Style','pushbutton','Pos', [10+100+10,pP(4)-635,85,30],'String','PLAY Movie',...
                        'Interruptible','on','fontsize',9,...
                        'Callback',@PlayAISmovie);
                    
 %=====================
 % temp override till update GUI
 cStruct.VidQuality = 85; %motion jpeg
 cStruct.CompressionRatio = 10; %motion jpeg 2000
 cStruct.TifCompMode = 'lzw'; %tiff

 %======================

 
guidata(fPanel,cStruct)
%% Static Display

function getAISdata(hObject,eventdata)
        
        %set(hGo,'BackGroundColor',[0.9 0.9 0.9],'String','Running...')
        set(hGoMovie,'BackgroundColor',[0.9 0.9 0.9])
        %if exist('hPlayMovie','var')
        set(hPlayMovie,'BackgroundColor',[0.9 0.9 0.9])
        %end
if ~firstRun
        oldAis = cStruct.UserSel.aisNumber;
end
        cStruct.UserSel = UserDataCleanser(SelData,L.years(6:end),uRad);

[cStruct.UserSel.aisNumber cStruct.UserSel.hour] =...
    LookupOrbit(cStruct.UserSel.month,cStruct.UserSel.day,cStruct.UserSel.year,cStruct.UserSel.hour);
if oldAis ~= cStruct.UserSel.aisNumber, firstRun = true; end
cStruct.TimeAv = InitialPlot(cStruct.UserSel,pData,...
        hGo,hPtxt,false,compType,cStruct.linearUnits,cStruct); %main program Code

% add movie start/stop times to GUI
if firstRun
hFBsel.Start   = uicontrol(pUinput,'Style','popup','Pos', [55,pP(4)-562,75,15],'String','Start Time','Value',cStruct.Def.Start);
hFBsel.End     = uicontrol(pUinput,'Style','popup','Pos', [55,pP(4)-587,75,15],'String','End Time','Value',1);%cStruct.Def.End);
firstRun = false;
end
hFBsel = UpdateMovieMenu(cStruct.TimeAv,hFBsel);
set(hGoMovie,'BackgroundColor','Green','String','MAKE Movie')

        %guidata(fPanel,CommonStruct)
        
end
%==========================================================================
function [AISnum] = LookupOrbitEmb(hObject,eventdata)
       US = UserDataCleanser(SelData,L.years(6:end),uRad);
        
        AISnum = AISorbNum(AISorbNum(:,2)==US.year & AISorbNum(:,3)==US.month & ...
                    AISorbNum(:,4)==US.day & AISorbNum(:,5)==US.hour,1);
                
if isempty(AISnum)
%     warning(['There were no AIS data taken by the MARSIS radar at: '...
%         num2str(year) '-' num2str(month) '-' num2str(day) ' T ' num2str(hour) ':xx UT'])
    temp = double(AISorbNum(AISorbNum(:,2)==US.year & AISorbNum(:,3)==US.month & ...
        AISorbNum(:,4)==US.day,:)); %at least find something from the same calendar day            
        %AISorbNum(:,4)==US.day:US.day+1,:)); %at least find something from the same calendar day
    ind = findnearest(US.hour,temp(:,5));
    AISnum = temp(ind,1);
    if isempty(AISnum)
        warning(['Could not find any AIS data for calendar day ',...
            int2str(year),'-',int2str(month),'-',int2str(day)])
    AISnum=[];
    end            
end
set(SelData.orb,'String',int2str(AISnum))
end
%% Dynamic Display

function flipB(hObject,eventdata)
%% initial setup of maker figure    
    if exist('hPlayMovie','var')
    set(hPlayMovie,'BackgroundColor',[0.9 0.9 0.9])
    end
    try close(cStruct.fTempM), end
    try close(cStruct.fMovPlay), end
    
    TimeAv = cStruct.TimeAv;
    
    fTempM = figure('Position',[pF(1)+10, pF(2) 560 480],...
                'Toolbar','none',...
                'MenuBar','figure','Name',['Making: ' TimeAv.filename],'NumberTitle','off');
            cStruct.fTempM = fTempM;
    fTempA1 = axes('Parent',fTempM); 
    fTempImg = imagesc(NaN,'Parent',fTempA1,...
        cStruct.CaxLim);
    fTempA2 = axes('Parent',fTempM,'Pos',get(fTempA1,'Position'),...
             'YAxisLocation','right','YDir','reverse',...
             'Color','none',...
            'XColor',get(fTempM,'Color'),'xtick',[] ,'YColor','k');
     
        %increase figure height to accomodate colorbar
        Tmp = get(fTempM,'pos');
        set(fTempM,'pos',[Tmp(1:3) Tmp(4)+100])
    

ylabel('\Deltat, Time delay (ms)','Parent',fTempA1);
xlabel('f, Frequency (MHz)','Parent',fTempA1);
ylabel('c\Deltat/2, Apparent Range (km)','Parent',fTempA2);
a2 = 'Electric field spectral density (V^2 m^{-2} Hz^{-1})';
text(90,505, a2,'Parent',fTempA1,'Units','pixels','HandleVisibility','off')
text(-25,468,'10^','Parent',fTempA1,'Units','pixels','Interpreter','none','HandleVisibility','off');
fTempTitle=title(fTempA1,'');
    %cStruct = guidata(fPanel); 
     UserSel = cStruct.UserSel;
    
    startInd = get(hFBsel.Start,'Value'); cStruct.Def.Start = startInd;
    endInd = get(hFBsel.End,'Value'); cStruct.Def.End = endInd;
    cStruct.Def.frm = get(hFBsel.FrameSp,'Value');
    FrameRt = str2double(FrameSp(cStruct.Def.frm)); 
    hr = hFBsel.TimesHr; mn = hFBsel.TimesMn; sc = hFBsel.TimesSc;
    hr = [hr(startInd) hr(endInd)]; mn = [mn(startInd) mn(endInd)]; sc = [sc(startInd) sc(endInd)];
    
    %time_x = TimeAv.t;
    folder = TimeAv.folder;
    filename = TimeAv.filename;
    aisNumber = TimeAv.aisNumber;
    month = UserSel.month; day1 = UserSel.day; %hour = TimeAv.hour; minute = TimeAv.minute; sec = TimeAv.sec; 
    load([folder filename,'.mat'],'year', 'day', 'time_x', 'frequency_y', 'band', 'receiverAtt', 'powerLevel', 'signal_z')
    
secIndex = ConvertTimeToSecIndex(hr,mn,sc);
    aOrig = find( (time_x > secIndex(1) - 1 ) & (time_x < secIndex(1) + 1)); %starting point
    aEnd = find( (time_x > secIndex(2) - 1 ) & (time_x < secIndex(2) + 1)); %ending point
    a = 0; iL=1;
   
    % determine movie type
    cStruct.VidTypeSel = get(hFBsel.VidType,'Value');
    
    
        % test to see if filename available for writing
%         fTmpF = fopen([folder filename '.avi'],'w+');
%         if fTmpF<0
%             close(fTempM)
%             error(['Could not open ' folder filename '.avi for writing. Do you have this file open in your video player?'])
%         else
%             fclose(fTmpF);
%         end        
        %cStruct.Def.fmt = cStruct.VidTypeSel;
        switch cStruct.VidTypeSel
            case 1, VidType = 'Motion JPEG AVI';
                fVideo.Quality = cStruct.VidQuality; 
                set(fTempM,'Name',[get(fTempM,'Name'),'.avi'])
            case 2, VidType = 'Motion JPEG 2000';
                fVideo.CompressionRatio = cStruct.CompressionRatio;
                  set(fTempM,'Name',[get(fTempM,'Name'),'.mj2'])
            case 3, VidType = 'Archival';
                  set(fTempM,'Name',[get(fTempM,'Name'),'.mj2'])
            case 4, set(fTempM,'Name',[get(fTempM,'Name'),'.tif'])
            case 5, set(fTempM,'Name',[get(fTempM,'Name'),'.mat'])
            case 6, set(fTempM,'Name',[get(fTempM,'Name'),'.png'])
        end
        
   if cStruct.VidTypeSel <4 %it's literally a video
        fVideo = VideoWriter([folder filename],VidType);
        fVideo.FrameRate = FrameRt;
        
         open(fVideo)
    end

try
while all(a<=aEnd-1)
    
    a = aOrig(1)+(((iL-1)*160):(iL-1)*160+160-1);
    [hour, minute, sec] = ConvertSecIndexToTime(time_x(a(1)));
%{    
       timeDelay = linspace(0.25,7.5,80); %ms
freqMHz = frequency_y(a)/1e3; % MHz
NumLinFreqPoints = 500; %orig program was 1000
freqLin = linspace(freqMHz(1),freqMHz(end),...
            NumLinFreqPoints);
    
    im = signal_z(:,a);  %#ok<NODEF>
%% correct for non-linear chirp
% the MARSIS RF chirp is 160 points, spread between approx. 100kHz to approx. 5.5MHz
% it's desirable to put this back to a linear scale for display.

if ~cStruct.origFreqScale
imC = nan(size(im)); %tt = nan(NumLinFreqPoints,1);
   
    for i = 1:length(freqLin) %<caution> can throw away data if NumLinFreqPoints is too low
        %<update> what about using interpolation?
        % take i-th row, its frequency is freqLin(i)
        t = find(freqMHz >= freqLin(i),1,'first'); 
        imC(:,i) = im(:,t);
        
        %diagnostic
       %if 0, tt(i) = t; end

    end
else
    imC = im; %no freq scaling--uses non-linear freq. sampling (as MARSIS hardware does)
end
    if ~cStruct.linearUnits, imC = log10(imC); end
%}
    [timeDelay,freqMHz,freqLin,imC] = dataMangle(cStruct,frequency_y,a,signal_z);
    %% TEST
    
    %{
    redunLine = freqMHz(tt);
    [yTest yInd fInd] = unique(redunLine);
    
    figure
    line(1:NumLinFreqPoints,redunLine )
    %line(1:length(a),redunLine(fInd),'linestyle','none','marker','.')
    
    title({['non-linear to linear mapping--redundancies. ',int2str(NumLinFreqPoints),' points used'],...
            ['which captures: ',int2str(size(yTest,2)),'/',int2str(length(a)),' original frequency data bins']})
        xlabel('data point #'),ylabel('Frequency (MHz)')
    %}
%% plot outcome
    

    set(fTempA2,'YLim',c/2*[timeDelay(1), timeDelay(end)]/1e6 ); %puts axis to units of km

    if ~cStruct.origFreqScale
        set(fTempA1, 'XLim',[freqLin(1), freqLin(end)]) %linear, Gurnett scaling
        set(fTempImg,'XData',freqLin)
    else %non-linear, hardware spacing
        set(fTempA1, 'XLim',[freqMHz(1), freqMHz(end)]) 
        set(fTempImg,'XData',freqMHz)
        set(fTempA1, 'xtick',[freqMHz(1),freqMHz(end)])
    end
    set(fTempA1,'YLim',[timeDelay(1), timeDelay(end)])
    
    %update movie display with latest data snapshot
    
    set(fTempImg,'YData',timeDelay,...
                 'CData',imC)
        
    a1 = (['frm\_ais\_rdr' num2str(aisNumber) '    ' num2str(month,'%02.0f') '/' num2str(day1,'%02.0f') '/' num2str(year,'%4.0f') '   ' ...
    num2str(hour,'%02.0f') ':' num2str(minute,'%02.0f') ':' num2str(sec,'%06.3f') ' UT']);

    %title(a1,'Parent',hD);
    set(fTempTitle,'String',a1)

    %Temp = get(fTempA1,'Pos');
    try %to get rid of old colorbar while preserving axes position
        delete(findobj(fTempM,'tag','Colorbar'))
     
    end
    colormap(MovCmap)
    colorbar('peer',fTempA1,'Location','NorthOutside');

    
    %fix axes 2, since colorbar only pushes its peer axes down
    set(fTempA2,'Pos',get(fTempA1,'pos')) %puts the axes back where they were, for new colorbar
     
    currFrame = getframe(fTempM);
    if cStruct.VidTypeSel <4 %it's literally a video
        writeVideo(fVideo,currFrame);
        
    else %write multi-frame image
        switch cStruct.VidTypeSel
            case 4
        fImgName=[folder filename];
        % write with title/axes
        imwrite(currFrame.cdata,[fImgName '.tif'],'writemode','append',...
            'Compression',cStruct.TifCompMode)
            case 5
                ImgS(:,:,iL) = imC;
                fImgName=[folder filename];
        %write just the data alone
%         imwrite(imC,MovCmap,[fImgName '_data.tif'],'writemode','append',...
%             'Compression',cStruct.TifCompMode)
            case 6 %png
        fImgName=[folder filename '_M' num2str(time_x(a(1))) '.png'];
        print(fTempM,fImgName,'-dpng')
        end
    end
    iL = iL +1;
    
end
catch exception
    if cStruct.VidTypeSel <4, close(fVideo), end
    display(['Error while creating movie on loop ' num2str(iL)])
    throw(exception)
end

if cStruct.VidTypeSel == 5
%save Matlab HDF5 of data
save([fImgName '_data.mat'],'ImgS','cStruct','freqMHz')
end

if cStruct.VidTypeSel <4, close(fVideo),end
    Def = cStruct.Def; %#ok<NASGU>
    save('AISguiDefaults.mat','Def')
    
    text(20,25, 'Movie Generation Complete','Parent',fTempA1,...
        'Units','pixels','FontSize',24,'BackgroundColor','black','Color','white','HandleVisibility','off')
    set(hGoMovie,'String','Movie Complete !')
    set(hPlayMovie,'String','Play Now !','BackgroundColor','green')
end

%% Movie Player
function PlayAISmovie(hObject,eventdata)
    try close(cStruct.fTempM), end
    try close(cStruct.fMovPlay), end
    cStruct.VidTypeSel = get(hFBsel.VidType,'Value');
        fMovPlay = figure('Position',[pF(1)+pF(3)+10, pF(2) 560 580],...
                'Toolbar','none',...
                'MenuBar','none',...
                'Name','Video Maker','NumberTitle','off',...
                'doublebuffer','on');
            cStruct.fMovPLay = fMovPlay;
        TimeAv = cStruct.TimeAv;
        switch cStruct.VidTypeSel
            case 1, ext = '.avi'; 
            case 2, ext = '.mj2';
            case 3, ext = '.mj2';
            case 4, ext = '.tif';
            case 5, ext = '.mat';
            case 6, ext = '.png';
        end
  %%      
     if cStruct.VidTypeSel <4
        fvMov = VideoReader([TimeAv.folder TimeAv.filename ext]);
        frmRate = fvMov.FrameRate;
        nFrames = fvMov.NumberOfFrames;
        vidHeight = fvMov.Height; vidWidth = fvMov.Width;
        
        % Preallocate movie structure.
            mov(1:nFrames) = ...
             struct('cdata', zeros(vidHeight, vidWidth, 3, 'uint8'),...
                'colormap', []);
            
            % Read one frame at a time.
        for k = 1 : nFrames
         mov(k).cdata = read(fvMov, k);
        end
        
        % Play back the movie once at the video's frame rate.
            movie(fMovPlay,mov, 1, frmRate);

     elseif cStruct.VidTypeSel == 4 %images
            fnImg = [TimeAv.folder TimeAv.filename ext];
            aMovPlay = axes('parent',fMovPlay);
            ImgInfo = imfinfo(fnImg);
            hIMP = imshow(nan(ImgInfo(1).Height,ImgInfo(1).Width));
            iptsetpref('ImshowBorder', 'tight')
            set(aMovPlay,...
            'xlimmode','manual',...
            'ylimmode','manual',...
            'zlimmode','manual',...
            'climmode','manual',...
            'alimmode','manual','visible','off');
            nFrames = length(ImgInfo);
            
            for k = 1: nFrames
                Img = imread(fnImg,'Index',k,'info',ImgInfo);
                pause(0.01)
                set(hIMP,'cdata',Img)
            end
     elseif cStruct.VidTypeSel == 5 %.mat file
         fnImg = [TimeAv.folder TimeAv.filename '_data' ext];
            aMovPlay = axes('parent',fMovPlay);
            
            ImgS = load(fnImg); ImgS = ImgS.ImgS;
            
            hIMP = imagesc(nan(size(ImgS,1),size(ImgS,2)),cStruct.CaxLim);
            colormap(MovCmap)
            
            nFrames = size(ImgS,3);
         for k = 1: nFrames
            set(hIMP,'cdata',ImgS(:,:,k))
            pause(0.05)
         end
     end
            
            
 end

%% helper functions   
function [UserSel] = UserDataCleanser(SelData,years,uRad)
     %converts user selected indicies to actual values
     years = textscan(years,'%f|',100); years=years{1};
     try
         cStruct.Def.yr = get(SelData.year,'Value');
     UserSel.year = years(cStruct.Def.yr-1);
     
     cStruct.Def.mo = get(SelData.month,'Value');
     UserSel.month = cStruct.Def.mo-1; 
     if UserSel.month == 0
         UpdateProgDisp(hPtxt,'Please select desired month')
         error('Please select desired month')
     end
     
     cStruct.Def.dy = get(SelData.day,'Value');
     UserSel.day = cStruct.Def.dy -1; 
     if UserSel.day == 0, 
         UpdateProgDisp(hPtxt,'Please select desired day')
         error('Please select desired day')
     end
     catch exception, errordlg('You must at least select Year, Month, Day')
         UpdateProgDisp(hPtxt,'You must at least select Year, Month, Day')
         set(hGo,'BackgroundColor',[.9 .9 .9],'String','Go !')
         throw(exception)
     end
     
     %if user didn't select time of day, default to 00:00:00 UT
     hour = get(SelData.hour,'Value')-2; if hour<0, hour=0; end, cStruct.Def.hr = hour+2;
     minute = get(SelData.minute,'Value')-2; if minute<0, minute=0; end, cStruct.Def.mn = minute+2;
     second = get(SelData.second,'Value')-2; if second<0, second=0; end, cStruct.Def.sc = second+2;
     UserSel.hour   = hour;
     UserSel.minute = minute;
     UserSel.second = second;
     UserSel.download = get(uRad.Y,'Value'); cStruct.Def.ftp = UserSel.download;
     cStruct.Def.srv = get(SelData.server,'Value');
 
     UpdateProgDisp(hPtxt,['User Selected Data: ',num2str(UserSel.year),num2str(UserSel.month,'%02.0f'),num2str(UserSel.day,'%02.0f'),'T',num2str(hour,'%02.0f'),':',num2str(minute,'%02.0f'),':',num2str(second,'%02.0f'),' UT']);
pause(0.1)
end

function hFBsel =  UpdateMovieMenu(TimeAv,hFBsel)
    [HourAv MinAv SecAv] = ConvertSecIndexToTime(TimeAv.t);
    hr=HourAv(1); mn=MinAv(1); sc=SecAv(1);
    Avail{1} = [num2str(hr(1),'%02.0f'),':',num2str(mn(1),'%02.0f'),':',num2str(sc(1),'%02.0f')];
    ii = 1; N = length(TimeAv.t)/160; %round((TimeAv.t(end)-TimeAv.t(1))./160);
    while ii+1<=N
        ii=ii+1;
        [hr(ii) mn(ii) sc(ii)] = ConvertSecIndexToTime(TimeAv.t((ii-1)*160+1));
        Avail{ii} = [num2str(hr(ii),'%02.0f'),':',num2str(mn(ii),'%02.0f'),':',num2str(sc(ii),'%02.0f')];
     end
            
    hFBsel.TimesHr = hr; hFBsel.TimesMn = mn; hFBsel.TimesSc = sc;
    
    set(hFBsel.Start,'String',Avail)
    set(hFBsel.End,'String',Avail,'Value',length(Avail)) %BUG ?
end

%% setup GUI
function [SelData L uRad hFBsel hPtxt cStruct] = GUIlistMaker(FrameSp,cStruct)
    try load('AISguiDefaults.mat')
    catch, Def.yr = 1; Def.mo = 1; Def.dy = 1; Def.hr = 1; Def.mn = 1; Def.sc = 1;
        Def.Start = 1; Def.End = 1; Def.frm = 5; Def.fmt = 1; Def.ftp = true; Def.srv = 1;
    end
    cStruct.Def = Def;
L.years = ['Year|', '2005|2006|2007|2008|2009|2010|2011'];
L.months = ['Month|','JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC'];
for ii = 1:31
    L.days(3*ii-2:3*ii) = [num2str(ii,'%02.0f'), '|']; %make day of month list
end
L.days(5:end+4) = L.days; L.days(1:4) = 'Day|';

for ii = 1:23
    L.hours(3*ii-2:3*ii) = [num2str(ii,'%02.0f'), '|']; % make hours list
end
L.hours(9:end+8) = L.hours; L.hours(1:8) = 'Hour|00|';

for ii = 1:59
    L.minutes(3*ii-2:3*ii) = [num2str(ii,'%02.0f'), '|']; % make minutes list
end
L.minutes(11:end+10) = L.minutes; L.minutes(1:10) = 'Minute|00|';

for ii = 1:59
    L.seconds(3*ii-2:3*ii) = [num2str(ii,'%02.0f'), '|']; % make seconds list
end
L.seconds(11:end+10) = L.seconds; L.seconds(1:10) = 'Second|00|';

                
uicontrol(pUinput,'Style','text','Pos',[5,pP(4)-55,230,20],'FontSize',10,...
                'String','1. Select desired AIS data parameters.');
            
%load('orbnum.mat')
%orbList = {num2str(AISorbNum(:,1),'%04.0f'), repmat(' ',length(AISorbNum),1), num2str(AISorbNum(:,2)), num2str(AISorbNum(:,3),'%02.0f'), num2str(AISorbNum(:,4),'%02.0f')};
InitOrb = LookupOrbit(...
    Def.mo - 1,Def.dy - 1,str2double(L.years(6:9))+Def.yr - 2,Def.hr - 1);

uicontrol(pUinput,'Style','text','Pos',[260 pP(4)-57 60 18],'String','Orbit #')
SelData.orb = uicontrol(pUinput,'Style','edit','String',int2str(InitOrb),'Pos',[260 pP(4)-78 60 18]);
                    
SelData.year = uicontrol(...
    pUinput,'Style','popup','String',L.years,'Pos',[20 pP(4)-75 50 15],...
    'Value',Def.yr,'Callback',@LookupOrbitEmb);
SelData.month = uicontrol(...
    pUinput,'Style','popup','String',L.months,'Pos',[80 pP(4)-75 50 15],...
    'Value',Def.mo,'Callback',@LookupOrbitEmb);
SelData.day = uicontrol(...
    pUinput,'Style','popup','String',L.days,'Pos',[140 pP(4)-75 50 15],...
    'Value',Def.dy,'Callback',@LookupOrbitEmb);
uicontrol(pUinput,'Style','text','Pos',[200,pP(4)-82,50,20],'FontSize',10,...
                'String','required','FontAngle','italic','BackgroundColor','white');
SelData.hour = uicontrol(...
    pUinput,'Style','popup','String',L.hours,'Pos',[20 pP(4)-110 50 15],...
    'Value',Def.hr,'Callback',@LookupOrbitEmb);
SelData.minute = uicontrol(...
    pUinput,'Style','popup','String',L.minutes,'Pos',[80 pP(4)-110 50 15],...
    'Value',Def.mn,'Callback',@LookupOrbitEmb);
SelData.second = uicontrol(...
    pUinput,'Style','popup','String',L.seconds,'Pos',[140 pP(4)-110 50 15],...
    'Value',Def.sc,'Callback',@LookupOrbitEmb);
uicontrol(pUinput,'Style','text','Pos',[200,pP(4)-118,50,20],'FontSize',10,...
                'String','optional','FontAngle','italic','BackgroundColor','white');

uicontrol(pUinput,'Style','text','Pos',[5,pP(4)-150,250,15],'String','PDS FTP Server','BackgroundColor','white');
SelData.server = uicontrol(pUinput,'Style','popup','String',host,'Pos',[5,pP(4)-165,250,15],'Value',Def.srv);


uicontrol(pUinput,'Style','text','Pos',[8,pP(4)-250,290,45],...
    'String','Download data via FTP if no local copy? (takes 1-2 minutes to download)','BackgroundColor','white');
hRadG1 = uibuttongroup('Units','pixels','Pos',[5,pP(4)-255,390,55],'Parent',pUinput);
uRad.Y = uicontrol('Style','radio','String','Yes','Pos',[295,20,40,15],'Parent',hRadG1);
uRad.N = uicontrol('Style','radio','String','No','Pos',[345,20,40,15],'Parent',hRadG1);
if Def.ftp, DefFTP = uRad.N; else DefFTP = uRad.Y; end
set(hRadG1,'SelectedObject',DefFTP)
set(hRadG1,'Visible','on');

uicontrol(pUinput,'Style','text','Pos',[10,pP(4)-280,280,20],'FontSize',10,...
    'String','2. Press ''Go !'' to see AIS measurement result');

uicontrol(pUinput,'Style','text','Pos',[10,pP(4)-360,380,20],'FontSize',12,...
    'String','Program Status')

hPtxt = uicontrol(pUinput,'Style','edit','Enable','inactive','Pos',[10,pP(4)-510,380,150],'FontSize',11,...
    'String','Idle....','max',2);

uicontrol(pUinput,'Style','text','Pos',[10,pP(4)-540,380,20],'FontSize',10,...
    'String','3. Movie Generation (optional) (requires R2010b or newer)')

uicontrol(pUinput,'Style','text','Pos',[10,pP(4)-565,35,15],'FontSize',9, 'String','Start:')
uicontrol(pUinput,'Style','text','Pos',[10,pP(4)-590,35,15],'FontSize',9, 'String','End:')


uicontrol(pUinput,'Style','text','Pos',[155,pP(4)-563,80,15],'String','Frames/sec.')
hFBsel.FrameSp = uicontrol(pUinput,'Style','popup',...
    'Pos', [240 pP(4)-560 40 15],'String',FrameSp,'Value',Def.frm);

uicontrol(pUinput,'Style','text','Pos',[155,pP(4)-588,80,15],'String','Format')
hFBsel.VidType = uicontrol(pUinput,'Style','popup',...
    'Pos', [240 pP(4)-585 150 15],...
    'String',{'Motion JPEG (.avi)',...
              'Motion JPEG 2000 (.mj2)',...
              'Lossless Motion JPEG 2000 (.mj2)',...
              'TIFF (.tif)',...
              'MATLAB HDF (.mat)'},...
    'Value',5);


end

end


