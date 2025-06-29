# Global ARG declarations (available to the entire Dockerfile)
ARG PROJ=twp


# Stage 1: Base image.
FROM amazonlinux:2023.6.20241031.0 AS base

# Local ARG declarations
ARG PROJ

# Install the essential system packages.
RUN dnf install -y wget tar gzip python3-pip shadow-utils openssl

# Create a non-privileged user
RUN useradd -r -s /usr/sbin/nologin ${PROJ}

# Install Supervisor.
RUN python3 -m pip install supervisor

# Create necessary directories and set permissions
RUN set -x \
  && mkdir -p /opt/mysql/mysql8.4.3/{data,log,conf,system,schema} \
  && chown -R ${PROJ}:${PROJ} /opt/mysql


# Stage 2: Build stage.
FROM base AS build

# Install MySQL.
RUN set -x \
  && dnf install -y https://dev.mysql.com/get/mysql84-community-release-el9-1.noarch.rpm \
  && dnf install -y mysql-community-server


# Stage 3: Development image
FROM build AS dev

# Install the system packages required for debugging.
RUN dnf install -y less procps net-tools iputils bind-utils vim-minimal

# Set default work directory.
WORKDIR /opt/mysql
