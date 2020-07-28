# Marsis Radar

[![DOI](https://zenodo.org/badge/24042603.svg)](https://zenodo.org/badge/latestdoi/24042603)

Read and plot ESA MARSIS radar data.
Works with GNU Octave and Matlab.

## main program

Generate plots for the date you desire (optionally specify hour,minute,second):

```matlab
NoGui([year,month,day],'out.avi')
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
NoGui([2008,9,9,1,0,0])
```

data is output to the data/ directory

## Reference

The normal user does not have to do these, or only infrequently.

### Creating orbnum.mat

```sh
wget -P data ftp://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v1.0/mexsp_1000/EXTRAS/ORBNUM/ORMM_MERGED_00966.ORB
```

```matlab
OrbReader
```

[alternative download](http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum)
