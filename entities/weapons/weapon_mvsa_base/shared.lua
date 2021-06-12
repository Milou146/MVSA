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

SWEP.Secondary.Ammo			= ""

SWEP.NextFireSelect = 0

SWEP.IronSightsPos = Vector (2.4537, 1.0923, 0.2696)
SWEP.IronSightsAng = Vector (0.0186, -0.0547, 0)
SWEP.FirstTime = 0

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]

function SWEP:Initialize()
	self:SetNWBool("IsLowering", false)
	self:SetNWBool("IsLowered", false)
	self:SetNWBool("IsReloading", false)
	self:SetNWBool("HaveToBeSwitchedAuto", false)
	self:SetNWBool("IsDeploying", true)
	self:SetNWBool("IsDeployed", false)
	self:SetNWBool("IsSelectingFireMode", false)
	self:SetHoldType(self.HoldType)
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
	self:ShootBullet( 150, 1, 0.05, self.Primary.Ammo )

	-- Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))

end

--[[---------------------------------------------------------
	Name: SWEP:SecondaryAttack()
	Desc: +attack2 has been pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
end

--[[---------------------------------------------------------
	Name: SWEP:Reload()
	Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:Reload()
	if !(self:GetOwner():KeyDown(IN_SPEED)) and !(self:GetOwner():KeyDown(IN_USE)) and !self:GetNWBool("IsSelectingFireMode") then
		if self.FirstTime == 0 then
			self.FirstTime = CurTime()
		end
		timer.Simple( 0.1,
		function()
			if !self:GetOwner():KeyDown(IN_RELOAD) then
				if (CurTime() - self.FirstTime) < 0.3 then
					self.FirstTime = 0
					if self:Clip1() <= 0 then
						self:SetNWBool("IsReloading", true)
						self:DefaultReload( ACT_VM_RELOAD_EMPTY )
						self:GetOwner():SetAnimation( PLAYER_RELOAD )
						if self:GetNWBool("HaveToBeSwitchedAuto") then
							self.Primary.Automatic = true
						end
					else if self:Clip1() < self.Primary.ClipSize then
						self:SetNWBool("IsReloading", true)
						self:DefaultReload( ACT_VM_RELOAD )
						self:GetOwner():SetAnimation( PLAYER_RELOAD )
					end end
				else
					self.FirstTime = 0
				end
			end
		end)
	end
end

--[[---------------------------------------------------------
	Name: SWEP:Think()
	Desc: Called every frame
-----------------------------------------------------------]]

function SWEP:Think()
	if !self:GetNWBool("IsDeployed") and self:GetOwner():IsPlayer() then
		self:SendWeaponAnim(ACT_VM_DEPLOY)
		timer.Simple(self:GetOwner():GetViewModel():SequenceDuration(),
		function()
			if self:GetOwner():Alive() then
				self:SetNWBool("IsDeploying", false)
			end
		end)
		self:SetNWBool("IsDeployed", true)
	end
	if !self:GetNWBool("IsDeploying") then
		if !self:GetNWBool("IsLowering") and self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_RELOAD) then
			self:SetNWBool("IsLowering", true)
			if !self:GetNWBool("IsLowered") then
				self:SetNWBool("IsLowered", true)
			else
				self:SetNWBool("IsLowered", false)
			end
		end
		if !self:GetOwner():KeyDown(IN_RELOAD) then
			if self:GetNWBool("IsLowering") then
				self:SetNWBool("IsLowering", false)
			end
			if self:GetNWBool("IsReloading") then
				self:SetNWBool("IsReloading", false)
			end
			if !self:GetOwner():KeyDown(IN_USE) and self:GetNWBool("IsSelectingFireMode") then
				self:SetNWBool("IsSelectingFireMode", false)
			end
		end
		if self:GetNWBool("IsLowered") then
			self:SendWeaponAnim( ACT_VM_IDLE_LOWERED )
			self:SetHoldType( "passive" )
		else
			self:SendWeaponAnim( ACT_VM_IDLE )
			self:SetHoldType( self.HoldType )
		end
		if !self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_RELOAD) and self.BothFireMode and self.NextFireSelect < CurTime() then
			self.NextFireSelect = CurTime() + 1
			self:EmitSound("Weapon_AR2.Empty")
			self:SetNWBool("IsSelectingFireMode", true)
			if self:GetNWBool("HaveToBeSwitchedAuto") then
				self:SetNWBool("HaveToBeSwitchedAuto", false)
			end
			if self.Primary.Automatic then
				self.Primary.Automatic = false
				if CLIENT then
					self:GetOwner():PrintMessage(HUD_PRINTTALK, "Semi-automatic selected.")
				end
			else
				self.Primary.Automatic = true
				if CLIENT then
					self:GetOwner():PrintMessage(HUD_PRINTTALK, "Automatic selected.")
				end
			end
		end
		if self:GetOwner():KeyDown(IN_SPEED) then
			self:SendWeaponAnim( ACT_VM_IDLE_LOWERED )
			self:SetHoldType( "passive" )
			timer.Simple( 0.1 ,
			function()
				if !self:GetOwner():KeyDown(IN_SPEED) and !self:GetNWBool("IsLowered") and self:GetOwner():Alive() and !self:GetNWBool("IsReloading") then
					self:SendWeaponAnim( ACT_VM_IDLE )
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
	return true
end

--[[---------------------------------------------------------
	Name: SWEP:Deploy()
	Desc: Whip it out
-----------------------------------------------------------]]
function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	return true
end

--[[---------------------------------------------------------
	Name: SWEP:ShootEffects()
	Desc: A convenience function to create shoot effects
-----------------------------------------------------------]]
function SWEP:ShootEffects()
	local L = { ACT_VM_RECOIL1 , ACT_VM_RECOIL2 , ACT_VM_RECOIL3 }

	self:SendWeaponAnim( L[math.random(1,3)] )		-- View model animation
	self:GetOwner():MuzzleFlash()						-- Crappy muzzle light
	self:GetOwner():SetAnimation( PLAYER_ATTACK1 )		-- 3rd Person Animation

end

--[[---------------------------------------------------------
	Name: SWEP:ShootBullet()
	Desc: A convenience function to shoot bullets
-----------------------------------------------------------]]
function SWEP:ShootBullet( damage, num_bullets, aimcone, ammo_type, force, tracer )

	local bullet = {}
	bullet.Num		= num_bullets
	bullet.Src		= self:GetOwner():GetShootPos()			-- Source
	bullet.Dir		= self:GetOwner():GetAimVector()			-- Dir of bullet
	bullet.Spread	= Vector( aimcone, aimcone, 0 )		-- Aim Cone
	bullet.Tracer	= tracer || 5						-- Show a tracer on every x bullets
	bullet.Force	= force || 1						-- Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = ammo_type || self.Primary.Ammo

	self:SetNWBool("IsLowered", false)
	self:SetHoldType( self.HoldType )

	self:GetOwner():FireBullets( bullet )

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

		self:GetOwner():RemoveAmmo( num, self:GetPrimaryAmmoType() )

	return end

	self:SetClip1( self:Clip1() - num )

end

--[[---------------------------------------------------------
	Name: SWEP:TakeSecondaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakeSecondaryAmmo( num )
end

--[[---------------------------------------------------------
	Name: SWEP:CanPrimaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()

	if self:GetOwner():KeyDown(IN_SPEED) then
		return false
	else if self:GetOwner():KeyDown(IN_USE) then
		return false
	end end

	if ( self:Clip1() <= 0 ) then

		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SendWeaponAnim( ACT_VM_DRYFIRE )
		if self.Primary.Automatic then
			self.Primary.Automatic = false
			self:SetNWBool("HaveToBeSwitchedAuto", true)
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
	return self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() )
end

--[[---------------------------------------------------------
	Name: Ammo2
	Desc: Returns how much of ammo2 the player has
-----------------------------------------------------------]]
function SWEP:Ammo2()
	return self:GetOwner():GetAmmoCount( self:GetSecondaryAmmoType() )
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