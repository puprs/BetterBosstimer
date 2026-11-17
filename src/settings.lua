local Settings = {}
local BoxSettingsKey = "anims_on"
local boxIsChecked = true

local function toBoolean(value)
    return value == true or value == 1
end

if PersistentDB:CheckExists(BoxSettingsKey) then
    boxIsChecked = toBoolean(PersistentDB:Get(BoxSettingsKey))
end

function Settings.IsBoxChecked()
    return boxIsChecked
end

local function onSettingsLayerReady(settingsLayerReadyEvent)
    local rootLayer = settingsLayerReadyEvent.component

    local myCheck = ui.Check.new(rootLayer)
    myCheck:SetSize(200, 50)
    myCheck:SetPos(16, 16)
    myCheck.stylesheetID = id.StyleSheet.CHECKBOX_DEFAULT
    myCheck.label = "Personal Record Animations"
    myCheck.alignment = ui.CheckAlignMode.INLINE
    myCheck.buttonSize = 20
    myCheck.value = boxIsChecked
    myCheck:Subscribe(ui.Hook.ONBUTTONPRESSED, "myHook",
        function (check, ticked)
            boxIsChecked = toBoolean(ticked)
            PersistentDB:Set(BoxSettingsKey, boxIsChecked)
        end)
end

Event.SettingsLayerReady.Subscribe("myEvent", onSettingsLayerReady)

return Settings
