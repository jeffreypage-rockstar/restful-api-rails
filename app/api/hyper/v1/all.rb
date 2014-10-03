module Hyper
  module V1
    class All < Grape::API
      mount Hyper::V1::Status
      mount Hyper::V1::Login
      mount Hyper::V1::Auth
      mount Hyper::V1::Account
      mount Hyper::V1::Devices
      mount Hyper::V1::Stacks
      mount Hyper::V1::Subscriptions
      mount Hyper::V1::Cards
      mount Hyper::V1::Comments
      mount Hyper::V1::Flags
      mount Hyper::V1::SuggestedImages
      mount Hyper::V1::Networks
      mount Hyper::V1::Reputations
      mount Hyper::V1::Notifications
      mount Hyper::V1::Usernames

      base_path_proc = Proc.new do |r|
        if Rails.env.development?
          "http#{r.base_url}"
        else
          "http://#{r.host}"
        end
      end
      add_swagger_documentation mount_path: "api_docs",
                                api_version: "v1",
                                hide_documentation_path: true,
                                hide_format: true,
                                base_path: base_path_proc
    end
  end
end
