module NetHTTP2SpecHelper
  def http_request(method, uri, options = {}, &block)
    begin
      uri = URI.parse(uri)
    rescue
      uri = Addressable::URI.heuristic_parse(uri)
    end
    response = nil
    method_symbol = method.to_s.downcase.to_sym
    
    host = uri.scheme + "://" + uri.host

    if options[:basic_auth]
      host = "#{options[:basic_auth][0]}:#{options[:basic_auth][1]}@#{host}"
    end


    client = NetHttp2::Client.new(host, connect_timeout: 60)
    response = client.call(method_symbol, "#{uri.path}#{uri.query ? '?' : ''}#{uri.query}",
                      headers: options[:headers], 
                      body: options[:body])

    OpenStruct.new({
      body: response.body,
      headers: WebMock::Util::Headers.normalize_headers(response.headers),
      status: response.status,
      message: response.message
    })
  end

  def http_library
    :net_http2
  end
end
