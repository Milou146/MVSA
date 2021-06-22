SWEP.PrintName = "Scripted Weapon"
SWEP.Author = ""
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_pistol.mdl"
SWEP.WorldModel = "models/weapons/w_357.mdl"
SWEP.UseHands = true
SWEP.HoldType = ""
SWEP.BothFireMode = true -- Have the weapon both fire mode?
SWEP.Primary.ClipSize = 8 -- Size of a clip
SWEP.Primary.DefaultClip = 32 -- Default number of bullets in a clip
SWEP.Primary.Automatic = false -- Automatic/Semi Auto
SWEP.Primary.Ammo = ""
SWEP.Primary.RPM = 150
SWEP.Primary.Sound = Sound("")
SWEP.Primary.Spread = .02 -- Spread while not aiming
SWEP.Primary.IronAccuracy = .005 -- Spread while aiming
SWEP.DryFireSound = Sound("Weapon_Pistol.Empty")
SWEP.FireSelectSound = Sound("Weapon_AR15.fireselect")
SWEP.Secondary.Ammo = "" -- Useless but we have to let it here to avoid LUA error
SWEP.NextFireSelect = 0 -- When can we change the firemode again?
SWEP.FirstTime = 0 -- Used in the reloading function (you can ignored this)
SWEP.IronTime = 0.15 -- Time to aim
SWEP.IronSightsPos = Vector(-2.8, -8, 1)
SWEP.IronSightsAng = Vector(0, 0, 0)
SWEP.VerticalKick = 0.5
SWEP.HorizontalKick = 0.125
SWEP.AimingTime = 0 -- Time elapsed since the last aiming occurence (used for GetViewModelPosition)
SWEP.CurrentTime = 0
SWEP.DrawTime = 0

--[[---------------------------------------------------------
	Name: GetViewModelPosition
	Desc: Allows you to re-position the view model
-----------------------------------------------------------]]
function SWEP:GetViewModelPosition(pos, ang)
    local mul = math.Clamp((self.CurrentTime - self.AimingTime) / self.IronTime, 0, 1)
    if not self:GetAiming() then
        mul = 1 - mul
    end

    ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * mul)
    ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * mul)
    ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * mul)

    local Offset = self.IronSightsPos
    local Right = ang:Right()
    local Up = ang:Up()
    local Forward = ang:Forward()
    pos = pos + Offset.x * Right * mul
    pos = pos + Offset.y * Forward * mul
    pos = pos + Offset.z * Up * mul

    return pos, ang
end

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Lowering")
    self:NetworkVar("Bool", 1, "Lowered")
    self:NetworkVar("Bool", 2, "Reloading")
    self:NetworkVar("Bool", 3, "HaveToBeSwitchedAuto")
    self:NetworkVar("Bool", 4, "Deployed")
    self:NetworkVar("Bool", 5, "SelectingFireMode")
    self:NetworkVar("Bool", 6, "Aiming")
    self:NetworkVar("Bool", 7, "DrawMag")
    self:NetworkVar("Bool", 8, "Input1")
    self:NetworkVar("String", 0, "FireMode")
    self:NetworkVar("Float", 0, "SightsTime")
end

--[[---------------------------------------------------------
	Name: SWEP:Initialize()
	Desc: Called when the weapon is first loaded
-----------------------------------------------------------]]
function SWEP:Initialize()
    self:SetHoldType(self.HoldType)
    self:SetDeployed(false)
    self:SetDrawMag(false)
    self:SetFireMode("semi")
    self:SetSightsTime(0)
end

--[[---------------------------------------------------------
	Name: SWEP:PrimaryAttack()
	Desc: +attack1 has been pressed
-----------------------------------------------------------]]
function SWEP:PrimaryAttack()
    -- Make sure we can shoot first
    if not self:CanPrimaryAttack() then return end
    -- Play shoot sound
    self:EmitSound(self.Primary.Sound)
    -- Remove 1 bullet from our clip
    self:TakePrimaryAmmo(1)
    self:SetNextPrimaryFire(CurTime() + 1 / (self.Primary.RPM / 60))
    self:ShootBullet(150, 1, self.ConeSpread, self.Primary.Ammo)
end

--[[---------------------------------------------------------
	Name: SWEP:SecondaryAttack()
	Desc: +attack2 has been pressed
-----------------------------------------------------------]]
function SWEP:SecondaryAttack()
    if self:GetReloading() then return end
    self.AimingTime = CurTime()
    self:SetAiming(not self:GetAiming())
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

--[[---------------------------------------------------------
	Name: SWEP:Reload()
	Desc: Reload is being pressed
-----------------------------------------------------------]]
function SWEP:Reload()
    if not self:GetOwner():KeyDown(IN_SPEED) and not self:GetOwner():KeyDown(IN_USE) and not self:GetSelectingFireMode() then
        if self.FirstTime == 0 then
            self.FirstTime = CurTime()
        end

        timer.Simple(0.1, function()
            if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetOwner():Alive() and not self:GetOwner():KeyDown(IN_RELOAD) then
                if (CurTime() - self.FirstTime) < 0.3 then
                    self.FirstTime = 0

                    if self:Clip1() <= 0 then
                        self:SetReloading(true)
                        self:DefaultReload(ACT_VM_RELOAD_EMPTY)
                        self:GetOwner():SetAnimation(PLAYER_RELOAD)

                        if self:GetHaveToBeSwitchedAuto() then
                            self.Primary.Automatic = true
                        end
                    else
                        if self:Clip1() < self.Primary.ClipSize then
                            self:SetReloading(true)
                            self:DefaultReload(ACT_VM_RELOAD)
                            self:GetOwner():SetAnimation(PLAYER_RELOAD)
                        end
                    end
                else
                    -- wait bro why don't you put this before the if-statement? Because in all cases you make it go to 0
                    -- because it is used in the if-statement itself bro
                    self.FirstTime = 0
                end
            end
        end)
    end
end
--[[---------------------------------------------------------
	You can draw to the HUD here - it will only draw when
	the client has the weapon deployed..
-----------------------------------------------------------]]
function SWEP:DrawHUD()
    local mul1 = math.Clamp((self.CurrentTime - self.DrawTime) / 0.002, 0, 255)
    if not self:GetDrawMag() then
        mul1 = 255 - mul1
    end
    surface.SetDrawColor(255, 255, 255, mul1)
    MagazineMat = Material(self.MagazineIcon, "")
    surface.SetMaterial(MagazineMat)
    local MagazineMatW = MagazineMat:GetInt("$realwidth")
    local MagazineMatH = MagazineMat:GetInt("$realheight")
    surface.DrawTexturedRect(ScrW() - MagazineMatW, ScrH() - MagazineMatH, MagazineMatW, MagazineMatH)
    draw.DrawText( math.floor(self:Ammo1() / self.Primary.ClipSize) + 1, "DermaDefault", ScrW() - MagazineMatW / 2, ScrH() - MagazineMatH / 2, Color( 58, 56, 56, mul1), TEXT_ALIGN_LEFT )
    -----------------------
    surface.SetDrawColor(255, 255, 255, mul1)
    local FireModeIcon = self.FireModeIconPath .. self:GetFireMode() .. ".png"
    FireModeMat = Material(FireModeIcon, "")
    surface.SetMaterial(FireModeMat)
    local FireModeMatW = FireModeMat:GetInt("$realwidth")
    local FireModeMatH = FireModeMat:GetInt("$realheight")
    surface.DrawTexturedRect(ScrW() - FireModeMatW - MagazineMatW, ScrH() - FireModeMatH, FireModeMatW, FireModeMatH)
    --------------------
end

--[[---------------------------------------------------------
	Name: SWEP:Think()
	Desc: Called every frame
-----------------------------------------------------------]]
function SWEP:Think()
    self.CurrentTime = CurTime()
    if self:GetAiming() then
        self.ConeSpread = self.Primary.IronAccuracy
        if CLIENT then
            self.BobScale = .1
            self.SwayScale = .1
        end
    else
        self.ConeSpread = self.Primary.Spread
        if CLIENT then
            self.BobScale = 1
            self.SwayScale = 1
        end
    end

    if not self:GetOwner():KeyDown(IN_RELOAD) then
        self:SetLowering(false)
        self:SetReloading(false)
        self:SetInput1(false)

        if not self:GetOwner():KeyDown(IN_USE) and self:GetSelectingFireMode() then
            self:SetSelectingFireMode(false)
        end
    end

    if self:GetDeployed() then
        if self:GetOwner():KeyDown(IN_RELOAD) and not self:GetInput1() then
            self:SetInput1(true)
            if not self:GetOwner():KeyDown(IN_RELOAD) then return end
            timer.Simple(.3,
            function()
                if self:GetOwner():KeyDown(IN_RELOAD) then
                    self:SetDrawMag(true)
                    self.DrawTime = CurTime()
                    timer.Simple(1,
                    function()
                        if IsValid(self) then
                            self:SetDrawMag(false)
                            self.DrawTime = CurTime()
                        end
                    end)
                else
                    self:SetInput1(false)
                end
            end)
        end
        -- lower the weapon / entering safe mode
        if not self:GetLowering() and self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_RELOAD) then
            self:SetLowering(true)
            self:SetLowered(not self:GetLowered())
            self:EmitSound(self.FireSelectSound)

            -- when you left safe mode
            if self.Primary.Automatic then
                self:SetFireMode("auto")
            else
                self:SetFireMode("semi")
            end
        end

        if self:GetLowered() then
            self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
            self:SetHoldType("passive")
            self:SetFireMode("safe")
        else
            self:SendWeaponAnim(ACT_VM_IDLE)
            self:SetHoldType(self.HoldType)
        end

        -- select the fire mode
        if not self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_USE) and self:GetOwner():KeyDown(IN_RELOAD) and self.BothFireMode and self.NextFireSelect < CurTime() then
            self.NextFireSelect = CurTime() + 1
            self:SendWeaponAnim(ACT_VM_FIREMODE)
            self:EmitSound(self.FireSelectSound)
            self:SetSelectingFireMode(true)

            if self:GetHaveToBeSwitchedAuto() then
                self:SetHaveToBeSwitchedAuto(false)
            end

            if self.Primary.Automatic then
                self.Primary.Automatic = false
                self:SetFireMode("semi")
            else
                self.Primary.Automatic = true
                self:SetFireMode("auto")
            end
        end

        -- lower the weapon while you run
        if self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_FORWARD) or self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_BACK) or self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_MOVELEFT) or self:GetOwner():KeyDown(IN_SPEED) and self:GetOwner():KeyDown(IN_MOVERIGHT) then
            self:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
            self:SetHoldType("passive")
            self:SetAiming(false)

            timer.Simple(0.1, function()
                if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetOwner():Alive() and not self:GetOwner():KeyDown(IN_SPEED) and not self:GetLowered() and not self:GetReloading() then
                    self:SendWeaponAnim(ACT_VM_IDLE)
                    self:SetHoldType(self.HoldType)
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
function SWEP:Holster(wep)
    return true
end

--[[---------------------------------------------------------
	Name: SWEP:Deploy()
	Desc: Whip it out
-----------------------------------------------------------]]
function SWEP:Deploy()
    self:SetAiming(false)

    if not self:GetDeployed() then
        self:SendWeaponAnim(ACT_VM_DEPLOY)
        -- wait the animation is finished before doing anything
        timer.Simple(self:GetOwner():GetViewModel():SequenceDuration(), function()
            if IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() and self:GetOwner():Alive() and self:GetOwner():GetActiveWeapon() == self then
                self:SetDeployed(true)
            end
        end)
    else
        self:SendWeaponAnim(ACT_VM_DRAW)
    end

    return true
end

--[[---------------------------------------------------------
	Name: FireAnimationEvent
	Desc: Allows you to override weapon animation events
-----------------------------------------------------------]]
function SWEP:FireAnimationEvent(pos, ang, event, options, source)
    -- this play the reloading sound serverside
    if event == 3015 then
        self:EmitSound(options)

        return true
    end
end

--[[---------------------------------------------------------
	Name: SWEP:ShootEffects()
	Desc: A convenience function to create shoot effects
-----------------------------------------------------------]]
function SWEP:ShootEffects()
    local L = {ACT_VM_RECOIL1, ACT_VM_RECOIL2, ACT_VM_RECOIL3}

    self:SendWeaponAnim(L[math.random(1, 3)]) -- View model animation
    self:GetOwner():MuzzleFlash()
    self:GetOwner():SetAnimation(PLAYER_ATTACK1) -- 3rd Person Animation
end

--[[---------------------------------------------------------
	Name: SWEP:ShootBullet()
	Desc: A convenience function to shoot bullets
-----------------------------------------------------------]]
function SWEP:ShootBullet(damage, num_bullets, aimcone, ammo_type, force, tracer)
    local bullet = {}
    bullet.Num = num_bullets
    bullet.Src = self:GetOwner():GetShootPos() -- Source
    bullet.Dir = self:GetOwner():GetAimVector() -- Dir of bullet
    bullet.Spread = Vector(aimcone, aimcone, 0) -- Aim Cone
    bullet.Tracer = tracer or 5 -- Show a tracer on every x bullets
    bullet.Force = force or 1 -- Amount of force to give to phys objects
    bullet.Damage = damage
    bullet.AmmoType = ammo_type or self.Primary.Ammo
    self:SetLowered(false)
    self:SetHoldType(self.HoldType)
    self:GetOwner():FireBullets(bullet)
    self:ShootEffects()
    local kickangle = Angle(-math.Rand(0, self.VerticalKick), math.Rand(-self.HorizontalKick, self.HorizontalKick), 0)
    self:GetOwner():ViewPunch(kickangle)
    self:GetOwner():SetEyeAngles(self:GetOwner():EyeAngles() + kickangle)
end

--[[---------------------------------------------------------
	Name: SWEP:TakePrimaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakePrimaryAmmo(num)
    -- Doesn't use clips
    if self:Clip1() <= 0 then
        if self:Ammo1() <= 0 then return end
        self:GetOwner():RemoveAmmo(num, self:GetPrimaryAmmoType())

        return
    end

    self:SetClip1(self:Clip1() - num)
end

--[[---------------------------------------------------------
	Name: SWEP:TakeSecondaryAmmo()
	Desc: A convenience function to remove ammo
-----------------------------------------------------------]]
function SWEP:TakeSecondaryAmmo(num)
end

--[[---------------------------------------------------------
	Name: SWEP:CanPrimaryAttack()
	Desc: Helper function for checking for no ammo
-----------------------------------------------------------]]
function SWEP:CanPrimaryAttack()
    if self:GetOwner():KeyDown(IN_SPEED) or self:GetSelectingFireMode() or self:GetReloading() or not self:GetDeployed() or self:GetLowering() or self:GetLowered() or self:GetOwner():WaterLevel() == 3 then return false end -- results with self:GetOwner():WaterLevel() are better than those with self:WaterLevel() 

    if (self:Clip1() <= 0) then
        self:SendWeaponAnim(ACT_VM_DRYFIRE)
        self:EmitSound(self.DryFireSound)

        if self.Primary.Automatic then
            self.Primary.Automatic = false
            self:SetHaveToBeSwitchedAuto(true)
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
    return self:GetOwner():GetAmmoCount(self:GetPrimaryAmmoType())
end

--[[---------------------------------------------------------
	Name: Ammo2
	Desc: Returns how much of ammo2 the player has
-----------------------------------------------------------]]
function SWEP:Ammo2()
    return self:GetOwner():GetAmmoCount(self:GetSecondaryAmmoType())
end

--[[---------------------------------------------------------
	Name: SetDeploySpeed
	Desc: Sets the weapon deploy speed.
		 This value needs to match on client and server.
-----------------------------------------------------------]]
function SWEP:SetDeploySpeed(speed)
    self.m_WeaponDeploySpeed = tonumber(speed)
end

--[[---------------------------------------------------------
	Name: DoImpactEffect
	Desc: Callback so the weapon can override the impact effects it makes
		 return true to not do the default thing - which is to call UTIL_ImpactTrace in c++
-----------------------------------------------------------]]
function SWEP:DoImpactEffect(tr, nDamageType)
    return false
end