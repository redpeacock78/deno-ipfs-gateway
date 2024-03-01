FROM gcr.io/distroless/cc as cc

FROM alpine:latest AS kubo

ARG TARGETPLATFORM
ARG version="v0.26.0"

WORKDIR /app

RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
  PLATFORM="amd64";\
  elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
  PLATFORM="arm64";\
  fi && \
  apk add --no-cache aria2 tar && \
  aria2c -s20 -j20 -x16 -k20M https://dist.ipfs.tech/kubo/v0.26.0/kubo_${version}_linux-${PLATFORM}.tar.gz && \
  tar zxvf kubo_${version}_linux-${PLATFORM}.tar.gz

FROM denoland/deno:alpine-1.41.0 AS deno

WORKDIR /app

COPY ./ /app/

RUN deno compile -A -o proxy_app main.ts

FROM alpine:latest

WORKDIR /app

COPY --from=cc --chown=root:root --chmod=755 /lib/*-linux-gnu/* /usr/local/lib/
COPY --from=cc --chown=root:root --chmod=755 /lib/ld-linux-* /lib/
COPY --from=kubo /app/kubo/ipfs /usr/local/bin/ipfs
COPY --from=deno /app/proxy_app /app/proxy_app
COPY ./entrypoint.sh /app/

RUN mkdir /lib64 \
  && ln -s /usr/local/lib/ld-linux-* /lib64/ && \
  apk add --no-cache curl && \
  chmod +x /app/entrypoint.sh

ENV LD_LIBRARY_PATH="/usr/local/lib"

ENTRYPOINT ["/app/entrypoint.sh"]
