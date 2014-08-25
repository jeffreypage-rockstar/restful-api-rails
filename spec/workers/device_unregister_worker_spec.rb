require "rails_helper"

RSpec.describe DeviceUnregisterWorker, type: :worker do
  let(:worker) { DeviceUnregisterWorker.new }
  let(:device) { create(:device_with_arn) }

  before do
    # stub register job trigger
    allow(DeviceRegisterWorker).to receive(:perform_async)
  end

  it "performs a device arn unregister on delete" do
    VCR.use_cassette("sns_delete_endpoint") do
      expect(worker.perform(device.sns_arn)).to be_truthy
    end
  end

  it "does nothing for an invalid arn endpoint" do
    invalid_arn = "arn:aws:sns:us-east-1:462786100731:endpoint/APNS_SANDBOX/"\
                  "hyper-test/invalid"
    VCR.use_cassette("sns_delete_endpoint_invalid") do
      expect(worker.perform(invalid_arn)).to be_falsey
    end
  end
end
