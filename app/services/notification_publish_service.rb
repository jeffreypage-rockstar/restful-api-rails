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

  def publish_to_users(notification, user_ids)
    notified_devices = []
    Device.includes(:user).with_arn.recent.where(user_id: user_ids).
      each do |device|
        begin
          sns.publish(message_attributes(notification, device.sns_arn,
                                         user: device.user))
          notified_devices << device
        rescue AWS::SNS::Errors::EndpointDisabled,
               AWS::SNS::Errors::InvalidParameter
          device.clear_push_token!
        end
      end
    notified_devices
  end

  def message_attributes(notification, target_arn, options = {})
    extra = notification.extra || {}
    badge = 1
    if user = options[:user] || notification.user
      badge = user.unseen_notifications_count
    end
    common_values = {
      "aps" => { "content-available" => 1,
                 "alert" => notification.caption,
                 "badge" => badge },
      "data" => extra.merge(
                        "notification_id" => notification.id,
                        "subject_id" => notification.subject_id,
                        "subject_type" => notification.subject_type
                      )
    }.to_json

    {
      message: {
        "apns_sandbox" => common_values,
        "apns" => common_values
      }.to_json,
      message_structure: "json",
      target_arn: target_arn
    }
  end

  private

  def sns
    @sns ||= AWS::SNS.new.client
  end
end
