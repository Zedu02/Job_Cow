local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRPl = {}
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_vacar")
Lclient = Tunnel.getInterface("vrp_vacar","vrp_vacar")
Tunnel.bindInterface("vrp_vacar",vRPl)

cfg = module("vrp_vacar", "cfg/config")

Citizen.CreateThread(function()
	for k,v in pairs(cfg.leite) do
		vRP.defInventoryItem({k,v.name,v.desc,v.choices,v.weight})
	end
end)

local units = {}

Citizen.CreateThread(function()
	while true do
		for k,v in pairs(cfg.vacas) do
			units[k] = cfg.max_leite
		end
		Citizen.Wait(1000*cfg.cooldown_timer)
	end
end)


local coletar = true

function vRPl.coletarLeite(coletarP,k)
	coletar = coletarP
	local source = source
	local user_id = vRP.getUserId({source})
	local InventoryWeight = {}
	local ItemWeight = {}
	local InventoryMaxWeight = {}
	InventoryWeight[user_id] = vRP.getInventoryWeight({user_id})
	ItemWeight[user_id] = vRP.getItemWeight({"lapte"})
	InventoryMaxWeight[user_id] = vRP.getInventoryMaxWeight({user_id})
	if vRP.hasGroup({user_id,"Vacar"}) then
		if coletar then
			vRPclient.setProgressBar(source,{"vRP:leite","center","...",255,255,255,0})
			TriggerClientEvent("leite:anim",source)
			TriggerClientEvent("leite:prop",source)
		end
		while coletar do
			Citizen.Wait(1000)
			vRPclient.setProgressBarValue(source,{"vRP:leite",math.floor(units[k]/cfg.max_leite*100.0)})
			if units[k] > 0 then
				vRPclient.setProgressBarText(source,{"vRP:leite","Colectezi Lapte: "..units[k].."/"..cfg.max_leite})
				if ((InventoryWeight[user_id]+ItemWeight[user_id]) <= InventoryMaxWeight[user_id]) then
					vRP.giveInventoryItem({user_id,"lapte",1,true})
					units[k] = units[k] - 1
					InventoryWeight[user_id] = InventoryWeight[user_id] + 1
				else
					vRPclient.notify(source,{"~r~Inventarul dvs. este plin."})
				end
			else
				vRPclient.setProgressBarText(source,{"vRP:leite","Ai muls tot laptele"})
			end
		end
		vRPclient.removeProgressBar(source,{"vRP:leite"})
	else
		vRPclient.notify(source,{"~r~Nu detii job ul de Vacar"})
	end
end

function vRPl.abater()
	local user_id = vRP.getUserId({source})
	local amount = math.random(cfg.min_carne,cfg.max_carne)
	if ((vRP.getInventoryWeight({user_id})+(vRP.getItemWeight({"carne"}))*amount) <= vRP.getInventoryMaxWeight({user_id})) then
		vRP.giveInventoryItem({user_id,"carne",amount,true})
	else
		vRPclient.notify(source,{"~r~Inventarul dvs. este plin."})
	end
end

function vRPl.conduzir(k)
	local user_id = vRP.getUserId({source})
	local amount = math.random(cfg.min_carne,cfg.max_carne)
	if vRP.hasGroup({user_id,"Vacar"}) then
		TriggerClientEvent("vrp:abater",source,k)
	else
		vRPclient.notify(source,{"~r~Nu detii job ul de Vacar"})
	end
end

RegisterNetEvent('vrp:perm')
AddEventHandler("vrp:perm", function(user_id)
	local source = source
	local user_id = vRP.getUserId({source})
	if user_id and vRP.hasGroup({user_id,"Vacar"}) then
		TriggerClientEvent("vrp:perm",source,true)
	else
		TriggerClientEvent("vrp:perm",source,false)
	end
end)