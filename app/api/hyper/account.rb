module Hyper
  # api to create a user and/or get the current user data
  class Account < Base
    resource :user do
      # POST /user
      desc 'Create a new user account'
      params do
        requires :email, type: String, desc: 'User email.'
        requires :password, type: String, desc: 'User password.'
        requires :password_confirmation, type: String,
                                         desc: 'User password confirmation.'
        optional :username, type: String, desc: 'User username.'
        optional :avatar_url, type: String, desc: 'User avatar url'
      end
      post do
        User.create!(declared(params, include_missing: false))
      end

      # GET /user
      desc 'Returns current user data'
      get do
        authenticate!
        current_user
      end

      # PUT /user
      desc 'Update current user data and settings'
      params do
        optional :email, type: String, desc: 'User email.'
        optional :username, type: String, desc: 'User username.'
        optional :avatar_url, type: String, desc: 'User avatar url'
      end
      put do
        authenticate!
        current_user.update_attributes!(
          declared(params, include_missing: false)
        )
        current_user
      end

      # DELETE /user
      desc 'Deletes the current user account'
      delete do
        authenticate!
        current_user.destroy!
      end
    end
  end
end
