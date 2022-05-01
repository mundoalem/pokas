FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu-21.04

# #####################################################################################################################
# ARGUMENTS
# #####################################################################################################################

# Defaults
ARG DEFAULT_LOCALE="en_US.UTF-8"

# Versions
ARG USE_DELTA_VERSION="0.12.1"
ARG USE_GOLANG_VERSION="1.18.1"

# #####################################################################################################################
# ENVIRONMENT VARIABLES
# #####################################################################################################################

# General
ENV DEBIAN_FRONTEND="noninteractive"

# Localization
ENV LC_ALL=$DEFAULT_LOCALE

# #####################################################################################################################
# BASE SETUP
# #####################################################################################################################

# Install dependencies
RUN apt-get update \
    && apt-get -y install --no-install-recommends \
        build-essential \
        git \
        git-extras \
        gpg-agent \
        locales \
        software-properties-common \
    && apt-get autoremove -y \
    && apt-get clean autoclean -y \
    && rm -r /var/cache/* /var/lib/apt/lists/*

# Set locale
RUN locale-gen $DEFAULT_LOCALE \
    && update-locale LANG=$DEFAULT_LOCALE

# Install git-delta
RUN if [ "$(uname -m)" = "aarch64" ]; then ARCH="arm64"; else ARCH="amd64"; fi \
    && wget -O /tmp/git-delta.deb https://github.com/dandavison/delta/releases/download/${USE_DELTA_VERSION}/git-delta_${USE_DELTA_VERSION}_${ARCH}.deb \
    && dpkg -i /tmp/git-delta.deb \
    && rm -f /tmp/git-delta.deb

# #####################################################################################################################
# USER SETUP
# #####################################################################################################################

USER vscode

ENV HOME="/home/vscode"
ENV GOENV_ROOT="$HOME/.goenv"
ENV GOROOT="$GOENV_ROOT/versions/$GOLANG_VERSION"
ENV GOPATH="$HOME/go/$GOLANG_VERSION"
ENV PATH="$GOENV_ROOT/bin:$HOME/.local/bin:$PATH"

WORKDIR $HOME

# Install go and its ecosystem utilities required by vscode extensions
RUN git clone https://github.com/syndbg/goenv.git $HOME/.goenv \
    && eval "$(goenv init -)" \
    && goenv install $USE_GOLANG_VERSION \
    && goenv rehash \
    && goenv global $USE_GOLANG_VERSION \
    && go install golang.org/x/tools/gopls@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install github.com/uudashr/gopkgs/cmd/gopkgs@v2 \
    && go install github.com/ramya-rao-a/go-outline@latest \
    && go install github.com/fatih/gomodifytags@latest \
    && go install github.com/josharian/impl@latest \
    && go install github.com/securego/gosec/v2/cmd/gosec@latest \
    && go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.45.2 \
    && go install mvdan.cc/gofumpt@latest

# Setup user's bash
RUN mkdir $HOME/.history \
    && touch $HOME/.history/.bash_history \
    && chown -R vscode $HOME/.history \
    && echo "export PROMPT_COMMAND='history -a'" >> $HOME/.bashrc \
    && echo "export HISTFILE=$HOME/.history/.bash_history" >> $HOME/.bashrc \
    && echo "eval \"\$($GOENV_ROOT/bin/goenv init -)\"" >> $HOME/.bashrc
