#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="sratoolkit"
MODULE_VERSION="2.9.2"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# download and extract sratoolkit
mkdir -p ${SOFTWAREDIR}/${MODULE_NAME}

wget -q https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/${MODULE_VERSION}/sratoolkit.${MODULE_VERSION}-centos_linux64.tar.gz
tar -xf sratoolkit.${MODULE_VERSION}-centos_linux64.tar.gz

rm -rf ${MODULE_PATH}
mv sratoolkit.${MODULE_VERSION}-centos_linux64 ${MODULE_PATH}

rm -rf sratoolkit.${MODULE_VERSION}-centos_linux64.tar.gz

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
EOF
