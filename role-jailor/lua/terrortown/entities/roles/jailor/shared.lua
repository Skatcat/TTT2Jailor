if SERVER then
	AddCSLuaFile()

	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_jail.vmt")
end

-- creates global var "TEAM_SERIALKILLER" and other required things
-- TEAM_[name], data: e.g. icon, color,...
roles.InitCustomTeam(ROLE.name, {
		icon = "vgui/ttt/dynamic/roles/icon_jail",
		color = Color(49, 105, 109, 255)
})

ROLE.color = Color(107, 124, 151, 255) -- ...
ROLE.dkcolor = Color(107, 124, 151, 255) -- ...
ROLE.bgcolor = Color(107, 124, 151, 255) -- ...
ROLE.abbr = "jail" -- abbreviation
ROLE.defaultTeam = TEAM_INNOCENT -- the team name: roles with same team name are working together
ROLE.defaultEquipment = SPECIAL_EQUIPMENT -- here you can set up your own default equipment
ROLE.radarColor = Color(150, 150, 150) -- color if someone is using the radar
ROLE.surviveBonus = 0 -- bonus multiplier for every survive while another player was killed
ROLE.scoreKillsMultiplier = 1 -- multiplier for kill of player of another team
ROLE.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
ROLE.unknownTeam = true -- player don't know their teammates

ROLE.conVarData = {
	pct = 0.15, -- necessary: percentage of getting this role selected (per player)
	maximum = 2, -- maximum amount of roles in a round
	minPlayers = 7, -- minimum amount of players until this role is able to get selected
	credits = 0, -- the starting credits of a specific role
	togglable = true, -- option to toggle a role for a client if possible (F1 menu)
}

-- now link this subrole with its baserole
hook.Add("TTT2BaseRoleInit", "TTT2ConBRIWithJail", function()
	JAILOR:SetBaseRole(ROLE_INNOCENT)
end)

if CLIENT then
	hook.Add("TTT2FinishedLoading", "JailInitT", function()
		-- setup here is not necessary but if you want to access the role data, you need to start here
		-- setup basic translation !
		LANG.AddToLanguage("English", JAILOR.name, "Jailor")
		LANG.AddToLanguage("English", "info_popup_" .. JAILOR.name,
			[[You are a Jailor!
				Lock 'em up!]])
		LANG.AddToLanguage("English", "body_found_" .. JAILOR.abbr, "This was a Jailor...")
		LANG.AddToLanguage("English", "search_role_" .. JAILOR.abbr, "This person was a Jailor!")
		LANG.AddToLanguage("English", "target_" .. JAILOR.name, "Jailor")
		LANG.AddToLanguage("English", "ttt2_desc_" .. JAILOR.name, [[The Jailor locks people up]])

		---------------------------------

		-- maybe this language as well...
		LANG.AddToLanguage("Deutsch", JAILOR.name, "Wärter")
		LANG.AddToLanguage("Deutsch", "info_popup_" .. JAILOR.name,
			[[Du bist Wärter!
				Sperr die Bösen ein!]])
		LANG.AddToLanguage("Deutsch", "body_found_" .. JAILOR.abbr, "Er war ein Wärter...")
		LANG.AddToLanguage("Deutsch", "search_role_" .. JAILOR.abbr, "Diese Person war ein Wärter!")
		LANG.AddToLanguage("Deutsch", "target_" .. JAILOR.name, "Wärter")
		LANG.AddToLanguage("Deutsch", "ttt2_desc_" .. JAILOR.name, [[Der Wärter sperrt Leute ein!]])
		
		---------------------------------

		LANG.AddToLanguage("English", JAILOR.name, "Тюремщик")
		LANG.AddToLanguage("English", "info_popup_" .. JAILOR.name,
			[[Вы тюремщик!
				Запри их всех!]])
		LANG.AddToLanguage("English", "body_found_" .. JAILOR.abbr, "Он был тюремщиком...")
		LANG.AddToLanguage("English", "search_role_" .. JAILOR.abbr, "Этот человек был тюремщиком!")
		LANG.AddToLanguage("English", "target_" .. JAILOR.name, "Тюремщик")
		LANG.AddToLanguage("English", "ttt2_desc_" .. JAILOR.name, [[Тюремщик запирает людей]])
	end)
end

-- nothing special, just a inno that is able to access the [C] shop
