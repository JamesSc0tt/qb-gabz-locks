RegisterNetEvent('qb-gabz-locks:update', function(doorid, status)
	Config.DoorList[doorid].locked = status
end)

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function openDoorAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
	SetTimeout(400, function()
		ClearPedTasks(PlayerPedId())
	end)
end

RegisterNetEvent('qb-gabz-locks:anim', function()
	openDoorAnim()
	local players = {}
	for i,v in ipairs(GetActivePlayers()) do
		if GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(v)), GetEntityCoords(PlayerPedId()), true) < 5 then
			players[#players+1] = {
				src = v
			}
		end
	end
	TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5.0, 'houses_door_lock', 0.1, players)
end)

-- thread
Citizen.CreateThread(function()
	while true do Citizen.Wait(0)
		for key, doorset in pairs(Config.DoorList) do
			local doorset_coords = doorset.objCoords
			if doorset.doors then doorset_coords = doorset.doors[1].objCoords end

			local dist = #(GetEntityCoords(PlayerPedId()) - doorset_coords)
			
			if dist < 15 then
				local doors = {}

				if not doorset.doors then
					doors[1] =  {
						objCoords = doorset.objCoords,
						objHash = doorset.objHash,
						objHeading = doorset.objHeading,
					}
				else
					doors = doorset.doors
				end

				for doorkey, door in pairs(doors) do
					local door_entity = GetClosestObjectOfType(door.objCoords, 4.0, door.objHash, false, false, false)
					if door_entity then
						if doorset.locked then
							door.objHeading = door.objHeading + 0.0
							local dist_from_closed = #(GetEntityCoords(door_entity) - door.objCoords)
							local dist_from_heading = math.abs(door.objHeading - GetEntityHeading(door_entity))
							if door.objHeading == 0 then
								dist_from_heading = 0
							end

							if dist_from_closed < 1.0 and dist_from_heading < 0.1 then
								FreezeEntityPosition(door_entity, true)
							end
						else
							FreezeEntityPosition(door_entity, false)
						end
					end
				end

				if dist < doorset.maxDistance then
					if IsControlJustPressed(0, 38) then
						TriggerServerEvent('qb-gabz-locks:toggle', key)
					end
				end
			end
		end
	end
end)