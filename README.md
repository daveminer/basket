![Tests](https://github.com/daveminer/basket/actions/workflows/ci.yml/badge.svg)

# Basket

Watch your "basket" of stocks in real-time with data from [Alpaca](https://alpaca.markets/).

![](basket_demo.gif)

Basket is intended as a template; it provides a working example of a Phoenix Framework web server utilizing
the following tools and patterns:

- Continuous Integration
- [Phoenix Channels](https://hexdocs.pm/phoenix/channels.html)
- [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html)
- [Phoenix Presence](https://hexdocs.pm/phoenix/presence.html)
- [Pow](https://github.com/pow-auth/pow)
- Search Autocomplete (in LiveView)
- [WebSockex](https://github.com/Azolo/websockex)

Basket also serves as a reference for testing patterns:

- [ExMachina](https://hexdocs.pm/ex_machina/ExMachina.html)
- [Mox](https://github.com/dashbitco/mox)
- [Test Server](https://github.com/danschultzer/test_server)

Many thanks to the authors of these excellent libraries!

## Setup

### Install

- Ensure Postgres is running. If using Docker, `docker start postgres` usually works well.
- Run `mix setup` to install and set up dependencies
- Start the development server with `make dev`
- Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

### Create a Dev User

- Unauthenticated users will be redirected to the registration page as per [Pow](https://github.com/pow-auth/pow) standards.
  Sign up and verify your email (for a quick fix, populate the `email_verified_at` column in the `User` table)
- Log in and watch your basket!

## OAuth2 with Google
"Login with Google" is available via [Pow Assent](https://github.com/pow-auth/pow_assent) when the `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` environment variables are set.
Other Strategies can be implmented by following the pattern for Google OAuth2:

- Add a [Provider](https://github.com/daveminer/basket/commit/c1c914ae9a8b1d75b5a7720608acb6bde3a8f52a#diff-e43c5cbf91db7a8062b6cb860cbf118296c1b4c7ee32fdcf702e54234ba38092R39-R49)
- Add a [Login Button](https://github.com/daveminer/basket/commit/a12088574ae9a7533aaa8278225cfb9f65fe6e36#diff-63250f1964336b5c6175d1724abf70cc9be60ca58deb74b05893d5093f18eb85R87)

## Architecture

Basket uses HTTP and WebSocket connections to ingress stock data. The real-time updates are
received over WebSocket and distributed through Phoenix Channels, one per stock ticker. Phoenix
Presence is utilized to track ticker subscription lifecycles for all users in aggregate against
the WebSocket client, sharing one client connection efficiently.
