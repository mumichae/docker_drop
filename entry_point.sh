#!/usr/bin/env bash
set -Eeo pipefail

# set home folder and source the drop's bashrc
export HOME=/drop
. /drop/.bashrc
set -u

# some bash args or none at all (default)
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ] ;
then
    echo -e "Welcome to the drop command line!\n"
    exec bash "$@"

elif [ "${1#./}" == "bash" ]; then
    echo -e "Welcome to the drop command line!\n"
    exec "$@"
# any other command should be treated as command to be 
# run within the conda environment
else
    conda run -n drop "$@"
fi
