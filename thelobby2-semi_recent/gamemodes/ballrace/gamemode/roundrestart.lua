local preserve = {"player",
	--"viewmodel",
	"gmt_hat",
	"worldspawn",
	"predicted_viewmodel",
	"player_manager",
	"soundent",
	"ai_network",
	"ai_hint",
	"env_soundscape",
	"env_soundscape_proxy",
	"env_soundscape_triggerable",
	"env_sprite",
	"env_sun",
	"env_wind",
	"env_fog_controller",
	"func_wall",
	"func_illusionary",
	"func_brush",
	"info_node",
	"info_target",
	"info_node_hint",
	"point_commentary_node",
	"point_viewcontrol",
	"func_precipitation",
	"func_team_wall",
	"shadow_control",
	"sky_camera",
	"scene_manager",
	"trigger_soundscape",
	"commentary_auto",
	"point_commentary_node",
	"point_commentary_viewpoint"}

local preservegame = {}

for k,v in ipairs(preserve) do
	table.insert(preservegame, v)
end

function game.CleanUpMapEx()
	if CLIENT then return end
	game.CleanUpMap(true, preservegame)
end