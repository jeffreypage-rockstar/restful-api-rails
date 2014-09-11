require "spec_helper"

describe Hyper::SuggestedImages do
  let(:device) { create(:device) }
  let(:user) { device.user }

  # ======== GETTING SUGGESTED IMAGES ==================
  describe "GET /api/suggested_images" do
    it "requires authentication" do
      get "/api/suggested_images?q=xbox+one"
      expect(response.status).to eql 401 # authentication
    end

    it "returns a set of images given a query" do
      VCR.use_cassette("bing_image_search_xbox_one") do
        http_login device.id, device.access_token
        get "/api/suggested_images?q=xbox+one", nil, @env
        expect(response.status).to eql 200
        r = JSON.parse(response.body)
        expect(r.size).to eql(10)
        expect(r.first["url"]).to_not be_blank
        expect(r.first["thumbnail"]).to_not be_blank
      end
    end

    it "accepts pagination" do
      VCR.use_cassette("bing_image_search_xbox_page2") do
        http_login device.id, device.access_token
        get "/api/suggested_images?q=xbox&page=2&per_page=3", nil, @env
        expect(response.status).to eql 200
        r = JSON.parse(response.body)
        expect(r.size).to eql(3)
        # response headers
        expect(response.header["Total"]).to eql("74400")
        link = 'api/suggested_images?page=3&per_page=3&q=xbox>; rel="next"'
        expect(response.header["Link"]).to include(link)
      end
    end

    it "return empty for a out of bounds page" do
      VCR.use_cassette("bing_image_search_xbox_page100") do
        http_login device.id, device.access_token
        get "/api/suggested_images?q=xbox&page=746&per_page=100", nil, @env
        expect(response.status).to eql 200
        r = JSON.parse(response.body)
        expect(r.size).to eql(0)
        # response headers
        expect(response.header["Total"]).to eql("74400")
      end
    end
  end
end
