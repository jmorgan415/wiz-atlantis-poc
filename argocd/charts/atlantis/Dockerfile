FROM --platform=linux/amd64 ghcr.io/runatlantis/atlantis:v0.19.9

RUN apk add --no-cache \
        python3 \
        py3-pip \
        jq \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*
