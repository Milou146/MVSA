include( "sh_gasmask.lua" )
util.AddNetworkString("GASMASK_RequestToggle")

concommand.Add("gasmask_toggle", function(ply)
    if ply:GetNWInt("GasMask") > 1 then
        if not ply:GetNWInt("GASMASK_SpamDelay") or ply:GetNWInt("GASMASK_SpamDelay") < CurTime() then
            ply:SetNWInt("GASMASK_SpamDelay", math.Round(CurTime()) + 4)
            ply.GASMASK_LastWeapon = ply:GetActiveWeapon()
            ply:SetSuppressPickupNotices(true)
            ply:StripWeapon("weapon_gasmask")
            ply:Give("weapon_gasmask")
            ply:SelectWeapon("weapon_gasmask")

            if ply:GetNWBool("GasMaskSet") then
                ply:SetNWBool("GasMaskSet", false)
                net.Start("GASMASK_RequestToggle")
                net.WriteBool(false)
                net.Send(ply)
                ply:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[3])
            else
                ply:SetNWBool("GasMaskSet", true)
                net.Start("GASMASK_RequestToggle")
                net.WriteBool(true)
                net.Send(ply)
                ply:SetBodygroup(PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[1], PlayerModels[ply:GetNWString("Faction")][ply:GetNWInt("ModelIndex")].gasmask_bodygroup[2])
            end

            timer.Simple(1.8, function()
                if ply.GASMASK_LastWeapon:IsValid() then ply:SelectWeapon(ply.GASMASK_LastWeapon) end -- eliminate the case where the player do not hold a weapon
                ply:StripWeapon("weapon_gasmask")
                ply:SetSuppressPickupNotices(false)
            end)
        end
    else
        ply:ChatPrint("You need a gas mask in order to do this")
    end
end)

local gasmask_dmgtypes = {
    [DMG_NERVEGAS] = 0,
    [DMG_RADIATION] = 0.05
}

hook.Add("EntityTakeDamage", "GASMASK_TakeDamage", function(ent, dmginfo)
    if ent:IsPlayer() and ent:GetNWBool("GasMaskSet") then
        local dmgtype = dmginfo:GetDamageType()

        if gasmask_dmgtypes[dmgtype] then
            dmginfo:ScaleDamage(gasmask_dmgtypes[dmgtype])
        end
    elseif ent:isPlayer() and player_manager.GetPlayerClass(ent) == "player_spectator" then
        dmginfo:ScaleDamage(0)
    end
end)