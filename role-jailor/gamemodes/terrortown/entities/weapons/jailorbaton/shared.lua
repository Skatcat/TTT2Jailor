/// TTT Support!
local IsTTT = ((ROLE_TRAITOR != nil) and (ROLE_INNOCENT != nil) and (ROLE_DETECTIVE != nil))
if IsTTT then
	SWEP.Base = "weapon_tttbase"
	SWEP.Kind = WEAPON_EQUIP2
	SWEP.Icon = "entities/adminstick"
	SWEP.CanBuy = {}
	SWEP.InLoadoutFor = nil
	SWEP.LimitedStock = true
	SWEP.EquipMenuData = {
		type = "Weapon",
		desc = "Stick used for administration"
	}
	SWEP.AllowDrop = true
	SWEP.IsSilent = true
	SWEP.NoSights = true
	SWEP.AutoSpawnable = false
end

local ULXCmds = ULib.cmds.translatedCmds // Shortcut

local avcommands = {} // List of available commands
if SERVER then
	/*
	Writes current commands to the file
	*/
	local function WriteFile()
		local filedat = table.concat(avcommands,"¤")
		file.Write("adminstick.txt", filedat)
	end
	
	/*
	Adds a command
	*/
	local function AddCmd(cmd)
		table.insert(avcommands, cmd)
		WriteFile()
		
		net.Start("adminsticksendinitcmds")
			net.WriteTable(avcommands)
		net.Broadcast()
	end
	
	/*
	Removes a command
	*/
	local function RemoveCmd(cmd)
		for k,v in pairs(avcommands) do
			if v == cmd then
				table.remove(avcommands, k)
				break
			end
		end
		
		WriteFile()
		
		net.Start("adminsticksendinitcmds")
			net.WriteTable(avcommands)
		net.Broadcast()
	end
	
	/*
	Reads the file and adds the commands it found
	*/
	hook.Add("Initialize", "LoadJailor's BatonCommands", function()
		if not file.Exists("adminstick.txt", "DATA") then return end
		
		local filedat = file.Read("adminstick.txt", "DATA")
		local commies = string.Explode("¤", filedat)
		for k,v in pairs(commies) do
			if not ULXCmds[v] then
				MsgN("Jailor's Baton Readfile: Tried to add invalid command \""..v.."\" to the adminstick!")
				return
			end
			
			table.insert(avcommands, v)
		end
	end)
	
	/*
	Send commands upon player spawn
	*/
	util.AddNetworkString("adminsticksendinitcmds")
	hook.Add("PlayerInitialSpawn", "SendJailor's BatonCommandsToPlayer", function(ply)
		net.Start("adminsticksendinitcmds")
			net.WriteTable(avcommands)
		net.Send(ply)
	end)
	
	concommand.Add("adminstick_addcmd", function(ply,_,args)
		if IsValid(ply) and not ply:IsAdmin() and not game.SinglePlayer() then
			ply:PrintMessage(HUD_PRINTCONSOLE, "Run this from server console or rcon (or just be admin)!")
			return
		end
		
		local cmd = table.concat(args, " ")
		if not ULXCmds[cmd] then
			MsgN("Invalid ulx command! \""..cmd.."\" (Make sure you prefix it with 'ulx', example: \"ulx slap\")")
			return
		end
		
		AddCmd(cmd)
		
		MsgN("\""..cmd.."\" was added successfully!")
	end)
	
	concommand.Add("adminstick_removecmd", function(ply,_,args)
		if IsValid(ply) and not ply:IsAdmin() and not game.SinglePlayer() then
			ply:PrintMessage(HUD_PRINTCONSOLE, "Run this from server console or rcon!")
			return
		end
		
		local cmd = table.concat(args, " ")
		if not table.HasValue(avcommands, cmd) then
			MsgN("This command doesn't currently exist for the adminstick!")
			return
		end
		
		RemoveCmd(cmd)
		
		MsgN("\""..cmd.."\" was removed successfully!")
	end)
else
	net.Receive("adminsticksendinitcmds", function()
		avcommands = net.ReadTable()
	end)
end

if SERVER then
	AddCSLuaFile("shared.lua")
	resource.AddFile("materials/entities/adminstick.png")
end

if CLIENT then
	SWEP.PrintName = "Jailor's Baton"
	SWEP.Slot = 0
	SWEP.SlotPos = 5
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = false

concommand.Add("adminstick_help", function()
	MsgN([[
Jailor's Baton for ULX
Created by Donkie
http://steamcommunity.com/id/Donkie

RCon commands:
adminstick_addcmd <ulx command> (Example: 'adminstick_addcmd ulx slap')
adminstick_removecmd <ulx command> (Example: 'adminstick_removecmd ulx slap')]]..[[

If a ulx command requires a player argument, such as 'ulx slap', the player argument will automatically get set to the player you hit with the baton.

ConVars:
adminstick_unlimitedrange <1/0> (Set to 1 if you want the stick to have unlimited range, otherwise it's 100 units. Default: 0)]]..[[
adminstick_spawnforadmin <1/0> (Set to 1 if you want any admin to spawn with the stick automatically. Default: 0)
adminstick_allowuseonself <1/0> (Set to 1 if you want to allow admins to use the stick on themself. Default: 1)
]])
end)

usermessage.Hook("_openadminstickgui", function(um)
	if LocalPlayer():GetActiveWeapon():GetClass() != "adminstick" then return end

	/*
	Filter out commands not available to the user.
	This is done clientside and on every opening for dynamics, if the player changes rank, etc.
	*/
	local tempavcommands = {}
	for k,v in pairs(avcommands) do
		if ULib.ucl.query(LocalPlayer(), v, true) then
			table.insert(tempavcommands, v)
		end
	end
	
	local btnheight = 18
	local commandsnum = #tempavcommands
	local panellistheight = (commandsnum * (btnheight + 5)) + 5
	
	local men = vgui.Create("DFrame")
		men:SetSize(200, panellistheight + 22 + 5)
		men:Center()
		men:SetTitle("Jailor's Baton")
		men:MakePopup()
	
	if commandsnum == 0 then
		local lbl = vgui.Create("DLabel", men)
			lbl:SetText("No commands found.\nEither your rank doesn't cover any or\nnone is added.\nIf you want to add commands, type\n'adminstick_help' for further instructions.")
			lbl:SizeToContents()
			lbl:SetPos(5,25)
		
		men:SetTall(lbl:GetTall() + 25 + 5)
		return
	end
	
	local pnllist = vgui.Create("DPanelList", men)
		pnllist:SetSize(200, panellistheight)
		pnllist:SetPos( 0, 22 + 5)
		pnllist:SetSpacing(5)
		pnllist:SetPadding(5)
		pnllist:EnableVerticalScrollbar(false)
		pnllist:EnableHorizontal(false)
	
	for k,v in pairs(tempavcommands) do
		local btn = vgui.Create("DButton")
			btn:SetHeight(btnheight)
			btn:SetText(v)
			btn.DoClick = function()
				local targcmds = ULXCmds[v].args
				local frame, plist
				local function CreateFrame()
					if not frame then
						frame = vgui.Create("DFrame")
							frame:SetSize(200, 50)
							frame:Center()
							local px, py = frame:GetPos()
							frame:SetPos(100 + px, py)
							frame:SetTitle(v)
							frame:MakePopup()
						
						plist = vgui.Create("DPanelList", frame)
							plist:SetSize(200, 50)
							plist:SetPos(0, 25)
							plist:SetSpacing(5)
							plist:SetPadding(5)
							plist:EnableVerticalScrollbar(false)
							plist:EnableHorizontal(false)
					end
				end
				
				//Does garry let you change color of panels? Who knows? I don't atleast, so I'm drawing them myself.
				local pnlpaint = function(self, w, h)
					surface.SetDrawColor( Color(100, 100, 100, 255) )
					surface.DrawRect( 0, 0, w, h )
				end
				
				local args = {}
				local tall = 0
				for k2,v2 in ipairs(targcmds) do
					if v2.invisible then // Some parameters is only ment to be called from ulx, "ulx ragdoll" has a second parameter which is enable/disable ragdoll.
						continue
					end
					
					/*
					Adds a list of arguments, supports strings, numbers and booleans. Any player argument is turned into "#ply#" for processing serverside.
					*/
					if v2.type == ULib.cmds.PlayerArg or v2.type == ULib.cmds.PlayersArg then
						table.insert(args, function() return "#ply#" end)
					elseif v2.type == ULib.cmds.StringArg then
						//String argument
						CreateFrame()
						local p = vgui.Create("DPanel")
							p:SetTall(40)
							p.Paint = pnlpaint
						local lbl = vgui.Create("DLabel", p)
							lbl:SetText(v2.hint or "String Argument")
							lbl:SizeToContents()
							lbl:SetPos(3,3)
						local bx = vgui.Create("DTextEntry",p)
							bx:SetWide(180)
							bx:SetPos(3, 18)
							bx:SetText( "15" )
							
						plist:AddItem(p)
						table.insert(args, function() return "\""..bx:GetText().."\"" end)
						tall = tall + 45
					elseif v2.type == ULib.cmds.BoolArg then
						//Boolean argument
						CreateFrame()
						local p = vgui.Create("DPanel")
							p:SetTall(20)
							p.Paint = pnlpaint
						local bx = vgui.Create("DCheckBoxLabel",p)
							bx:SetPos(3, 3)
							bx:SetText(v2.hint or "Boolean Argument")
							bx:SetValue(0)
							bx:SizeToContents()
						plist:AddItem(p)
						table.insert(args, function() return bx:GetChecked() end)
						tall = tall + 25
					elseif v2.type == ULib.cmds.NumArg then
						//Number argument
						CreateFrame()
						local p = vgui.Create("DPanel")
							p:SetTall(40)
							p.Paint = pnlpaint
						local lbl = vgui.Create("DLabel", p)
							lbl:SetText(v2.hint or "Number Argument")
							lbl:SizeToContents()
							lbl:SetPos(3,3)
						local bx = vgui.Create("DTextEntry",p)
							bx:SetWide(580)
							bx:SetPos(3, 58)
							bx:SetText( "30" )
							bx.OnKeyCode = function()
								/*
								This code will prevent any characters except numbers from being inputted.
								I could use a numberwang but I fucking hate the new ones.
								Works like a charm except for cases where the caret isn't at the end of the string. Too small bug for me to care fixing.
								*/
								timer.Simple(.02,function()
									local gsubd = string.gsub(bx:GetText(), "[^%d]", "")
									local CaretPos = bx:GetCaretPos()
									bx:SetText( gsubd )
									bx:OnValueChange( gsubd )
									bx:SetCaretPos( math.min(CaretPos, #gsubd) ) // Uses math.min to prevent caret from going outside the string.
								end)
							end
						plist:AddItem(p)
						table.insert(args, function() return (tonumber(bx:GetText()) or 0) end)
						tall = tall + 45
					end
				end
				
				local function BuildString()
					local strtbl = {v} // Add the ulx command to the table
					for k2,v2 in ipairs(args) do
						table.insert(strtbl, v2()) // Add any arguments
					end
					
					return table.concat(strtbl, " ") // Bake it into a string
				end
				
				local function SendCmd()
					local str = BuildString()
					net.Start("adminsticksendcommand")
						net.WriteString(str)
					net.SendToServer()
					men:Close()
				end
				
				if frame then
					local runbtn = vgui.Create("DButton")
						runbtn:SetTall(20)
						runbtn:SetText("Continue")
						runbtn.DoClick = function()
							SendCmd()
							if frame then // Could've been closed
								frame:Close()
							end
						end
					plist:AddItem(runbtn)
						
					tall = tall + 25 + 5
					plist:SetTall(tall)
					frame:SetTall(tall + 25)
				else
					SendCmd()
				end
			end
		
		pnllist:AddItem(btn)
	end
end)
end

SWEP.Author = "Donkie"
SWEP.Instructions = "Rightclick to set command.\nLeftclick on player to execute it.\nReload to use the command on yourself (if enabled)."
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.IconLetter = ""

SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "stunstick"

SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.ViewModel = Model("models/weapons/v_stunbaton.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.Sound = Sound("weapons/stunstick/stunstick_swing1.wav")

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:OnDrop()
	self.command = ""
	
	if IsTTT then
		self:Remove()
	end
	return true
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:Initialize()
	self:SetWeaponHoldType("normal")

	self.command = "ulx jail"
	self.NextStrike = 0
end

local unlimitedrange
local allowuseonself
if SERVER then
	util.AddNetworkString("adminsticksendcommand")
	
	net.Receive("adminsticksendcommand", function(_,ply)
		if not IsValid(ply) then return end
		
		local wep = ply:GetWeapon("adminstick")
		if not wep or not IsValid(wep) then return end
		
		local cmd = net.ReadString()
		wep.command = cmd
	end)
	unlimitedrange = CreateConVar( "adminstick_unlimitedrange", 0, bit.bor(FCVAR_GAMEDLL, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE), "Does the adminstick have unlimited range?" )
	allowuseonself = CreateConVar( "adminstick_allowuseonself", 0, bit.bor(FCVAR_GAMEDLL, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE), "Can admins use the stick on themselves?" )
	
	local adminspawn = CreateConVar( "adminstick_spawnforadmin", 0, bit.bor(FCVAR_GAMEDLL, FCVAR_ARCHIVE, FCVAR_SERVER_CAN_EXECUTE), "Is the adminstick given to admins upon spawning?" )
	hook.Add("PlayerSpawn", "adminstickgivetoadmins", function(ply)
		if ply:IsAdmin() and adminspawn:GetBool() == true then
			ply:Give("adminstick")
		end
	end)
end

function SWEP:DoAttack( t )
	if self.NextStrike > CurTime() then return false end

	self:SetWeaponHoldType("melee")
	timer.Simple(0.3, function() if self:IsValid() then self:SetWeaponHoldType("normal") end end)

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Weapon:EmitSound(self.Sound)
	self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)

	self.NextStrike = CurTime() + .5

	if CLIENT then return true end

	if t == "secondary" then
		umsg.Start("_openadminstickgui", self.Owner)
		umsg.End()
		return false
	end
	
	if not self.command or self.command == "" then
		self.Owner:PrintMessage(HUD_PRINTTALK, "You have not set any action! (Use rightclick!)")
		return false
	end
	
	//If the command requires a player
	local reqplayer = ((string.find( self.command, "#ply#" ) or 0) > 0)
	if reqplayer then
		if t == "reload" then
			if allowuseonself:GetBool() == false then
				self.Owner:PrintMessage(HUD_PRINTTALK, "Using on self is disabled!")
				return false
			end
			
			local cmd = string.gsub( self.command, "#ply#", "\""..self.Owner:Nick().."\"" )
			MsgN("Jailor's Baton ("..self.Owner:Nick().."): "..cmd)
			self.Owner:ConCommand(cmd)
			return true
		end
		
		local trace = self.Owner:GetEyeTrace()
		if not IsValid(trace.Entity) or (unlimitedrange:GetBool() == false and (self.Owner:EyePos():Distance(trace.Entity:GetPos()) > 300)) then return false end
		
		//Makes you able to hit ragdolled players
		local ply
		if IsValid(trace.Entity.ragdolledPly) then
			ply = trace.Entity.ragdolledPly
		else
			ply = trace.Entity
		end
		
		if ply:IsPlayer() and ( self:CanPrimaryAttack() ) then
			local cmd = string.gsub( self.command, "#ply#", "\""..ply:Nick().."\"" )
			MsgN("Jailor's Baton ("..self.Owner:Nick().."): "..cmd)
			self.Owner:ConCommand(cmd)
			self.Weapon:TakePrimaryAmmo(1)
		end
	else
		MsgN("Jailor's Baton ("..self.Owner:Nick().."): "..(self.command))
		self.Owner:ConCommand(self.command)
	end
	
	return true
end

function SWEP:PrimaryAttack()
	if not self:DoAttack("primary") then return false end
	return true
end

function SWEP:SecondaryAttack()
	if not self:DoAttack("secondary") then return false end
	return true
end

function SWEP:Reload()
	if not self:DoAttack("reload") then return false end
	return true
end