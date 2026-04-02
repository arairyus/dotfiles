#syntax=docker/dockerfile:1

FROM mcr.microsoft.com/devcontainers/base:debian
ARG WORKUSER=vscode

RUN mkdir -m 0755 /nix && chown "${WORKUSER}:${WORKUSER}" /nix

USER ${WORKUSER}
ENV PATH=/home/${WORKUSER}/.nix-profile/bin:/usr/local/bin:/usr/bin:/bin

# Install Nix
RUN curl -fsSL https://nixos.org/nix/install | bash -s -- --no-daemon \
    && . ~/.nix-profile/etc/profile.d/nix.sh \
    && nix-channel --update

COPY --chown=${WORKUSER}:${WORKUSER} . /var/dotfiles
WORKDIR /var/dotfiles

# Build home-manager config
ENV USER=vscode
RUN . ~/.nix-profile/etc/profile.d/nix.sh \
    && mkdir -p ~/.config/nix \
    && echo 'experimental-features = nix-command flakes' > ~/.config/nix/nix.conf \
    && nix run home-manager -- switch --flake .#devcontainer -b bak \
    && nix store gc

WORKDIR /home/${WORKUSER}
CMD ["bash", "--login"]
