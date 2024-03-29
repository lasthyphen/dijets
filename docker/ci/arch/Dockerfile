# while using circle we'll use circle's base image.
FROM archlinux:base-devel-20210815.0.31571@sha256:4423b3d76fc91172bf77a429c5a2f872c2767786dfde0d4a82fd4446e8d2002a AS setup_ci_arch

WORKDIR /dijets
COPY rust-toolchain /dijets/rust-toolchain
COPY scripts/dev_setup.sh /dijets/scripts/dev_setup.sh

# WORKAROUND for glibc 2.33 and old Docker
# See https://github.com/actions/virtual-environments/issues/2658
# Thanks to https://github.com/lxqt/lxqt-panel/pull/1562
RUN patched_glibc=glibc-linux4-2.33-4-x86_64.pkg.tar.zst && \
    curl -LO "https://repo.archlinuxcn.org/x86_64/$patched_glibc" && \
    bsdtar -C / -xvf "$patched_glibc"

# Batch mode and all operations tooling
RUN scripts/dev_setup.sh -t -o -y -b -p && pacman -Scc --noconfirm
ENV PATH "/root/.cargo/bin:/root/bin/:$PATH"

FROM setup_ci_arch as tested_ci_arch

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
    && [ -x "$(command -v xsltproc)" ]
# These should eventually be installed and tested, but since we don't automate on arch, low pri.
# && [ -x "$(command -v javac)" ] \
# && [ -x "$(command -v clang)" ] \
# && [ -x "$(command -v python3)" ] \
# && [ -x "$(command -v go)" ] \
# && [ -x "$(command -v npm)" ]

# should be a no-op
RUN scripts/dev_setup.sh -t -o -y -b -p

FROM setup_ci_arch as build_environment_arch
