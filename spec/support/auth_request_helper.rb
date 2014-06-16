module AuthRequestHelper
  #
  # pass the @env along with your request, eg:
  #
  # GET '/labels', {}, @env
  #
  def http_login(user, pw)
    @env ||= {}
    @env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
  end
end

RSpec.configure do |config|
  config.include AuthRequestHelper, :type => :request
end