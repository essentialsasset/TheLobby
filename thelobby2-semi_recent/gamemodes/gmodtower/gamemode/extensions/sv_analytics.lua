
-------------------------------------------------
require("reqwest")



module( "analytics", package.seeall )

function postDiscord( Type, text )

	text = "["..(Type or "Logs").."] " .. text

	local authKey = "y2TLzMxGzEbLH8tTyzDLQsu7zFfMi8tCy7vL78tky7vL78u7"
	local AnalyticsURL = "http://gmtthelobby.com/deluxeanalytics.php?"

	reqwest({
		method = "POST",
		url = AnalyticsURL .. "key=" .. authKey .. "&message=" .. text .. "&user=" .. "SERVER @ " .. tostring(game.GetIPAddress()),
		timeout = 30,
		
		body = util.TableToJSON({ content = "test" }), -- https://discord.com/developers/docs/resources/webhook#execute-webhook
		type = "application/json",

		headers = {
			["User-Agent"] = "My User Agent", -- This is REQUIRED to dispatch a Discord webhook
		},

		success = function(status, body, headers)
			print("HTTP " .. status)
			PrintTable(headers)
			print(body)
		end,

		failed = function(err, errExt)
			print("Error: " .. err .. " (" .. errExt .. ")")
			MsgC( Color( 255, 0, 0 ), "/!\\---Deluxe Analytics Error---/!\\\n")
			MsgC( Color( 255, 0, 0 ), failed .. "(" .. errExt .. ")" )
		end
	})
	-- http.Post( AnalyticsURL, { key = authKey, message = text, user = "SERVER @ " .. tostring(game.GetIPAddress()) }, function( result )
	-- end,
	-- function( failed )
	-- 	MsgC( Color( 255, 0, 0 ), "/!\\---Deluxe Analytics Error---/!\\\n")
	-- 	MsgC( Color( 255, 0, 0 ), failed )
	-- end )
end

hook.Add( "InitPostEntity", "InitAnalytics", function()
    timer.Simple( 25, function()
      analytics.postDiscord( "Logs", engine.ActiveGamemode() .. " server went up at " .. tostring( game.GetIPAddress() ) )
    end)
end )

hook.Add( "ShutDown", "ShutdownAnalytics", function()
    analytics.postDiscord( "Logs", engine.ActiveGamemode() .. " server shutting down..." )
end )
