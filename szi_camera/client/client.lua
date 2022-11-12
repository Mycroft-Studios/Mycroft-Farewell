local phone, frontCam = false, false
phoneId = 0

function PhonePlayOut()
	PhonePlayAnim('out')
end

RegisterNetEvent('camera:open')
AddEventHandler('camera:open', function()
    CreateMobilePhone(1)
	CellCamActivate(true, true)
	phone = true
    PhonePlayOut()
end)

function CellFrontCamActivate(activate)
	return Citizen.InvokeNative(0x2491A93618B7D838, activate)
end

exports.ox_inventory:displayMetadata('photo', 'Photo')
local metadata = nil
exports('picture', function(data, slot)
    metadata = slot.metadata.photo
    print(metadata)
    SendNUIMessage({action = 'show:pic', picture = metadata})
    Wait(10000)
    SendNUIMessage({action = 'hide:pic'})
end)

exports('camera', function(data, slot)
    --exports['screenshot-basic']:requestScreenshotUpload(data.url, data.field, function(data)
    CreateMobilePhone(1)
    CellCamActivate(true, true)
    local takePhoto = true
    Wait(0)
    if hasFocus == true then
        SetNuiFocus(false, false)
        hasFocus = false
    end
	while takePhoto do
        Wait(0)
        HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(8)
		HideHudComponentThisFrame(9)
		HideHudComponentThisFrame(6)
		HideHudComponentThisFrame(19)
        HideHudAndRadarThisFrame()
		if IsControlJustPressed(1, 27) then -- Toogle Mode
		    frontCam = not frontCam
			CellFrontCamActivate(frontCam)
        elseif IsControlJustPressed(1, 177) then -- CANCEL
            DestroyMobilePhone()
            CellCamActivate(false, false)
            takePhoto = false
        break
        elseif IsControlJustPressed(1, 176) then -- TAKE.. PIC
            exports['screenshot-basic']:requestScreenshotUpload(Config.Webhook, 'files[]', function(data)
                -- local resp = json.decode(data)
                local image = json.decode(data)
                TriggerServerEvent("szi_camera:TakePhoto",image.attachments[1].proxy_url)
                DestroyMobilePhone()
                CellCamActivate(false, false)
                takePhoto = false
                --cb(json.encode({ url = resp.files[1].url }))       cb(json.encode({ url = image.attachments[1].proxy_url }))
            end)
	    end
    end
    Wait(1000)
--   PhonePlayAnim('text', false, true)
end)
