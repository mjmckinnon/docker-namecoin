FROM mjmckinnon/ubuntubuild as builder

# Namecoin
ENV VERSION="nc0.21.1" \
    GITREPO="https://github.com/namecoin/namecoin-core.git" \
    GITNAME="namecoin-core" \
    COMPILEFLAGS="--disable-tests --disable-bench --enable-cxx --disable-shared --with-pic --disable-wallet --without-gui --without-miniupnpc" \
    DEBIAN_FRONTEND="noninteractive"

# Get the source from Github
WORKDIR /root
# Checkout the right version, compile, and grab
RUN \
    echo "** checkout and compile **" \
    && git clone ${GITREPO} \
    && cd /root/${GITNAME} \
    && git checkout ${VERSION} \
    && ./autogen.sh \
    && ./configure CXXFLAG="-O2" LDFLAGS=-static-libstdc++ ${COMPILEFLAGS} \
    && make \
    && echo "** install and strip the binaries **" \
    && mkdir -p /dist-files \
    && make install DESTDIR=/dist-files \
    && strip /dist-files/usr/local/bin/* \
    && echo "** removing extra lib files **" \
    && find /dist-files -name "lib*.la" -delete \
    && find /dist-files -name "lib*.a" -delete \
    && cd .. && rm -rf ${GITREPO}

FROM ubuntu:20.04
LABEL maintainer="Michael J. McKinnon <mjmckinnon@gmail.com>"

# Put our entrypoint script in
COPY ./docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Copy the compiled files
COPY --from=builder /dist-files/ /

RUN \
    echo "** setup the namecoin user **" \
    && groupadd -g 1000 namecoin \
    && useradd -u 1000 -g namecoin namecoin

ENV DEBIAN_FRONTEND="noninteractive"
RUN \
    echo "** update and install dependencies ** " \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
    gosu \
    libboost-filesystem1.71.0 \
    libboost-thread1.71.0 \
    libevent-2.1-7 \
    libevent-pthreads-2.1-7 \
    libczmq4 \
    && apt-get clean autoclean \
    && apt-get autoremove --yes \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/ \
    && rm -rf /tmp/* /var/tmp/*

ENV DATADIR="/data"
EXPOSE 8334
VOLUME /data
CMD ["namecoind", "-printtoconsole"]