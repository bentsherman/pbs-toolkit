#!/bin/bash

# parse command-line arguments
if [[ $# != 1 ]]; then
	echo "usage: $0 <version>"
	exit -1
fi

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="ace"
MODULE_VERSION="$1"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build ACE from source
module purge
module load openmpi/3.1.5-gcc/8.3.1-cuda11_0-ucx
module load qt/5.14.2-gcc/8.3.1

BUILDDIR="${HOME}/ace"
LD_LIBRARY_PATH="/usr/lib64:${LD_LIBRARY_PATH}"

rm -rf ${MODULE_PATH}

git clone -q https://github.com/SystemsGenetics/ACE.git ${BUILDDIR}

cd ${BUILDDIR}
git checkout -q ${MODULE_VERSION}

cd ${BUILDDIR}/build
qmake ../src/ACE.pro PREFIX=${MODULE_PATH} CUDADIR=${CUDA_ROOT}
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
module load openmpi/3.1.5-gcc/8.3.1-cuda11_0-ucx
module load qt/5.14.2-gcc/8.3.1

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH                ${MODULE_PATH}/bin
prepend-path CPLUS_INCLUDE_PATH  ${MODULE_PATH}/include
prepend-path LD_LIBRARY_PATH     ${MODULE_PATH}/lib
prepend-path LIBRARY_PATH        ${MODULE_PATH}/lib
EOF
