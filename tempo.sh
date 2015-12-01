#!/bin/bash

module swap PrgEnv-intel PrgEnv-gnu #need to use GNU compiler
module swap PrgEnv-pgi PrgEnv-gnu #need to use GNU compiler

export OMP_NUM_THREADS=6
./makelmdz_fcm -arch local -d 96x72x19 -parallel mpi_omp -mem gcm
