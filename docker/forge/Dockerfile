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

RUN IMAGE_TARGETS="test" ./docker/build-common.sh

FROM debian:buster-20210816@sha256:e2fe52e17d649812bddcac07faf16f33542129a59b2c1c59b39a436754b7f146

RUN apt-get update && apt-get install -y libssl1.1 openssh-client wget && apt-get clean && rm -r /var/lib/apt/lists/*

RUN mkdir /dijets
COPY rust-toolchain /dijets/rust-toolchain
COPY scripts/dev_setup.sh /dijets/scripts/dev_setup.sh
RUN /dijets/scripts/dev_setup.sh -b -p -i kubectl -i helm -i git -i unzip -i awscli -i vault
ENV PATH "$PATH:/root/bin"

RUN mkdir /etc/forge
WORKDIR /etc/forge
COPY --from=builder /dijets/target/release/forge /usr/local/bin/forge
ENTRYPOINT ["forge"]
ARG BUILD_DATE
ARG GIT_REV
ARG GIT_UPSTREAM
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.vcs-ref=$GIT_REV
