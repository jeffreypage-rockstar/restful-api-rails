require 'spec_helper'

describe Hyper::Stacks do
  let(:device){ create(:device) }

  # ======== CREATING STACKS ==================
  describe 'POST /api/stacks' do
    it 'requires authentication' do
      post '/api/stacks', { name: 'My Stack Title' }
      expect(response.status).to eql 401 # authentication
    end

    it 'creates a new valid stack' do
      http_login device.id, device.access_token
      post '/api/stacks', { name: 'My Stack Title', protected: true }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 201 # created
      expect(r['stack']['name']).to eql 'My Stack Title'
      expect(r['stack']['id']).to_not be_blank
      expect(r['stack']['protected']).to eql true
      expect(r['stack']['user_id']).to eql device.user_id
    end

    it 'requires a unique stack title' do
      http_login device.id, device.access_token
      stack = create(:stack)
      post '/api/stacks', { name: stack.name }, @env
      r = JSON.parse(response.body)
      expect(response.status).to eql 403 # invalid
      expect(r['status_code']).to eql 'record_invalid'
      expect(r['error']).to match('name has already been taken')
    end
  end

  # ======== GETTING USER STACKS ==================
  describe 'GET /api/stacks' do
    it 'requires authentication' do
      get '/api/stacks'
      expect(response.status).to eql 401 # authentication
    end

    it 'returns the current user stacks' do
      stack = create(:stack, user: device.user)
      http_login device.id, device.access_token
      get '/api/stacks', nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['stacks'].size).to eql(1)
      expect(r['stacks'].first['user_id']).to eql(device.user_id)
    end
    
    it 'accepts pagination' do
      (1..10).map{ stack = create(:stack, user: device.user) }
      http_login device.id, device.access_token
      get '/api/stacks', {:page => 2, :per_page => 3}, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['stacks'].size).to eql(3)
      #response headers
      expect(response.header["Total"]).to eql("10")
      next_link = 'api/stacks?page=3&per_page=3>; rel="next"'
      expect(response.header["Link"]).to include(next_link)
    end
  end
  
  # ======== GETTING SUGGESTIONS TO THE USER ==================
  describe 'GET /api/stacks/suggestions' do
    it 'requires authentication' do
      get '/api/stacks/suggestions'
      expect(response.status).to eql 401 # authentication
    end

    it 'returns the stacks suggestions to the current user' do
      # stack = create(:stack, user: device.user)
      http_login device.id, device.access_token
      get '/api/stacks/suggestions', nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r).to be_empty
    end
  end
  
  # ======== GETTING RELATED STACKS ==================
  describe 'GET /api/stacks/related' do
    it 'requires authentication' do
      get '/api/stacks/related', stacks: ["invalid"]
      expect(response.status).to eql 401 # authentication
    end

    it 'returns the stacks related to the provided stacks list' do
      stack = create(:stack, user: device.user)
      other_stack = create(:stack)
      http_login device.id, device.access_token
      get '/api/stacks/related', { stacks: [stack.id] }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['stacks'].size).to eql(1)
      expect(r['stacks'].first['id']).to eql other_stack.id
    end
  end
  
  # ======== GETTING STACKS FOR AUTOCOMPLETE ==================
  describe 'GET /api/stacks/names' do
    it 'requires authentication' do
      get '/api/stacks/names', q: "name"
      expect(response.status).to eql 401 # authentication
    end

    it 'returns the stacks with name matching the query' do
      stack = create(:stack)
      http_login device.id, device.access_token
      get '/api/stacks/names', { q: stack.name[0..2] }, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['stacks'].size).to eql(1)
    end
  end
  
  # ======== GETTING A STACK DETAILS ==================
  
  describe 'GET /api/stacks/:id' do
    it 'requires authentication' do
      get "/api/stacks/1"
      expect(response.status).to eql 401 # authentication
    end

    it 'returns a stack with related stacks list' do
      stack = create(:stack, user: device.user)
      http_login device.id, device.access_token
      get "/api/stacks/#{stack.id}", nil, @env
      expect(response.status).to eql 200
      r = JSON.parse(response.body)
      expect(r['stack']['id']).to eql(stack.id)
    end
  end
end
