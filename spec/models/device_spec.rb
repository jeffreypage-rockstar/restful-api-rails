require "rails_helper"

describe Device do
  let(:user) { create(:user) }

  describe ".create" do

    let(:attrs) { { user_id: user.id, device_type: "iphone" } }

    it "creates a valid device" do
      expect(Device.new(attrs)).to be_valid
    end

    it "requires an user_id" do
      user = Device.new(attrs.merge(user_id: ""))
      expect(user).to_not be_valid
    end

    it "generates an access_token" do
      user = Device.create(attrs)
      expect(user).to be_valid
      expect(user.access_token).to_not be_blank
    end
  end

  describe "sign_in!" do
    let(:device) { create(:device) }

    it "sets last_sign_in_at time" do
      expect(device.last_sign_in_at).to be_blank
      device.sign_in!
      expect(device.last_sign_in_at).to_not be_blank
    end
  end

end
