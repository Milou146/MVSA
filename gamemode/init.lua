AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "panel/mvsa_panel.lua" )
AddCSLuaFile( "config.lua" )

util.AddNetworkString("mvsa_character_creation")
util.AddNetworkString("mvsa_character_deletion")
util.AddNetworkString("mvsa_character_selection")
util.AddNetworkString("mvsa_character_selected")
util.AddNetworkString("mvsa_character_information")

sql.Query("CREATE TABLE IF NOT EXISTS mvsa_player_character( SteamID64 BIGINT NOT NULL, Faction BOOL, RPName VARCHAR(45), ModelIndex TINYINT, Size SMALLINT NOT NULL, Skin TINYINT, BodyGroups VARCHAR(60) )")

include( "shared.lua" )
include( "config.lua" )

local function CheckData(ply)
	local data = sql.Query(" SELECT * FROM mvsa_player_character WHERE SteamID64 = " .. tostring(ply:SteamID64()))
	if not data then
		net.Start( "mvsa_character_creation" )
		net.Send(ply)
	else
		net.Start( "mvsa_character_selection" )
		net.WriteUInt( #data, 5 )
		for k,v in pairs(data) do
			net.WriteString( v["Faction"] )
			net.WriteString( v["RPName"] )
			net.WriteString( v["ModelIndex"] )
			net.WriteString( v["Size"] )
			net.WriteString( v["Skin"] )
			net.WriteString( v["BodyGroups"] )
		end
		net.Send(ply)
	end
end

function RunClass( ply )
	player_manager.SetPlayerClass( ply, "player_" .. string.lower(ply.Faction) )
	player_manager.RunClass(ply, "Loadout")
	ply:Spawn()
end
local function SetupMapLua()
	MapLua = ents.Create( "lua_run" )
	MapLua:SetName( "triggerhook" )
	MapLua:Spawn()
end

hook.Add( "InitPostEntity", "SetupMapLua", SetupMapLua )
hook.Add( "PostCleanupMap", "SetupMapLua", SetupMapLua )

function GM:PlayerInitialSpawn(ply, transition)
	player_manager.SetPlayerClass( ply, "player_spectator" )
	CheckData(ply)
end

function GM:PlayerSpawn(ply, transition)
	if player_manager.GetPlayerClass( ply ) == "player_spectator" then
		local view_ent = ents.FindByName("spectator_view")[1]
		ply:SetViewEntity(view_ent)

	else
		ply:SetViewEntity(ply)
		ply:SetModel( MVSA[ply.Faction][ply.ModelIndex][1] )
		ply:SetModelScale( ply.Size / 180, 0 )
		ply:SetSkin( ply.Skin )
		for k,v in pairs(ply.BodyGroups) do
			ply:SetBodygroup( k - 1, v )
		end
		ply:SetupHands() -- Create the hands and call GM:PlayerSetHandsModel
	end
end

net.Receive( "mvsa_character_information", function( len, ply )
	ply.SteamID64 = ply:SteamID64()
	ply.Faction = net.ReadBit()
	ply.RPName = net.ReadString()
	ply.ModelIndex = net.ReadUInt( 5 )
	ply.Size = net.ReadUInt( 8 )
	ply.Skin = net.ReadUInt( 5 )
	ply.BodyGroups = net.ReadString()

	sql.Query( "INSERT INTO mvsa_player_character VALUES( " .. ply.SteamID64 .. ", " .. tostring(ply.Faction) .. ", " .. SQLStr(ply.RPName) .. ", " .. tostring(ply.ModelIndex) .. ", " .. tostring(ply.Size) .. ", " .. tostring(ply.Skin) .. ", '" .. ply.BodyGroups .. "' )")
	ply.BodyGroups = string.Split(ply.BodyGroups, ",")
	if ply.Faction == 1 then
		ply.Faction = "Survivor"
	else
		ply.Faction = "USMC"
	end
	RunClass( ply )
end)

net.Receive("mvsa_character_deletion", function(len, ply)
	local rpname = net.ReadString()
	sql.Query("DELETE FROM mvsa_player_character WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. rpname .. "'")
end)

net.Receive("mvsa_character_selected", function(len, ply)
	local rpname = net.ReadString()
	local Character = sql.QueryRow("SELECT * FROM mvsa_player_character WHERE SteamID64 = " .. tostring(ply:SteamID64()) .. " AND RPName = " .. "'" .. rpname .. "'")
	if Character.Faction == "1" then Character.Faction = "Survivor" else Character.Faction = "USMC" end
	ply.Faction = Character.Faction
	ply.ModelIndex = tonumber(Character.ModelIndex)
	ply.Size = tonumber(Character.Size)
	ply.Skin = tonumber(Character.Skin)
	ply.BodyGroups = string.Split(Character.BodyGroups, ",")
	RunClass( ply )
end)

function GM:PlayerSelectSpawn( ply, transition )
	if ply.Faction == "USMC" then
		local spawns = ents.FindByClass("info_player_usmc")
		local random_entry = math.random(#spawns)

		return spawns[random_entry]
	elseif ply.Faction == "Survivor" then
		local spawns = ents.FindByClass("info_player_survivor")
		local random_entry = math.random(#spawns)

		return spawns[random_entry]
	end
end




hook.Add( "GasMaskNeeded", "TestTeleportHook", function()
	print("Gas mask needed!")
end )