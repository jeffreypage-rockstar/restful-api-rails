require 'spec_helper'

describe Hyper::Auth do

  let(:user) { create(:user, confirmed_at: nil) }
  let(:device) { create(:device, user: user) }

  describe 'POST /api/auth/email-verification' do
    before do
      @raw_token, user.confirmation_token =
        Devise.token_generator.generate(User, :confirmation_token)
      user.save
    end

    it 'confirms an user email with a confirmation token' do
      http_login device.id, device.access_token
      post '/api/auth/email-verification',
           { confirmation_token: @raw_token },
           @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r['user']['email']).to eql user.email
      expect(r['user']['confirmed']).to eql true
    end

    it 'rejects an invalid confirmation token' do
      http_login device.id, device.access_token
      post '/api/auth/email-verification',
           { confirmation_token: 'invalidtoken' },
           @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 # invalid
      expect(r['error']).to match 'confirmation token is invalid'
    end
  end

  describe 'PUT /api/auth/password-reset' do
    before do
      @raw_token, user.reset_password_token =
        Devise.token_generator.generate(User, :reset_password_token)
      user.reset_password_sent_at = Time.now.utc
      user.save
    end

    it 'updates the user password with a valid token' do
      put '/api/auth/password-reset', reset_password_token: @raw_token,
                                      password: 'newpass123',
                                      password_confirmation: 'newpass123'
      r = JSON.parse(response.body)
      expect(response.status).to eql 200
      expect(r['user']['email']).to eql user.email
    end

    it 'rejects the new user password without a valid confirmation' do
      put '/api/auth/password-reset', reset_password_token: @raw_token,
                                      password: 'newpass123',
                                      password_confirmation: 'newpass1234'
      r = JSON.parse(response.body)
      expect(response.status).to eql 403
      expect(r['error']).to match "password confirmation doesn't match password"
    end

    it 'rejects an invalid reset token' do
      put '/api/auth/password-reset', reset_password_token: 'invalidtoken',
                                      password: 'newpass123',
                                      password_confirmation: 'newpass123'
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 # invalid
      expect(r['error']).to match 'reset password token is invalid'
    end
  end

  describe 'POST /api/auth/password-reset' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it 'generates a password reset token for an existent email' do
      post '/api/auth/password-reset', email: user.email
      expect(response.status).to eql 201
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to match 'Reset password instructions'
      expect(mail.to).to eql [user.email]
    end

    it 'fails to send password reset token for an invalid email' do
      post '/api/auth/password-reset', email: 'invalid@example.com'
      r = JSON.parse(response.body)
      expect(response.status).to eql 403
      expect(r['error']).to match 'email not found'
    end
  end
end
