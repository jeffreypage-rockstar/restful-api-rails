require "rails_helper"

RSpec.describe DeviceSnsWorker, type: :worker do
  let(:worker) { DeviceSnsWorker.new }
  let(:device) { create(:device_with_arn) }

  it "performs a device resgitration on sns" do
    VCR.use_cassette("sns_create_platform_endpoint") do
      expect(worker.perform(device.id)).to be_truthy
      expect(device.reload.sns_arn).to_not be_blank
    end
  end

  it "does nothing for an invalid device id" do
    user = create(:user)
    expect(worker.perform(user.id)).to be_falsey
  end

  it "does nothing for a device without a push_token" do
    device = create(:device)
    expect(worker.perform(device.id)).to be_falsey
  end

  it "sets an existent sns if device is registered" do
    new_device = create(:device, push_token: device.push_token)
    VCR.use_cassette("sns_create_platform_endpoint_duplicated") do
      expect(worker.perform(new_device.id)).to be_truthy
      expect(new_device.reload.sns_arn).to eql device.sns_arn
    end
  end
end
