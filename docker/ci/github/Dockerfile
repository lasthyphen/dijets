FROM debian:buster-20210816@sha256:e2fe52e17d649812bddcac07faf16f33542129a59b2c1c59b39a436754b7f146 AS setup_ci

RUN mkdir /dijets
COPY rust-toolchain /dijets/rust-toolchain
COPY scripts/dev_setup.sh /dijets/scripts/dev_setup.sh

#this is the default home on docker images in gha, until it's not?
ENV HOME "/github/home"
#Needed for sccache to function
ENV CARGO_HOME "/opt/cargo/"

# Batch mode and all operations tooling
RUN mkdir -p /github/home \
    && mkdir -p /opt/cargo/ \
    && mkdir -p /opt/git/ \
    && /dijets/scripts/dev_setup.sh -t -o -b -p -y -s\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH "/opt/cargo/bin:/usr/lib/golang/bin:/github/home/bin:$PATH"
ENV DOTNET_ROOT "/github/home/.dotnet"
ENV Z3_EXE "/github/home/bin/z3"
ENV CVC4_EXE "/github/home/bin/cvc4"
ENV BOOGIE_EXE "/github/home/.dotnet/tools/boogie"

FROM setup_ci as tested_ci

# Compile a small rust tool?  But we already have in dev_setup (sccache/grcov)...?
# Test that all commands we need are installed and on the PATH
RUN [ -x "$(command -v shellcheck)" ] \
    && [ -x "$(command -v hadolint)" ] \
    && [ -x "$(command -v vault)" ] \
    && [ -x "$(command -v terraform)" ] \
    && [ -x "$(command -v kubectl)" ] \
    && [ -x "$(command -v rustup)" ] \
    && [ -x "$(command -v cargo)" ] \
    && [ -x "$(command -v cargo-guppy)" ] \
    && [ -x "$(command -v sccache)" ] \
    && [ -x "$(command -v grcov)" ] \
    && [ -x "$(command -v helm)" ] \
    && [ -x "$(command -v aws)" ] \
    && [ -x "$(command -v z3)" ] \
    && [ -x "$(command -v "$HOME/.dotnet/tools/boogie")" ] \
    && [ -x "$(xargs rustup which cargo --toolchain < /dijets/rust-toolchain )" ] \
    && [ -x "$(command -v tidy)" ] \
    && [ -x "$(command -v xsltproc)" ] \
    && [ -x "$(command -v javac)" ] \
    && [ -x "$(command -v clang)" ] \
    && [ -x "$(command -v python3)" ] \
    && [ -x "$(command -v go)" ] \
    && [ -x "$(command -v npm)" ]

# should be a no-op
# sccache builds fine, but is not executable ??? in alpine, ends up being recompiled.  Wierd.
RUN /dijets/scripts/dev_setup.sh -t -o -y -b -p -s

FROM setup_ci as build_environment
