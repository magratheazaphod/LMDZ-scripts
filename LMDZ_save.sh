#!/bin/bash

#LMDZ_save.sh
#written by Jesse Day, July 28th 2015. Script that save output from LMDZ model runs.

#the variable time is defined in the control script LMDZ_control.sh
#location of REBUILD script is also given in control script LMDZ_control.sh

#get rid of old temporary reconstructed files in case they exist
if [ -f histmth_"$RUNDATE".nc ]; then

	rm histmth_"$RUNDATE".nc

fi

if [ -f histday_"$RUNDATE".nc ]; then

	rm histday_"$RUNDATE".nc

fi

if [ -f histhf_"$RUNDATE".nc ]; then

	rm histhf_"$RUNDATE".nc

fi

#precautionary code in case these files have already been created - be careful not to overwrite past data!
if [ -f "$HISTDIR"/histmth_"$RUNDATE".nc ]; then
 
	mv -f "$HISTDIR"/histmth_"$RUNDATE".nc "$HISTDIR"/histmth_"$RUNDATE"_old.nc

fi

if [ -f "$HISTDIR"/histday_"$RUNDATE".nc ]; then

	mv -f "$HISTDIR"/histday_"$RUNDATE".nc "$HISTDIR"/histday_"$RUNDATE"_old.nc

fi

if [ -f "$HISTDIR"/histhf_"$RUNDATE".nc ]; then

	mv -f "$HISTDIR"/histhf_"$RUNDATE".nc "$HISTDIR"/histhf_"$RUNDATE"_old.nc

fi


#use the rebuild script from IOIPSL to glue parallel components back together
"$REBUILD" -o histmth_"$RUNDATE".nc histmth_*.nc   #month
cp histmth_"$RUNDATE".nc "$HISTDIR"/histmth_"$RUNDATE".nc
"$REBUILD" -o histday_"$RUNDATE".nc histday_*.nc   #day
cp histday_"$RUNDATE".nc "$HISTDIR"/histday_"$RUNDATE".nc
"$REBUILD" -o histhf_"$RUNDATE".nc histhf_*.nc   #high-frequency
cp histhf_"$RUNDATE".nc "$HISTDIR"/histhf_"$RUNDATE".nc


#save restart.nc and restartphy.nc so that simulation can be started over again at any month
#for simplicity we use the RUNDATE suffix on restart.nc, such that restart_198701.nc is 
#equivalent to start_198702.nc, and restart_199912.nc equivalent to start_200001.nc.

cp restart.nc restart_"$RUNDATE".nc
cp restartphy.nc restartphy_"$RUNDATE".nc

if [ -f "$RESTARTDIR"/restart_"$RUNDATE".nc ]; then
 
	mv -f "$RESTARTDIR"/restart_"$RUNDATE".nc "$RESTARTDIR"/restart_"$RUNDATE"_old.nc

fi

if [ -f "$RESTARTDIR"/restartphy_"$RUNDATE".nc ]; then

	mv -f "$RESTARTDIR"/restartphy_"$RUNDATE".nc "$RESTARTDIR"/restartphy_"$RUNDATE"_old.nc

fi

cp restart_"$RUNDATE".nc "$RESTARTDIR"/restart_"$RUNDATE".nc
cp restartphy_"$RUNDATE".nc "$RESTARTDIR"/restartphy_"$RUNDATE".nc


#SAVE TO HSI
#as additional backup, all output data is stored in hsi, NERSC server's storage space
#history files
hsi "cd ${HSIHIST}; mv -f histmth_${RUNDATE}.nc histmth_${RUNDATE}_old.nc"
hsi "cd ${HSIHIST}; mv -f histday_${RUNDATE}.nc histday_${RUNDATE}_old.nc"
hsi "cd ${HSIHIST}; mv -f histhf_${RUNDATE}.nc histhf_${RUNDATE}_old.nc"

hsi "cd ${HSIHIST}; put histmth_${RUNDATE}.nc"
hsi "cd ${HSIHIST}; put histday_${RUNDATE}.nc"
hsi "cd ${HSIHIST}; put histhf_${RUNDATE}.nc"

#restart files
hsi "cd ${HSIRESTART}; put restart_${RUNDATE}.nc; put restartphy_${RUNDATE}.nc"

hsi "ls ${HSIHOME}; cd ${HSIRESTART}"

#remove temporary copy of files (had to create to upload to HSI)
rm histmth_"$RUNDATE".nc
rm histday_"$RUNDATE".nc
rm histhf_"$RUNDATE".nc
rm restart_"$RUNDATE".nc
rm restartphy_"$RUNDATE".nc

#clean up leftover hist parts
rm histmth_*.nc
rm histday_*.nc
rm histhf_*.nc

###

#delete leftover history files - restart files are deleted in main script.
#rm tmp_mth.nc
#rm tmp_day.nc
#rm tmp_hf.nc

#change of approach - we keep the tmp files around in case the next run ends up aborting for some reason