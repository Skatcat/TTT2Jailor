if CLIENT then
	SWEP.PrintName = "Collar Gun"
	SWEP.Author = "TFlippy"
	
	SWEP.Slot = 6 -- add 1 to get the slot number key
	
	SWEP.ViewModelFOV  = 55
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

SWEP.Primary.ClipSize = 5
SWEP.Primary.ClipMax = 1
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Ammo = "AR2AltFire"
SWEP.HeadshotMultiplier = 5

SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

SWEP.Primary.Damage = 5
SWEP.Primary.Cone = 0.00025
SWEP.Primary.NumShots = 0

SWEP.IronSightsPos = Vector( -5.91, -4, 2.84 )
SWEP.IronSightsAng = Vector(-0.5, 0, 0)

SWEP.UseHands	= true
SWEP.ViewModel  = Model("models/tflappy/cstrike/c_pist_usp.mdl")
SWEP.WorldModel = Model("models/tflappy/w_pist_usp_silencer.mdl")
SWEP.Primary.Sound = Sound( "TFlippy_Neurotoxin.Single" )
 
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK_SILENCED
SWEP.ReloadAnim = ACT_VM_RELOAD_SILENCED

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
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
 
	if not self:CanPrimaryAttack() then return end
	self.Owner:LagCompensation(true)
	
	self.Weapon:EmitSound( self.Primary.Sound )
	self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK_SILENCED)

	self:Shoot()
	
	local trEntity = self.Owner:GetEyeTrace().Entity
	ParticleEffect("tflippy_poison02", self.Owner:GetEyeTrace().HitPos, trEntity:GetAngles())
	
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
	end
	
	self:TakePrimaryAmmo( 1 )
	 
	if IsValid(self.Owner) then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		self.Owner:ViewPunch( Angle( math.Rand(-0.8,-0.8) * self.Primary.Recoil, math.Rand(-0.1,0.1) *self.Primary.Recoil, 0 ) )
	end
	self.Owner:LagCompensation(false)
 
end

function SWEP:WasBought(buyer)
	if IsValid(buyer) then
		buyer:GiveAmmo( 0, "AR2AltFire" )
	end
end

hook.Add("TTTEndRound", "KillSeizureTimer_End", function()
	for k,v in pairs(player.GetAll()) do
		timer.Destroy(v:UniqueID() .. "seizure")
		timer.Destroy(v:UniqueID() .. "spazmax")
	end
end)

hook.Add("TTTPrepareRound", "KillSeizureTimer_Prep", function()
	for k,v in pairs(player.GetAll()) do
		timer.Destroy(v:UniqueID() .. "seizure")
		timer.Destroy(v:UniqueID() .. "spazmax")
	end
end)