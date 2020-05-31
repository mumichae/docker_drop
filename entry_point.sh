#!/usr/bin/env bash
set -Eeuo pipefail

echo "$@"

# first arg is `-f` or `--some-option`
# or there are no args
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    # docker run bash -c 'echo hi'
    echo "run with bash prefix: '$@'"
    exec bash "$@"
elif [ "${1#./}" == "bash" ]; then
     echo "run with no prefix: '$@'"
     exec "$@"
else
    echo "run with conda prefix: '$@'"
    conda run -n drop-docker $@
fi

echo "bye bye ..."
