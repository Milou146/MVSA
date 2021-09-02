util.AddNetworkString("GASMASK_RequestToggle")

concommand.Add("gasmask_toggle", function(ply)
    if ply.GasMaskEquiped then
        if not ply.GASMASK_SpamDelay or ply.GASMASK_SpamDelay < CurTime() then
            ply.GASMASK_SpamDelay = CurTime() + 4
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
                ply:SetBodygroup(17, 0)
                ply:ConCommand("cl_mvsa_set_gasmask 0")
            else
                ply:SetNWBool("GasMaskSet", true)
                net.Start("GASMASK_RequestToggle")
                net.WriteBool(true)
                net.Send(ply)
                ply:SetBodygroup(17, 2)
                ply:ConCommand("cl_mvsa_set_gasmask 1")
            end

            timer.Simple(1.8, function()
                ply:SelectWeapon(ply.GASMASK_LastWeapon)
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
    end
end)