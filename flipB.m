function flipB(cs, moviefn)
c = 299792458; % [m/s]
%% initial setup of maker figure
ta = cs.TimeAv;

hf = figure(Toolbar='none', MenuBar='none', Name=ta.filename);

hA1 = axes('Parent',hf,'YDir','reverse');
%hA2 = axes('Parent',hf,'position',get(hA1,'Position'),...
%        'YAxisLocation','right','YDir','reverse',...
%         'Color','none',...
%        'XColor',get(hf,'Color'),'xtick',[] ,'YColor','k');

%increase figure height to accomodate colorbar
%Tmp = get(hf,'position');
%set(hf,'position',[Tmp(1:3) Tmp(4)+100])

%ylabel(hA2,'\Deltat, Time delay (ms)')
a2 = 'Electric field spectral density (V^2 m^{-2} Hz^{-1})';
%text(-25,468,'10^','Parent',hA1,'Units','pixels','Interpreter','none','HandleVisibility','off');
%% output setup
[path,name,ext] = fileparts(moviefn);
if isempty(path)
  path='.';
end

switch ext
    case '.avi', VidType = 'Motion JPEG AVI';
    case '.mj2', VidType = 'Archival';
    case '.mp4', VidType = "MPEG-4";
    otherwise,   VidType = [];
end

if ~isempty(VidType)
    fVideo = VideoWriter(moviefn,VidType);
    fVideo.FrameRate = 3;
    open(fVideo)
end
%%
load(fullfile(ta.folder, ta.filename + ".mat"), 'dt', 'time_x', 'frequency_y', 'signal_z')
% 'band', 'receiverAtt', 'powerLevel')

stride = 160; %by inspection/documentation

Nt = length(time_x)/stride; %number of times in file

for i = 1:Nt
    % determine current index slice
    a = ((i-1)*stride+1:i*stride);

    [timeDelay,freqMHz,freqLin,imC] = dataMangle(cs, frequency_y, a, signal_z);
%% plot outcome
    dtp = dt + seconds(time_x(a(1)));
    a1 = "frm\_ais\_rdr" + num2str(ta.aisNumber) + "    " + string(dtp) + " UT";

    hA1.YLim = c/2*[timeDelay(1), timeDelay(end)]/1e6; %puts axis to units of km
    %set(hA2,'YLim',[timeDelay(1), timeDelay(end)])

    %update movie display with latest data snapshot
    if i==1
        if ~cs.origFreqScale %linear, Gurnett scaling
            hA1.XLim = [freqLin(1), freqLin(end)];
            x = freqLin;
        else %non-linear, hardware spacing
            hA1.XLim = [freqMHz(1), freqMHz(end)];
            x = freqMHz;
            set(hA1, 'xtick',[freqMHz(1),freqMHz(end)])
        end

      hImg = imagesc(x,c/2*[timeDelay(1), timeDelay(end)]/1e6,imC,'Parent',hA1);

      xlabel(hA1,'f, Frequency (MHz)')
      ylabel(hA1,'c\Deltat/2, Apparent Range (km)')

      set(hA1,'clim', cs.CaxLim)

      hT = title(hA1,'');
      text(90,345, a2,'Parent',hA1,'Units','pixels','HandleVisibility','off')
    else
      set(hImg,'YData',c/2*[timeDelay(1), timeDelay(end)]/1e6, 'CData', imC)
    end

    assert(isscalar(a1))
    set(hT,'String', a1)

    if i==1
      colorbar('peer',hA1,'Location','NorthOutside')
    end

    pause(.001) %compositor delay
    if ~isempty(VidType) %it's literally a video
        writeVideo(fVideo, getframe(hf));
    else %write multi-frame image
        switch ext
            case '.tif'
                currFrame = getframe(hf);
                imwrite(currFrame.cdata, moviefn, 'writemode','append')
            case '.png'
                fImgName = fullfile(path, name + '_M' + num2str(time_x(a(1))) + ".png");
                exportgraphics(hf, fImgName)
            case '.mat'
                ImgS(:,:,iL) = imC;
        end
    end
end %for


if ext == ".mat"
    save(moviefn,'ImgS','cs','freqMHz')
end

if exist('fVideo', 'var')
  close(fVideo)
end

end %function
