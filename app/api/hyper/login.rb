module Hyper
  class Login < Base
    # POST /login
    desc 'Post to authenticate a user in a device'
    params do
      requires :email, type: String, desc: 'User email.'
      requires :password, type: String, desc: 'User password.'
      optional :device_id, type: Integer,
          desc: 'Current device id. If blank, a new device entry is created.'
      optional :device_type, type: String, desc: 'Current device type.'
    end
    post '/login' do
      user = User.find_for_database_authentication(email: params[:email])
      if user && user.valid_password?(params[:password])
        req = Hashie::Mash.new(remote_ip: env['REMOTE_ADDR'])
        user.sign_in_from_device!(req, params[:device_id],
                                  device_type: params[:device_type])
        user
      else
        auth_error!
      end
    end
  end
end
