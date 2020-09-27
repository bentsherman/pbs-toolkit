#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="KINC"
MODULE_VERSION="v1"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build KINC from source
module purge
module use ${HOME}/modules
module load git
module load gsl/2.3
module load mixmod/3.2.2
module load openblas/0.3.5

BUILDDIR="${HOME}/KINC"
CPLUS_INCLUDE_PATH="${OPENBLAS_DIR}/include:${CPLUS_INCLUDE_PATH}"

rm -rf ${MODULE_PATH}
mkdir -p ${MODULE_PATH}/bin

git clone -q https://github.com/SystemsGenetics/KINC.git ${BUILDDIR}

cd ${BUILDDIR}
git checkout -q version1

make -s clean
make -s -j $(cat ${PBS_NODEFILE} | wc -l)

cp kinc ${MODULE_PATH}/bin

rm -rf ${BUILDDIR}

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module load gsl/2.3
module load mixmod/3.2.2
module load openblas/0.3.5

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH ${MODULE_PATH}/bin
EOF
