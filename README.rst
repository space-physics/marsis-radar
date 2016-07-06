============
marsis-utils
============

Utilities for reading and ploting ESA MARSIS radar data

Please feel free to contact me with questions

CLI main program
================
Generate plots for the date you desire (optionally specify hour,minute,second)::

    NoGui([year,month,day])


Setup
=====

Creating orbnum.mat
-------------------
::

    wget -P data ftp://naif.jpl.nasa.gov/pub/naif/pds/data/mex-e_m-spice-6-v1.0/mexsp_1000/EXTRAS/ORBNUM/ORMM_MERGED_00966.ORB

    OrbReader
    

alternative URL:
http://ssols01.esac.esa.int/adcs/SPICE/ftp_browse.php?mission=MEX&type=orbnum

Compiling READAIS.C
-------------------
I obtained and cleaned up the original http://www-pw.physics.uiowa.edu/marsx/Gurnett_etal_GRL_2015/VOLUME/SOFTWARE/READAIS.C::

    make
    
or::

    cc read_ais.c -o read_ais
    
    
Main GUI (optional)
===================
``UserGUI.m`` is the main program to run. It will allow you to auto-download and plot
MARSIS ionospheric radar data by date. But first do the one-time setup.

