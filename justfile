run:
    docker run --privileged --rm -it buildah/buildah sh


hello:
    docker run --privileged buildah/buildah docker run alpine:3.9 echo hello from nested podman container
