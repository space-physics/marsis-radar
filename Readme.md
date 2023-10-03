# Marsis Radar

[![DOI](https://zenodo.org/badge/24042603.svg)](https://zenodo.org/badge/latestdoi/24042603)

Read and plot ESA MARSIS radar data.
Works with GNU Octave and Matlab.

## main program

Generate plots for the date you desire (optionally specify hour,minute,second):

```matlab
NoGui(datetime(2008,9,9,1,0,0),'out.avi')
```

where 'out.avi' is the optional movie output filename.

## Setup

### Compiling READAIS.C

I obtained and cleaned up the
[original](http://www-pw.physics.uiowa.edu/marsx/Gurnett_etal_GRL_2015/VOLUME/SOFTWARE/READAIS.C)

```sh
cc read_ais.c -o read_ais
```

## Examples

To see the data for Sept 9, 2008 starting at 1 UT:

```matlab
NoGui(datetime(2008,9,9,1,0,0))
```

data is output to the data/ directory

## Reference

The normal user does not have to do these, or only infrequently.

### Create orbnum.mat

Update the URL to get most recent orbits

```matlab
orbfile = OrbDownload("data", "https://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v2.0/mexsp_2000/EXTRAS/ORBNUM/ORMM_MERGED_01825.ORB")

OrbReader(orbfile)
```

[alternative download](http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum)
