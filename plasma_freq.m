eps0 = 8.854187817e-12; % F/m
me = 9.10938356e-31;  %kg
q = 1.60217662e-19; % coulombs

fpe = .109e6; % Hz
omegape = 2*pi*fpe;

ne = omegape^2 * eps0 * me / q^2

const = 1/(2*pi)^2 * eps0*me/q^2
