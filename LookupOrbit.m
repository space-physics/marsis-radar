function [AISnum, hour] = LookupOrbit(month,day,year,hour)
% by mhirsch@bu.edu
% data in 'orbnum.mat' converted from:
% ftp://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v1.0/mexsp_1000/EXTRAS/ORBNUM/ORMM_MERGED_00731.ORB
% and
% http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum
% (esa.int is more up to date)
% then
% use OrbReader.m to produce orbnum.mat
load('orbnum.mat')

AISnum = AISorbNum(AISorbNum(:,2)==year & AISorbNum(:,3)==month & ...
                    AISorbNum(:,4)==day & AISorbNum(:,5)==hour,1);
                
if isempty(AISnum)
    warning(['There were no AIS data taken by the MARSIS radar at: '...
        num2str(year) '-' num2str(month,'%02d') '-' num2str(day,'%02d') ' T ' num2str(hour) ':xx UT'])
    temp = double(AISorbNum(AISorbNum(:,2)==year & AISorbNum(:,3)==month & ...
                    AISorbNum(:,4)==day,:)); %at least find something from the same calendar day
                ind = findnearest(hour,temp(:,5));
    AISnum = temp(ind,1);
    if isempty(AISnum)
        warning(['Could not find any AIS data for calendar day ',num2str(year),'-',num2str(month),'-',num2str(day)])
    else
        
        display(['Substituted data from hour ' num2str(temp(ind,5),'%02d')...
            ' UT in place of your request for hour ' num2str(hour,'%02d') ' UT '])
        hour = temp(ind,5);
    end
                
end

end