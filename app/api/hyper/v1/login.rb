module Hyper
  module V1
    class Login < Base
      # POST /login
      desc "Post to authenticate a user in a device"
      params do
        optional :username, type: String, desc: "User username."
        optional :password, type: String, desc: "User password."
        optional :facebook_token, type: String, desc: "User facebook token."
        optional :device_id, type: String,
                             desc: "Current device id. If blank, a new device"\
                                   " entry is created.",
                             uuid: true
        optional :device_type, type: String, desc: "Current device type."
        mutually_exclusive :password, :facebook_token
      end
      post :login do
        user = SignInService.new(env["REMOTE_ADDR"], permitted_params).call
        user || auth_error!
      end
    end
  end
end
