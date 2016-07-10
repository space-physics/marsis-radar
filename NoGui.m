% load, plot, playback MARSIS data without bulky main GUI
function NoGui(dt,moviefn)
if nargin<2, moviefn=''; end
% INPUTS
% dt: datevec() of requested time--at least [year,month,day]  optional [hour,min,sec]

cs.linearUnits = true;
cs.origFreqScale = true; %false to produce Gurnett plots


if cs.linearUnits
    cs.CaxLim = [1e-20,1e-15];
else
    cs.CaxLim = [-17, -9];
end
%% does data exist at all for desired day/hour?
if length(dt)<4
    dt(4) = 0; % hour
end

[cs.UserSel.aisNumber, cs.UserSel.hour] =  LookupOrbit(dt(2),dt(3),dt(1),dt(4));
cs.UserSel.year = dt(1);
cs.UserSel.month = dt(2);
cs.UserSel.day = dt(3);
cs.UserSel.minute=0;
cs.UserSel.second=0;
%% found some data from that day, now plot
cs.TimeAv = InitialPlot(cs.UserSel,[],cs);
%% movie maker
if ~isempty(moviefn)
    flipB(cs,moviefn)
end 

end %function