# syntax=docker/dockerfile:1

ARG PG_VERSION=15
FROM postgres:${PG_VERSION}

# Install build dependencies for PostgreSQL version
RUN MAJOR_VER=$(echo ${PG_VERSION} | cut -d. -f1) && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libpq-dev \
        postgresql-server-dev-${MAJOR_VER} && \
    rm -rf /var/lib/apt/lists/*

# Build pgvector from source
RUN git clone -b v0.7.1 https://github.com/ankane/pgvector.git /tmp/pgvector && \
    cd /tmp/pgvector && \
    make && make install && \
    cd / && rm -rf /tmp/pgvector

# Build pg_bigm from local source
COPY . /pg_bigm
RUN cd /pg_bigm && \
    make && make install && \
    cd / && rm -rf /pg_bigm

# Clean up build tools
RUN apt-get purge -y build-essential && \
    apt-get autoremove -y