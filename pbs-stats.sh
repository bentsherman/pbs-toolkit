#!/bin/bash

# fetch list of currently running jobs
JOBS="$(qstat -u ${USER} | grep ${USER} | awk '{ print $1 }')"
NUM_JOBS=$(qstat -u ${USER} | grep ${USER} | wc -l)

# show current usage of compute nodes
qstat -u ${USER} | head -n 20
echo

echo "... ${NUM_JOBS} jobs in queue"
echo

# show availability of storage
df -h /scratch*
echo

for JOB in ${JOBS}; do
	NODE="$(qstat -n ${JOB} | grep node | head -n 1 | awk '{ split($0,a,"/"); print a[1] }')"

	if [[ ! -z ${NODE} ]]; then
		ssh ${NODE} "df -h /local_scratch/pbs.${JOB} | tail -n 1"
	fi
done
echo
