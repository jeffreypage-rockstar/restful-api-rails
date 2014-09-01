module Hyper
  # api to search for existent usernames
  class Usernames < Base
    resource :usernames do
      # GET /usernames/:username
      desc "Returns a status 200 (found) or 404 (not found) given a username"
      params do
        requires :username, type: String, desc: "A username."
      end
      route_param :username do
        get nil, serializer: UserShortSerializer do
          authenticate!
          User.find_by!(username: params[:username])
        end
      end
    end

    resource "available-usernames" do
      # GET /available-usernames/:username
      desc "Returns a status 200 if username is avaliable, 404 if taken"
      params do
        requires :username, type: String, desc: "A username."
      end
      route_param :username do
        get do
          authenticate!
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
