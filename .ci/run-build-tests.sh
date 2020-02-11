#!/bin/bash -xe
#
# Copyright 2013-2020 Lawrence Livermore National Security, LLC and other
# Spack Project Developers. See the top-level COPYRIGHT file for details.
#
# SPDX-License-Identifier: (Apache-2.0 OR MIT)

#
# Description:
#     Runs Spack build smoke tests.  This installs flux-core and flux-sched
#     with a few variants of the master branch.
#
# Usage:
#     run-build-tests.sh
#

if [ -z "$SPACK_ROOT" ]; then
    echo "Error: SPACK_ROOT must be set"
    exit 1
fi

# Move to root directory of Spack
# Allows script to be run from anywhere
cd "$SPACK_ROOT"

# Fetch the sources in a mirror, and add it to Spack
#mkdir -p ~/.mirror
#bin/spack mirror add travis ~/.mirror
#bin/spack mirror create -D -d ~/.mirror flux-core@${SPEC} flux-sched@${SPEC}

# Make sure we have a spec to build.
if [ -z "$SPEC" ]; then
    echo "Error: run-build-tests requires the $SPEC to build to be set."
    exit 1
fi

# Add this git repo as a spack repo
bin/spack repo add $GITHUB_WORKSPACE

# Print repos information
bin/spack repo list

# Print compiler information
bin/spack config get compilers

# Print spack spec
bin/spack spec -l flux-sched@${SPEC}

# Run some build smoke tests
bin/spack install --test=root --show-log-on-error flux.flux-core@${SPEC}
bin/spack install --test=root --show-log-on-error flux.flux-sched@${SPEC}
