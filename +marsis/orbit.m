function [AISnum, ahour] = orbit(dt, orbfile)
arguments
  dt (1,1) datetime
  orbfile (1,1) string = fullfile("data", "orbnum.mat")
end
% by Michael Hirsch
% data in 'orbnum.mat' converted from:
% ftp://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v1.0/mexsp_1000/EXTRAS/ORBNUM/ORMM_MERGED_00731.ORB
% and
% http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum
% (esa.int is more up to date)
% then
% use marsis.read_orbit() produces orbnum.mat

assert(isfile(orbfile), "see README.md for how to create orbnum.mat")

ahour = hour(dt);

AISorbNum = load(orbfile, 'AISorbNum');
AISorbNum = AISorbNum.AISorbNum;

AISnum = AISorbNum(AISorbNum(:,2)==year(dt) & AISorbNum(:,3)==month(dt) & ...
                    AISorbNum(:,4)==day(dt) & AISorbNum(:,5)==hour(dt), 1);

if isempty(AISnum)
  disp("There were no AIS data taken by the MARSIS radar at: " + string(dt))

  %at least find something from the same calendar day
  temp = double(AISorbNum(AISorbNum(:,2)==year(dt) & AISorbNum(:,3)==month(dt) ...
                  & AISorbNum(:,4)==day(dt),:));
  ind = findnearest(hour(dt),temp(:,5));

  AISnum = temp(ind,1);

  if isempty(AISnum)
    warning("Could not find any AIS data for calendar day " + string(dt))
  else
    disp(['Substituted data from hour ' num2str(temp(ind,5),'%02d')...
        ' UT in place of your request for hour ' num2str(hour(dt),'%02d') ' UT '])
    ahour = temp(ind,5);
  end

end %if

end %function
