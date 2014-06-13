require File.expand_path('../environments/api', __FILE__)

Dir[File.expand_path('../../app/models/*.rb', __FILE__)].each do |f|
  require f
end
Dir[File.expand_path('../../app/api/hyper/*.rb', __FILE__)].each do |f|
  require f
end

require 'app/api/api'

ApplicationServer = Rack::Builder.new do
  use Rack::Static, urls: [], root: 'public', index: 'index.html'

  map '/' do
    run API
  end
end
