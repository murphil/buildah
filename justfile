run:
    docker run --privileged --rm -it buildah/buildah sh

build:
    docker build . -t buildah

hello:
    docker run --privileged buildah/buildah docker run alpine:3.9 echo hello from nested podman container


bud stage:
    docker build . -t nnurphy/buildah:{{stage}} -f Dockerfile-{{stage}}

build-base:
    just bud runc
    just bud podmanbuildbase

build-all:
    just bud buildah
    just bud skopeo
    just bud fuse-overlayfs
    just bud slirp4netns
    just bud cniplugins
    just bud conmon
    just bud podman