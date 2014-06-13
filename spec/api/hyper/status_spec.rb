require 'spec_helper'

describe Hyper::Status do

  describe 'GET /api/status' do

    it 'returns ok' do
      get '/api/status'
      expect(response.status).to be 200
      r = JSON.parse(response.body)
      expect(r['status']).to be_eql 'ok'
    end
  end
end
