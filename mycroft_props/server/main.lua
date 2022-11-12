function CreateUseableItem(data) 
    if not data then return end 

    ESX.RegisterUsableItem(data.name, function(playerId)
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if data.RemoveOnUse then 
        xPlayer.removeInventoryItem(data.name, 1)
        end
        if data.ShowNotification then 
            xPlayer.showNotification(data.Notification)
        end
        xPlayer.triggerEvent("mycroft_props:UseProp", data)
      end)
end

CreateUseableItem({
    --------------------------- Avaivle Types ------------------------------------
    -- scenario (requires the scenario = {}) table
    -- anim  (requires the anim = {}) table 
    -- prop  (requires Prop,PropBone, PropPlacement) 
    -- animProp  (requires Prop,PropBone, PropPlacement and the anim = {}) 
    -------------------------------------------------------------------------------
    name = "umbrella",
    RemoveOnUse = false , -- Note: Does not give item back
    ShowNotification = true,
    Notification = "Using Umbrella.",
    Type = "animProp",
    Prop = "p_amb_brolly_01",
    PropBone = 57005,
    PropPlacement = {0.15, 0.005, 0.0, 87.0, -20.0, 180.0},
    anim = {
        dict = "amb@world_human_drinking@coffee@male@base",
        name =  "base",
        freezePlayer = false,
        blendIn = 8.0,
        BlendOut = 8.0,
    },
   -- scenario = {
     --   name =  "WORLD_HUMAN_MAID_CLEAN", -- https://pastebin.com/6mrYTdQv
    --    delay = 0, -- Normally -1 -> 1
   --     EnterAnim = true -- Players the starting transition of the animation
   -- }
})
