#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="mixmod"
MODULE_VERSION="3.2.2"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build ACE from source
module purge
module add gcc/5.4.0
module add git

rm -rf ${MODULE_PATH}

wget http://www.mixmod.org/IMG/tgz/libmixmod_3.2.2_src.tgz
tar -xf libmixmod_3.2.2_src.tgz

cd libmixmod_3.2.2/BUILD

cmake .. -DCMAKE_INSTALL_PREFIX=${MODULE_PATH}
make -s -j $(cat ${PBS_NODEFILE} | wc -l)
make -s install

cd ../../
rm -rf libmixmod_3.2.2_src.tgz libmixmod_3.2.2

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module add gcc/5.4.0

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path CPLUS_INCLUDE_PATH  ${MODULE_PATH}/include
prepend-path LD_LIBRARY_PATH     ${MODULE_PATH}/lib
prepend-path LIBRARY_PATH        ${MODULE_PATH}/lib
EOF
