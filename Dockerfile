FROM alpine:3 AS downloader

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}${TARGETVARIANT}"

WORKDIR /

RUN apk add --no-cache wget unzip

RUN wget https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && unzip pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && chmod +x /pocketbase

FROM alpine:3

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata curl

COPY --from=downloader /pocketbase /usr/local/bin/pocketbase
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8090

HEALTHCHECK \
  --interval=5s \
  --timeout=3s \
  --retries=3 \
  CMD sh -c 'curl -fsS "http://127.0.0.1:${PB_PORT:-8090}/api/health" >/dev/null || exit 1'

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
