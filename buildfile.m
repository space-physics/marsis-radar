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

exe = fullfile(rootFolder, "+marsis/read_ais");
if ispc
  exe = exe + ".exe";
end

system("cc " + fullfile(rootFolder, "src/read_ais.c") + " -o " + exe);

mustBeFile(exe)

end

function testTask(context)

rootFolder = context.Plan.RootFolder;
datadir = fullfile(rootFolder, "data");
if ~isfolder(datadir)
  mkdir(datadir);
end

orbfile = marsis.download_orbit(datadir, "https://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v2.0/mexsp_2000/EXTRAS/ORBNUM/ORMM_MERGED_01825.ORB");

marsis.read_orbit(orbfile)

cs = marsis.show(datetime(2008,9,9,1,0,0));

mustBeMember(class(cs), "struct")

end
