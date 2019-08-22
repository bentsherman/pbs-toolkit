#!/bin/bash

# parse command-line arguments
if [[ $# != 2 ]]; then
	echo "usage: $0 <version> <ace-version>"
	exit -1
fi

MODULEDIR="${HOME}/privatemodules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="KINC"
MODULE_VERSION="$1"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

ACE_VERSION="$2"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build KINC from source
module purge
module add use.own
module add ACE/${ACE_VERSION}
module add git
module add gsl/2.3
module add openblas/0.3.5
module add statslib

BUILDDIR="${HOME}/KINC"
CPLUS_INCLUDE_PATH="${OPENBLAS_DIR}/include:${CPLUS_INCLUDE_PATH}"
LD_LIBRARY_PATH="/usr/lib64:${LD_LIBRARY_PATH}"

rm -rf ${MODULE_PATH}

git clone -q https://github.com/SystemsGenetics/KINC.git ${BUILDDIR}

cd ${BUILDDIR}
git checkout -q ${MODULE_VERSION}

cd ${BUILDDIR}/build
qmake ../src/KINC.pro PREFIX=${MODULE_PATH} CUDADIR=${CUDA_ROOT}
make -s clean
make -s -j $(cat ${PBS_NODEFILE} | wc -l)
make -s qmake_all
make -s -j $(cat ${PBS_NODEFILE} | wc -l) install

rm -rf ${BUILDDIR}

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module add ACE/${ACE_VERSION}
module add gsl/2.3
module add openblas/0.3.5
module add statslib

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH ${MODULE_PATH}/bin
EOF
