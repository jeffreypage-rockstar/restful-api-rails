require 'spec_helper'

describe Hyper::Account do

  describe 'POST /api/user' do

    it 'returns the valid user data' do
      post '/api/user', email: 'user@example.com', password: '123testme', password_confirmation: '123testme'
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 #created
      expect(r['user']['email']).to eql 'user@example.com'
      expect(r['user']['id']).to_not be_blank
      expect(r['user']['confirmed']).to eql false
    end
  end
end
