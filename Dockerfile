FROM amd64/alpine:latest AS kubo_builder

ARG BUILDARCH
ARG version="v0.26.0"

WORKDIR /app

RUN apk add --no-cache aria2 tar && \
  aria2c -s20 -j20 -x16 -k20M https://dist.ipfs.tech/kubo/v0.26.0/kubo_${version}_linux-${BUILDARCH}.tar.gz && \
  tar zxvf kubo_v0.26.0_linux-amd64.tar.gz

FROM denoland/deno:alpine AS deno_builder

WORKDIR /app

COPY ./main.ts /app/

RUN deno compile -A -o proxy_app main.ts

FROM frolvlad/alpine-glibc:alpine-3.13

ENV PORT="8000"

WORKDIR /app

COPY --from=kubo_builder /app/kubo/ipfs /usr/local/bin/ipfs
COPY --from=deno_builder /app/proxy_app /app/proxy_app

COPY ./entrypoint.sh /app/

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]