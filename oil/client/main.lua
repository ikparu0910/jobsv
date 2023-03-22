MP = {}
MP.__index = MP

local cy = coroutine.yield
local firstSpawn = false
local blip2, blip3, blip4

Citizen.CreateThread(function()
    MP:Init()

    loadModel("cs_floyd")
    local pedhash = GetHashKey("cs_floyd")


    loadModel("csb_trafficwarden")
    local pedhash2 = GetHashKey("csb_trafficwarden")

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

        local pedSellPos = Config.SellOil.Pos
        local npc1 = CreatePed(6, pedhash2, pedSellPos.x, pedSellPos.y, pedSellPos.z - 0.99, Config.SellOil.pedHeading, false, false)
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
    o.duration = 6000
    o.PlayerProps = {}
    o.PlayerHasProp = false
    o:BlipThread()
    o:ClaimJobThread()
    o:SearchThread()
    o:FilterThread()
    o:RefindedThread()
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

    end)
end

function MP:AddBlipJob()
    Citizen.CreateThread(function()
        if self.InJob then
            ESX.ShowNotification(TranslateCap('claimJob_success'))

            local zoneOilField = Config.OilFieldZone
            blip2 = AddBlipForCoord(zoneOilField.Pos)
            SetBlipSprite(blip2, zoneOilField.Sprite)
            SetBlipDisplay              (blip2, 2)
            SetBlipScale                (blip2, zoneOilField.Scale )
            SetBlipColour               (blip2, zoneOilField.Colour)
            SetBlipAsShortRange         (blip2, true)
            SetBlipHighDetail           (blip2, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_oilfield'))
            EndTextCommandSetBlipName   (blip2)

            local zoneOilFilter = Config.OilFilter
            blip3 = AddBlipForCoord(zoneOilFilter.Pos)
            SetBlipSprite(blip3, zoneOilFilter.Sprite)
            SetBlipDisplay              (blip3, 2)
            SetBlipScale                (blip3, zoneOilFilter.Scale )
            SetBlipColour               (blip3, zoneOilFilter.Colour)
            SetBlipAsShortRange         (blip3, true)
            SetBlipHighDetail           (blip3, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_oilfilter'))
            EndTextCommandSetBlipName   (blip3)

            local zoneOilRefinded = Config.OilRefined
            blip4 = AddBlipForCoord(zoneOilRefinded.Pos)
            SetBlipSprite(blip4, zoneOilRefinded.Sprite)
            SetBlipDisplay              (blip4, 2)
            SetBlipScale                (blip4, zoneOilRefinded.Scale )
            SetBlipColour               (blip4, zoneOilRefinded.Colour)
            SetBlipAsShortRange         (blip4, true)
            SetBlipHighDetail           (blip4, true)
            BeginTextCommandSetBlipName ("STRING")
            AddTextComponentString      (TranslateCap('blip_oilrefinded'))
            EndTextCommandSetBlipName   (blip4)
        end
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
            local sellPos = Config.SellOil.Pos
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


function MP:SearchThread()
    Citizen.CreateThread(function ()
        while true do
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.OilFields, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.OilFields[i].x, Config.OilFields[i].y, Config.OilFields[i].z, true) < 25 and self.InJob == true then
                        DrawMarker(20, Config.OilFields[i].x, Config.OilFields[i].y, Config.OilFields[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.OilFields[i].x, Config.OilFields[i].y, Config.OilFields[i].z, true) <= 1 then
                            ESX.ShowHelpNotification(TranslateCap("action_search"))
                                if IsControlJustReleased(1, 51) then
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "oil",
                                        duration = Config.mineDuration,
                                        label = "Đang hút dầu",
                                        useWhileDead = false,
                                        canCancel = true,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        animation = {
                                            animDict = "amb@prop_human_bum_bin@idle_a",
                                            anim = "idle_a",
                                        },
                                    }, function(status)
                                        if not status then
                                            print("aaaa")
                                            self.isBusy = false
                                        else
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

function MP:FilterThread()
    Citizen.CreateThread(function ()
        while true do 
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.OilFilterLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.OilFilterLocations[i].x, Config.OilFilterLocations[i].y, Config.OilFilterLocations[i].z, true) < 25 and self.InJob == true then
                    if GetDistanceBetweenCoords(pedCoords, Config.OilFilterLocations[i].x, Config.OilFilterLocations[i].y, Config.OilFilterLocations[i].z, true) <= 20 then
                        DrawMarker(20, Config.OilFilterLocations[i].x, Config.OilFilterLocations[i].y, Config.OilFilterLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.OilFilterLocations[i].x, Config.OilFilterLocations[i].y, Config.OilFilterLocations[i].z, true) <= 1 then
                            ESX.ShowHelpNotification(TranslateCap("action_filter"))
                            if IsControlJustReleased(1, 51) then
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "oilFilter",
                                        duration = Config.filterDuration,
                                        label = "Đang lọc dầu",
                                        useWhileDead = false,
                                        canCancel = true,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        animation = {
                                            animDict = "amb@prop_human_bum_bin@idle_a",
                                            anim = "idle_a",
                                        },
                                    }, function(status)
                                        if not status then
                                            print("bbbb")
                                            self.isBusy = false
                                        else
                                            self.isBusy = false
                                        end
                                        p:resolve(status)
                                    end)
                                    Citizen.Await(p)
                            end
                        end
                    end
                else
                    Wait(2000)
                end
            end
        end
    end)
end   

function MP:RefindedThread()
    Citizen.CreateThread(function ()
        while true do 
            cy(0)
            self.ped = PlayerPedId()
            local pedCoords = GetEntityCoords(self.ped)
            for i=1 , #Config.OilRefinedLocations, 1 do
                if GetDistanceBetweenCoords(pedCoords, Config.OilRefinedLocations[i].x, Config.OilRefinedLocations[i].y, Config.OilRefinedLocations[i].z, true) < 30 and self.InJob == true then
                    if GetDistanceBetweenCoords(pedCoords, Config.OilRefinedLocations[i].x, Config.OilRefinedLocations[i].y, Config.OilRefinedLocations[i].z, true) <= 20 then
                        DrawMarker(20, Config.OilRefinedLocations[i].x, Config.OilRefinedLocations[i].y, Config.OilRefinedLocations[i].z, 0, 0, 0, 0, 0, 100.0, 1.0, 1.0, 1.0, 0, 155, 253, 155, 0, 0, 2, 0, 0, 0, 0)
                        if GetDistanceBetweenCoords(pedCoords, Config.OilRefinedLocations[i].x, Config.OilRefinedLocations[i].y, Config.OilRefinedLocations[i].z, true) <= 1 then
                            
                            ESX.ShowHelpNotification(TranslateCap("action_refinded"))
                                if IsControlJustPressed(1, 51) then
                                    print("123123")
                                    self.isBusy = true
                                    local p = promise.new()
                                    ClearPedTasksImmediately(GetPlayerPed( -1))
                                    ResetPedMovementClipset(PlayerPedId())
                                    TriggerEvent("mythic_progbar:client:progress", {
                                        name = "oilRefinded",
                                        duration = Config.refindedDuration,
                                        label = "Đang chế biến dầu",
                                        useWhileDead = false,
                                        canCancel = true,
                                        controlDisables = {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        },
                                        animation = {
                                            animDict = "amb@prop_human_bum_bin@idle_a",
                                            anim = "idle_a",
                                        },
                                    }, function(status)
                                        if not status then
                                            
                                            self.isBusy = false
                                        else
                                            self.isBusy = false
                                        end
                                        p:resolve(status)
                                    end)
                                    Citizen.Await(p)
                                end
                        end
                    end
                else
                    Wait(2000)
                end
            end
        end
    end)
end   


function MP:OpenMenuClaimJob()
    local elements = {
        {unselectable = true, icon = "fas fa-oil-can", title = TranslateCap("menu_claim")}
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
            RemoveBlip(blip3)
            RemoveBlip(blip4)
        end

    end)
end

function OpenMenuSell()
    local elements = {
        {unselectable = true, icon = "fas fa-oil-can", title = TranslateCap("menu_sell")}
    }
    
    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_diesel"),
		value = "sell_diesel",
		type = "sell_diesel"
    }

    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_a92"),
		value = "sell_a92",
		type = "sell_a92"
    }

    elements[#elements + 1] = {
        icon = "fas fa-dollar-sign",
		title = TranslateCap("sell_a95"),
		value = "sell_a95",
		type = "sell_a95"
    }


    ESX.OpenContext("right", elements, function(menu, elements)
        if elements.value == "sell_diesel" then
            print("sell_diesel")
        elseif elements.value == "sell_a92" then
            print("sell_a92")
        elseif elements.value == "sell_a95" then
            print("sell_a95")        
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