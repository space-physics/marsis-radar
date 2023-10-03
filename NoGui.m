% load, plot, playback MARSIS data without bulky main GUI
function NoGui(dt, moviefn)
% INPUTS
% dt: requested datetime
arguments
  dt (1,1) datetime
  moviefn string {mustBeScalarOrEmpty} = string.empty
end

cs.linearUnits = true;
cs.origFreqScale = true; %false to produce Gurnett plots

if cs.linearUnits
    cs.CaxLim = [1e-20, 1e-15];
else
    cs.CaxLim = [-17, -9];
end
%% does data exist at all for desired day/hour?
[cs.UserSel.aisNumber, dt.Hour] = LookupOrbit(dt);
cs.UserSel.datetime = dt;
%% found some data from that day, now plot
cs.TimeAv = InitialPlot(cs.UserSel,[],cs);
%% movie maker
if ~isempty(moviefn)
    flipB(cs,moviefn)
end

end %function
