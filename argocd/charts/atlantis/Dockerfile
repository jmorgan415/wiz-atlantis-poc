FROM runatlantis/atlantis:v0.18.4

RUN apk add --no-cache \
        python3 \
        py3-pip \
        jq \
    && pip3 install --upgrade pip \
    && pip3 install \
        awscli \
    && rm -rf /var/cache/apk/*

RUN chown -R atlantis:atlantis /usr/local/bin/atlantis
