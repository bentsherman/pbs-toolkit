#!/bin/bash

MODULEDIR="${HOME}/privatemodules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="statslib"
MODULE_VERSION="master"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# install statslib
rm -rf ${MODULE_PATH}

git clone -q https://github.com/kthohr/gcem
git clone -q https://github.com/kthohr/stats

mkdir -p ${MODULE_PATH}/include
cp -r gcem/include/* ${MODULE_PATH}/include
cp -r stats/include/* ${MODULE_PATH}/include

rm -rf gcem
rm -rf stats

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

prepend-path CPLUS_INCLUDE_PATH ${MODULE_PATH}/include
EOF
