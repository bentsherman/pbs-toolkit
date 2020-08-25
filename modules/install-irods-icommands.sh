#!/bin/bash

MODULEDIR="${HOME}/modules"
SOFTWAREDIR="${HOME}/software"

MODULE_NAME="irods-icommands"
MODULE_VERSION="4.1.12"
MODULE_PATH="${SOFTWAREDIR}/${MODULE_NAME}/${MODULE_VERSION}"

# make sure user is not on the login node
if [ ${HOSTNAME} = "login001" ]; then
	echo "error: please use a compute node to install this module"
	exit -1
fi

module purge
module add singularity/3.2

# initialize module directory
rm -rf ${MODULE_PATH}
mkdir -p ${MODULE_PATH}

# build Singularity image (pull from DockerHub)
SIMG_PATH="${MODULE_PATH}/irods-icommands-${MODULE_VERSION}.simg"

singularity build ${SIMG_PATH} docker://systemsgenetics/irods-icommands:${MODULE_VERSION}

# create modulefile
SINGULARITY="singularity -q exec -B /scratch2:/scratch2 -B /scratch3:/scratch3 -B /scratch4:/scratch4 ${SIMG_PATH}"

mkdir -p ${MODULEDIR}/${MODULE_NAME}

cat > "${MODULEDIR}/${MODULE_NAME}/${MODULE_VERSION}" <<EOF
#%Module1.0
##
## ${MODULE_NAME}/${MODULE_VERSION}  modulefile
##
module-whatis "Set up environment for ${MODULE_NAME}"
module add singularity/3.2

# for Tcl script use only
set version "3.2.6"

# Make sure no other hpc modulefiles are loaded before loading this module
eval set [ array get env MODULESHOME ]

set-alias iadmin       "${SINGULARITY} iadmin"
set-alias ibun         "${SINGULARITY} ibun"
set-alias icd          "${SINGULARITY} icd"
set-alias ichksum      "${SINGULARITY} ichksum"
set-alias ichmod       "${SINGULARITY} ichmod"
set-alias icp          "${SINGULARITY} icp"
set-alias ienv         "${SINGULARITY} ienv"
set-alias ierror       "${SINGULARITY} ierror"
set-alias iexecmd      "${SINGULARITY} iexecmd"
set-alias iexit        "${SINGULARITY} iexit"
set-alias ifsck        "${SINGULARITY} ifsck"
set-alias iget         "${SINGULARITY} iget"
set-alias igroupadmin  "${SINGULARITY} igroupadmin"
set-alias ihelp        "${SINGULARITY} ihelp"
set-alias iinit        "${SINGULARITY} iinit"
set-alias ils          "${SINGULARITY} ils"
set-alias ilsresc      "${SINGULARITY} ilsresc"
set-alias imcoll       "${SINGULARITY} imcoll"
set-alias imeta        "${SINGULARITY} imeta"
set-alias imiscsvrinfo "${SINGULARITY} imiscsvrinfo"
set-alias imkdir       "${SINGULARITY} imkdir"
set-alias imv          "${SINGULARITY} imv"
set-alias ipasswd      "${SINGULARITY} ipasswd"
set-alias iphybun      "${SINGULARITY} iphybun"
set-alias iphymv       "${SINGULARITY} iphymv"
set-alias ips          "${SINGULARITY} ips"
set-alias iput         "${SINGULARITY} iput"
set-alias ipwd         "${SINGULARITY} ipwd"
set-alias iqdel        "${SINGULARITY} iqdel"
set-alias iqmod        "${SINGULARITY} iqmod"
set-alias iqstat       "${SINGULARITY} iqstat"
set-alias iquest       "${SINGULARITY} iquest"
set-alias iquota       "${SINGULARITY} iquota"
set-alias ireg         "${SINGULARITY} ireg"
set-alias irepl        "${SINGULARITY} irepl"
set-alias irm          "${SINGULARITY} irm"
set-alias irmtrash     "${SINGULARITY} irmtrash"
set-alias irsync       "${SINGULARITY} irsync"
set-alias irule        "${SINGULARITY} irule"
set-alias iscan        "${SINGULARITY} iscan"
set-alias isysmeta     "${SINGULARITY} isysmeta"
set-alias iticket      "${SINGULARITY} iticket"
set-alias itrim        "${SINGULARITY} itrim"
set-alias iuserinfo    "${SINGULARITY} iuserinfo"
set-alias ixmsg        "${SINGULARITY} ixmsg"
set-alias izonereport  "${SINGULARITY} izonereport"
EOF
