# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.17 as buildstage

ARG MOD_VERSION

RUN echo "**** grab transmission-web-control ****"
RUN mkdir -p /root-layer/themes
RUN \
  if [ -z ${MOD_VERSION+x} ]; then \
    MOD_VERSION=$(curl -s "https://api.github.com/repos/ronggang/transmission-web-control/releases/latest" \
    | jq -rc ".tag_name"); \
  fi
RUN echo "${MOD_VERSION}"
RUN curl -o /tmp/transmission-web-control.tar.gz -L \
    "https://github.com/ronggang/transmission-web-control/archive/refs/tags/${MOD_VERSION}.tar.gz"
RUN ls -lh /tmp/transmission-web-control.tar.gz
RUN mkdir -p /root-layer/themes/transmission-web-control
RUN \
  tar xzf \
    /tmp/transmission-web-control.tar.gz -C \
    /root-layer/themes/transmission-web-control --wildcards "*/src" --strip-components=2

# copy local files
COPY root/ /root-layer/

# ## Single layer deployed image ##
FROM scratch

LABEL maintainer="FujiZ"

# # Add files from buildstage
COPY --from=buildstage /root-layer/ /
