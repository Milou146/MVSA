concommand.Add("spawn", function( ply, cmd, args )
    if ply:GetUserGroup() ==  "admin" or "superadmin" then
        local ent = ents.Create( args[1] )
        ent:Spawn()
        ent:SetPos(ply:GetEyeTraceNoCursor()["HitPos"])
    else
        ply:ChatPrint("You have to be admin")
    end
end)