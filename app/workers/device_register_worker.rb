# register the device in amazon sns to receive push notifications
class DeviceRegisterWorker
  include Sidekiq::Worker

  def perform(device_id)
    device = Device.find_by(id: device_id)
    return false if device.try(:push_token).blank?
    endpoint_arn = register_device(device.push_token, user_id: device.user_id,
                                                      device_id: device.id)
    device.update sns_arn: endpoint_arn
  end

  private

  # token example:
  #   FE66489F304DC75B8D6E8200DFF8A456E8DAEACEC428B427E9518741C92C6660
  # sns response:
  # {:endpoint_arn=>"<<app_arn>>/8fb4f9e0-298a-38a3-9cf2-47614468d37e",
  # :response_metadata=>{:request_id=>"86343a37-a5f0-5dd0-a2da-7647cebe3fb9"}}
  def register_device(token, user_data = {})
    sns = AWS::SNS.new
    app_arn = Rails.application.secrets.aws_arn
    response = sns.client.
               create_platform_endpoint platform_application_arn: app_arn,
                                        token: token,
                                        custom_user_data: user_data.to_param
    response.fetch(:endpoint_arn, "")
  rescue AWS::SNS::Errors::InvalidParameter => e
    # deal with already registered device
    if e.message =~ /already exists with the same Token/
      Device.find_by(push_token: token).try(:sns_arn)
    else
      raise e
    end
  end
end
