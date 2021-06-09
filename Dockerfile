FROM ubuntu:20.04
LABEL maintainer="Michael J. McKinnon <mjmckinnon@gmail.com>"

# Put our entrypoint script in
COPY ./docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Add the dist-files
ADD ./0.21.1/dist-files /

ENV DEBIAN_FRONTEND="noninteractive"
RUN \
    echo "** update and install dependencies ** " \
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