#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="BioDepVis"
MODULE_VERSION="develop"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build BioDepVis from source
module purge
module load cuda-toolkit/9.2
module load gcc/5.4.0
module load git
module load Qt/5.9.2

BUILDDIR="${HOME}/BioDep-Vis"

rm -rf ${MODULE_PATH}

if [ ! -d ${BUILDDIR} ]; then
	git clone https://github.com/SystemsGenetics/BioDepVis.git ${BUILDDIR}
fi

cd ${BUILDDIR}

make clean
make -j $(cat ${PBS_NODEFILE} | wc -l) CUDADIR=${CUDA_ROOT}
make install

mkdir -p ${MODULE_PATH}/bin
cp BioDepVis ${MODULE_PATH}/bin

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module load cuda-toolkit/9.2
module load gcc/5.4.0
module load Qt/5.9.2

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH ${MODULE_PATH}/bin
EOF
