# syntax=docker/dockerfile:1.0

## STAGE 1: Build the static binary
FROM alpine:edge AS build
ARG VERSION=main
RUN apk add --no-cache autoconf automake build-base git
RUN git clone --depth 1 --branch ${VERSION} https://github.com/dadyan4/tinyproxy
RUN set -x \
    && cd tinyproxy \
    && ./autogen.sh \
    && ./configure CFLAGS="-Os -s -static" \
        --enable-manpage_support \
        --enable-transparent \
        --enable-xtinyproxy \
        --prefix=/ \
    && make -j12
RUN mkdir /empty

## STAGE 2: Build the container proper
FROM scratch AS run
COPY --from=build /tinyproxy/src/tinyproxy /bin/
COPY --from=build /empty/ /etc/

# Start it as a server.
EXPOSE 8888/tcp
ENTRYPOINT [ "/bin/tinyproxy", "-d", \
    "-c", "/etc/tinyproxy.conf" ]
