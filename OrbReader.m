function OrbReader()
% data in 'orbnum.mat' converted from:
% ftp://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v1.0/mexsp_1000/EXTRAS/ORBNUM/ORMM_MERGED_00731.ORB
% and
% http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum
% (esa.int is more up to date)
% then
% use OrbReader.m to produce orbnum.mat
fid=fopen('data/ORMM_MERGED_00966.ORB');
newfn = 'orbnum.mat';
xx = textscan(fid,'%u %u %s %u %u:%u:%u %*[^\n]','HeaderLines',2);
fclose(fid);
%% convert text times 
ii = [1:2,4:7];
for jj = 1:6
    zz(:,ii(jj)) = xx{ii(jj)};
end

mnth = {'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
for ii = 1:12
    jj = strcmp(xx{3},mnth{ii});
    zz(jj,3) = ii;
end

AISorbNum = zz;

AISkey = {'AIS Orbit Number','Year','Month','Day','Hour','Minute','Second'};

if exist(newfn,'file')
    oldfn = [date,'_',num2str(cputime),'_orbnum.mat'];
    movefile(newfn,oldfn)
    disp(['Saved old ',newfn,' file as ',oldfn])
end
%% save
disp(['saving ',newfn])
save(newfn,'AISorbNum','AISkey')

end


