class NotificationPublishService
  MAX_DEVICES = 3

  def publish(notification)
    user = notification.user
    notified_devices = []
    if user.present? && notification.require_push_notification?
      user.devices.with_arn.recent.limit(MAX_DEVICES).each do |device|
        begin
          sns.publish(message_attributes(notification, device.sns_arn))
          notified_devices << device
        rescue AWS::SNS::Errors::EndpointDisabled,
               AWS::SNS::Errors::InvalidParameter
          device.clear_push_token!
        end
      end
    end
    notified_devices
  end

  private

  def sns
    @sns ||= AWS::SNS.new.client
  end

  def message_attributes(notification, target_arn)
    {
      message: notification.caption,
      message_attributes: {
        "subject_id" => { data_type: "String",
                          string_value: notification.subject_id },
        "subject_type" => { data_type: "String",
                            string_value: notification.subject_type }
      },
      target_arn: target_arn
    }
  end
end
