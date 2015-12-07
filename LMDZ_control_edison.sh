#!/bin/bash

#LMDZ_control.sh, written by Jesse Day, July 27th 2015. Runs the LMDZ model for a given subset of years.
#Creates batch jobs to run model one month at a time, saves output.

#Depends on the previous upload of the LMDZ_save.sh script to the same folder

#REZ gives resolution, while RUNNAME is the unique identifier for a set of runs (for instance, with altered SST)

#Also allows for indefinite customization of run by changing the unique set of definition files .def contained in DefLists folder.
#similarly, can go to tailored ce0l folders 

#Note...currently running without coupling to ORCHIDEE. Bucket model used.

#8/27 updated - added output.def definition file, which dictates what outputs are published.

#the proper execution of this script requires that DefLists include certain existing reference
#definition files - all of the *_5B.def files, the LMDZ_save.sh script and lmdzrun.pbs

#10/21 updated - script now customized for running on Edison:
#-loads lmdzrun_edison.pbs instead of lmdzrun.pbs, which changes the compiler for batch jobs.

module swap PrgEnv-intel PrgEnv-gnu #need to use GNU compiler
module swap PrgEnv-pgi PrgEnv-gnu #need to use GNU compiler

#naming of run
export REZ='192x192x39'
export ADDON='editest'
export RUNNAME="$REZ""$ADDON" 

#runtime parameters - how long is this run going for?
yb=1991
ye=1991
mb=1
me=2

#reference directories
export LMDZDIR="$PWD"
export SUF='_'$REZ'_phylmd_para_mem' #suffix that gcm.e and ce0l.e will be saved under
export SUFSEQ='_'$REZ'_phylmd_seq' #suffix that gcm.e and ce0l.e will be saved under
export RUNDIR="$PWD"/sim_"$RUNNAME"
export CE0LDIR="$PWD"/create_etat0_limit_"$RUNNAME"
export CE0LREFDIR="$PWD"/create_etat0_limit #where base versions of boundary condition files are kept 
export CE0L_OLD="$PWD"/bin/ce0l"$SUFSEQ".e
export GCM_OLD="$PWD"/bin/gcm"$SUF".e
export HISTDIR="$RUNDIR"/hist
export REBUILD=/scratch2/scratchdirs/jessed/LMDZtrunk/modipsl/bin/rebuild
export DEFDIR="$PWD"/DefLists
export RESTARTDIR="$RUNDIR"/restart

#base version of definition and boundary condition files, in case these folders 
#still do not exist in operating directory
export BASEDIR=/global/homes/j/jessed/LMDZ_config

now=$(date +"%m%d%Y")
export LMDZOUT="$RUNDIR"/LMDZOUT_"$RUNNAME"_"$now".txt

#output now saved to logfile for preservation purposes
#correct way to follow - open second shell and use tail -f $LMDZOUT (sub in real name)
exec 4>&1
exec >> "$LMDZOUT" 
echo RUNNAME: "$RUNNAME"
echo "Exporting to log file $LMDZOUT"
echo "Run from years $yb to $ye and months $mb to $me"
sleep 2

#optional restart parameters - what month are we restarting from?
#looks for corresponding restart.nc and restartphy.nc
export isrestart=0

if [ $isrestart -eq 1 ]; then

	#chosen month and year for restart
	restartm=5
	restarty=1991 
	echo "Restarting existing run from month $restartm year $restarty"
	sleep 2

fi

#optional toggles
export CLIMORUN=1 #is this run just using climatological SST?
echo "Climatological run toggle: $CLIMORUN"

#choice of definition files - now a 3-tiered system.
#central, most generic versions exist in the main configuration folder, BASEDIR.
#version-specific files exist inside of DefLists in PWD.
#run-specific filex exist with special suffixes in PWD.

#TIER 1 - base files used (if no specialized files exist)
export CONFIGORIG="$BASEDIR"/config_JD.def
export GCMORIG="$BASEDIR"/gcm_5B.def
export ORCHIDEEORIG="$BASEDIR"/orchidee_5B.def
export OUTPUTORIG="$BASEDIR"/output_JD.def
export PHYSIQORIG="$BASEDIR"/physiq_5B.def
export RUNDEFORIG="$BASEDIR"/run_5B.def
export TRACEURORIG="$BASEDIR"/traceur_5B.def

#TIER 2 - base files used (if no specialized files exist)
export CONFIGBASE="$DEFDIR"/config_JD.def
export GCMBASE="$DEFDIR"/gcm_5B.def
export ORCHIDEEBASE="$DEFDIR"/orchidee_5B.def
export OUTPUTBASE="$DEFDIR"/output_JD.def
export PHYSIQBASE="$DEFDIR"/physiq_5B.def
export RUNDEFBASE="$DEFDIR"/run_5B.def
export TRACEURBASE="$DEFDIR"/traceur_5B.def

#TIER 3 - location of tailored definition files
export CONFIGPATH="$DEFDIR"/config_"$RUNNAME".def
export GCMPATH="$DEFDIR"/gcm_"$RUNNAME".def
export ORCHIDEEPATH="$DEFDIR"/orchidee_"$RUNNAME".def
export OUTPUTPATH="$DEFDIR"/output_"$RUNNAME".def
export PHYSIQPATH="$DEFDIR"/physiq_"$RUNNAME".def
export RUNDEFPATH="$DEFDIR"/run_"$RUNNAME".def
export TRACEURPATH="$DEFDIR"/traceur_"$RUNNAME".def


#TIER 1 -> TIER 2
#copy generic versions of definition files to present LMDZ version if necessary.
if ! [ -f "$CONFIGBASE" ]; then

	cp "$CONFIGORIG" "$CONFIGBASE"

fi

if ! [ -f "$GCMBASE" ]; then

	cp "$GCMORIG" "$GCMBASE"

fi

if ! [ -f "$ORCHIDEEBASE" ]; then

	cp "$ORCHIDEEORIG" "$ORCHIDEEBASE"

fi

if ! [ -f "$OUTPUTBASE" ]; then

	cp "$OUTPUTORIG" "$OUTPUTBASE"

fi

if ! [ -f "$PHYSIQBASE" ]; then

	cp "$PHYSIQORIG" "$PHYSIQBASE"

fi

if ! [ -f "$RUNDEFBASE" ]; then

	cp "$RUNDEFORIG" "$RUNDEFBASE"

fi

if ! [ -f "$TRACEURBASE" ]; then

	cp "$TRACEURORIG" "$TRACEURBASE"

fi

#make definition files for this run in particular, if they
#don't already exist - allows us to customize run files.
if ! [ -f "$CONFIGPATH" ]; then

	cp "$CONFIGBASE" "$CONFIGPATH"

fi

if ! [ -f "$GCMPATH" ]; then

	cp "$GCMBASE" "$GCMPATH"

fi

if ! [ -f "$ORCHIDEEPATH" ]; then

	cp "$ORCHIDEEBASE" "$ORCHIDEEPATH"

fi

if ! [ -f "$OUTPUTPATH" ]; then

	cp "$OUTPUTBASE" "$OUTPUTPATH"

fi

if ! [ -f "$PHYSIQPATH" ]; then

	cp "$PHYSIQBASE" "$PHYSIQPATH"

fi

if ! [ -f "$RUNDEFPATH" ]; then

	cp "$RUNDEFBASE" "$RUNDEFPATH"

fi

if ! [ -f "$TRACEURPATH" ]; then

	cp "$TRACEURBASE" "$TRACEURPATH"

fi


## CREATE ESSENTIAL DIRECTORIES
if ! [[ -d "$RUNDIR" ]]; then

	mkdir ${RUNDIR}

fi

if ! [[ -d "$CE0LREFDIR" ]]; then

	mkdir ${CE0LREFDIR}

fi

if ! [[ -d "$CE0LDIR" ]]; then

	mkdir ${CE0LDIR}

fi

if ! [[ -d "$HISTDIR" ]]; then

	mkdir ${HISTDIR}

fi

if ! [[ -d "$RESTARTDIR" ]]; then

	mkdir ${RESTARTDIR}

fi


#Setting up boundary condition files for run
#when a run is first created, files will be taken from $CE0LREFDIR.
#can later be changed as necessary for different boundary conditions (for instance, altered topography)

#revert to default boundary files unless customized ones already exist
#FULL LIST OF FILES NECESSARY FOR PROPER EXECUTION OF ce0l.e:
#Albedo.nc
#ECDYN.nc
#ECPHY.nc
#landiceref.nc
#Relief.nc
#Rugos.nc
#along with SIC and SST files, which are already obtained above.

#choice of definition files
#three-tiered system - ultimate reference versions stored in personal directory.
#version specific files stored in CE0LREFDIR
#run-specific files stored locally with special appended filename.

export ALBEDOORIG="$BASEDIR"/Albedo.nc
export ECDYNORIG="$BASEDIR"/ECDYN.nc
export ECPHYORIG="$BASEDIR"/ECPHY.nc
export LANDICEORIG="$BASEDIR"/landiceref.nc
export RELIEFORIG="$BASEDIR"/Relief.nc
export RUGOSORIG="$BASEDIR"/Rugos.nc

export ALBEDOBASE="$CE0LREFDIR"/Albedo.nc
export ECDYNBASE="$CE0LREFDIR"/ECDYN.nc
export ECPHYBASE="$CE0LREFDIR"/ECPHY.nc
export LANDICEBASE="$CE0LREFDIR"/landiceref.nc
export RELIEFBASE="$CE0LREFDIR"/Relief.nc
export RUGOSBASE="$CE0LREFDIR"/Rugos.nc

export ALBEDOPATH="$CE0LREFDIR"/Albedo_"$RUNNAME".nc
export ECDYNPATH="$CE0LREFDIR"/ECDYN_"$RUNNAME".nc
export ECPHYPATH="$CE0LREFDIR"/ECPHY_"$RUNNAME".nc
export LANDICEPATH="$CE0LREFDIR"/landiceref_"$RUNNAME".nc
export RELIEFPATH="$CE0LREFDIR"/Relief_"$RUNNAME".nc
export RUGOSPATH="$CE0LREFDIR"/Rugos_"$RUNNAME".nc


#Tier 1 - populate this version of LMDZ with generic boundary condition files, if necessary
if ! [ -f "$ALBEDOBASE" ]; then

	cp "$ALBEDOORIG" "$ALBEDOBASE"

fi

if ! [ -f "$ECDYNBASE" ]; then

	cp "$ECDYNORIG" "$ECDYNBASE"

fi

if ! [ -f "$ECPHYBASE" ]; then

	cp "$ECPHYORIG" "$ECPHYBASE"

fi

if ! [ -f "$LANDICEBASE" ]; then

	cp "$LANDICEORIG" "$LANDICEBASE"

fi

if ! [ -f "$RELIEFBASE" ]; then

	cp "$RELIEFORIG" "$RELIEFBASE"

fi

if ! [ -f "$RUGOSBASE" ]; then

	cp "$RUGOSORIG" "$RUGOSBASE"

fi

#Tier 2 - copy the version-specific files to this specific run, unless files
#already exist.
if ! [ -f "$ALBEDOPATH" ]; then

	cp "$ALBEDOBASE" "$ALBEDOPATH"

fi

if ! [ -f "$ECDYNPATH" ]; then

	cp "$ECDYNBASE" "$ECDYNPATH"

fi

if ! [ -f "$ECPHYPATH" ]; then

	cp "$ECPHYBASE" "$ECPHYPATH"

fi

if ! [ -f "$LANDICEPATH" ]; then

	cp "$LANDICEBASE" "$LANDICEPATH"

fi

if ! [ -f "$RELIEFPATH" ]; then

	cp "$RELIEFBASE" "$RELIEFPATH"

fi

if ! [ -f "$RUGOSPATH" ]; then

	cp "$RUGOSBASE" "$RUGOSPATH"

fi

## SET UP CE0L FOLDER CONTENTS
#first step - remove any existing links.
if [ -f "$CE0LDIR"/Albedo.nc ]; then

	rm "$CE0LDIR"/Albedo.nc

fi

if [ -f "$CE0LDIR"/ECDYN.nc ]; then

	rm "$CE0LDIR"/ECDYN.nc

fi

if [ -f "$CE0LDIR"/ECPHY.nc ]; then

	rm "$CE0LDIR"/ECPHY.nc

fi

if [ -f "$CE0LDIR"/landiceref.nc ]; then

	rm "$CE0LDIR"/landiceref.nc

fi

if [ -f "$CE0LDIR"/Relief.nc ]; then

	rm "$CE0LDIR"/Relief.nc

fi

if [ -f "$CE0LDIR"/Rugos.nc ]; then

	rm "$CE0LDIR"/Rugos.nc

fi

echo "Creating ce0l (boundary condition) directory"
echo "ce0l directory for this run: $CE0LDIR"

#linking to boundary condition files
ln -s "$ALBEDOPATH" ${CE0LDIR}/Albedo.nc
ln -s "$ECDYNPATH" ${CE0LDIR}/ECDYN.nc
ln -s "$ECPHYPATH" ${CE0LDIR}/ECPHY.nc
ln -s "$LANDICEPATH" ${CE0LDIR}/landiceref.nc
ln -s "$RELIEFPATH" ${CE0LDIR}/Relief.nc
ln -s "$RUGOSPATH" ${CE0LDIR}/Rugos.nc

#removing any leftover definition files from previous runs
if [ -f "$CE0LDIR"/config.def ]; then
	rm "$CE0LDIR"/config.def
fi

if [ -f "$CE0LDIR"/gcm.def ]; then
	rm "$CE0LDIR"/gcm.def
fi

if [ -f "$CE0LDIR"/orchidee.def ]; then
	rm "$CE0LDIR"/orchidee.def
fi

if [ -f "$CE0LDIR"/output.def ]; then
	rm "$CE0LDIR"/output.def
fi

if [ -f "$CE0LDIR"/physiq.def ]; then
	rm "$CE0LDIR"/physiq.def
fi

if [ -f "$CE0LDIR"/run.def ]; then
	rm "$CE0LDIR"/run.def
fi

if [ -f "$CE0LDIR"/traceur.def ]; then
	rm "$CE0LDIR"/traceur.def
fi

#linking to definition files - required for ce0l.e to run properly
ln -s "$CONFIGPATH" ${CE0LDIR}/config.def
ln -s "$GCMPATH" ${CE0LDIR}/gcm.def
ln -s "$ORCHIDEEPATH" ${CE0LDIR}/orchidee.def
ln -s "$OUTPUTPATH" ${CE0LDIR}/output.def
ln -s "$PHYSIQPATH" ${CE0LDIR}/physiq.def
ln -s "$RUNDEFPATH" ${CE0LDIR}/run.def
ln -s "$TRACEURPATH" ${CE0LDIR}/traceur.def


## MAKE ESSENTIAL EXECUTABLES: gcm.e and ce0l.e ##
#[ -f "$CE0LDIR"/ce0l.e ] && echo "byah" || echo "nyah"

# put scripts in the right place.
if [ -f "$CE0LDIR"/ce0l.e ]; then

	rm "$CE0LDIR"/ce0l.e 

fi

#create boundary conditions script and move to correct location
if ! [[ -f "$CE0L_OLD" ]]; then

	echo "Producing forcing-maker ce0l.e"
	ulimit -Ss unlimited #solves issues with lack of memory for higher resolution ce0l
	./makelmdz_fcm -arch local -d "$REZ" ce0l

fi

cp "$CE0L_OLD" "$CE0LDIR"/ce0l.e

if [ -f "$RUNDIR"/gcm.e ]; then

	rm "$RUNDIR"/gcm.e 

fi

if ! [[ -f "$GCM_OLD" ]]; then

	echo "Producing GCM gcm.e"
	./makelmdz_fcm -arch local -d "$REZ" -parallel mpi -mem gcm

fi

cp "$GCM_OLD" "$RUNDIR"/gcm.e


#create analogous storage directories on HSI, the NERSC storage system, for redundancy:
export HSIHOME=/home/j/jessed
export HSIRUN="$HSIHOME"/LMDZ/"$RUNNAME"
export HSIHIST="$HSIRUN"/hist
export HSILIMIT="$HSIRUN"/limit
export HSIRESTART="$HSIRUN"/restart

#make backup directories on HSI
echo "Making backup directories on HSI for archival of data."
echo "Folder for all LMDZ runs: $HSIHOME/LMDZ"
hsi "mkdir $HSIHOME/LMDZ"
echo "Run folder: $HSIRUN"
hsi "mkdir ${HSIRUN}"
echo "History folder: $HSIHIST"
hsi "mkdir ${HSIHIST}"
echo "Boundary conditions folder: $HSILIMIT"
hsi "mkdir ${HSILIMIT}"
echo "Restart folder: $HSIRESTART"
hsi "mkdir ${HSIRESTART}"


#If necessary, run through and create limit files and start files for each year using external script
#LMDZ_bcs.sh

#./LMDZ_bcs.sh



#####
###CREATE BOUNDARY CONDITIONS
#####

#should be able to customize use of aerosols and ozone here.
#okozone=0;


#for climatological run, using climo SST and sea ice
if [ -f "$CE0LDIR"/amipbc_sic_1x1.nc  ]; then

	rm "$CE0LDIR"/amipbc_sic_1x1.nc 

fi

if [ -f "$CE0LDIR"/amipbc_sst_1x1.nc ]; then

	rm "$CE0LDIR"/amipbc_sst_1x1.nc

fi

#Clear any existing boundary condition files from the simulation directory
if [ -f "$RUNDIR"/limit.nc ]; then

	rm "$RUNDIR"/limit.nc

fi

if [ -f "$RUNDIR"/start.nc ]; then

	rm "$RUNDIR"/start.nc

fi

if [ -f "$RUNDIR"/startphy.nc ]; then

	rm "$RUNDIR"/startphy.nc

fi


#if isrestart is 1, then we don't need to run ce0l - can just use existing limit conditions.
if [ "$isrestart" -eq 0 ]; then

	cd "$CE0LDIR"	

	if [ "$CLIMORUN" -eq 1 ]
	then

		#obtain AMIP climatological SIC and SST
		cp /global/homes/j/jessed/LMDZ_BCs/AMIP/amipbc_sic_1x1_clim.nc "$CE0LDIR"/amipbc_sic_1x1.nc
		cp /global/homes/j/jessed/LMDZ_BCs/AMIP/amipbc_sst_1x1_clim.nc "$CE0LDIR"/amipbc_sst_1x1.nc

	else #if climorun=0, we load the SST and sea ice conditions from the starting year yb

		#if run is for particular calendar years, use AMIP forcing files for that year.
		cp /global/homes/j/jessed/LMDZ_BCs/AMIP/sic/amipbc_sic_360x180_"$yb".nc "$CE0LDIR"/amipbc_sic_1x1.nc
		cp /global/homes/j/jessed/LMDZ_BCs/AMIP/sst/amipbc_sst_360x180_"$yb".nc "$CE0LDIR"/amipbc_sst_1x1.nc

		if ! [[ -f "/global/homes/j/jessed/LMDZ_BCs/AMIP/sic/amipbc_sic_360x180_${yb}.nc" ]]; then

			echo "Missing AMIP sea ice file for requested year. Script aborted."
			exit 1

		elif ! [[ -f "/global/homes/j/jessed/LMDZ_BCs/AMIP/sst/amipbc_sst_360x180_${yb}.nc" ]]; then

			echo "Missing AMIP SST file for requested year. Script aborted."
			exit 1

		else

			echo "Starting with SST and sea ice boundary condition files from year ${yb}"

		fi

	fi

	#if files are already in ce0l directory, remove them
	if [ -f limit.nc ]; then

		rm limit.nc

	fi

	if [ -f start.nc ]; then

		rm start.nc

	fi

	if [ -f startphy.nc ]; then

		rm startphy.nc

	fi

	if [ -f grilles_gcm.nc ]; then

		rm grilles_gcm.nc

	fi
	

	#make sure that we obtain updated gcm.def file - used to determine zoom on model.
	if [ -f gcm.def ]; then

		rm gcm.def

	fi

	ln -s "$GCMPATH" gcm.def

	#run ce0l, move boundary condition files into sim directory
	ulimit -Ss unlimited #solves issues with lack of memory for higher resolution ce0l
	./ce0l.e
	#note - ce0l.e automatically outputs grilles_gcm.nc file, useful for visualizing grid.

	#save output to HSI
	hsi "cd ${HSILIMIT}; mv -f limit.nc limit_old.nc; mv -f start.nc start_old.nc; mv -f startphy.nc startphy_old.nc"
	echo "Saving boundary condition files to HSI."
	hsi "cd ${HSILIMIT}; put limit.nc; put start.nc; put startphy.nc"

	mv limit.nc "$RUNDIR"
	mv start.nc "$RUNDIR"
	mv startphy.nc "$RUNDIR"
	cd "$LMDZDIR"

else

	#if we're picking up from an existing run, transfer conditions from restart.nc and restartphy.nc
	if [ $restartm -eq 1 ]
	then
	        ryb=$(($restarty-1))
	        rmb=12
	else
	        ryb=$restarty
	        rmb=$(($restartm-1))
	fi
	if [ $rmb -le 9 ]
	then
	        rmb="0$rmb"
	fi
	echo "Obtaining restart.nc and restartphy.nc from run: $ryb$rmb"

	#we make sure that when running the model, the output is stored as restart_yrmth.nc
	#and restartphy_yrmth.nc	
	LIM=${HSILIMIT}/limit.nc
	STA=${HSIRESTART}/restart_${ryb}${rmb}.nc
	SPH=${HSIRESTART}/restartphy_${ryb}${rmb}.nc

	echo "limit.nc file used: $LIM"
	echo "start.nc file used: $STA"
	echo "startphy.nc file used: $SPH"

	hsi "get $RUNDIR/limit.nc : $LIM"
	hsi "get $RUNDIR/start.nc : $STA"
	hsi "get $RUNDIR/startphy.nc : $SPH"

fi

#Verification module - if previous code somehow failed to supply boundary conditions, crashes script
if ! [[ -f "$RUNDIR/limit.nc" ]]; then

	echo "Missing limit.nc boundary condition file! Script aborted."
	exit 1

fi

if ! [[ -f "$RUNDIR/start.nc" ]]; then

	echo "Missing start.nc boundary condition file! Script aborted."
	exit 1

fi

if ! [[ -f "$RUNDIR/startphy.nc" ]]; then

	echo "Missing startphy.nc boundary condition file! Script aborted."
	exit 1

fi


#DEFINITION FILES - write symbolic links to all control files.
#for instance, gcm.def will symbolic link to gcm_96x95x39 in the
#DefLists folder.

#complete set of definitions: config.def, gcm.def, output.def, physiq.def, 
#run.def and traceur.def. Optional additions: guide.def and 
#orchidee.def

if [ -f "$RUNDIR"/config.def ]; then

	rm "$RUNDIR"/config.def

fi

if [ -f "$RUNDIR"/gcm.def ]; then

	rm "$RUNDIR"/gcm.def

fi

if [ -f "$RUNDIR"/orchidee.def ]; then

	rm "$RUNDIR"/orchidee.def

fi

if [ -f "$RUNDIR"/output.def ]; then

	rm "$RUNDIR"/output.def

fi

if [ -f "$RUNDIR"/physiq.def ]; then

	rm "$RUNDIR"/physiq.def

fi

if [ -f "$RUNDIR"/run.def ]; then

	rm "$RUNDIR"/run.def

fi

if [ -f "$RUNDIR"/traceur.def ]; then

	rm "$RUNDIR"/traceur.def

fi

cd "$RUNDIR"
echo "Sim directory: $RUNDIR"


ln -s "$CONFIGPATH" ${RUNDIR}/config.def
ln -s "$GCMPATH" ${RUNDIR}/gcm.def
ln -s "$ORCHIDEEPATH" ${RUNDIR}/orchidee.def
ln -s "$OUTPUTPATH" ${RUNDIR}/output.def
ln -s "$PHYSIQPATH" ${RUNDIR}/physiq.def
ln -s "$RUNDEFPATH" ${RUNDIR}/run.def
ln -s "$TRACEURPATH" ${RUNDIR}/traceur.def

#again, new 3-tier system - most generic version of lmdzrun.pbs stored inside of
#BASEDIR. If none exists for this version yet, that one will be copied over.
if ! [ -f "$LMDZDIR"/lmdzrun.pbs ]; then

	cp "$BASEDIR"/lmdzrun.pbs "$LMDZDIR"/lmdzrun.pbs

fi

#if we don't have a tailored version of the lmdzrun.pbs script for this run yet, then make one
if ! [ -f "$LMDZDIR"/lmdzrun_${RUNNAME}.pbs ]; then

	cp "$LMDZDIR"/lmdzrun.pbs "$LMDZDIR"/lmdzrun_${RUNNAME}.pbs

fi

#move the job submission script lmdzrun.pbs to sim directory if necessary.
if [ -f "$RUNDIR"/lmdzrun.pbs ]; then

	rm "$RUNDIR"/lmdzrun.pbs

fi

cp "$LMDZDIR"/lmdzrun_${RUNNAME}.pbs "$RUNDIR"/lmdzrun.pbs


#editing the job submission script to name of current run
sed -i -e "s/#PBS -N LMDZ[A-Za-z0-9_][A-Za-z0-9_]*/#PBS -N LMDZ${ADDON}/" lmdzrun.pbs

#if the LMDZ_save.sh script does not exist in this version yet, import from 
#reference folder
if [ -f "$LMDZDIR"/LMDZ_save.sh ]; then

	cp "$BASEDIR"/LMDZ_save.sh "$LMDZDIR"/LMDZ_save.sh

fi

#if this particular run doesn't have the LMDZ_save.sh script yet, copy the reference
#one for this particular version.
if [ -f "$RUNDIR"/LMDZ_save.sh ]; then

	rm "$RUNDIR"/LMDZ_save.sh

fi

cp "$LMDZDIR"/LMDZ_save.sh "$RUNDIR"/LMDZ_save.sh


#clean up directory to prevent script from breaking:
if [ -f histmth_0001.nc ]; then

	rm histmth_*.nc

fi

if [ -f histday_0001.nc ]; then

	rm histday_*.nc

fi

if [ -f histhf_0001.nc ]; then

	rm histhf_*.nc

fi

#if existing Bands file exists, use that instead - otherwise, allow executable to make new one
#should implement at some point.

# BANDPATH="Bands_192x192x39_64prc.dat"

# if [f "${LMDZDIR}/${BANDPATH}" ]; then

# 	cp "${LMDZDIR}/${BANDPATH}" "${RUNDIR}/${BANDPATH}"
# 	ls "${RUNDIR}"
# 	sleep 5

# fi

#SIMULATI"ON LOOP
skiploop=0 #used when restarting sim from restart files.

for (( yl=$yb; yl<=$ye; yl++ ))
do

	echo "year: ${yl}"

	if [ "$isrestart" -eq 1 ]; then

		if [ "$yl" -lt "$restarty" ]; then
			skiploop=1
			echo "Restart year: $restarty"
			echo "Skipping year ${yl}, sim will begin in year ${restarty}..."
		else
			skiploop=0
		fi
	fi

	if [ "$skiploop" -eq 0 ]; then 

		#change year in run.def to correct year
		sed -i -e 's/anneeref=[0-9][0-9]*/anneeref='$yl'/' ./run.def

		#obtain correct boundary conditions if necessary
		# if [ "$CLIMORUN" -eq 0 ]
		# then

		# 	./LMDZ_obtain_start.sh

		# fi

		for (( ml=$mb; ml<=$me; ml++ ))
		do

			echo "month: ${ml}"
			let daystart="30*($ml-1)+1" ;
			echo "starting day: ${daystart}"

			#loop below skips months, but only in the restart year (after that you presumably
			#want to do all of the months)
			if [ "$isrestart" -eq 1 ]; then

				if [ "$ml" -lt "$restartm" -a "$yl" -eq "$restarty" ]; then
					skiploop=1
					echo "Restart month: $restartm"
					echo "Skipping month ${ml}, sim will begin in month ${restartm}..."
				else 
					skiploop=0
				fi

			fi

			if [ "$skiploop" -eq 0 ]; then 

				md="$ml"

				if [ $md -le 9 ]; then
				    md="0$md" #where md is short for "month display"
				fi

				export RUNDATE=${yl}${md}
				echo "Run tag: ${RUNDATE}"
				sleep 2

				#change starting day in run.def to correct day
				sed -i -e 's/dayref=[0-9][0-9]*/dayref='$daystart'/' ./run.def
				#sed -i -e "s/dayref=[0-9][0-9]*/dayref=${daystart}/" ./run.def

				#submit job
				#add year and month to name of run in lmdzrun.pbs
				sed -i -e "s/#PBS -N LMDZ${ADDON}[A-Za-z0-9_]*/#PBS -N LMDZ${ADDON}${RUNDATE}/" lmdzrun.pbs

				#job submission and defining filenames
				jobname=$(qsub lmdzrun.pbs)
				echo "Jobname: ${jobname}"
				joberr="my_job.${jobname}.err"
				jobout="my_job.${jobname}.out"
				joberrtemp="${jobname}.ER"
				jobouttemp="${jobname}.OU"
				echo "Temporary job error log: ${joberrtemp}"
				echo "Temporary job output: ${jobouttemp}"
				echo "Final job error log: ${joberr}"
				echo "Final job output: ${jobout}"

				# #must wait until job finishes to continue with rest of script - checks if output file exists yet or not
				ii="0"

				while [ ! -f "$jobout" ] ;
				do
		      		sleep 30
					ii=$[$ii+30]
		      		echo "Waiting "${ii}" seconds..."

		      		#following posts a message if job is actually being run
		      		if [ ! -f "$jobouttemp" ]
		      		then
		      			echo "Still waiting to start job"
		      		else
		      			echo "Job currently running"
		      	    fi

				done

				echo "Previous job complete!"

				# save run output to hsi, set up next run. 
				# also, saves restart.nc and restartphy.nc so that run can easily be restarted at any point in time.
				./LMDZ_save.sh

				# move restart.nc and restartphy.nc to start.nc and startphy.nc
				# keep simulation going
				rm start.nc
				rm startphy.nc
				mv restart.nc start.nc
				mv restartphy.nc startphy.nc
			
			fi

		done

	fi

done

echo "Finished final year of simulation $RUNNAME, congrats!"
