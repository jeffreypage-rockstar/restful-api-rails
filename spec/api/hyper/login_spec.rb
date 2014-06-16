require 'spec_helper'

describe Hyper::Login do

  describe 'POST /api/login' do

    let(:user) { create(:user) }
    let(:device) { create(:device, user: user) }
    let(:pass) { 'please123' }

    it 'requires a user email' do
      post '/api/login', password: pass
      expect(response.status).to eql 400 # bad request
    end

    it 'requires a user password' do
      post '/api/login', email: user.email
      expect(response.status).to eql 400
    end

    it 'authenticate a valid user, creating a new device token' do
      post '/api/login', email: user.email, password: pass
      r = JSON.parse(response.body)
      expect(response.status).to eql 201
      expect(r['user']['email']).to eql user.email
      expect(r['user']['id']).to_not be_blank
      expect(r['user']['auth']['device_id']).to_not be_blank
      expect(r['user']['auth']['access_token']).to_not be_blank
    end

    it 'authenticate a valid user, using the existent device id' do
      post '/api/login', email: user.email, password: pass, device_id: device.id
      r = JSON.parse(response.body)
      expect(response.status).to eql 201
      expect(r['user']['email']).to eql user.email
      expect(r['user']['id']).to_not be_blank
      expect(r['user']['auth']['device_id']).to eql device.id
      expect(r['user']['auth']['access_token']).to_not be_blank
    end

    it 'does not authenticate an invalid user' do
      post '/api/login', email: user.email, password: '123testme1'
      expect(response.status).to eql 401
    end
  end
end
