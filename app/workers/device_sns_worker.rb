# register the device in amazon sns to receive push notifications
class DeviceSnsWorker
  include Sidekiq::Worker

  def perform(device_id)
    device = Device.find_by(id: device_id)
    return false if device.try(:push_token).blank?
    device.update sns_arn: register_device(device.push_token)
  end

  private

  # token example:
  #   FE66489F304DC75B8D6E8200DFF8A456E8DAEACEC428B427E9518741C92C6660
  # sns response:
  # {:endpoint_arn=>"<<app_arn>>/8fb4f9e0-298a-38a3-9cf2-47614468d37e",
  # :response_metadata=>{:request_id=>"86343a37-a5f0-5dd0-a2da-7647cebe3fb9"}}
  def register_device(token)
    sns = AWS::SNS.new
    app_arn = Rails.application.secrets.aws_arn
    response = sns.client.
               create_platform_endpoint platform_application_arn: app_arn,
                                        token: token
    response.fetch(:endpoint_arn, "")
  end
end
