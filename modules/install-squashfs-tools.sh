#!/bin/bash

MODULEDIR="${HOME}/privatemodules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="squashfs-tools"
MODULE_VERSION="4.3"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build squashfs-tools from source
module purge
module add gcc/5.4.0
module add git

BUILDDIR="${HOME}/squashfs-tools"

rm -rf ${MODULE_PATH}

if [ ! -d ${BUILDDIR} ]; then
	git clone https://github.com/plougher/squashfs-tools.git ${BUILDDIR}
fi

cd ${BUILDDIR}/squashfs-tools
make -s -j $(cat ${PBS_NODEFILE} | wc -l)

mkdir -p ${MODULE_PATH}/bin
cp mksquashfs unsquashfs ${MODULE_PATH}/bin

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

prepend-path PATH ${MODULE_PATH}/bin
EOF
