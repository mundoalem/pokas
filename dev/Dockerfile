# ######################################################################################################################
# LICENSE
# ######################################################################################################################

#
# This file is part of pokas.
#
# The pokas is free software: you can redistribute it and/or modify it under the terms of the GNU Affero
# General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your
# option) any later version.
#
# The pokas is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
# implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU Affero General Public License along with pokas. If not, see
# <https://www.gnu.org/licenses/>.
#

# ######################################################################################################################
# PRELUDE
# ######################################################################################################################

#
# CHECKOV
#

# This is a container intended to be used as a remote development environment, we want to allow the user the ability to
# become root
#checkov:skip=CKV2_DOCKER_1:Ensure that sudo isn't used
#checkov:skip=CKV_DOCKER_7:Ensure the base image uses a non latest version tag

# ----------------------------------------------------------------------------------------------------------------------
# BASE IMAGE
# ----------------------------------------------------------------------------------------------------------------------

FROM mundoalem/dev-base:latest

# ----------------------------------------------------------------------------------------------------------------------
# ARGUMENTS
# ----------------------------------------------------------------------------------------------------------------------

#
# DOCKER BUILDKIT
#

ARG BUILDARCH
ARG BUILDOS
ARG BUILDPLATFORM
ARG TARGETARCH
ARG TARGETOS
ARG TARGETPLATFORM

#
# PROJECT
#

ARG PROJECT_BUILD_DATE
ARG PROJECT_COMMIT
ARG PROJECT_VERSION

# ######################################################################################################################
# SETUP: BASE
# ######################################################################################################################

SHELL [ "/bin/bash", "-o", "pipefail", "-c" ]

USER root

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL SYSTEM PACKAGES
# ----------------------------------------------------------------------------------------------------------------------

RUN export DEBIAN_FRONTEND="noninteractive" \
    && apt-get update \
    && apt-get -y install --no-install-recommends \
    build-essential \
    clang \
    && apt-get autoremove -y \
    && apt-get clean autoclean -y \
    && rm -r /var/cache/* /var/lib/apt/lists/*

# ######################################################################################################################
# SETUP: CUSTOM (AS DEV USER)
# ######################################################################################################################

USER dev

#
# ENV
#

ENV HOME="/home/dev"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL GOENV
# ----------------------------------------------------------------------------------------------------------------------

#
# ENV
#

ENV GOENV_ROOT="${HOME}/.goenv"
ENV PATH="${GOENV_ROOT}/bin:${PATH}"

#
# INSTALL
#

RUN git clone https://github.com/go-nv/goenv.git "${HOME}/.goenv" \
    && echo "eval \"\$(goenv init -)\"" >> "${HOME}/.bashrc" \
    && echo "export PATH=\"\$GOPATH/bin:\$GOROOT/bin:\$PATH\"" >> "${HOME}/.bashrc"

# ----------------------------------------------------------------------------------------------------------------------
# INSTALL GOLANG
# ----------------------------------------------------------------------------------------------------------------------

COPY .go-version "${HOME}/.goenv/version"

RUN eval "$(goenv init -)" \
    && export PATH="$GOPATH/bin:$GOROOT/bin:$PATH" \
    && cat "${HOME}/.goenv/version" | xargs goenv install --skip-existing

#
# INSTALL PACKAGES
#

RUN eval "$(goenv init -)" \
    && export PATH="$GOPATH/bin:$GOROOT/bin:$PATH" \
    && go install github.com/cweill/gotests/...@latest \
    && go install github.com/fatih/gomodifytags@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install github.com/haya14busa/goplay/cmd/goplay@latest \
    && go install github.com/josharian/impl@latest \
    && go install github.com/securego/gosec/v2/cmd/gosec@latest \
    && go install golang.org/x/tools/gopls@latest \
    && go install honnef.co/go/tools/cmd/staticcheck@2022.1

# ######################################################################################################################
# RUN
# ######################################################################################################################

#
# Empty
#

# ----------------------------------------------------------------------------------------------------------------------
# HEALTHCHECK
# ----------------------------------------------------------------------------------------------------------------------

HEALTHCHECK NONE

# ----------------------------------------------------------------------------------------------------------------------
# ENTRYPOINT
# ----------------------------------------------------------------------------------------------------------------------

ENTRYPOINT [ ]

# ----------------------------------------------------------------------------------------------------------------------
# COMMAND
# ----------------------------------------------------------------------------------------------------------------------

CMD [ ]
