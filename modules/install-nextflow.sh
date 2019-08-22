#!/bin/bash

# parse command-line arguments
if [[ $# != 1 ]]; then
	echo "usage: $0 <version>"
	exit -1
fi

MODULEDIR="${HOME}/privatemodules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="nextflow"
MODULE_VERSION="$1"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

module add java/1.8.0

# create nextflow binary
mkdir -p "${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

curl -s https://get.nextflow.io | bash
mv nextflow "${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module add java/1.8.0

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

setenv NXF_VER ${MODULE_VERSION}
prepend-path PATH ${MODULE_PATH}
EOF
