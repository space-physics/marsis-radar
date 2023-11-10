function days2005 = daysSince2005(dt)
arguments
  dt datetime
end

epoch = datetime(2005,1,1);

days2005 = floor(days(dt - epoch)) + 1;

end
