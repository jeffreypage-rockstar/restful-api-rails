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

  describe "#update" do
    it "does not regenerate access_token" do
      device = create(:device)
      old_access_token = device.access_token
      device.save
      expect(device.access_token).to eql old_access_token
    end
  end

  describe "#push_token" do
    it "trigger a sns worker when adding a push token" do
      device = create(:device)
      expect(DeviceRegisterWorker).to receive(:perform_async).with(device.id)
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

  describe "#destroy" do
    it "trigger an unregister worker job if arn exists" do
      allow(DeviceRegisterWorker).to receive(:perform_async)
      device = create(:device_with_arn)
      expect(DeviceUnregisterWorker).to receive(:perform_async).
                                        with(device.sns_arn)
      device.destroy
    end

    it "does not trigger the unregister worker job if arn is blank" do
      device = create(:device)
      expect(DeviceUnregisterWorker).to_not receive(:perform_async)
      device.destroy
    end
  end

end
