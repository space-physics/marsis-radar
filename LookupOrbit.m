function [AISnum, hour] = LookupOrbit(month,day,year,hour)
% by Michael Hirsch
% data in 'orbnum.mat' converted from:
% ftp://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v1.0/mexsp_1000/EXTRAS/ORBNUM/ORMM_MERGED_00731.ORB
% and
% http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum
% (esa.int is more up to date)
% then
% use OrbReader.m to produce orbnum.mat
AISorbNum = load('orbnum.mat','AISorbNum'); AISorbNum=AISorbNum.AISorbNum;

AISnum = AISorbNum(AISorbNum(:,2)==year & AISorbNum(:,3)==month & ...
                    AISorbNum(:,4)==day & AISorbNum(:,5)==hour,1);

if isempty(AISnum)
  disp(['There were no AIS data taken by the MARSIS radar at: '...
            datestr(datenum(year,month,day,hour,0,0)), ' UT'])

  %at least find something from the same calendar day
  temp = double(AISorbNum(AISorbNum(:,2)==year & AISorbNum(:,3)==month & AISorbNum(:,4)==day,:));
  ind = findnearest(hour,temp(:,5));

  AISnum = temp(ind,1);

  if isempty(AISnum)
    warning(['Could not find any AIS data for calendar day ',datestr(datenum(year,month,day))])
  else
    disp(['Substituted data from hour ' num2str(temp(ind,5),'%02d')...
        ' UT in place of your request for hour ' num2str(hour,'%02d') ' UT '])
    hour = temp(ind,5);
  end

end %if

end %function
