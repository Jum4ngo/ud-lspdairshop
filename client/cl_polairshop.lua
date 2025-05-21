local QBCore = exports['qb-core']:GetCoreObject()

local function isNear()
    if #(vector3(464.35, -1012.87, 28.07) - GetEntityCoords(PlayerPedId())) < 5.0 then
        return true
    end
    return false
end

CreateThread(function()
    while not HasModelLoaded('s_m_y_cop_01') do
        RequestModel('s_m_y_cop_01')
        Wait(10)
    end

    ped = CreatePed(1, 's_m_y_cop_01',464.35, -1012.87, 27.07, 175.54, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                label = 'Purchase An LSPD Aircraft',
                icon = 'fa-solid fa-circle',
                action = function()
                    TriggerEvent('ud-lspdairshop:OpenPoliceShopMenu')
                end,
                canInteract = function()
                    local Player = QBCore.Functions.GetPlayerData()
                    return not IsEntityDead(PlayerPedId()) and isNear() and Player.job.name == "police" and Player.job.grade.level >= 10
                end
            },
        },
        distance = 2.0
    })
end)

RegisterNetEvent('ud-lspdairshop:OpenPoliceShopMenu')
AddEventHandler('ud-lspdairshop:OpenPoliceShopMenu', function()
    local Player = QBCore.Functions.GetPlayerData()
    if Player.job.name ~= "police" and Player.job.grade.level < 10 then
        QBCore.Functions.Notify("You must be LSPD rank 10 or higher to access this.", "error")
        return
    end
        
    exports['qb-menu']:openMenu({
        {
            header = "LSPD Aircraft Shop",
            isMenuHeader = true
        },
        {
            header = 'AS350 LSPD Helicopter',
            icon = "fas fa-circle",
            txt = "PRICE: $263,340",
            params = {
                event = "ud-lspdairshop:hasmoney",
                args = { model = 'as350', price = 263340 }
            }
        },
    })
end)

RegisterNetEvent('ud-lspdairshop:hasmoney')
AddEventHandler('ud-lspdairshop:hasmoney', function(data, cb)
  QBCore.Functions.TriggerCallback("ud-lspdairshop:purchaseVehicle", function(success, vehicle, plate)
    print(success, vehicle)
    if success then
        Wait(50)
        cb({
        data = {},
        meta = {
         ok = true,
        }
        });
    end;
    end, data.model, data.price)
end);

RegisterNetEvent('ud-lspdairshop:client:SpawnVehicle')
AddEventHandler('ud-lspdairshop:client:SpawnVehicle', function(vehicle, plate)
    local Player = QBCore.Functions.GetPlayerData()
    local coords

    if Player.job.name == "police" then
        coords = vector4(1852.37, 3689.28, 33.98, 210.0) -- BCSO Spawn (adjust as needed)
    else
        QBCore.Functions.Notify("You are not authorized to spawn a vehicle.", "error")
        return
    end

    QBCore.Functions.SpawnVehicle(vehicle, function(veh)
        SetEntityHeading(veh, coords.w)
        SetVehicleNumberPlateText(veh, plate)
        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
        exports['LegacyFuel']:SetFuel(veh, 100)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
    end, coords, true)
end)