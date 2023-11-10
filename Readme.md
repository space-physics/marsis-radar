# Marsis Radar

[![matlab](https://github.com/space-physics/marsis-radar/actions/workflows/ci.yml/badge.svg)](https://github.com/space-physics/marsis-radar/actions/workflows/ci.yml)

[![DOI](https://zenodo.org/badge/24042603.svg)](https://zenodo.org/badge/latestdoi/24042603)

Read and plot ESA MARSIS radar data.
Works with GNU Octave and Matlab.

## Quickstart

One-time program setup and self-test

```matlab
buildtool
```

Generate plots for the date you desire (optionally specify hour,minute,second):

```matlab
marsis.show(datetime(2008,9,9,1,0,0), 'out.avi')
```

where 'out.avi' is the optional movie output filename.

## Setup

I cleaned up the
[original readais.c](http://www-pw.physics.uiowa.edu/marsx/Gurnett_etal_GRL_2015/VOLUME/SOFTWARE/READAIS.C)

```sh
cc src/read_ais.c -o +marsis/read_ais
```

Update the URL to get most recent orbits

```matlab
orbfile = marsis.download_orbit("data", "https://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v2.0/mexsp_2000/EXTRAS/ORBNUM/ORMM_MERGED_01825.ORB")

marsis.read_orbit(orbfile)
```

## Example

Sept 9, 2008 starting at 1 UT:

```matlab
marsis.show(datetime(2008,9,9,1,0,0))
```

data is output to the data/ directory



[orbnum alternative download](http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum)
