function orbfile = OrbDownload(datadir, url)
arguments
  datadir (1,1) {mustBeFolder}
  url (1,1) string
end

[~, name, ext] = fileparts(url);

orbfile = fullfile(datadir, name + ext);
disp(url + " => " + orbfile)

websave(orbfile, url);

end
