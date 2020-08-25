#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="stringtie"
MODULE_VERSION="1.3.4d"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# download and extract stringtie
mkdir -p ${SOFTWAREDIR}/${MODULE_NAME}

wget -q http://ccb.jhu.edu/software/stringtie/dl/stringtie-1.3.4d.Linux_x86_64.tar.gz
tar -xf stringtie-1.3.4d.Linux_x86_64.tar.gz

rm -rf ${MODULE_PATH}
mv stringtie-1.3.4d.Linux_x86_64 ${MODULE_PATH}

rm -rf stringtie-1.3.4d.Linux_x86_64.tar.gz

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

prepend-path PATH ${MODULE_PATH}
EOF
