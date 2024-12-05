require 'async/http'

endpoint = Async::HTTP::Endpoint.parse('http://localhost:9294')
Sync do
	Async(transient: true) do
		server = Async::HTTP::Server.for(endpoint) do |request|
			::Protocol::HTTP::Response[200, {}, ["Hello World"]]
		end
		loop do
			server.run
		end
	end
end