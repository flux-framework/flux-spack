#!/bin/bash -x
#
# Copyright 2020 Lawrence Livermore National Security, LLC
# (c.f. AUTHORS, NOTICE.LLNS, COPYING)
#
# This file is part of the Flux resource manager framework.
# For details, see https://github.com/flux-framework.
#
# SPDX-License-Identifier: LGPL-3.0

#
# Description:
#     Find flux build logs inside of Spack staging directory and dump
#     their contents
#
# Usage:
#     run-build-tests
#

if [ -z "$SPACK_ROOT" ]; then
    echo "Error: SPACK_ROOT must be set"
    exit 1
fi

# Move to root directory of Spack
# Allows script to be run from anywhere
cd "$SPACK_ROOT"

# Lines taken from the flux-core travis.yml:
# https://github.com/flux-framework/flux-core/blob/9622d7df0ecf7dd656f19631914c86aedd1daf0d/.travis.yml#L167
function dump_logs {
    find $1 -name test-suite.log | xargs -i sh -c 'printf "===XXX {} XXX===";cat {}'
    find $1 -name t[0-9]*.output | xargs -i sh -c 'printf "\033[31mFound {}\033[39m\n";cat {}'
    find $1 -name *.broker.log | xargs -i sh -c 'printf "\033[31mFound {}\033[39m\n";cat {}'
    find $1 -name *.asan.* | xargs -i sh -c 'printf "\033[31mFound {}\033[39m\n";cat {}'
    #src/test/backtrace-all.sh
    grep -q 'configure. exit 1' $1/config.log && cat $1/config.log
}

build_dir=$(bin/spack location -b flux-core@master)/spack-build
dump_logs `readlink -e $build_dir`

build_dir=$(bin/spack location -b flux-sched@master)/spack-build
if [[ "$build_dir" == "/spack-build" ]]; then
    echo "Build process didn't get to flux-sched, skipping log dump for flux-sched"
else
    dump_logs `readlink -e $build_dir`
fi
