#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="trimmomatic"
MODULE_VERSION="0.38"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# download and extract stringtie
mkdir -p ${SOFTWAREDIR}/${MODULE_NAME}

wget -q http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip
unzip -q Trimmomatic-0.38.zip

rm -rf ${MODULE_PATH}
mv Trimmomatic-0.38 ${MODULE_PATH}

rm -rf Trimmomatic-0.38.zip

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

module load java/1.8.0

prepend-path CLASSPATH ${MODULE_PATH}/trimmomatic-0.38.jar
set-alias trimmomatic {java -jar ${MODULE_PATH}/trimmomatic-0.38.jar}
EOF
