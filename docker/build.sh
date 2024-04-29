#!/bin/bash
set -e

# Choose build
# --isolated-install : install each package into its own install space
# --merge-install : merge all packages into one install space


catkin_make \
        -DCMAKE_BUILD_TYPE=Release
