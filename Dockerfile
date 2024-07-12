FROM elixir:1.17.1

RUN mix local.hex --force && \
  mix local.rebar --force && \
  apt-get update && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get install -y nodejs

WORKDIR /app

COPY mix.exs mix.lock ./
COPY config config

RUN mix deps.get

COPY . .

RUN cd assets && npm install

RUN cd assets && npm run deploy
RUN mix phx.digest

RUN mix do compile

EXPOSE 4000

CMD ["mix", "phx.server"]