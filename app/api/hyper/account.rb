module Hyper
  # api to create a user and/or get the current user data
  class Account < Base
    
    resource :user do
      desc "Create a new user account"
      params do
        requires :email, type: String, desc: "User email."
        requires :password, type: String, desc: "User password."
        requires :password_confirmation, type: String, desc: "User password confirmation."
      end
      post do
        User.create!(
          email: params[:email],
          password: params[:password],
          password_confirmation: params[:password_confirmation]
        )
      end
    end
  end
end
