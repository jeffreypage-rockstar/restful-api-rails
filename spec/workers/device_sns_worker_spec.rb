require "rails_helper"

RSpec.describe DeviceSnsWorker, type: :worker do
  let(:worker) { DeviceSnsWorker.new }
  let(:device) { create(:device) }

  it "performs a device resgitration on sns" do
    device.push_token = "avalidpushtoken"
    device.save

    sns_arn = "<<app_arn>>/8fb4f9e0-298a-38a3-9cf2-47614468d37e"
    response = {
      endpoint_arn: sns_arn,
      response_metadata: {
        request_id: "86343a37-a5f0-5dd0-a2da-7647cebe3fb9"
      }
    }
    client = double("client")
    sns = double("sns", client: client)
    expect(client).to receive(:create_platform_endpoint).
                      with(platform_application_arn: /arn:aws:sns/,
                           token: device.push_token).
                      and_return(response)
    expect(AWS::SNS).to receive(:new).and_return(sns)
    expect(worker.perform(device.id)).to be_truthy
    expect(device.reload.sns_arn).to eql(sns_arn)
  end

  it "does nothing for an invalid device id" do
    user = create(:user)
    expect(worker.perform(user.id)).to be_falsey
  end

  it "does nothing for a device without a push_token" do
    expect(worker.perform(device.id)).to be_falsey
  end
end
