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

bin/spack -d bootstrap -v
source $SPACK_ROOT/share/spack/setup-env.sh

# Add this git repo as a spack repo
spack repo add $GITHUB_WORKSPACE

# Print repos information
spack repo list

# Get the latest version (now that we've added the local repo)
if [[ "$SPEC" == "latest-tag" ]]; then
    CORE_SPEC=$(spack versions -s flux.flux-core | grep '[0-9.]' | head -n1)
    SCHED_SPEC=$(spack versions -s flux.flux-sched | grep '[0-9.]' | head -n1)
elif [[ "$SPEC" == "master" ]]; then
    CORE_SPEC="$SPEC"
    SCHED_SPEC="$SPEC"
else
    echo "Unrecognized SPEC: $SPEC"
    exit 1
fi

# Print the SPEC
echo "Spec: $SPEC"

# Print compiler information
spack config get compilers

# Print spack spec
spack spec -l flux-sched@${SCHED_SPEC}

# Print filesystem info (make sure flock'ing is supported)
mount

# Run some build smoke tests
spack install --test=root --show-log-on-error flux.flux-core@${CORE_SPEC}
spack load flux-core@${CORE_SPEC}
flux keygen # generate keys so that bootstrapping in flux-sched tests works
spack install --test=root --show-log-on-error flux.flux-sched@${SCHED_SPEC}
