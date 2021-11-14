concommand.Add("spawn", function( ply, cmd, args )
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        local ent = ents.Create( args[1] )
        if IsValid(ent) then
            ent:Spawn()
            ent:SetPos(ply:GetEyeTraceNoCursor()["HitPos"])
        else
            ply:ChatPrint("The specified class does not exist")
        end
    else
        ply:ChatPrint("You have to be admin")
    end
end)

concommand.Add("cleanup", function( ply, cmd, args )
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        game.CleanUpMap()
    else
        ply:ChatPrint("You have to be admin")
    end
end)

concommand.Add("removedecals", function( ply, cmd, args )
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        for k, ent in ipairs( ents.GetAll() ) do
            ent:RemoveAllDecals()
        end
    else
        ply:ChatPrint("You have to be admin")
    end
end)

concommand.Add("removeragdolls", function( ply, cmd, args )
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        for k, ent in ipairs( ents.GetAll() ) do
            if ent:IsRagdoll() then
                ent:Remove()
            end
        end
    else
        ply:ChatPrint("You have to be admin")
    end
end)