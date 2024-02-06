FROM ipfs/kubo:latest AS kubo_binary
FROM denoland/deno:latest AS deno_builder

WORKDIR /app

COPY ./main.ts /app/

RUN deno compile -A -o proxy_app main.ts

FROM amd64/alpine:latest

ENV PORT="8000"

WORKDIR /app

COPY --from=kubo_binary /usr/local/bin/ipfs /usr/local/bin/ipfs
COPY --from=deno_builder /app/proxy_app /app/proxy_app

COPY ./scripts/entrypoint.sh /app/

RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]