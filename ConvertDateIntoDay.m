function dayIndex = ConvertDateIntoDay(month, day, year)
% starting 1/1/2005
if IsLeapYear(year)
    m = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
else
    m = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
end
dayIndex = sum(m(1:(month-1)));
dayIndex = dayIndex + day + 365*(year - 2005);

end
