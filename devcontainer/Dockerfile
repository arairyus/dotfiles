#syntax=docker/dockerfile:1

FROM mcr.microsoft.com/devcontainers/base:debian
ARG WORKUSER=vscode

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN <<EOS
mkdir -m 0755 /nix
chown "${WORKUSER}:${WORKUSER}" /nix
EOS

USER ${WORKUSER}
ENV PATH=/home/${WORKUSER}/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin

# Install Nix
RUN <<EOS
curl -fsSL https://nixos.org/nix/install | bash -s -- --no-daemon
. ~/.nix-profile/etc/profile.d/nix.sh
nix-channel --update
EOS

# Copy dotfiles for testing
COPY --chown=${WORKUSER}:${WORKUSER} . /var/dotfiles

WORKDIR /var/dotfiles

CMD ["bash", "--login"]
