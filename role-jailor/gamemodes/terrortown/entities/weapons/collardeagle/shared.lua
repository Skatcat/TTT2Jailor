if CLIENT then
	SWEP.PrintName = "Collar Gun"
	SWEP.Author = "TFlippy"
	
	SWEP.Slot = 6 -- add 1 to get the slot number key
	
	SWEP.ViewModelFOV  = 70
	SWEP.ViewModelFlip = false
	SWEP.CSMuzzleFlashes = true
	
	SWEP.EquipMenuData = {
	type = "Gun",
	};
end

SWEP.Base = "weapon_tttbase"

SWEP.HoldType = "revolver"
SWEP.AutoSpawnable = false
SWEP.AllowDrop = true
SWEP.IsSilent = true
SWEP.NoSights = false
SWEP.Kind = WEAPON_EQUIP1

SWEP.Primary.Delay = 1.00
SWEP.Primary.Recoil = 1.50
SWEP.Primary.Automatic = false
SWEP.Primary.SoundLevel = 30

SWEP.Primary.ClipSize = 3
SWEP.Primary.ClipMax = 3
SWEP.Primary.DefaultClip = 3
SWEP.Primary.Ammo = ""

SWEP.CanBuy = { }
SWEP.LimitedStock = true

SWEP.Primary.Damage = 0.001
SWEP.Primary.Cone = 0.00025
SWEP.Primary.NumShots = 1

SWEP.IronSightsPos = Vector( -5.91, -4, 2.84 )
SWEP.IronSightsAng = Vector(-0.5, 0, 0)

SWEP.UseHands	= true
SWEP.ViewModel	= "models/weapons/v_tcom_deagle.mdl"	-- Weapon view model
SWEP.WorldModel	= "models/weapons/w_tcom_deagle.mdl"	-- Weapon world model
SWEP.Primary.Sound = Sound( "Weapon_TDegle.Single" )
 
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_SILENCED
SWEP.ReloadAnim = ACT_VM_RELOAD_SILENCED

function SWEP:Reload()
end

function SWEP:ReloadMenu()
	
	if not CLIENT then return end
	if self.Window then return end
	
	for k, v in pairs(self.Owner.Slaves) do
		if IsValid( v ) then
			if v:GetNWEntity( "slavecollar" ) == nil or v:GetNWEntity( "slavecollar" ) == NULL then
				table.RemoveByValue( self.Owner.Slaves, v )
				return
			end
		end
	end
	
	self.Window = vgui.Create("DFrame")
	self.Window:Center()
	self.Window:SetSize(608, 160)
	self.Window:SetTitle(" ")
	self.Window:ShowCloseButton(false)
				
	local alph = 0
	self.Window:MakePopup()
	//self.Window:SetDraggable(false)
	self.Window.Paint = function()
		if self.Window and IsValid(self.Window) then
			if alph < 200 then alph = alph + 3 end
		
			local w = self.Window:GetWide()
			local t = self.Window:GetTall()
		
			draw.RoundedBox(0, 0, 0, w, t, Color(0, 0, 0, alph))
		end
	end
	
	local btn = vgui.Create("DButton", self.Window)
	btn:SetPos(580, 10)
	btn:SetSize(20, 20)
	btn:SetText("X")
	btn:SetFont("default")
	btn:SetColor(Color(255, 255, 255))
	btn.DoClick = function()
		if self.Window and IsValid(self.Window) then 
			self.Window:Close() 
			self.Window = nil 
		else 
			print("ERROR: Window invalid")
		end
	end
	btn.Paint = function()
		local w = btn:GetWide()
		local t = btn:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0, alph * 0.7))
	end

	--------------------------------------------------------------------------
	
	local mg = vgui.Create("DListView", self.Window)
	mg:SetPos(12.5, 35)
	mg:SetSize(275, 30)
	mg:AddColumn("Prisoners (KILL)")
	mg.Paint = function() 
		local w = mg:GetWide()
		local t = mg:GetTall()
		
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 255, 255, alph * 0.5))
	end
	local all = vgui.Create("DButton", self.Window)
	all:SetPos(60, 70)
	all:SetSize(200, 30)
	all:SetText("KILL ALL")
	all:SetFont("default")
	all:SetColor(Color(255, 255, 255))
	all.DoClick = function()
		net.Start("TagSlaveAll")
			net.WriteEntity(self)
			net.WriteBool( true )
		net.SendToServer()
		table.Empty( self.Owner.Slaves )
		self.Window:Close() 
		self.Window = nil 
	end
	all.Paint = function()
		local w = all:GetWide()
		local t = all:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0, alph * 0.7))
	end
	for k, v in pairs(self.Owner.Slaves) do
		if IsValid( v ) then
			mg:AddLine(v:GetName(), "")
		end
	end
	mg.OnClickLine = function(parent, line, isselected)
		if not self.Weapon or not self then return end
		net.Start("TagSlave")
			net.WriteEntity(self)
			net.WriteString(line:GetValue(1))
			net.WriteBool( true )
		net.SendToServer()
		self.Window:Close() 
		self.Window = nil 
		
		timer.Simple(1, function()
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) then
					if v:GetNWEntity( "slavecollar" ) == nil or v:GetNWEntity( "slavecollar" ) == NULL then
						table.RemoveByValue( self.Owner.Slaves, v )
						return
					end
				end
			end
		end)
	end
	
	--------------------------------------------------------------------------
	
	local mg = vgui.Create("DListView", self.Window)
	mg:SetPos(320, 35)
	mg:SetSize(275, 30)
	mg:AddColumn("Prisoners (FREE)")
	mg.Paint = function() 
		local w = mg:GetWide()
		local t = mg:GetTall()
		
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 255, 255, alph * 0.5))
	end
	local all = vgui.Create("DButton", self.Window)
	all:SetPos(350, 70)
	all:SetSize(200, 30)
	all:SetText("FREE ALL")
	all:SetFont("default")
	all:SetColor(Color(255, 255, 255))
	all.DoClick = function()
		net.Start("TagSlaveAll")
			net.WriteEntity(self)
			net.WriteBool( false )
		net.SendToServer()
		table.Empty( self.Owner.Slaves )
		self.Window:Close() 
		self.Window = nil 
	end
	all.Paint = function()
		local w = all:GetWide()
		local t = all:GetTall()
		draw.RoundedBox(0, 0, 0, w, t, Color(255, 0, 0, alph * 0.7))
	end
	for k, v in pairs(self.Owner.Slaves) do
		if IsValid( v ) then
			mg:AddLine(v:GetName(), "")
		end
	end
	mg.OnClickLine = function(parent, line, isselected)
		if not self.Weapon or not self then return end
		
		net.Start("TagSlave")
			net.WriteEntity(self)
			net.WriteString(line:GetValue(1))
			net.WriteBool( false )
		net.SendToServer()
		self.Window:Close() 
		self.Window = nil 
		
		timer.Simple(1, function()
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) then
					if v:GetNWEntity( "slavecollar" ) == nil or v:GetNWEntity( "slavecollar" ) == NULL then
						table.RemoveByValue( self.Owner.Slaves, v )
						return
					end
				end
			end
		end)
	end
	
end

function SWEP:Think()

	if not self.Owner.SlaveDetonateDist then
		self.Owner.SlaveDetonateDist = 600
	end
	if not self.Owner.Slaves then
		self.Owner.Slaves = {}
	end

	if self.Owner:GetVelocity():Length() > 350 or self.Weapon:GetDTBool(0) then
		self:SetWeaponHoldType( 'normal' )
		self:SetHoldType( 'normal' )
	else
		self:SetWeaponHoldType(self.HoldType)
		self:SetHoldType(self.HoldType)
	end
	
	if self.Enslave then
		local ent = self:GetNWEntity( "EnslaveTarg" )
		if ent then
			local trace = util.QuickTrace( self.Owner:EyePos(), self.Owner:GetAimVector() * 80, self.Owner )
			if trace.Entity ~= ent then
				self:SetNWEntity( "EnslaveTarg", nil )
				self.Enslave = false
			end
		end
		if self:GetNWFloat( "EnslaveTime" ) < CurTime() then
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			local vm = self.Owner:GetViewModel()
			self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW)
			timer.Simple( vm:SequenceDuration(), function()
				if not self then return end
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_THROW2)
				timer.Simple( vm:SequenceDuration(), function()
					if not self then return end
					self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_IDLE)
				end)
			end)
			table.insert( self.Owner.Slaves, ent )
			self.Enslave = false
			
			if SERVER then
				local collar = ents.Create("ent_mad_collar")
				self.Weapon:TakePrimaryAmmo(1)
				if ent:LookupBone( "ValveBiped.Bip01_Neck1" ) then
					collar:SetPos( ent:GetBonePosition( ent:LookupBone( "ValveBiped.Bip01_Neck1" ) ) )
					collar:SetParent( ent, ent:LookupBone( "ValveBiped.Bip01_Neck1" ) )
				else
					collar:SetPos( ent:GetPos() + Vector( 0, 0, 50 ) )
					collar:SetParent( ent )
				end
				collar.Attach = ent
				collar:SetOwner( self.Owner )
				collar:Spawn()
				collar:Activate()
				
				ent.slavecollar = collar
				ent:SetNWEntity( "slavecollar", collar )
			end
		end
	end
	

	self:SecondThink()

	self:NextThink(CurTime())
end

/*---------------------------------------------------------
   Name: SWEP:SecondThink()
   Desc: Called every frame.
---------------------------------------------------------*/
function SWEP:SecondThink()
	if self.Owner:KeyPressed( IN_RELOAD ) then
		self:ReloadMenu()
	end
	if SERVER then
		net.Receive("SetDetonationDistance", function() 
			local dist = net.ReadFloat()
			self.Owner.SlaveDetonateDist = dist
		end)
		net.Receive("TagSlave", function()
			local wep = net.ReadEntity()
			local name = net.ReadString()
			local kill = net.ReadBool()
			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
			timer.Simple( self.Owner:GetViewModel():SequenceDuration(), function()
				if not self then return end
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_IDLE)
			end)
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			if not self.Owner.Slaves then return end
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) and v:GetName() == name then
					if IsValid( v.slavecollar ) then
						if kill then
							v.slavecollar:Explode() --v:TakeDamage( 250, self.Owner, v.slavecollar )
						else
							v.slavecollar:Remove()
						end
					end
					table.RemoveByValue( self.Owner.Slaves, v )
					return
				end
			end
		end)
		net.Receive("TagSlaveAll", function()
			local wep = net.ReadEntity()
			local kill = net.ReadBool()
			if not self.Owner.Slaves then return end
			self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
			timer.Simple( self.Owner:GetViewModel():SequenceDuration(), function()
				if not self then return end
				self.Weapon:SendWeaponAnim(ACT_SLAM_THROW_IDLE)
			end)
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
			for k, v in pairs(self.Owner.Slaves) do
				if IsValid( v ) then
					if IsValid( v.slavecollar ) then
						if kill then
							v.slavecollar:Explode() --v:TakeDamage( 250, self.Owner, v.slavecollar )
						else
							v.slavecollar:Remove()
						end
					end
					table.RemoveByValue( self.Owner.Slaves, v )
				end
			end
		end)
	end
end
 
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW_SILENCED)
	return true
end
  
function SWEP:Shoot()
	local cone = self.Primary.Cone
	local bullet = {}
	bullet.Num		 = self.Primary.NumShots
	bullet.Src		 = self.Owner:GetShootPos()
	bullet.Dir		 = self.Owner:GetAimVector()
	bullet.Tracer	 = 0
	bullet.Force	 = 1
	bullet.Damage	 = self.Primary.Damage
	--bullet.TracerName = "AntlionGib"

	self.Owner:FireBullets( bullet )
end
  
function SWEP:PrimaryAttack(worldsnd)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
 
	if not self:CanPrimaryAttack() then return end
	if self.Enslave then return end
	self.Owner:LagCompensation(true)
	
	self.Weapon:EmitSound( self.Primary.Sound )
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)

	self:Shoot()
	
	local trEntity = self.Owner:GetEyeTrace().Entity
	
	if SERVER then
		if self.Owner:GetEyeTrace().HitNonWorld and self.Owner:GetEyeTrace().Entity:IsPlayer() then	
			local id = trEntity:UniqueID()
								
			if IsValid(trEntity) and trEntity:IsTerror() then
				self:SetNWEntity( "EnslaveTarg", trEntity )
				self.Enslave = true
			end
			else
		end
	end

	if IsValid(self.Owner) then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self.Owner:ViewPunch( Angle( math.Rand(-0.8,-0.8) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	end
 
end

SWEP.IronSightsPos = Vector (-1.7102, 0, 1.2585)
SWEP.IronSightsAng = Vector (0, 0, 0)
SWEP.SightsPos = Vector (-1.7102, 0, 0.2585)
SWEP.SightsAng = Vector (0, 0, 0)
SWEP.RunSightsPos = Vector(3.444, -7.823, -6.27)
SWEP.RunSightsAng = Vector(60.695, 0, 0)

function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom( bIronsights )
   end

   self:SetNextSecondaryFire( CurTime() + 0.3 )
end
function SWEP:SetZoom(state)
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then
      self.Owner:SetFOV(60, 0.5)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

if SERVER then
	hook.Add("Initialize", "AddCollarToDefaultLoadout", function()
		local wep = weapons.GetStored("collardeagle")

		if wep then
			wep.InLoadoutFor = wep.InLoadoutFor or {}

			if not table.HasValue(wep.InLoadoutFor, ROLE_JAILOR) then
				table.insert(wep.InLoadoutFor, ROLE_JAILOR)
			end
		end
	end)
end