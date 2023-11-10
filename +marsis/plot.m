function TimeAv = plot(sD, fPanel,cs)

dt = sD.datetime;
aisNumber = sD.aisNumber;

c = 299792458; % [m/s]

aisTextNum = int2str(aisNumber);
filename = ['frm_ais_rdr_', aisTextNum];
folder = fullfile(pwd, "data/RDR" + aisTextNum(1:3) + "X");
%% load data from frm_ais_rdr_'aisNumber' mat file
ig = marsis.read_ais(folder, filename);
%% locates exact time moment
secIndex = seconds(timeofday(ig.dt));
a = find( (ig.time_x > secIndex - 1 ) & (ig.time_x < secIndex + 1));

% user picked a time when AIS was not on; find nearby time
if isempty(a)
  a = findnearest(secIndex, ig.time_x);
  dt = ig.dt + seconds(ig.time_x(a(1)));
end

TimeAv.t = ig.time_x;
TimeAv.folder = folder;
TimeAv.filename = filename;
TimeAv.aisNumber = aisNumber;
TimeAv.datetime = dt;

[timeDelay,freqMHz,freqLin,imC] = marsis.chirp(cs, ig.frequency_y, a, ig.signal_z);

%% setup big panel figure

%set(hImg,'YData',timeDelay,'CData',imC)
if ~cs.origFreqScale
    %set(hD,'XLim',[freqLin(1) freqLin(end)])
    %set(hImg,'XData',freqLin)
    iXdata = freqLin;
else
    %set(hD,  'XLim', [freqMHz(1) freqMHz(end)])
    %set(hImg,'XData',freqMHz)
    iXdata = freqMHz;
end


if isempty(fPanel)
    fPanel = figure(1);
    hD = axes;
else
    hD = axes('Parent',fPanel,'Units','pixels','Position',[50 45 490 490]);
end

imagesc(iXdata,...
                c/2 * [timeDelay(1), timeDelay(end)] / 1e3 / 1e3,...
                imC,...
                'Parent',hD);
%set(hImg,'edgecolor','none')
set(hD,'clim',cs.CaxLim)

if cs.origFreqScale %don't want inaccurate labels
    set(hD,'xtick',[freqMHz(1), freqMHz(end)]);
end
%% insert right axis labels with blank axes
% this seems to be HG1 only -- consider yyaxis() new for R2016a
% hD2 = axes('Parent',fPanel,'Units','pixels','Position',get(hD,'Position'),...
%              'YAxisLocation','right','YDir','reverse',...
%             'Color','none',...
%             'xtick',[] ,'YColor','k'); %'XColor',get(fPanel,'BackGroundColor'),
%ylabel(hD2,'\Deltat, Time delay (ms)')
xlabel(hD,'f, Frequency (MHz)')
ylabel(hD,'c\Deltat/2, Apparent Range (km)')


if ~cs.linearUnits
text(-25,460,'10^','Parent',hD,'Units','pixels','Interpreter','none','HandleVisibility','off');
end
hTitle=title(hD,'');
%% update figure
%set(hD,'YLim',c/2*[timeDelay(1) timeDelay(end)]/1e3/1e3 );
%set(hD,'ytick',c/2*[timeDelay(1) timeDelay(end)]/1e3/1e3 );
%set(hD2,'YLim',[timeDelay(1) timeDelay(end)])

a1 = "frm\_ais\_rdr" + num2str(aisNumber) + "    " + string(dt) + " UT";

%title(a1,'Parent',hD);
set(hTitle, 'String', a1)

%Temp = get(hD,'Position');
try %#ok<TRYNC>
    % get rid of old colorbar while preserving axes position
    delete(findobj(fPanel,'tag','Colorbar'))
end
% colormap(jet)
 colorbar('peer',hD,'Location','NorthOutside');
% pause(0.05) %time to composite
 a2 = 'Electric field spectral density (V^2 m^{-2} Hz^{-1})';
text(90,360, a2,'Parent',hD,'Units','pixels','HandleVisibility','off')

%fix axes 2, since colorbar only pushes its peer axes down
%set(hD2,'Position',get(hD,'Position'))
%set(hD,'Position',Temp) %puts the axes back where they were, for new colorbar
end
