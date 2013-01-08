PayPal Access for Ruby
=====
This helper class helps you to integrate [PayPal Access](https://www.x.com/developers/paypal/products/paypal-access) (via OpenID Connect) into your Ruby projects. The example demonstrates how an integration in [Sinatra](http://www.sinatrarb.com/) could look like.

Usage
----
Integrate the helper by adding the following line
			
	require './access.rb'
Initialize it by providing your client's id, secret & callback-url. Providing additional scopes is optional and can be used to retrieve additional user values.
	
	access = Access.new('YOUR_ID', 'YOUR_SECRET', 'http://myurl.com/auth')
	access.set_scopes('openid+profile+email')

Gems being used
-----
- Helper class 
	- *restclient* - for all POST- and GET-requests
	- *json* - to parse PayPal's responses
- Example
	- *sinatra* - a lightweight webserver


Author
-----
Tim Messerschmidt - PayPal Developer Evangelist - [tmesserschmidt@paypal.com](mailto:tmesserschmidt@paypal.com)