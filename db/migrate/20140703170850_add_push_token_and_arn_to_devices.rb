class AddPushTokenAndArnToDevices < ActiveRecord::Migration
  def change
  	 add_column :devices, :push_token, :string
  	 add_column :devices, :sns_arn, :string
  end
end
