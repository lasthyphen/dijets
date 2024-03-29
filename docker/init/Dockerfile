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
FROM debian:buster-20210816@sha256:e2fe52e17d649812bddcac07faf16f33542129a59b2c1c59b39a436754b7f146  AS pre-prod

RUN apt-get update && apt-get -y install libssl1.1 wget busybox gettext-base && apt-get clean && rm -r /var/lib/apt/lists/*
RUN cd /usr/local/bin && wget "https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kubectl" -O kubectl && chmod +x kubectl
RUN cd /usr/local/bin && wget "https://releases.hashicorp.com/vault/1.5.0/vault_1.5.0_linux_amd64.zip" -O- | busybox unzip - && chmod +x vault

RUN mkdir -p /opt/dijets/bin
COPY --from=builder /dijets/target/release/dijets-genesis-tool /usr/local/bin
COPY --from=builder /dijets/target/release/dijets-operational-tool /usr/local/bin

### Get Move modules bytecodes for genesis ceremony
RUN mkdir -p /dijets/move
COPY --from=builder /dijets/language/dijets-framework/releases/artifacts/current /dijets/move

FROM pre-prod as testing

RUN /usr/local/bin/dijets-genesis-tool -h
RUN /usr/local/bin/dijets-operational-tool -h

FROM pre-prod as prod

ARG BUILD_DATE
ARG GIT_REV
ARG GIT_UPSTREAM

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$GIT_REV
