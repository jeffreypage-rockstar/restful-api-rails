module Hyper
  class Status < Base
    desc "Returns the status of the API"
    get "/status" do
      { status: "ok" }
    end
  end
end
