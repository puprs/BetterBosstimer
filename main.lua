-- load modules
local BossTimerUI = require("src/boss_timer_ui")
local Animations = require("src/animations")
local CombatStyle = require("src/combat_style")
local Settings = require("src/settings")

game_window = ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__PLUGIN_BUILD_LAYER_TOP)
--initialise variables
local currentBossTimer = 0
local personalRecordText = "New Personal Record"
local completionText = "Completion Time"
local completionCheck = false
local flag = false

--chat messagge
Event.ChatMessage.Subscribe("detectBossRecord", function(chatMessageEvent)
    if chatMessageEvent.chatType ~= ChatType.GENERAL then
        return
    end
    if string.find(chatMessageEvent.chatMessage, personalRecordText, 1, true) then --pr
        BossTimerUI.HideForRecord()
        if Settings.IsBoxChecked() then
            local combatStyle = CombatStyle.checkEquippedMainhand()
            Animations.PlayForCombatStyle(combatStyle, game_window)
        end
    end
    if string.find(chatMessageEvent.chatMessage, completionText, 1, true) then --killend
        completionCheck = true
    end
end)

--20ms
Event.Logic.Subscribe("checkBossTimerUI", function()
    if var.VarPlayer.BOSS_INSTANCE_TIMED_START.value ~= 0 then
        if not BossTimerUI.IsCreated() and ui.Interfaces:GetComponent(id.Component.TIMED_KILL__TIME_TEXT) ~= nil then
            BossTimerUI.Create()
            if var.VarPlayer.BOSS_INSTANCE_CURRENT_BOSS.value == 11 and currentBossTimer < 5 then --i hate kalphite king
            currentBossTimer = 5
            end
            BossTimerUI.Update(currentBossTimer)
        end
        BossTimerUI.UpdateKillCount()
    end
    Animations.Update()
end)

--600ms
Event.ServerLogic.Subscribe("updateBossTimer", function()
    if (var.VarClient.BOSS_INSTANCE_CLIENT_TIMER_SECONDS_ELAPSED.value ~= 0) and (var.VarPlayer.BOSS_INSTANCE_TIMED_START.value ~=0) and completionCheck == false then
        currentBossTimer = currentBossTimer + 1
        BossTimerUI.Update(currentBossTimer)
        flag = true
    end
    if completionCheck == true or (var.VarPlayer.BOSS_INSTANCE_TIMED_START.value == 0 and flag == true) then
            currentBossTimer = currentBossTimer + 1
            BossTimerUI.Update(currentBossTimer)
            BossTimerUI.Reset()
            currentBossTimer = 0
            completionCheck = false
            flag = false
    end
end)



