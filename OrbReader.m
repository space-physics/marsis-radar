function OrbReader(orbfile)
% data in 'orbnum.mat' converted from:
% ftp://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-*
% or
% ftp://ssols01.esac.esa.int/pub/data/SPICE/MEX
% use OrbReader.m to produce orbnum.mat
arguments
  orbfile (1,1) {mustBeFile}
end

fid = fopen(orbfile, "r");
datadir = fileparts(orbfile);
newfn = fullfile(datadir, "orbnum.mat");

xx = textscan(fid,'%u %u %s %u %u:%u:%u %*[^\n]','HeaderLines',2);
fclose(fid);
%% convert text times
ii = [1:2,4:7];
for jj = 1:6
    zz(:,ii(jj)) = xx{ii(jj)};
end

mnth = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
for ii = 1:12
    jj = strcmp(xx{3}, mnth{ii});
    zz(jj,3) = ii;
end

AISorbNum = zz;

AISkey = {'AIS Orbit Number','Year','Month','Day','Hour','Minute','Second'};

%% save
disp("save " + newfn)
save(newfn, 'AISorbNum', 'AISkey')

end
