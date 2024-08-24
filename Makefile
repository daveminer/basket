console:
	iex -S mix phx.server
t:
	MIX_ENV=test mix test
coverage:
	MIX_ENV=test mix test --cover
release:
	docker build . -t basket
start:
	mix phx.server