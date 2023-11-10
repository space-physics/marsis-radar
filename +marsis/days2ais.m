function aisDay = days2ais(day)
% converts day into aisDay notation, to be used to load data from that folder
arguments
  day {mustBeInteger}
end

x = [185, 226, 348];
y = [1886, 2032, 2466];

a = (y(1) - y(2)) / (x(1) - x(2));
b = y(1) - a*x(1);
aisDay = a*day + b;

end
