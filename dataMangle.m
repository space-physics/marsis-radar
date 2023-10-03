function [timeDelay,freqMHz,freqLin,imC] = dataMangle(cStruct, frequency_y, a, signal_z)

timeDelay = linspace(0.25,7.5,80); %ms
freqMHz = frequency_y(a)/1e3; % MHz
NumLinFreqPoints = 500; %orig program was 1000
freqLin = linspace(freqMHz(1),freqMHz(end),...
            NumLinFreqPoints);

im = signal_z(:,a);
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

end
