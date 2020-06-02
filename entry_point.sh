#!/usr/bin/env bash
set -Eeuo pipefail

# start script
echo "my input: '$@'"

# some bash args or non at all (default)
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ] ;
then
    echo "run as bash with just parameters ..."
    exec bash "$@"
elif [ "${1#./}" == "bash" ]; then
    echo "bash command is provided ..."
    exec "$@"
else
    echo "run it using conda env ..."
    conda run -n drop-docker "$@"
fi


