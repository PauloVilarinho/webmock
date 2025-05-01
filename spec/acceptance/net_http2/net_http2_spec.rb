require 'spec_helper'
require 'ostruct'
require 'acceptance/webmock_shared'
require 'acceptance/net_http2/net_http2_spec_helper'

include NetHTTP2SpecHelper

describe "Net:HTTP2" do
  include_examples "with WebMock"
end
