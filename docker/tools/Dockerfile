FROM debian:buster-20210816@sha256:e2fe52e17d649812bddcac07faf16f33542129a59b2c1c59b39a436754b7f146 AS toolchain

# To use http/https proxy while building, use:
# docker build --build-arg https_proxy=http://fwdproxy:8080 --build-arg http_proxy=http://fwdproxy:8080

RUN apt-get update && apt-get install -y cmake curl clang git pkg-config libssl-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none
ENV PATH "$PATH:/root/.cargo/bin"

WORKDIR /dijets
COPY rust-toolchain /dijets/rust-toolchain
RUN rustup install $(cat rust-toolchain)

FROM toolchain AS builder

ARG ENABLE_FAILPOINTS
COPY . /dijets

RUN IMAGE_TARGETS="release" ./docker/build-common.sh

### Production Image ###
FROM debian:buster-20210816@sha256:e2fe52e17d649812bddcac07faf16f33542129a59b2c1c59b39a436754b7f146 AS prod

RUN echo "deb http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list.d/bullseye.list && \
    echo "Package: *\nPin: release n=bullseye\nPin-Priority: 50" > /etc/apt/preferences.d/bullseye

RUN apt-get update && \
    apt-get --no-install-recommends --yes install wget curl libssl1.1 ca-certificates socat python3-botocore/bullseye awscli/bullseye && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/local/bin/python
COPY docker/tools/boto.cfg /etc

RUN cd /usr/local/bin && wget https://azcopyvnext.azureedge.net/release20210226/azcopy_linux_amd64_10.9.0.tar.gz -O- | tar --gzip --wildcards --extract '*/azcopy' --strip-components=1 --no-same-owner && chmod +x azcopy
RUN wget https://storage.googleapis.com/pub/gsutil.tar.gz -O- | tar --gzip --directory /opt --extract && ln -s /opt/gsutil/gsutil /usr/local/bin

COPY --from=builder /dijets/target/release/dijets-genesis-tool /usr/local/bin
COPY --from=builder /dijets/target/release/dijets-operational-tool /usr/local/bin
COPY --from=builder /dijets/target/release/db-bootstrapper /usr/local/bin
COPY --from=builder /dijets/target/release/db-backup /usr/local/bin
COPY --from=builder /dijets/target/release/db-backup-verify /usr/local/bin
COPY --from=builder /dijets/target/release/db-restore /usr/local/bin
COPY --from=builder /dijets/target/release/dijets-transaction-replay /usr/local/bin
COPY --from=builder /dijets/target/release/dijets-writeset-generator /usr/local/bin

### Get Move modules bytecodes for genesis ceremony
RUN mkdir -p /dijets/move
COPY --from=builder /dijets/language/dijets-framework/releases/artifacts/current /dijets/move

ARG BUILD_DATE
ARG GIT_REV
ARG GIT_UPSTREAM

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$GIT_REV
