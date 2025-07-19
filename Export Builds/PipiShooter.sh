#!/bin/sh
echo -ne '\033c\033]0;PipiShooter\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/PipiShooter.x86_64" "$@"
