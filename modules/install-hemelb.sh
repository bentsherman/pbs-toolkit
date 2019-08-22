#!/bin/bash

# parse command-line arguments
if [[ $# != 1 ]]; then
	echo "usage: $0 <lattice-type>"
	exit -1
fi

LATTICE_TYPE="$1"

MODULEDIR="${HOME}/privatemodules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="hemelb"
MODULE_VERSION="dev-${LATTICE_TYPE}"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

module purge
module add boost
module add cmake/3.10.0
module add cuda-toolkit/9.2
module add gcc/5.4.0
module add hdf5/1.10.0
module add openmpi/1.10.7

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
	-DBOOST_ROOT:PATHNAME=${BOOST} \
	-DCMAKE_INSTALL_PREFIX=${MODULE_PATH} \
        -DHEMELB_BUILD_MAIN=ON \
        -DHEMELB_BUILD_MULTISCALE=OFF \
        -DHEMELB_BUILD_TESTS_ALL=ON \
        -DHEMELB_BUILD_TESTS_FUNCTIONAL=OFF \
        -DHEMELB_BUILD_TESTS_UNIT=OFF \
	-DHEMELB_SUBPROJECT_MAKE_JOBS=$(cat ${PBS_NODEFILE} | wc -l) \
        -DHEMELB_OPTIMISATION="-O3" \
        -DHEMELB_PROFILING="" \
        -DHEMELB_LATTICE=${LATTICE_TYPE} \
        -DHEMELB_LATTICE_INCOMPRESSIBLE=OFF
make

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module add boost
module add cmake/3.10.0
module add cuda-toolkit/9.2
module add gcc/5.4.0
module add hdf5/1.10.0
module add openmpi/1.10.7

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH ${MODULE_PATH}/bin
EOF
