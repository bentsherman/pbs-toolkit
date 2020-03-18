#!/bin/bash

MODULEDIR="${HOME}/privatemodules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="hpx"
MODULE_VERSION="1.4.1"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# load module dependencies
module purge
module add boost/1.71.0
module add cmake/3.13.1
module add gcc/5.4.0
module add git
module add hwloc/1.11.12

# remove previous installation
rm -rf ${MODULE_PATH}

# download hpx source
wget -q https://github.com/STEllAR-GROUP/hpx/archive/${MODULE_VERSION}.zip
unzip ${MODULE_VERSION}.zip
rm -f ${MODULE_VERSION}.zip

# build hpx from source
BUILDDIR="${HOME}/hpx-${MODULE_VERSION}"

cd ${BUILDDIR}

mkdir build
cd build

cmake \
	-DCMAKE_INSTALL_PREFIX=${MODULE_PATH} \
	-DBOOST_ROOT=/software/boost/1.71.0 \
	-DHWLOC_ROOT=/software/hwloc/1.11.12 \
	-DHPX_WITH_MALLOC=system \
	..

make -j $(wc -l ${PBS_NODEFILE}) install

# remove build directory
#rm -rf ${BUILDDIR}

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module add boost/1.71.0
module add gcc/5.4.0
module add hwloc/1.11.12

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH                ${MODULE_PATH}/bin
prepend-path CPLUS_INCLUDE_PATH  ${MODULE_PATH}/include
prepend-path LD_LIBRARY_PATH     ${MODULE_PATH}/lib
prepend-path LIBRARY_PATH        ${MODULE_PATH}/lib
EOF
