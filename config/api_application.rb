require File.expand_path('../environments/api', __FILE__)

Dir[File.expand_path("../../app/models/*.rb", __FILE__)].each {|f| require f}
Dir[File.expand_path("../../app/api/hyper/*.rb", __FILE__)].each {|f| require f}

require "app/api/api"

ApplicationServer = Rack::Builder.new {
  use Rack::Static, :urls => [
    "/css",
    "/images",
    "/lib"
  ], :root => "public", index: 'index.html'

  map "/" do
    run API
  end
}
