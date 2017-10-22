function bool = IsLeapYear(year)
if mod(year,4) == 0
   if (mod(year,25) == 0)
       bool = 0;
   else
       bool = 1;
   end
   
else
   bool = 0;
end