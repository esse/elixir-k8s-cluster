FROM elixir:1.9-alpine AS base

# Set exposed ports

WORKDIR /app

ADD . /app

EXPOSE 4000
ENV PORT 4000
ENV MIX_ENV prod
ENV SECRET_KEY_BASE ahdajkdhaksjdhajksdhajks


RUN mix local.hex --force && \
  mix local.rebar --force && \
  mix do deps.get, deps.compile && \
  mix do compile, phx.digest

RUN mix release

FROM alpine:3.9.4 AS production
WORKDIR /app
RUN addgroup app && \
  adduser -h /app -S app app && \
  apk add --no-cache bash

USER app
COPY --from=base --chown=app:app /app/_build .
ENTRYPOINT ["./prod/rel/cluster/bin/cluster"]
CMD ["start"]
