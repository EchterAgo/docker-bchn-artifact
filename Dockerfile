FROM debian:stable-slim
LABEL maintainer="Axel Gembe <derago@gmail.com>"

ENV BCHN_REPO=https://gitlab.com/bitcoin-cash-node/bitcoin-cash-node
ENV BCHN_JOB_ID=845628966
ENV BCHN_ARTIFACT_URL=${BCHN_REPO}/-/jobs/${BCHN_JOB_ID}/artifacts
ENV INSTALL_DIR=/opt/bitcoin-cash-node-${BCHN_JOB_ID}
ENV BITCOIN_DATA=/data
ENV PATH=${INSTALL_DIR}/bin:$PATH

RUN set -ex && \
    apt-get update -y && \
    apt-get install -y curl binutils libjemalloc2 libevent-2.1 libevent-pthreads-2.1 libminiupnpc17 \
        libzmq5 libboost-filesystem1.67.0 libboost-thread1.67.0 libboost-chrono1.67.0 \
        libboost-date-time1.67.0 libdb5.3++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p "$INSTALL_DIR/bin" && \
    curl -SL -o "$INSTALL_DIR/bin/bitcoin-cli" "${BCHN_ARTIFACT_URL}/raw/build/src/bitcoin-cli" && \
    curl -SL -o "$INSTALL_DIR/bin/bitcoind" "${BCHN_ARTIFACT_URL}/raw/build/src/bitcoind" && \
    curl -SL -o "$INSTALL_DIR/bin/bitcoin-tx" "${BCHN_ARTIFACT_URL}/raw/build/src/bitcoin-tx" && \
    chmod a+x "$INSTALL_DIR/bin"/* && \
    strip "$INSTALL_DIR/bin"/* && \
    apt-get remove -y curl binutils && \
    apt-get autoremove -y

VOLUME ["/data"]
RUN ln -s /data /.bitcoin

EXPOSE 8332 8333 18332 18333 18443 18444 28332 28333 38332 38333

ENV LD_PRELOAD /usr/lib/x86_64-linux-gnu/libjemalloc.so.2

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["bitcoind"]
