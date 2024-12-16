require 'logger'
require 'singleton'
require 'falcon'
require 'protocol/http'

module MockedApp
  def self.call(env)
    Protocol::HTTP::Response.new(
      "http/1.1",
      200,
      Protocol::HTTP::Body::Buffered.wrap("hello world")
    )
  end
end

class WebMockServer
  include Singleton

  attr_reader :started

  def host_with_port
    "localhost:3000"
  end

  def concurrent
    unless RUBY_PLATFORM =~ /java/
      @pid = Process.fork do
        yield
      end
    else
      Thread.new { yield }
    end
  end

  def start
    @started = true
    mocked_app_endpoint = Async::HTTP::Endpoint.parse("http://#{host_with_port}")
    app = Falcon::Server.middleware(MockedApp)
    server = Falcon::Server.new(app, mocked_app_endpoint)

    concurrent do
      ['TERM', 'INT'].each do |signal|
        trap(signal) do
          Thread.new do
            server.close
          end
        end
      end
      server.run.wait
    end
  end

  def stop
    if @pid
      Process.kill('INT', @pid)
    end
  end
end
