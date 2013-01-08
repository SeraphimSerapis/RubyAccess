require 'sinatra'
require './access.rb'

access = Access.new('YOUR_ID', 'YOUR_SECRET', 'http://myurl.com/auth')
access.set_scopes('openid+profile+email')

get '/' do
  redirect to(access.get_auth_url)
end

get '/rubyauth' do
  @code = params[:code]
  access.get_access_token(@code)
end 

get '/profile' do
  access.get_profile()
end

get '/refresh' do
  access.refresh_access_token()
end

get '/validate' do
  access.validate()
end

get '/logout' do
  access.logout()
end