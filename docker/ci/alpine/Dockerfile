# while using circle we'll use circle's base image.
FROM alpine:3.14.1@sha256:eb3e4e175ba6d212ba1d6e04fc0782916c08e1c9d7b45892e9796141b1d379ae AS setup_ci_alpine

WORKDIR /dijets
COPY rust-toolchain /dijets/rust-toolchain
COPY scripts/dev_setup.sh /dijets/scripts/dev_setup.sh

RUN apk add bash=5.1.4-r0 --no-cache

# Batch mode and all operations tooling
RUN scripts/dev_setup.sh -t -o -y -b -p -s
ENV PATH "/root/.cargo/bin:/root/bin/:$PATH"

FROM setup_ci_alpine as tested_ci_alpine

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
    && [ -x "$(command -v tidy)" ] \
    && [ -x "$(command -v xsltproc)" ] \
    && [ -x "$(command -v "$HOME/.dotnet/tools/boogie")" ] \
    && [ -x "$(xargs rustup which cargo --toolchain < /dijets/rust-toolchain )" ] \
    && [ -x "$(command -v tidy)" ] \
    && [ -x "$(command -v xsltproc)" ] \
    && [ -x "$(command -v javac)" ] \
    && [ -x "$(command -v clang)" ] \
    && [ -x "$(command -v python3)" ] \
    && [ -x "$(command -v go)" ] \
    && [ -x "$(command -v npm)" ]

# should be a no-op, but since sccache failes to execute, sccache is rebuilt.
RUN scripts/dev_setup.sh -t -o -y -b -p -s

FROM setup_ci_alpine as build_environment_alpine
