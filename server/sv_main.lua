local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('ud-lspdairshop:purchaseVehicle', function(source, cb, model, price)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local money = xPlayer.PlayerData.money["bank"]
    
    if money >= price then
        xPlayer.Functions.RemoveMoney('bank', price)
        
        local plate = "POL" .. math.random(1000, 9999)
        
        RegisterVehicle(src, model, plate)
        
        cb(true, model, plate)

        TriggerClientEvent('ud-lspdairshop:client:SpawnVehicle', src, model, plate)
    else
        cb(false)
    end
end)

function RegisterVehicle(playerId, vehicleModel, vehiclePlate)
    local xPlayer = QBCore.Functions.GetPlayer(playerId)

    local license = xPlayer.PlayerData.license
    local citizenid = xPlayer.PlayerData.citizenid
    local job = xPlayer.PlayerData.job.name
    local grade = 6

    print("DEBUG: Registering vehicle for", license, citizenid, job, grade)

    exports.oxmysql:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state, damage, in_garage, garage_id, job_vehicle, job_vehicle_rank, gang_vehicle, gang_vehicle_rank, impound, impound_retrievable, impound_data, nickname) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', {
        license,
        'police',
        vehicleModel,
        GetHashKey(vehicleModel),
        '{}',
        vehiclePlate,
        'pdgarage',
        0,
        '',
        1,
        'pdgarage',
        1,
        grade,
        0,
        0,
        0,
        0,
        '',
        ''
    }, function(insertedId)
        if insertedId then
            print("DEBUG: Vehicle inserted successfully:", insertedId)
        else
            print("ERROR: Vehicle insert failed")
        end
    end)
end