function leap = IsLeapYear(year)

leap = mod(year, 4)==0 && (mod(year, 100) ~=0 || mod(year, 400) == 0);

end
