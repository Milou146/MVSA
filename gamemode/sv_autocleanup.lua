local CleanupDelay = 0

function AutoCleanup()
    if CurTime() > CleanupDelay then
        CleanupDelay = CurTime() + 500
        for k, ent in ipairs( ents.GetAll() ) do
            ent:RemoveAllDecals()
            if ent:IsRagdoll() then
                ent:Remove()
            end
        end
    end
end