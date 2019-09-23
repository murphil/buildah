run:
    docker run --privileged --rm -it buildah/buildah sh

build:
    docker build . -t buildah

hello:
    docker run --privileged buildah/buildah docker run alpine:3.9 echo hello from nested podman container
