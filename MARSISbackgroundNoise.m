% MARSIS background data simulator plot
% from Gurnett et al Figure 2 of "non-detectio nof impulsive radio signals
% from lightning in Martian dust storms using the radar receiver on the
% Mars Express spacecraft" Geophys. Res. Lett. 2010 Vol 37

NO = [3e-2,  5e-2, 8e-2, 1.5e-1,1.8e-1,2e-1,1.7e-1,1e-1,   5e-2,   1.5e-2,2e-3, 3e-5,   1e-8 ];
F =  [2e-21, 4e-21,9e-21,1.5e-20,3e-20,5e-20,8e-20,1.5e-19,2.9e-19,5e-19, 9e-19,1.5e-18,2.8e-18];

ps = stairs(F,NO);
set(gca,'yscale','log','xscale','log')

set(ps,'linewidth',2)

ylabel('Normalized Occurrence')
xlabel('Spectral Power Flux [Wm^{-2}Hz^{-1}]')
title({'MARSIS Cosmic Background Flux, 186,000 samples at 10,300 to 10,400 km',...
    'Data from Gurnett (2010) doi:10.1029/2010GL044368'})