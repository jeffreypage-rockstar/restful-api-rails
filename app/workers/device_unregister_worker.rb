# register the device in amazon sns to receive push notifications
class DeviceUnregisterWorker
  include Sidekiq::Worker

  def perform(device_arn)
    return false if device_arn.blank?
    sns = AWS::SNS.new
    sns.client.delete_endpoint endpoint_arn: device_arn
    true
  rescue AWS::SNS::Errors::InvalidParameter => e
    if e.message =~ /invalid endpointId/
      false
    else
      raise e
    end
  end
end
