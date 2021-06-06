# First stage - compile
FROM ubuntu:20.04 as builder

# Namecoin
ARG VERSION="0.21"
ARG GITREPO="https://github.com/namecoin/namecoin-core.git"
ARG GITNAME="namecoin-core"
ARG COMPILEFLAGS="--enable-cxx --disable-shared --with-pic --disable-wallet --without-gui --without-miniupnpc"

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Australia/Melbourne"

RUN \
    echo "** update and install packages **" \
    && apt update \
    && apt install -y \
    autoconf \
    automake \
    binutils \
    bison \
    bsdmainutils \
    ca-certificates \
    curl \
    g++-8 \
    gcc-8 \
    git \
    libtool \
    libboost-all-dev \
    libssl-dev \
    libevent-dev \
    patch \
    pkg-config \
    python3 \
    python3-pip \
    && echo "** cleanup **" \
    && rm -rvf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Get the source from Github
WORKDIR /root
RUN git clone ${GITREPO}

# Checkout the right version, compile, and grab
WORKDIR /root/${GITNAME}
RUN \
    echo "** checkout and compile **" \
    && git checkout ${VERSION} \
	&& ./autogen.sh \
	&& ./configure ${COMPILEFLAGS} \
	&& make \
    && mkdir /install \
    && make install DESTDIR=/install \
    && echo "** removing extra lib files **" \
    && find /install -name "lib*.la" -delete \
    && find /install -name "lib*.a" -delete

# Last stage
FROM ubuntu:20.04
LABEL maintainer="Michael J. McKinnon <mjmckinnon@gmail.com>"

# Copy from first stage /install -> /
COPY --from=builder /install /

# Put our entrypoint script in
COPY ./docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

ENV DEBIAN_FRONTEND="noninteractive"
RUN \
    echo "** update and setup ** " \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    gosu \
    libboost-filesystem-dev \
    libboost-thread-dev \
    libevent-dev \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && chmod +x /usr/local/bin/docker-entrypoint.sh \
    && groupadd -g 1000 namecoin \
    && useradd -u 1000 -g namecoin namecoin


ENV DATADIR="/data"
EXPOSE 8334
VOLUME /data
CMD ["namecoind", "-printtoconsole", "-server=1"]