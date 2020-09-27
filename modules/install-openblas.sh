#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="openblas"
MODULE_VERSION="0.3.5"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build openblas from source
module purge
module load git

rm -rf ${MODULE_PATH}

wget https://github.com/xianyi/OpenBLAS/archive/v0.3.5.zip
unzip v0.3.5.zip

cd OpenBLAS-0.3.5
make TARGET=CORE2 NUM_THREADS=80
make install PREFIX=${MODULE_PATH}

cd ..
rm -rf v0.3.5.zip OpenBLAS-0.3.5

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH ${MODULE_PATH}/bin
prepend-path C_INCLUDE_PATH ${MODULE_PATH}/include
prepend-path CPLUS_INCLUDE_PATH ${MODULE_PATH}/include
prepend-path LIBRARY_PATH ${MODULE_PATH}/lib
prepend-path LD_LIBRARY_PATH ${MODULE_PATH}/lib
EOF
