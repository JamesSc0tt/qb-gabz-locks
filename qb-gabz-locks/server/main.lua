function tablelength(tbl)
	local count = 0
	for k,v in pairs(tbl) do
		count = count + 1
	end
	return count
end

RegisterServerEvent('qb-gabz-locks:toggle', function(doorid)
	local auth = true
	local Player = QBCore.Functions.GetPlayer(source)
    local PlayerData = Player.PlayerData

    local job_name = PlayerData.job.name

	if Config.DoorList[doorid] then
		local doorset = Config.DoorList[doorid]
		if doorset.authorizedJobs and tablelength(doorset.authorizedJobs) > 0 then
			local hasjob = false
			for job, _ in pairs(doorset.authorizedJobs) do
				if job_name == job then
					hasjob = true
				end
			end
			auth = hasjob
		end
		if auth then
			Config.DoorList[doorid].locked = not Config.DoorList[doorid].locked
			if Config.DoorList[doorid].locked then
				-- locked
				TriggerClientEvent('QBCore:Notify', source, 'Locked', 'success')
			else
				-- unlocked
				TriggerClientEvent('QBCore:Notify', source, 'Unlocked', 'success')
			end
			TriggerClientEvent('qb-gabz-locks:anim', source)
		else
			-- not the right job
			TriggerClientEvent('QBCore:Notify', source, 'You don\'t have this key!', 'error')
		end
	end
	TriggerClientEvent('qb-gabz-locks:update', -1, doorid, Config.DoorList[doorid].locked)
end)