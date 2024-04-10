settings = Cfg.Data
local noShuffle = false

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local noShuffle = false
        if IsPedInAnyVehicle(ped, false) then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), 0) == ped then
                noShuffle = true
            end
        end
        SetPedConfigFlag(ped, 184, noShuffle)
        Wait(150)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local veh = GetVehiclePedIsTryingToEnter(playerPed)

        if veh ~= 0 and IsControlJustPressed(0, 23) then
            ClearPedTasksImmediately(playerPed)

            -- Überprüfen, ob der Spieler nicht bereits in einem Fahrzeug sitzt und nicht versucht, auf den Fahrersitz zu steigen
            if not IsPedInAnyVehicle(playerPed, false) and GetSeatPedIsTryingToEnter(playerPed) ~= -1 then
                local vehicle = GetClosestVehicle(GetEntityCoords(playerPed), 4.0, 0, 70)
                if DoesEntityExist(vehicle) then
                    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
                    if settings['debugMode'] then
                        TriggerEvent('notify', 3, 'Debug', ('maxSeats: %s remoteId: %s'):format(maxSeats + 1, NetworkGetNetworkIdFromEntity(vehicle)) , 2.5)
                    end
                    if maxSeats > 2 then
                        SetNuiFocus(true, true)
                        SendNUIMessage({
                            type = "showSeatSelection",
                            availableSeats = maxSeats + 1,
                            remoteId = NetworkGetNetworkIdFromEntity(vehicle)
                        })
                    else
                        TaskEnterVehicle(playerPed, vehicle, 5000, -1, 2.0, 1, 0)
                    end
                end
            end
        end
    end
end)

RegisterNUICallback('exitMenu', function()
    SetNuiFocus(false, false)
end)


RegisterNUICallback('takeSeat', function(data)
    local seatIndex = tonumber(data.seatIndex)
    local vehicleNetId = tonumber(data.vehicleNetId)
    local vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)

    if DoesEntityExist(vehicle) then
        local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
        if maxSeats > 6 then
            if seatIndex < 4 then
                TaskEnterVehicle(PlayerPedId(), vehicle, 5000, seatIndex - 1, 2.0, 1, 0)
            else
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, seatIndex)
            end
        else
           TaskEnterVehicle(PlayerPedId(), vehicle, 5000, seatIndex - 1, 2.0, 1, 0)
        end
    end
    SetNuiFocus(false, false)
end)
