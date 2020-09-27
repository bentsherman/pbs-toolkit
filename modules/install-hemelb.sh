#!/bin/bash

# parse command-line arguments
if [[ $# != 2 ]]; then
	echo "usage: $0 <lattice-type <gpu-model>>"
	exit -1
fi

LATTICE_TYPE="$1"
GPU_MODEL="$2"

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="hemelb"
MODULE_VERSION="${LATTICE_TYPE}-${GPU_MODEL}"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# load modules
module purge
module load anaconda3/5.1.0-gcc/8.3.1
module load boost/1.73.0-gcc/8.3.1-nompi
module load cmake/3.17.3-gcc/8.3.1
module load hdf5/1.12.0-gcc/8.3.1-cuda11_0-mpi
module load openmpi/3.1.5-gcc/8.3.1-cuda11_0-ucx

export CPLUS_INCLUDE_PATH="/usr/include/tirpc:${CPLUS_INCLUDE_PATH}"

# build hemelb-dev from source
BUILDDIR="${HOME}/workspace/hemelb-dev"

rm -rf ${MODULE_PATH}

if [ ! -d ${BUILDDIR} ]; then
	git clone https://github.com/Clemson-MSE/hemelb-dev.git ${BUILDDIR}
fi

rm -rf ${BUILDDIR}/build
mkdir -p ${BUILDDIR}/build
cd ${BUILDDIR}/build

cmake .. \
	-DCMAKE_INSTALL_PREFIX=${MODULE_PATH} \
	-DHEMELB_BUILD_MAIN=ON \
	-DHEMELB_BUILD_MULTISCALE=OFF \
	-DHEMELB_BUILD_TESTS_ALL=OFF \
	-DHEMELB_BUILD_TESTS_FUNCTIONAL=OFF \
	-DHEMELB_BUILD_TESTS_UNIT=OFF \
	-DHEMELB_SUBPROJECT_MAKE_JOBS=$(cat ${PBS_NODEFILE} | wc -l) \
	-DHEMELB_OPTIMISATION="-O3" \
	-DHEMELB_PROFILING="" \
	-DHEMELB_LATTICE=${LATTICE_TYPE} \
	-DHEMELB_LATTICE_INCOMPRESSIBLE=OFF \
	-DHEMELB_CUDA_AWARE_MPI=OFF
make

# install hemelb setup tool
CONDA_ENV=$(conda info --envs | awk '{ print $1 }' | grep hemelb)

if [[ ${CONDA_ENV} != "hemelb" ]]; then
	conda create -n hemelb -y python=2.7.14 cython pyyaml
	conda install -n hemelb -y -c vmtk vmtk
	conda install -n hemelb -y -c conda-forge cgal

	source activate hemelb

	export CPLUS_INCLUDE_PATH=${HOME}/.conda/envs/hemelb/include:${CPLUS_INCLUDE_PATH}
	export VTKINCLUDE=${HOME}/.conda/envs/hemelb/include/vtk-8.1

	cd ${BUILDDIR}/Code/geometry
	cp SiteDataBare.cu SiteDataBare.cc

	cd ${BUILDDIR}/Tools
	python setup.py build_ext --inplace

	cd ${BUILDDIR}/Tools/setuptool
	python setup.py build_ext --inplace
fi

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module load boost/1.73.0-gcc/8.3.1-nompi
module load cmake/3.17.3-gcc/8.3.1
module load hdf5/1.12.0-gcc/8.3.1-cuda11_0-mpi
module load openmpi/3.1.5-gcc/8.3.1-cuda11_0-ucx

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH ${MODULE_PATH}/bin
prepend-path PYTHONPATH ${BUILDDIR}/Tools:${BUILDDIR}/Tools/setuptool
EOF
