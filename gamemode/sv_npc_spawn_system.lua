local SpawnDelay = 0
local MinSpawnDistance = 3000
local MaxSpawnDistance = 20000
NPCCount = 0
local NPCLimit = 30

function NPCSpawnSystem()
    if SpawnDelay < CurTime() and NPCCount < NPCLimit then
        SpawnDelay = CurTime() + 20
        for k, v in pairs( player.GetAll() ) do
            local PlayerPos = v:GetPos()
            for i, j in pairs( ents.FindByClass( "info_zombie_spawn" ) ) do
                if not j.npc or not j.npc:IsValid() then
                    local EntPos = j:GetPos()
                    local distance = PlayerPos:Distance( EntPos )
                    if distance > MinSpawnDistance and distance < MaxSpawnDistance then
                        j.npc = ents.Create( table.Random(NPCList))
                        j.npc:SetPos(EntPos)
                        j.npc:Spawn()
                        NPCCount = NPCCount + 1
                    end
                end
            end
        end
    end
end