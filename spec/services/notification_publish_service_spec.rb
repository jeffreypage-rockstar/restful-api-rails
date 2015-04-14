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

  describe "#publish_to_users" do
    let(:devices) { create_list(:device_with_arn, 2) }
    let(:user_ids) { devices.map(&:user_id) }

    before do
      allow(DeviceRegisterWorker).to receive(:perform_async)
    end

    it "triggers amazon sns publish api for each device" do
      VCR.use_cassette("sns_publish_to_users") do
        notified = publisher.publish_to_users(notification, user_ids)
        expect(notified.size).to eql 2
        expect(notified.first.id).to eql devices.first.id
      end
    end

    it "unregister device when endpoint is disabled" do
      sns_double = double
      expect(sns_double).to receive(:publish).
                            and_raise(AWS::SNS::Errors::EndpointDisabled)
      allow(publisher).to receive(:sns).and_return(sns_double)
      expect(DeviceUnregisterWorker).to receive(:perform_async).
                                        with(devices.first.sns_arn)
      publisher.publish_to_users(notification, user_ids.first)
    end

    it "unregister device when arn is invalid" do
      sns_double = double
      expect(sns_double).to receive(:publish).
                            and_raise(AWS::SNS::Errors::InvalidParameter)
      allow(publisher).to receive(:sns).and_return(sns_double)
      expect(DeviceUnregisterWorker).to receive(:perform_async).
                                        with(devices.first.sns_arn)
      publisher.publish_to_users(notification, user_ids.first)
    end
  end

  describe "#message_attributes" do
    it "contains the correct badge counter" do
      notification = build(:notification, user: device.user)
      notification.sent!
      msg = publisher.message_attributes(notification, "")
      message = JSON.parse msg[:message]
      apns_message = JSON.parse message["apns"]
      expect(apns_message["aps"]["badge"]).to eql 1
    end

    it "accepts a user option" do
      notification = build(:notification, user: device.user)
      other_user = build(:user, unseen_notifications_count: 10)
      msg = publisher.message_attributes(notification, "", user: other_user)
      message = JSON.parse msg[:message]
      apns_message = JSON.parse message["apns"]
      expect(apns_message["aps"]["badge"]).to eql 10
    end
  end

end
