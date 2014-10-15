require "rails_helper"

RSpec.describe NotificationPublishService, type: :service do
  let(:device) { create(:device_with_arn) }
  let(:notification) { create(:notification, user: device.user) }
  let(:publisher) { NotificationPublishService.new }

  before do
    allow(DeviceRegisterWorker).to receive(:perform_async).once
  end

  describe "#publish" do
    it "triggers amazon sns publish api for each device" do
      VCR.use_cassette("sns_publish_message") do
        devices = publisher.publish(notification)
        expect(devices.size).to eql 1
        expect(devices.first.id).to eql device.id
      end
    end

    it "unregister device when endpoint is disabled" do
      sns_double = double
      expect(sns_double).to receive(:publish).
                            and_raise(AWS::SNS::Errors::EndpointDisabled)
      allow(publisher).to receive(:sns).and_return(sns_double)
      expect(DeviceUnregisterWorker).to receive(:perform_async).
                                        with(device.sns_arn)
      publisher.publish(notification)
    end

    it "unregister device when arn is invalid" do
      sns_double = double
      expect(sns_double).to receive(:publish).
                            and_raise(AWS::SNS::Errors::InvalidParameter)
      allow(publisher).to receive(:sns).and_return(sns_double)
      expect(DeviceUnregisterWorker).to receive(:perform_async).
                                        with(device.sns_arn)
      publisher.publish(notification)
    end
  end

  describe "#message_attributes" do
    it "contains the correct badge counter" do
      create(:notification, user: device.user)
      msg = publisher.message_attributes(notification, "")
      message = JSON.parse msg[:message]
      apns_message = JSON.parse message["apns"]
      expect(apns_message["aps"]["badge"]).to eql 2
    end
  end

end
