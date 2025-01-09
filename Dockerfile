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
                libsrtp2-dev \
		pkg-config \
		gengetopt \
		libtool \
		automake \
		build-essential \
		wget \
		git \
		gtk-doc-tools \
                cmake \
                meson && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*



RUN cd /tmp && \
	git clone https://gitlab.freedesktop.org/libnice/libnice && \
	cd libnice && \
	git checkout 0.1.22 && \
        meson --prefix=/usr build && ninja -C build && ninja -C build install


RUN cd /tmp && \
        git clone https://github.com/meetecho/janus-gateway.git && \
        cd janus-gateway && \
	sh autogen.sh && \
	./configure --enable-post-processing --prefix=/usr/local && \
	make && \
	make install && \
	make configs

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
		libglib2.0-0 \
		libopus0 \
		libogg0 \
		libcurl4 \
		liblua5.3-0 \
		libconfig9 \
		libusrsctp2 \
		libwebsockets19t64 \
		libnanomsg5 \
                libsrtp2-1 \
		librabbitmq4 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*


#COPY --from=0 /usr/lib/libnice.la /usr/lib/libnice.la
COPY --from=0 /usr/lib/x86_64-linux-gnu/libnice.so.10.14.0 /usr/lib/x86_64-linux-gnu/libnice.so.10.14.0
RUN ln -s /usr/lib/x86_64-linux-gnu/libnice.so.10.14.0 /usr/lib/libnice.so.10
RUN ln -s /usr/lib/x86_64-linux-gnu/libnice.so.10.14.0 /usr/lib/libnice.so

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
