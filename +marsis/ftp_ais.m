function ftp_ais(folder,filename, host)
arguments
    folder (1,1) string
    filename (1,1) string
    host (1,1) string = "pds-geosciences.wustl.edu"
end

%% is download needed
fnlbl = filename + ".lbl";
pathlbl = fullfile(folder, fnlbl);


fndat = filename + ".dat";
pathdat = fullfile(folder, fndat);

if isfile(pathlbl) && isfile(pathdat)
  return
end

%% download

f = ftp(host);

try

binary(f)
[~,~,~,mD] = regexp(folder,'RDR\d\d\dX');
mD = lower(mD{1});
mDn = str2double(mD(4:6));

if mDn >= 769 && mDn <= 957 % updated 3 MAR 2012
    remDir = ['mex/mex-m-marsis-3-rdr-ais-ext3-v1/mexmdi_1004/data/active_ionospheric_sounder/' mD];
elseif mDn >= 480 && mDn <= 766
    remDir = ['mex/mex-m-marsis-3-rdr-ais-ext2-v1/mexmdi_1003/data/active_ionospheric_sounder/' mD];
elseif mDn >= 254 && mDn <= 459
    remDir = ['mex/mex-m-marsis-3-rdr-ais-ext1-v1/mexmdi_1002/data/active_ionospheric_sounder/' mD];
elseif mDn <= 253
    remDir = ['mex/mex-m-marsis-3-rdr-ais-v1/mexmdi_1001/data/active_ionospheric_sounder/' mD];
else
    error(filename + " not found at WUSTL at programming time. You can check manually with a web browser to see if it''s at WUSTL.")
end

cd(f, remDir);

%% get .LBL
if ~isfile(pathlbl)
  mget(f, fnlbl, folder);
  disp(host + " => " + pathlbl)
end

%% get .DAT
if ~isfile(pathdat)
  mget(f, fndat, folder)
  disp(host + " => " + pathdat)
end

catch exception
    disp("Could not download " + host + " => " + filename)
    disp('Here are the available files in this FTP directory ')
    dir(f)
    rethrow(exception)
end

end
