module Hyper
  class Auth < Base
    # POST /auth/email-verification
    desc 'Post to verify the current user email'
    params do
      requires :confirmation_token,
               type: String,
               desc: 'E-mail confirmation token.'
    end
    post '/auth/email-verification' do
      authenticate!
      user = User.where(id: current_user.id).
                  confirm_by_token(params[:confirmation_token])
      raise ActiveRecord::RecordInvalid.new(user) if user.errors.any?
      user
    end
  end
end
