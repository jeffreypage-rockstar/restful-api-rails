module Hyper
  # api to create a user and/or get the current user data
  class Account < Base
    resource :user do
      # POST /user
      desc "Create a new user account"
      params do
        requires :email, type: String, desc: "User email."
        requires :username, type: String, desc: "User username."
        optional :password, type: String, desc: "User password."
        optional :facebook_token, type: String, desc: "User facebook token."
        optional :avatar_url, type: String, desc: "User avatar url."
        optional :device_type, type: String, desc: "Current device type."
        # mutually_exclusive :password, :facebook_token
      end
      post do
        user = SignUpService.new(permitted_params).call
        req = Hashie::Mash.new(remote_ip: env["REMOTE_ADDR"])
        user.sign_in_from_device!(req, nil, device_type: params[:device_type])
        header "Location", "/user"
        user
      end

      # GET /user
      desc "Returns current user data"
      get do
        authenticate!
        current_user
      end

      # PUT /user
      desc "Update current user data and settings"
      params do
        optional :email, type: String, desc: "User email."
        optional :username, type: String, desc: "User username."
        optional :facebook_token, type: String, desc: "User facebook token."
        optional :avatar_url, type: String, desc: "User avatar url"
      end
      put do
        authenticate!
        current_user.update_attributes!(permitted_params)
        empty_body!
      end

      # DELETE /user
      desc "Deletes the current user account"
      delete do
        authenticate!
        current_user.destroy!
        empty_body!
      end
    end
  end
end
