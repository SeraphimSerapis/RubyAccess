require 'restclient'
require 'json'

class Access
  # PayPal's OpenID Connect endpoints
  @@ENDPOINT_AUTHORIZE = 'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/authorize'
  @@ENDPOINT_ACCESS_TOKEN = 'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/tokenservice'
  @@ENDPOINT_PROFILE = 'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/userinfo'
  @@ENDPOINT_LOGOUT = 'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/endsession'
  @@ENDPOINT_VALIDATE = 'https://www.paypal.com/webapps/auth/protocol/openidconnect/v1/checkid'
  
  # the application's scope (profile, email, ...)
  @@SCOPES = 'openid'
  
  # the application's client details
  @@CLIENT_ID = 'YOUR ID'
  @@CLIENT_SECRET = 'YOUR SECRET'
  
  # the callback url to be used
  @@CALLBACK_URL = 'YOUR OWN URL'
  
  # the user's details
  @access_token = ''
  @refresh_token = ''
  @id_token = ''
  @nonce = ''
    
  # this method is being called when using the .new(..) method
  def initialize(id, secret, callback)
    @@CLIENT_ID = id
    @@CLIENT_SECRET = secret
    @@CALLBACK_URL = callback
    @nonce = Time.now.to_i + Random.rand(1...100)
  end
  
  # an optional method that helps to set additional scopes like 'openid+profile+email'
  def set_scopes(scopes)
    @@SCOPES = scopes
  end
  
  # returns the authorization url
  def get_auth_url
    "#{@@ENDPOINT_AUTHORIZE}?client_id=#{@@CLIENT_ID}&response_type=code&scope=#{@@SCOPES}&redirect_uri=#{@@CALLBACK_URL}&nonce=#{@nonce}"
  end
  
  # returns the profile's url
  def get_profile_url
    "#{@@ENDPOINT_PROFILE}?schema=openid&access_token=#{@access_token}"
  end
  
  # returns the logout url
  def get_logout_url
    "#{@@ENDPOINT_LOGOUT}?id_token=#{@id_token}&redirect_uri=#{URI.escape(@@CALLBACK_URL)}&logout=true"
  end
  
  # this method is being used to receive an access token
  def get_access_token(code)
    query = {
      'client_id' => @@CLIENT_ID,
      'client_secret' => @@CLIENT_SECRET,
      'grant_type' => 'authorization_code',
      'code' => code
    }
    
    begin
      body = RestClient.post @@ENDPOINT_ACCESS_TOKEN, query
      response = JSON.parse(body)
      @access_token = response['access_token']
      @refresh_token = response['refresh_token']
      @id_token = response['id_token']
    rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::BadRequest, RestClient::ResourceNotFound
      nil
    end
    nil
  end
  
  # this method is being used to refresh the user's access token
  def refresh_access_token
    query = {
      'client_id' => @@CLIENT_ID,
      'client_secret' => @@CLIENT_SECRET,
      'grant_type' => 'refresh_token',
      'refresh_token' => @refresh_token,
      'scope' => @@SCOPES
    }
    begin
      body = RestClient.post @@ENDPOINT_ACCESS_TOKEN, query
      response = JSON.parse(body)
      @access_token = response['access_token']
    rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::BadRequest, RestClient::ResourceNotFound
      nil
    end
    nil
  end
  
  # this method is being used to validate if the user's tokens are still valid
  def validate
    query = {
      'access_token' => @id_token
    }
    begin
      body = RestClient.post @@ENDPOINT_VALIDATE, query
    rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::BadRequest, RestClient::ResourceNotFound
      nil
    end
  end
  
  # this is being used to end the current session
  def logout
    begin
      body = RestClient.get get_logout_url()
    rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::BadRequest, RestClient::ResourceNotFound
      nil
    end
  end
  
  # this is being used to receive the user's profile according to the provided scopes
  def get_profile
    begin
      body = RestClient.get get_profile_url()
    rescue RestClient::Unauthorized, RestClient::Forbidden, RestClient::BadRequest, RestClient::ResourceNotFound
      nil
    end
  end
  
end
