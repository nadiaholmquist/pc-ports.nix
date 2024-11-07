#!/bin/bash

dataHome="${XDG_DATA_HOME:-$HOME/.local/share}"
configDir="$dataHome/xash3d"

mkdir -p "$configDir"

export XASH3D_BASEDIR="${XASH3D_BASEDIR:-$configDir}"
export XASH3D_GAME="${XASH3D_GAME:-valve}"

exec "@out@/bin/.xash3d-wrapped" -rodir "@out@/share/xash3d" "$@"
