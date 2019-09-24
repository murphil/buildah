FROM nnurphy/buildah:runc as runc
FROM nnurphy/buildah:podman as podman
FROM nnurphy/buildah:conmon as conmon
FROM nnurphy/buildah:cniplugins as cniplugins
FROM nnurphy/buildah:skopeo as skopeo
FROM nnurphy/buildah:fuse-overlayfs as fuse-overlayfs
FROM nnurphy/buildah:slirp4netns as slirp4netns
FROM nnurphy/buildah:buildah as buildah

FROM alpine:3.10
# Add gosu for easy step-down from root
ARG GOSU_VERSION=1.11
RUN set -eux; \
	wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64"; \
	chmod +x /usr/local/bin/gosu; \
	gosu nobody true
# Install iptables & new-uidmap
RUN set -eux; \
	sed -i 's/dl-cdn.alpinelinux.org/mirror.tuna.tsinghua.edu.cn/g' /etc/apk/repositories; \
	apk add --no-cache ca-certificates iptables ip6tables shadow-uidmap
# Copy binaries from other images
COPY --from=runc   /usr/local/bin/runc   /usr/local/bin/runc
COPY --from=podman /usr/local/bin/podman /usr/local/bin/podman
COPY --from=conmon /usr/libexec/podman/conmon /usr/libexec/podman/conmon
COPY --from=cniplugins /usr/libexec/cni /usr/libexec/cni
COPY --from=skopeo /usr/local/bin/skopeo /usr/local/bin/skopeo
COPY --from=fuse-overlayfs /usr/bin/fuse-overlayfs /usr/local/bin/fuse-overlayfs
COPY --from=slirp4netns /slirp4netns/slirp4netns /usr/local/bin/slirp4netns
COPY --from=buildah /usr/local/bin/buildah /usr/local/bin/buildah
RUN set -eux; \
	adduser -D podman -h /podman -u 9000; \
	echo 'podman:900000:65536' > /etc/subuid; \
	echo 'podman:900000:65536' > /etc/subgid; \
	ln -s /usr/local/bin/podman /usr/bin/docker; \
	mkdir -pm 775 /etc/containers /podman/.config/containers /etc/cni/net.d /podman/.local/share/containers/storage/libpod; \
	chown -R root:podman /podman; \
	wget -O /etc/containers/registries.conf https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora; \
	wget -O /etc/containers/policy.json     https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json; \
	wget -O /etc/cni/net.d/99-bridge.conflist https://raw.githubusercontent.com/containers/libpod/master/cni/87-podman-bridge.conflist; \
	runc --help >/dev/null; \
	podman --help >/dev/null; \
	/usr/libexec/podman/conmon --help >/dev/null; \
	slirp4netns --help >/dev/null; \
	fuse-overlayfs --help >/dev/null;
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
VOLUME /podman/.local/share/containers/storage
WORKDIR /podman
ENV HOME=/podman