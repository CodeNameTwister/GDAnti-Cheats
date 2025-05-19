class_name TrackNet extends Object
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#	GDAnti-Cheats
#
#	https://github.com/CodeNameTwister/GDAnti-Cheats
#	author:	"Twister"
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# TrackNet this is part of my Net API Anti-Cheat, 
# I decided to include it in this plugin because it doesn't perform kernel actions and It will surely be useful for some developer to use the technique of validating intercepts.
# As a tip, I suggest you validate the receipt of a dynamic response that isn't easily manipulated.

# Example usage: 
# check_connection(my_success_callback, my_fallback_callback)
#
# func my_success_callback(param0 : HttpClient):
# 	print("Has connection!") 
# 	#next_actions...
#
# func my_fallback_callback(param0 : Variant) -> void:
# 	print("Error, Not connection! http status:", param0)

static var user_agents : PackedStringArray = [
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.3923.1621 Safari/537.36",
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.1358.1972 Safari/537.36",
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/57.0.6908.1105 Safari/537.36",
	"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2583.1507 Safari/537.36"
]

# Change this if you want put a frienldy web for check validation in success response callback.
static var test_webs : PackedStringArray = [
	"www.google.com"
	,"archive.org"
	,"en.wikipedia.org"
	#,"www.eff.org"
	#"www.cloudflare.com"
]

static var use_agent : bool = true
static var use_random_agent : bool = false

## Check if user have a connection, 
## Please note that if your user has successfully logged in previously, they are online; any subsequent interceptions will indicate an offline connection.
## arguments:
## arg0: success_callback(param0 : HttpClient) # The HttpClient Maybe it have an body you want to validate.
## arg1: fallback(param0 : Variant) # Should be a intenger as Error Http Status Response.
static func check_connection(success_callback : Callable, fallback : Callable = TrackNet._fallback) -> void:
	var index : int = 0
	var response : Variant = null
	while index < test_webs.size():
		response = await _get_connection(test_webs[index])
		if response is HTTPClient:
			success_callback.call(response)
			return
		index += 1
	fallback.call(response)

static func _fallback(response : Variant) -> void:
	if OS.is_debug_build():
		printerr("Tracking Net, Fail Connection! Error: {0}".format([response]))


static func _get_connection(url : String) -> Variant:
	var err : int = 0
	var http : HTTPClient = HTTPClient.new()

	err = http.connect_to_host(url)
	
	if err != OK:
		return err
	
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		await Engine.get_main_loop().process_frame
		
	err = http.get_status()
	
	if err != HTTPClient.STATUS_CONNECTED:
		return err
	
	var agent : String = "Pirulo/1.0 (Godot)" #You will probably be blocked.
	if use_agent:
		if use_random_agent:
			var random : RandomNumberGenerator = RandomNumberGenerator.new()
			random.randomize()
			agent = user_agents[random.randi() % user_agents.size()]
			random = null
		else:
			agent = user_agents[0]
	
	var headers : PackedStringArray = ["User-Agent: {0}".format([agent]),"Content-Type: text/html;"]
	err = http.request(HTTPClient.METHOD_GET, "/index", headers)
	
	if err != OK:
		return err
	
	while http.get_status() == HTTPClient.STATUS_REQUESTING:
		http.poll()
		await Engine.get_main_loop().process_frame
		
	err = http.get_status() 
	
	if !(err == HTTPClient.STATUS_BODY or err == HTTPClient.STATUS_CONNECTED):
		return err

	return http
