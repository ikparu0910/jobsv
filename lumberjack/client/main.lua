MP = {}
MP.__index = MP

local cy = coroutine.yield
local firstSpawn = false
local blip2, blip3, blip4


Citizen.CreateThread(function()
    MP:Init()

    loadModel("mp_m_waremech_01")
    local pedhash = GetHashKey("mp_m_waremech_01")


    loadModel("mp_m_weapexp_01")
    local pedhash2 = GetHashKey("mp_m_weapexp_01")

    if firstSpawn == false then
        local pedClaimPos = Config.ClaimJob.Pos
        local npc = CreatePed(6, pedhash, pedClaimPos.x,  pedClaimPos.y,  pedClaimPos.z- 0.99, Config.ClaimJob.pedHeading, false, false)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
        SetPedDiesWhenInjured(npc, false)
        SetPedCanRagdollFromPlayerImpact(npc, false)
        SetPedCanRagdoll(npc, false)
        SetEntityAsMissionEntity(npc, true, true)
        SetEntityDynamic(npc, true)

        local pedSellPos = Config.SellWood.Pos
        local npc1 = CreatePed(6, pedhash2, pedSellPos.x, pedSellPos.y, pedSellPos.z - 0.99, Config.SellWood.pedHeading, false, false)
        SetEntityInvincible(npc1, true)
        FreezeEntityPosition(npc1, true)
        SetPedDiesWhenInjured(npc1, false)
        SetPedCanRagdollFromPlayerImpact(npc1, false)
        SetPedCanRagdoll(npc1, false)
        SetEntityAsMissionEntity(npc1, true, true)
        SetEntityDynamic(npc1, true)
    end

end)

function MP:Init()
    local o = {}
    setmetatable(o, MP)
    o.PlayerData = {}
    o.Ped = PlayerPedId()
    o.PlyerId = PlayerId()
    o.ServerId = GetPlayerServerId()
    o.InJob = false
    o.PlayerProps = {}
    o.PlayerHasProp = false
    o:ClaimJobThread()
    o:BlipThread()
    o:SawWood()
    o:SellThread()
    return o
end

function MP:BlipThread()
    Citizen.CreateThread(function()
        local zoneClaimJob = Config.ClaimJob
        local blip1 = AddBlipForCoord(zoneClaimJob.Pos)
        SetBlipSprite(blip1, zoneClaimJob.Sprite)
        SetBlipDisplay              (blip1, 2)
        SetBlipScale                (blip1, zoneClaimJob.Scale )
        SetBlipColour               (blip1, zoneClaimJob.Colour)
        SetBlipAsShortRange         (blip1, true)
        SetBlipHighDetail           (blip1, true)
        BeginTextCommandSetBlipName ("STRING")
        AddTextComponentString      (TranslateCap('blip_claimjob'))
        EndTextCommandSetBlipName   (blip1)

        local zoneMarket = Config.Market
        local blip5 = AddBlipForCoord(zoneMarket.Pos)
        SetBlipSprite(blip5, zoneMarket.Sprite)
        SetBlipDisplay              (blip5, 2)
        SetBlipScale                (blip5, zoneMarket.Scale )
        SetBlipColour               (blip5, zoneMarket.Colour)
        SetBlipAsShortRange         (blip5, true)
        SetBlipHighDetail           (blip5, true)
        BeginTextCommandSetBlipName ("STRING")
        AddTextComponentString      (TranslateCap('blip_market'))
        EndTextCommandSetBlipName   (blip5)
    end)
end


function MP:ClaimJobThread()
    Citizen.CreateThread(function()
        while true do
            cy(0)
            local claimJobPos = Config.ClaimJob.Pos
            local x, y, z = claimJobPos.x, claimJobPos.y, claimJobPos.z
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            local distance2 = GetDistanceBetweenCoords(x, y, z, pedCoords, true)
            if distance2 <= 2.0 then 
                if distance2 <= 1 then
                    ESX.ShowHelpNotification(TranslateCap('press_open_menu'))
                    if IsControlJustPressed(0, 38) then
                        self:OpenMenuClaimJob()
                    end
                end
            else
                Wait(1500)
            end
        end
    end)
end

function MP:SellThread()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            local sellPos = Config.SellWood.Pos
            local x, y, z = sellPos.x, sellPos.y, sellPos.z
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            local distance2 = GetDistanceBetweenCoords(x, y, z, pedCoords, true)
            if distance2 <= 3.0 then 
                if distance2 <= 1 then
                    ESX.ShowHelpNotification(TranslateCap('press_open_menu'))
                    if IsControlJustPressed(0, 38) then
                        OpenMenuSell()
                    end
                end
            else
                Wait(1500)
            end
            
        end
    end)
end


function MP:AddBlipJob()
    Citizen.CreateThread(function()
        if self.InJob then
            ESX.ShowNotification(TranslateCap('claimJob_success'))
            local zoneWoodField = Config.WoodFields
            blip2 = AddBlipForCoord(zoneWoodField.Pos)
            SetBlipSprite(blip2, zoneWoodField.Sprite)
            SetBlipDisplay              (blip2, 2)
            SetBlipScale                (blip2, zoneWoodField.Scale )
            SetBlipColour               (blip2, zoneWoodField.Colour)
            SetBlipAsShortRange         (blip2, true)
            SetBlipHighDetail           (blip2, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_woodfield'))
            EndTextCommandSetBlipName   (blip2)
        end
    end)
end


function MP:SawWood()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.WoodLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.WoodLocations[i].x, Config.WoodLocations[i].y, Config.WoodLocations[i].z, true) < 25 and self.InJob == false then
                        DrawMarker(20, Config.WoodLocations[i].x, Config.WoodLocations[i].y, Config.WoodLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.WoodLocations[i].x, Config.WoodLocations[i].y, Config.WoodLocations[i].z, true) <= 1 then
                            ESX.ShowHelpNotification(TranslateCap("action_mine"))
                                if IsControlJustReleased(1, 51) then
                                    local PropName = "prop_tool_fireaxe"
                                    local PropBone = 28422
                                    local PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(Config.PropMapPlacement)
                                    self:AddPropToPlayer( PropName , PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "sawWood",
                                        duration = Config.sawDuration,
                                        label = "Đang chặt gỗ",
                                        useWhileDead = false,
                                        canCancel = true,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        animation = {
                                            animDict = "melee@large_wpn@streamed_core",
                                            anim = "ground_attack_on_spot",
                                        },
                                    }, function(status)
                                        if not status then
                                            print("aaaa")
                                            self:DestroyAllProps()
                                            self.isBusy = false
                                        else
                                            self:DestroyAllProps()
                                            self.isBusy = false
                                        end
                                        p:resolve(status)
                                    end)
                                    Citizen.Await(p)
                            end
                    end
                end
            end
        end
    end)
end




function MP:OpenMenuClaimJob()
    local elements = {
        {unselectable = true, icon = "fas fa-info", title = TranslateCap("menu_claim")}
    }
    
    elements[#elements + 1] = {
        icon = "fas fa-check",
		title = TranslateCap("accept"),
		value = "claimjob",
		type = "claimjob"
    }

    elements[#elements + 1] = {
        icon = "fas fa-window-close",
		title = TranslateCap("cancel"),
		value = "canceljob",
		type = "canceljob"
    }

    ESX.OpenContext("right", elements, function(menu, elements)
        if elements.value == "claimjob" then
            self.InJob = true
            self:AddBlipJob()
            ESX.CloseContext()
        elseif elements.value == "canceljob" then
            ESX.CloseContext()
            self.InJob = false
            RemoveBlip(blip2)
        end

    end)
end

function OpenMenuSell()
    local elements = {
        {unselectable = true, icon = "fas fa-info", title = TranslateCap("menu_sell")}
    }
    
    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_wood"),
		value = "sell_wood",
		type = "sell_wood"
    }



    ESX.OpenContext("right", elements, function(menu, elements)
        if elements.value == "sell_wood" then
            print("sell_wood")
            
        end

    end)
end

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function MP:DestroyAllProps()
    for _, v in ipairs(self.PlayerProps) do
        DeleteEntity(v)
    end
    self.PlayerHasProp = false
end


function MP:AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
    local Player = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(Player))
    if not HasModelLoaded(prop1) then
        LoadPropDict(prop1)
    end
    prop = CreateObject(  GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
    AttachEntityToEntity(  prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(self.PlayerProps, prop)
    self.PlayerHasProp = true
    SetModelAsNoLongerNeeded(prop1)
    
end


function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end