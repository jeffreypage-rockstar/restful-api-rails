require 'spec_helper'

describe API::Status do

  def app
    API::Status
  end

  describe "GET /v1/status" do

    it "returns ok" do
      get "/v1/status"
      response.status.should == 200
      response = JSON.parse(last_response.body)
      expect(response["status"]).to be_eql "ok"
    end
  end
end