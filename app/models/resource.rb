class Resource
  private

  def self.client
    options = { url: Rails.configuration.x.registry_url }
    options.merge!(ssl: { verify: false }) if Rails.configuration.x.no_ssl_verification
    Faraday.new(options) do |f|
      if Rails.configuration.x.basic_auth_user && Rails.configuration.x.basic_auth_password
        f.use Faraday::Request::BasicAuthentication,
          Rails.configuration.x.basic_auth_user,
          Rails.configuration.x.basic_auth_password
      elsif (auth = Current.http_basic_auth).present?
        f.use Faraday::Request::BasicAuthentication, *auth
      end
      f.use FaradayMiddleware::ParseJson, content_type: /json|prettyjws/
      f.response :logger unless Rails.env.test?
      f.response :raise_error
      f.adapter  Faraday.default_adapter
    end
  end

  def client
    self.class.client
  end
end
