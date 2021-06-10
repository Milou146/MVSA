SWEP.PrintName		= "Scripted Weapon"
SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= ""

SWEP.ViewModelFOV	= 54
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_357.mdl"

SWEP.UseHands 		= true

SWEP.HoldType		= ""
SWEP.BothFireMode	= true				-- Have the weapon both fire mode

SWEP.Primary.ClipSize		= 8			-- Size of a clip
SWEP.Primary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Primary.Automatic		= false		-- Automatic/Semi Auto
SWEP.Primary.Ammo			= ""
SWEP.Primary.RPM			= 150
SWEP.Primary.Sound			= Sound("")

SWEP.Secondary.ClipSize		= 8			-- Size of a clip
SWEP.Secondary.DefaultClip	= 32		-- Default number of bullets in a clip
SWEP.Secondary.Automatic	= false		-- Automatic/Semi Auto
SWEP.Secondary.Ammo			= ""

SWEP.MuzzleAttachment		= "1"
 
SWEP.IronSightsPos = Vector (2.4537, 1.0923, 0.2696)
SWEP.IronSightsAng = Vector (0.0186, -0.0547, 0)

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
local IsLowering = false
local IsSelectingFireMode = false
local IsReloading = false
local IsDeploying = false
local HaveToBeSwitchedAuto = false

function SWEP:Initialize()
	self:SetNWBool("IsLowered", true)
	self:SetHoldType( "passive" )
	if IsValid(self.Owner) then
		self.Weapon:SendWeaponAnim( ACT_VM_DEPLOY )
		IsDeploying = true
		timer.Simple( self.Owner:GetViewModel():SequenceDuration() , function()
			IsDeploying = false
			self.Weapon:SendWeaponAnim( ACT_VM_IDLE_LOWERED )
		end )
	end
end

--[[---------------------------------------------------------
	Name: SWEP:PrimaryAttack()
	Desc: +attack1 has been pressed
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()

	-- Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	-- Play shoot sound
	self:EmitSound( self.Primary.Sound )

	-- Shoot 9 bullets, 150 damage, 0.75 aimcone
	self:ShootBullet( 150, 1, 0.01, self.Primary.Ammo )

	-- Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))

	-- Punch the player's view
	if ( !self.Owner:IsNPC() ) then self.Owner:ViewPunch( Angle( -1, 0, 0 ) ) end

end

--[[---------------------------------------------------------
	Name: SWEP:SecondaryAttack()
	Desc: +attack2 has been pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()

	-- Make sure we can shoot first
	if ( !self:CanSecondaryAttack() ) then return end

	-- Play shoot sound
	self:EmitSound("Weapon_Shotgun.Single")

	-- Shoot 9 bullets, 150 damage, 0.75 aimcone
	self:ShootBullet( 150, 9, 0.2, self.Secondary.Ammo )

	-- Remove 1 bullet from our clip
	self:TakeSecondaryAmmo( 1 )

	-- Punch the player's view
	if ( !self.Owner:IsNPC() ) then self.Owner:ViewPunch( Angle( -10, 0, 0 ) ) end

end

--[[---------------------------------------------------------
	Name: SWEP:Reload()
	Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:Reload()
	if !IsReloading and !IsSelectingFireMode and !IsLowering and !(self.Owner:KeyDown(IN_SPEED)) and !(self.Owner:KeyDown(IN_USE)) then
		if self:Clip1() <= 0 then
			IsReloading = true
			self.Weapon:DefaultReload( ACT_VM_RELOAD_EMPTY )
			self.Owner:SetAnimation( PLAYER_RELOAD )
			self:SetNWBool("IsLowered", false)
			self:SetHoldType( self.HoldType )
			if HaveToBeSwitchedAuto then
				self.Primary.Automatic = true
			end
		else if self:Clip1() < self.Primary.ClipSize then
			IsReloading = true
			self.Weapon:DefaultReload( ACT_VM_RELOAD )
			self.Owner:SetAnimation( PLAYER_RELOAD )
			self:SetNWBool("IsLowered", false)
			self:SetHoldType( self.HoldType )
		end end
	end
end

--[[---------------------------------------------------------
	Name: SWEP:Think()
	Desc: Called every frame
-----------------------------------------------------------]]

function SWEP:Think()
	if !self.IsDeploying and IsValid(self) and IsValid(self.Owner) then
		if !IsLowering and self.Owner:KeyDown(IN_SPEED) and self.Owner:KeyDown(IN_USE) and self.Owner:KeyDown(IN_RELOAD) then
			if !self:GetNWBool("IsLowered") then
				self.Weapon:SendWeaponAnim( ACT_VM_IDLE_LOWERED )
				IsLowering = true
				self:SetHoldType( "passive" )
				self:SetNWBool("IsLowered", true)
			else
				IsLowering = true
				self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
				self:SetHoldType( self.HoldType )
				self:SetNWBool("IsLowered", false)
			end
		end
		if IsLowering and !self.Owner:KeyDown(IN_RELOAD) then
			IsLowering = false
		end
		if !IsSelectingFireMode and !self.Owner:KeyDown(IN_SPEED) and self.Owner:KeyDown(IN_USE) and self.Owner:KeyDown(IN_RELOAD) and self.BothFireMode then
			IsSelectingFireMode = true
			if self.Primary.Automatic then
				self.Primary.Automatic = false
				if CLIENT then
					self.Owner:PrintMessage(HUD_PRINTTALK, "Semi-automatic selected.")
				end
				self.Weapon:EmitSound("Weapon_AR2.Empty")
			else
				self.Primary.Automatic = true
				if CLIENT then
					self.Owner:PrintMessage(HUD_PRINTTALK, "Automatic selected.")
				end
				self.Weapon:EmitSound("Weapon_AR2.Empty")
			end
		end
		if IsSelectingFireMode and !self.Owner:KeyDown(IN_RELOAD) then
			IsSelectingFireMode = false
		end
		if IsReloading and !self.Owner:KeyDown(IN_RELOAD) then
			IsReloading = false
		end
		if self.Owner:KeyDown(IN_SPEED) and !IsDeploying and !IsReloading then
			self.Weapon:SendWeaponAnim( ACT_VM_IDLE_LOWERED )
			self:SetHoldType( "passive" )
			timer.Simple( 0.1 , 
			function()
				if !self.Owner:KeyDown(IN_SPEED) and !self:GetNWBool("IsLowered") then
					self.Weapon:SendWeaponAnim( ACT_VM_IDLE )
					self:SetHoldType( self.HoldType )
				end
			end)
		end
	end
end

--[[---------------------------------------------------------
	Name: SWEP:Holster( weapon_to_swap_to )
	Desc: Weapon wants to holster
	RetV: Return true to allow the weapon to holster
-----------------------------------------------------------]]
function SWEP:Holster( wep )
	if self.IsDeploying then
		return false
	end
	return true
end

--[[---------------------------------------------------------
	Name: SWEP:Deploy()
	Desc: Whip it out
-----------------------------------------------------------]]
function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	return true
end

--[[---------------------------------------------------------
	Name: SWEP:ShootEffects()
	Desc: A convenience function to create shoot effects
-----------------------------------------------------------]]
function SWEP:ShootEffects()
	local L = { ACT_VM_RECOIL1 , ACT_VM_RECOIL2 , ACT_VM_RECOIL3 }

	self.Weapon:SendWeaponAnim( L[math.random(1,3)] )		-- View model animation
	self.Owner:MuzzleFlash()						-- Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )		-- 3rd Person Animation

end

--[[---------------------------------------------------------
	Name: SWEP:ShootBullet()
	Desc: A convenience function to shoot bullets
-----------------------------------------------------------]]
function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )

	local bullet = {}
	bullet.Num		= num_bullets
	bullet.Src		= self.Owner:GetShootPos()			-- Source
	bullet.Dir		= self.Owner:GetAimVector()			-- Dir of bullet
	bullet.Spread	= Vector( aimcone, aimcone, 0 )		-- Aim Cone
	bullet.Tracer	= tracer || 5						-- Show a tracer on every x bullets
	bullet.Force	= force || 1						-- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo
	
	self:SetNWBool("IsLowered", false)
	self:SetHoldType( self.HoldType )

	self.Owner:FireBullets( bullet )

	self:ShootEffects()

end

--[[---------------------------------------------------------
	Name: SWEP:TakePrimaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakePrimaryAmmo( num )

	-- Doesn't use clips
	if ( self:Clip1() <= 0 ) then

		if ( self:Ammo1() <= 0 ) then return end

		self.Owner:RemoveAmmo( num, self:GetPrimaryAmmoType() )

	return end

	self:SetClip1( self:Clip1() - num )

end

--[[---------------------------------------------------------
	Name: SWEP:TakeSecondaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakeSecondaryAmmo( num )

	-- Doesn't use clips
	if ( self:Clip2() <= 0 ) then

		if ( self:Ammo2() <= 0 ) then return end

		self.Owner:RemoveAmmo( num, self:GetSecondaryAmmoType() )

	return end

	self:SetClip2( self:Clip2() - num )

end

--[[---------------------------------------------------------
	Name: SWEP:CanPrimaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	if self.IsDeploying or self.Owner:KeyDown(IN_SPEED) then
		return false
	end

	if ( self:Clip1() <= 0 ) then

		self:EmitSound( "Weapon_Pistol.Empty" )
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE )
		if self.Primary.Automatic then
			self.Primary.Automatic = false
			HaveToBeSwitchedAuto = true
		end
		self.Primary.Automatic = false
		return false

	end

	return true

end

--[[---------------------------------------------------------
	Name: SWEP:CanSecondaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanSecondaryAttack()

	if self.IsDeploying then
		return false
	end

	if ( self:Clip2() <= 0 ) then

		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextSecondaryFire( CurTime() + 0.2 )
		return false

	end

	return true

end

--[[---------------------------------------------------------
	Name: OnRemove
	Desc: Called just before entity is deleted
-----------------------------------------------------------]]
function SWEP:OnRemove()
end

--[[---------------------------------------------------------
	Name: OwnerChanged
	Desc: When weapon is dropped or picked up by a new player
-----------------------------------------------------------]]
function SWEP:OwnerChanged()
end

--[[---------------------------------------------------------
	Name: Ammo1
	Desc: Returns how much of ammo1 the player has
-----------------------------------------------------------]]
function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self:GetPrimaryAmmoType() )
end

--[[---------------------------------------------------------
	Name: Ammo2
	Desc: Returns how much of ammo2 the player has
-----------------------------------------------------------]]
function SWEP:Ammo2()
	return self.Owner:GetAmmoCount( self:GetSecondaryAmmoType() )
end

--[[---------------------------------------------------------
	Name: SetDeploySpeed
	Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
-----------------------------------------------------------]]
function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

--[[---------------------------------------------------------
	Name: DoImpactEffect
	Desc: Callback so the weapon can override the impact effects it makes
		 return true to not do the default thing - which is to call UTIL_ImpactTrace in c++
-----------------------------------------------------------]]
function SWEP:DoImpactEffect( tr, nDamageType )

	return false

end