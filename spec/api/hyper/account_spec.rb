require 'spec_helper'

describe Hyper::Account do

  describe 'POST /api/user' do

    it 'creates a new valid user, not confirmed' do
      post '/api/user', email: 'user@example.com', password: '123testme', password_confirmation: '123testme'
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 #created
      expect(r['user']['email']).to eql 'user@example.com'
      expect(r['user']['id']).to_not be_blank
      expect(r['user']['confirmed']).to eql false
    end
    
    it 'requires valid user param' do
      post '/api/user', email: 'user@example.com', password: '123testme', password_confirmation: '123invalid'
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 #invalid
      expect(r['status_code']).to eql 'record_invalid'
      expect(r['error']).to match('password confirmation doesn\'t match')
    end
  end
  
  describe 'GET /api/user' do
    
    it 'requires authentication' do
      get '/api/user'
      expect(response.status).to eql 401 #authentication
    end
    
    it 'returns the current user data' do
      user = create(:user)
      get '/api/user', nil, {'x-user-id' => user.id}
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['user']['id']).to eql(user.id)
    end
  end
end
