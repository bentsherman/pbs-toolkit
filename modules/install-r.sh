#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="R"
MODULE_VERSION="3.2.5"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

# build openblas from source
module purge
module load gcc/5.4.0

rm -rf ${MODULE_PATH}

wget -q https://cran.r-project.org/src/base/R-3/R-3.2.5.tar.gz
tar -xzf R-3.2.5.tar.gz

cd R-3.2.5
./configure --prefix=${SOFTWAREDIR} --build=x86_64-unknown-linux-gnu
make -j $(cat ${PBS_NODEFILE} | wc -l) rhome=${SOFTWAREDIR}
make install

cd ..
rm -rf R-3.2.5 R-3.2.5.tar.gz

# create modulefile
mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module load gcc/5.4.0

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

prepend-path PATH ${MODULE_PATH}/bin
EOF
