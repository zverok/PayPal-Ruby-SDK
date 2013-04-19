
module PayPal::SDK
  module Core
    module OpenIDConnect
      autoload :API,             "paypal-sdk/core/openid_connect/api"
      autoload :SetAPI,          "paypal-sdk/core/openid_connect/set_api"
      autoload :GetAPI,          "paypal-sdk/core/openid_connect/get_api"
      autoload :RequestDataType, "paypal-sdk/core/openid_connect/request_data_type"
      autoload :DataTypes,       "paypal-sdk/core/openid_connect/data_types"

      include DataTypes

      class << self
        def api
          RequestDataType.api
        end

        def set_config(*args)
          RequestDataType.set_config(*args)
        end
        alias_method :config=, :set_config
      end

      module DataTypes
        class Tokeninfo < Base
          include RequestDataType
          PATH = "v1/identity/openidconnect/tokenservice"

          class << self
            def createFromAuthorizationCode(options, http_header = {})
              options = { :code => options } if options.is_a? String
              options = options.merge( :grant_type => "authorization_code" )
              Tokeninfo.new(api.post(PATH, with_credentials(options), http_header))
            end
            alias_method :create_from_authorization_code, :createFromAuthorizationCode
            alias_method :create, :createFromAuthorizationCode

            def createFromRefreshToken(options, http_header = {})
              options = { :refresh_token => options } if options.is_a? String
              options = options.merge( :grant_type => "refresh_token" )
              Tokeninfo.new(api.post(PATH, with_credentials(options), http_header))
            end
            alias_method :create_from_refresh_token, :createFromRefreshToken
            alias_method :refresh, :createFromRefreshToken

            def with_credentials(options = {})
              options = options.dup
              [ :client_id, :client_secret ].each do |key|
                options[key] = api.config.send(key) unless options[key] or options[key.to_s]
              end
              options
            end
          end

          def refresh
            self.class.createFromRefreshToken( :refresh_token => self.refresh_token )
          end
        end

        class Userinfo < Base
          include RequestDataType
          PATH = "v1/identity/openidconnect/userinfo"

          class << self
            def getUserinfo(options = {}, http_header = {})
              options = { :access_token => options } if options.is_a? String
              options = options.merge( :schema => "openid" ) unless options[:schema] or options["schema"]
              Userinfo.new(api.post(PATH, options, http_header))
            end
          end
        end

        class Authorizeinfo < Base
          include RequestDataType
          DEFAULT_OPENID_URL= "https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/authorize"

          class << self
            def authorize_url(params = {})
              params = default_params.merge(params)
              request_uri = openid_endpoint
              request_uri.query = api.encode_www_form(params)
              request_uri.to_s
            end

            def openid_endpoint
              URI(DEFAULT_OPENID_URL)
            end

            def default_params
              { :response_type => "code",
                :scope => "openid",
                :client_id => api.config.client_id,
                :redirect_uri => api.config.openid_redirect_uri }
            end
          end
        end

      end

    end
  end
end
