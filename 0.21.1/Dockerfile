FROM mjmckinnon/ubuntubuild

# Namecoin
ENV VERSION="nc0.21.1" \
    GITREPO="https://github.com/namecoin/namecoin-core.git" \
    GITNAME="namecoin-core" \
    COMPILEFLAGS="--disable-tests --disable-bench --enable-cxx --disable-shared --with-pic --disable-wallet --without-gui --without-miniupnpc" \
    DEBIAN_FRONTEND="noninteractive" \
    TZ="Australia/Melbourne"

# Get the source from Github
WORKDIR /root
RUN \
    echo "** fetch source code **" \
    && git clone ${GITREPO}

# Checkout the right version, compile, and grab
WORKDIR /root/${GITNAME}
RUN \
    echo "** checkout and compile **" \
    && git checkout ${VERSION} \
    && ./autogen.sh \
    && ./configure CXX=clang++ CC=clang CXXFLAG="-O2" ${COMPILEFLAGS} \
    && make \
    && mkdir -p /dist-files \
    && make install DESTDIR=/dist-files \
    && echo "** removing extra lib files **" \
    && find /dist-files -name "lib*.la" -delete \
    && find /dist-files -name "lib*.a" -delete
