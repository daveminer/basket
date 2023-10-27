console:
	iex -S mix phx.server
t:
	MIX_ENV=test mix coveralls
cover-html:
	MIX_ENV=test mix coveralls.html
cover-lcov:
	MIX_ENV=test mix coveralls.lcov
start:
	mix phx.server