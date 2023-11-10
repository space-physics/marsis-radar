function plan = buildfile
plan = buildplan(localfunctions);
plan.DefaultTasks = "test";
plan("test").Dependencies = ["check", "compile"];
end

function checkTask(~)
% Identify code issues (recursively all Matlab .m files)
issues = codeIssues;
assert(isempty(issues.Issues), formattedDisplayText(issues.Issues))
end

function compileTask(context)
rootFolder = context.Plan.RootFolder;
bindir = fullfile(rootFolder, "build");
if ~isfolder(bindir)
  mkdir(bindir);
end

exe = fullfile(bindir, "read_ais");
if ispc
  exe = exe + ".exe";
end

system("cc " + fullfile(rootFolder, "read_ais.c") + " -o " + exe);

mustBeFile(exe)

end

function testTask(context)

rootFolder = context.Plan.RootFolder;
datadir = fullfile(rootFolder, "data");
if ~isfolder(datadir)
  mkdir(datadir);
end

orbfile = OrbDownload(datadir, "https://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v2.0/mexsp_2000/EXTRAS/ORBNUM/ORMM_MERGED_01825.ORB");

OrbReader(orbfile)

NoGui(datetime(2008,9,9,1,0,0), 'out.avi')

end
