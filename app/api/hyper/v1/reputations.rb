module Hyper
  module V1
    # api to get reputations list
    class Reputations < Base
      # GET /reputations
      desc "Returns the available reputations"
      get :reputations do
        authenticate!
        Reputation.all
      end
    end
  end
end
