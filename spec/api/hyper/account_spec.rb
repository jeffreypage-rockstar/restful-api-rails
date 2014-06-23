require 'spec_helper'

describe Hyper::Account do
  let(:user) { create(:user) }
  let(:device) { create(:device, user: user) }

  # ======== CREATING A USER ACCOUNT ==================
  describe 'POST /api/user' do
    it 'creates a new valid user, not confirmed' do
      post '/api/user', email: 'user@example.com',
                        username: 'username',
                        password: '123testme'
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r['user']['email']).to eql 'user@example.com'
      expect(r['user']['id']).to_not be_blank
      expect(r['user']['confirmed']).to eql false
      expect(r['user']['auth']['device_id']).to_not be_blank
      expect(r['user']['auth']['access_token']).to_not be_blank
      expect(response.header['Location']).to match "\/user"
    end

    it 'requires valid user param' do
      post '/api/user', email: 'user@example.com',
                        username: 'username??',
                        password: '123testme'
      r = JSON.parse(response.body)
      expect(response.status).to eql 422 # invalid
      expect(r['status_code']).to eql 'invalid_resource'
      expect(r['error']).to match('username is invalid')
    end

    it 'does not accept duplicated email' do
      post '/api/user', email: user.email,
                        username: 'otherusername',
                        password: '123testme'
      r = JSON.parse(response.body)
      expect(response.status).to eql 409 # invalid
      expect(r['status_code']).to eql 'conflict'
      expect(r['error']).to match('email has already been taken')
    end
  end

  # ======== GETTING CURRENT USER INFO ==================
  describe 'GET /api/user' do
    it 'requires authentication' do
      get '/api/user'
      expect(response.status).to eql 401 # authentication
    end

    it 'returns the current user data' do
      http_login device.id, device.access_token
      get '/api/user', nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['user']['id']).to eql(device.user_id)
    end
  end

  # ======== UPDATING CURRENT USER INFO ==================
  describe 'PUT /api/user' do
    before do
      ActionMailer::Base.deliveries.clear
    end

    it 'requires authentication' do
      put '/api/user'
      expect(response.status).to eql 401 # authentication
    end

    it 'does not allow empty e-mail' do
      http_login device.id, device.access_token
      put '/api/user', { email: '' }, @env
      expect(response.status).to eql 422 # invalid
      r = JSON.parse(response.body)
      expect(r['error']).to match('email can\'t be blank')
    end

    it 'updates current user attributes/settings' do
      http_login device.id, device.access_token
      put '/api/user', { avatar_url: 'http://new_avatar_url' }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 200
      expect(r['user']['avatar_url']).to eql('http://new_avatar_url')
    end

    it 'updates current user e-mail, requiring new confirmation' do
      expect(user).to be_confirmed
      http_login device.id, device.access_token
      put '/api/user', { email: 'newemail@example.com' }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['user']['email']).to eql(user.email)
      expect(r['user']['unconfirmed_email']).to eql('newemail@example.com')
      expect(r['user']['confirmed']).to eql(false)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to match 'Confirmation instructions'
      expect(mail.to).to eql ['newemail@example.com']
    end
  end

  # ======== DELETING CURRENT USER ACCOUNT ==================
  describe 'delete /api/user' do
    it 'requires authentication' do
      delete '/api/user'
      expect(response.status).to eql 401 # authentication
    end

    it 'deletes current user account' do
      http_login device.id, device.access_token
      delete '/api/user', nil, @env
      expect(response.status).to eql 204 # no content
    end
  end
end
