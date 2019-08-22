#!/bin/bash

for NODE in $(uniq ${PBS_NODEFILE}); do
	ssh ${NODE} nvidia-smi
done
