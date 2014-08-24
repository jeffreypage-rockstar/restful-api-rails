require "rails_helper"

describe Device do
  let(:user) { create(:user) }

  describe ".create" do

    let(:attrs) { { user_id: user.id, device_type: "iphone" } }

    it "creates a valid device" do
      expect(Device.new(attrs)).to be_valid
    end

    it "requires an user_id" do
      device = Device.new(attrs.merge(user_id: ""))
      expect(device).to_not be_valid
    end

    it "generates an access_token" do
      device = Device.create(attrs)
      expect(device).to be_valid
      expect(device.access_token).to_not be_blank
    end
  end

  describe "#push_token" do
    it "trigger a sns worker when adding a push token" do
      device = create(:device)
      expect(DeviceSnsWorker).to receive(:perform_async).with(device.id)
      device.push_token = "avavliddevicetoken"
      expect(device.save).to be_truthy
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
