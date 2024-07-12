# Step 1: Use the official Elixir image as a base
FROM elixir:latest

# Step 2: Install hex, rebar, and Node.js for asset compilation
RUN mix local.hex --force && \
  mix local.rebar --force && \
  apt-get update && \
  curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
  apt-get install -y nodejs

# Step 3: Create and set the working directory
WORKDIR /app

# Step 4: Copy the mix files to install dependencies
COPY mix.exs mix.lock ./
COPY config config

# Step 5: Install Elixir dependencies
RUN mix deps.get

# Step 6: Copy the rest of your application code
COPY . .

# Step 7: Install Node.js dependencies
RUN cd assets && npm install

# Step 8: Compile the assets
RUN cd assets && npm run deploy
RUN mix phx.digest

# Step 9: Compile the project
RUN mix do compile

# Step 10: Expose the port on which your app runs
EXPOSE 4000

# Step 11: The command to run when the container starts
CMD ["mix", "phx.server"]