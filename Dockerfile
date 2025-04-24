FROM ubuntu:24.04 AS builder

RUN sed -E -i '~s#http://(archive|security).ubuntu.com/ubuntu/#http://192.168.50.40:8081/repository/ubuntu/#g; ~s#http://ports.ubuntu.com/ubuntu-ports/#http://192.168.50.40:8081/repository/ubuntu-ports/#g; ' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get -y update && \
    apt-get install -y \
        libavutil-dev \
        libavformat-dev \
        libavcodec-dev \
        libmicrohttpd-dev \
        libjansson-dev \
        libssl-dev \
        libsofia-sip-ua-dev \
        libglib2.0-dev \
        libopus-dev \
        libogg-dev \
        libcurl4-openssl-dev \
        liblua5.3-dev \
        libconfig-dev \
        libusrsctp-dev \
        libwebsockets-dev \
        libnanomsg-dev \
        librabbitmq-dev \
        libpaho-mqtt-dev \
        libsrtp2-dev \
        pkg-config \
        gengetopt \
        libtool \
        automake \
        build-essential \
        wget \
        git \
        gtk-doc-tools \
        doxygen \
        graphviz \
        cmake \
        meson && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN --mount=type=bind,target=/work,source=. \
        if [ -d /work/libnice ]; then \
          cp -r /work/libnice /tmp/libnice; \
        else \
          cd /tmp && \
          git clone https://gitlab.freedesktop.org/libnice/libnice && \
          cd libnice && git checkout 0.1.22; \
        fi && \
        cd /tmp/libnice && \
        meson --prefix=/usr build && ninja -C build && ninja -C build install

WORKDIR /tmp

RUN --mount=type=bind,target=/work,source=. \
        if [ -d /work/janus-gateway ]; then \
          cp -r /work/janus-gateway /tmp/janus-gateway; \
        else \
          cd /tmp && \
          git clone https://github.com/meetecho/janus-gateway.git; \
        fi && \
        cd /tmp/janus-gateway && \
        sed -i -e '~s#https://janus.conf.meetecho.com/#/#g' docs/header.html && \
        sh autogen.sh && \
        ./configure --enable-post-processing --prefix=/usr/local --enable-docs --enable-mqtt --enable-plugin-lua && \
        make -j$(nproc) && \
        make install && \
        make configs

RUN mkdir /tmp/copy && \
    cp /usr/lib/$(gcc -print-multiarch)/libnice.so.10.14.0 /tmp/copy/ && \
    mkdir /tmp/copy/docs && cp -R $(find /usr/local/share/doc/janus-gateway/ -type d -name 'html')/* /tmp/copy/docs/


FROM ubuntu:24.04

ARG BUILD_DATE="undefined"
ARG GIT_BRANCH="undefined"
ARG GIT_COMMIT="undefined"
ARG VERSION="undefined"

LABEL build_date=${BUILD_DATE}
LABEL git_branch=${GIT_BRANCH}
LABEL git_commit=${GIT_COMMIT}
LABEL version=${VERSION}

RUN sed -E -i '~s#http://(archive|security).ubuntu.com/ubuntu/#http://192.168.50.40:8081/repository/ubuntu/#g; ~s#http://ports.ubuntu.com/ubuntu-ports/#http://192.168.50.40:8081/repository/ubuntu-ports/#g; ' /etc/apt/sources.list.d/ubuntu.sources


RUN apt-get -y update && \
    apt-get install -y \
        libmicrohttpd12 \
        libavutil-dev \
        libavformat-dev \
        libavcodec-dev \
        libjansson4 \
        libssl3t64 \
        libsofia-sip-ua0 \
        libpaho-mqtt1.3 \
        libglib2.0-0 \
        libopus0 \
        libogg0 \
        libcurl4 \
        liblua5.3-0 \
        lua-json lua-term \
        libconfig9 \
        libusrsctp2 \
        libwebsockets19t64 \
        libnanomsg5 \
        libsrtp2-1 \
        librabbitmq4 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


COPY --from=0 /tmp/copy /tmp/copy
RUN cp /tmp/copy/libnice.so.10.14.0 /usr/lib/$(gcc -print-multiarch)/libnice.so.10.14.0 && \
    ln -s /usr/lib/$(gcc -print-multiarch)/libnice.so.10.14.0 /usr/lib/$(gcc -print-multiarch)/libnice.so.10 && \
    ln -s /usr/lib/$(gcc -print-multiarch)/libnice.so.10.14.0 /usr/lib/$(gcc -print-multiarch)/libnice.so && \
    chmod -x /usr/lib/$(gcc -print-multiarch)/libnice.so.10.14.0 && \
    rm -rf /tmp/copy

COPY --from=0 /usr/local/bin/janus /usr/local/bin/janus
COPY --from=0 /usr/local/bin/janus-pp-rec /usr/local/bin/janus-pp-rec
COPY --from=0 /usr/local/bin/janus-cfgconv /usr/local/bin/janus-cfgconv
COPY --from=0 /usr/local/etc/janus /usr/local/etc/janus
COPY --from=0 /usr/local/lib/janus /usr/local/lib/janus
COPY --from=0 /usr/local/share/janus /usr/local/share/janus

ENV BUILD_DATE=${BUILD_DATE}
ENV GIT_BRANCH=${GIT_BRANCH}
ENV GIT_COMMIT=${GIT_COMMIT}
ENV VERSION=${VERSION}

EXPOSE 10000-10200/udp
EXPOSE 8188
EXPOSE 8088
EXPOSE 8089
EXPOSE 8889
EXPOSE 8000
EXPOSE 7088
EXPOSE 7089

CMD ["/usr/local/bin/janus"]
