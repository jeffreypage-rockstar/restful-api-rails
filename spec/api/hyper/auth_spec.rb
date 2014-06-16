require 'spec_helper'

describe Hyper::Auth do

  let(:user){ create(:user, confirmed_at: nil) }
  let(:device){ create(:device, user: user) }

  describe 'POST /api/auth/email-verification' do
    before do
      @raw_token, user.confirmation_token = Devise.token_generator.generate(User, :confirmation_token)
      user.save
    end

    it 'confirms an user email with a confirmation token' do
      http_login device.id, device.access_token
      post '/api/auth/email-verification',
            { confirmation_token: @raw_token},
            @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 #created
      expect(r['user']['email']).to eql user.email
      expect(r['user']['confirmed']).to eql true
    end
    
    it 'rejects an invalid confirmation token' do
      http_login device.id, device.access_token
      post '/api/auth/email-verification',
            { confirmation_token: "invalidtoken"},
            @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 #invalid
      expect(r['error']).to match "confirmation token is invalid"
    end
  end
end
