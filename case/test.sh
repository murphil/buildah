#!/usr/bin/env bash -x

ctr1=$(buildah from "${1:-alpine}")

echo $ctr1

## Get all updates and install our minimal httpd server
buildah run "$ctr1" -- apk update
buildah run "$ctr1" -- apk add zsh

# ## Include some buildtime annotations
# buildah config --annotation "com.example.build.host=$(uname -n)" "$ctr1"
#
# ## Run our server and expose the port
# buildah config --cmd "zsh" "$ctr1"
# buildah config --port 80 "$ctr1"
#
# ## Commit this container to an image name
# buildah commit "$ctr1" "${2:-$USER/test-buildah}"