require File.expand_path("../environments/api", __FILE__)

require "app/api/hyper/base"

folders = %w(
  models/concerns models serializers services api/validations
  api/hyper
)
folders.each do |folder|
  Dir[File.expand_path("../../app/#{folder}/*.rb", __FILE__)].each do |f|
    require f
  end
end

require "app/api/api"

API.logger.level = Logger::DEBUG

ApplicationServer = Rack::Builder.new do
  use Rack::Static, urls: %w(/docs/), root: "public/api", index: "index.html"

  map "/" do
    run API
  end
end
