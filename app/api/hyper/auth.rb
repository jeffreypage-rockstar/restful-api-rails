module Hyper
  class Auth < Base
    # POST /auth/email-verification
    desc "Post to verify the current user email"
    params do
      requires :confirmation_token,
               type: String,
               desc: "E-mail confirmation token."
    end
    post "/auth/email-verification" do
      authenticate!
      user = User.where(id: current_user.id).
                  confirm_by_token(params[:confirmation_token])
      raise ActiveRecord::RecordInvalid.new(user) if user.errors.any?
      user
    end

    # POST /auth/password-reset
    desc "Request a password reset, delivering the reset password token"
    params do
      requires :email,
               type: String,
               desc: "Password reset token."
    end
    post "/auth/password-reset" do
      user = User.send_reset_password_instructions(email: params[:email])
      validate_record!(user) && empty_body!
    end

    # PUT /auth/password-reset
    desc 'Change the user\'s password'
    params do
      requires :reset_password_token,
               type: String,
               desc: "Password reset token."
      requires :password, type: String, desc: "New password"
    end
    put "/auth/password-reset" do
      user = User.reset_password_by_token(
        reset_password_token: params[:reset_password_token],
        password: params[:password],
        password_confirmation: params[:password]
      )
      validate_record!(user)
    end
  end
end
