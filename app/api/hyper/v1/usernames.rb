module Hyper
  module V1
    # api to search for existent usernames
    class Usernames < Base
      resource "available-usernames" do
        # GET /available-usernames/:username
        desc "Returns a status 200 if username is avaliable, 404 if taken"
        params do
          requires :username, type: String, desc: "A username."
        end
        route_param :username do
          get do
            if User.find_by(username: params[:username])
              raise ActiveRecord::RecordNotFound
            else
              true
            end
          end
        end
      end
    end
  end
end
