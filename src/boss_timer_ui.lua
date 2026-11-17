local BossCalculation = require("src/boss_calculation")
local BossTimerUI = {}

local timerlabel
local prlabel
local kclabel
local labelsCreated = false
local displayedBossIcon
local timer_icon
local pr_icon
local kc_icon
local horizontalLine
local horizontalLine2

local colour1 = Vector4.new(0.941, 0.753, 0.502, 1.0)
local colour2 = Vector4.new(0.961, 0.627, 0.251, 1.0)
local colour3 = Vector4.new(0.941, 0.502, 0.125, 1.0)
local colour4 = Vector4.new(0.910, 0.353, 0.094, 1.0)
local colour5 = Vector4.new(0.847, 0.196, 0.063, 1.0)
local colour6 = Vector4.new(0.745, 0.0, 0.0, 1.0)


--format kc
local function format_int(n)
    if n then
        return tostring(math.floor(n))
            :reverse()
            :gsub("(%d%d%d)", "%1,")
            :gsub(",(%-?)$", "%1")
            :reverse()
    end
end

--create interface function
function BossTimerUI.Create()

    displayedBossIcon = nil

    local x = 105
    local y = 92

    -- set height of ui elements
    ui.Interfaces:GetComponent(id.Component.TIMED_KILL__CONTAINER_LAYER):SetHeight(y)
    ui.Interfaces:GetComponent(id.Component.TIMED_KILL__CONTAINER_LAYER):SetWidth(x)
    ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__BOSS_TIMER_WINDOW_CONTENT):SetHeight(y)
    ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__BOSS_TIMER_WINDOW_CONTENT):SetWidth(x)
    ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__BOSS_TIMER_WINDOW):SetHeight(y)
    ui.Interfaces:GetComponent(id.Component.TOPLEVEL_V2__BOSS_TIMER_WINDOW):SetWidth(x)

    -- hide ui text
    ui.Interfaces:GetComponent(id.Component.TIMED_KILL__TIME_TEXT).alpha = 0.0

    -- move icon out the way (can i just hide it too?)
    ui.Interfaces:GetComponent(
        id.Component.TIMED_KILL__BOSS_ICON
    ):SetY(-10000)

    local parent = ui.Interfaces:GetComponent(
        id.Component.TIMED_KILL__CONTAINER_LAYER
    )


    timer_icon = ui.Sprite.new(parent)
    timer_icon:SetSize(20, 20)
    timer_icon:SetPos(6, 7)
    timer_icon.sprite = Plugin.resources.RS3_ICON_TIMER_23PX

    pr_icon = ui.Sprite.new(parent)
    pr_icon:SetSize(20, 20)
    pr_icon:SetPos(6, 35)
    pr_icon.sprite = Plugin.resources.SGS_ICON_COMP_GEMS_TROPHY

    kc_icon = ui.Sprite.new(parent)
    kc_icon:SetSize(20, 20)
    kc_icon:SetPos(6, 64)
    kc_icon.sprite = Plugin.resources.AIF_BOSS_SLAYER_ICONS_0

    horizontalLine = ui.Line.new(parent)
    horizontalLine:SetSize(30, 0)
    horizontalLine:SetWidth(102)
    horizontalLine:SetY(30)
    horizontalLine:SetX(1)
    horizontalLine.width = 1
    horizontalLine.colour = Vector4.new(0.353, 0.275, 0.165, 1.0)

    horizontalLine2 = ui.Line.new(parent)
    horizontalLine2:SetSize(30, 0)
    horizontalLine2:SetWidth(102)
    horizontalLine2:SetY(60)
    horizontalLine2:SetX(1)
    horizontalLine2.width = 1
    horizontalLine2.colour = Vector4.new(0.353, 0.275, 0.165, 1.0)

    timerlabel = ui.Text.new(parent)
    timerlabel:AlignTo(ui.AlignMode.CENTRE)
    timerlabel:SetSize(100, 50)
    timerlabel.font = 210
    timerlabel:SetY(-8)
    timerlabel:SetX(12)
    
    prlabel = ui.Text.new(parent)
    prlabel:AlignTo(ui.AlignMode.CENTRE)
    prlabel:SetSize(100, 50)
    prlabel.font = 210
    prlabel:SetY(20)
    prlabel:SetX(12)

    kclabel = ui.Text.new(parent)
    kclabel:AlignTo(ui.AlignMode.CENTRE)
    kclabel.content = "0"
    kclabel:SetSize(100, 50)
    kclabel.font = 210
    kclabel:SetY(49)
    kclabel:SetX(12)

    labelsCreated = true
end

local function updateBossIcon(boss_icon)
    if kc_icon == nil or boss_icon == displayedBossIcon then
        return
    end

    local spriteName

    if boss_icon == "hm" then
        spriteName = "AIF_BOSS_SLAYER_ICONS_1"
    else
        spriteName = "AIF_BOSS_SLAYER_ICONS_0"
    end
    kc_icon.sprite = Plugin.resources[spriteName]
    displayedBossIcon = boss_icon
end

function BossTimerUI.UpdateKillCount()
    if kclabel == nil then
        return
    end

    local current_kc, boss_icon = BossCalculation.Run()
    if current_kc ~= nil then
        kclabel.content = tostring(format_int(current_kc))
    end
    updateBossIcon(boss_icon)
    
end

-- changes when we get a pr
function BossTimerUI.HideForRecord()
    if timerlabel == nil
        or prlabel == nil
        or horizontalLine == nil
        or horizontalLine2 == nil
        or timer_icon == nil
        or pr_icon == nil then
        return
    end

    prlabel:SetY(-10000)
    timerlabel:SetY(-10000)
    horizontalLine:SetY(-10000)
    horizontalLine2:SetY(-10000)
    timer_icon:SetY(-10000)
    pr_icon:SetY(-10000)
    ui.Interfaces:GetComponent(
        id.Component.TIMED_KILL__NEW_RECORD_LAYER):SetY(-15)
end

function BossTimerUI.Update(currentBossTimer)
    if timerlabel == nil or prlabel == nil or kclabel == nil then
        return
    end

    local current_kc, boss_icon = BossCalculation.Run()
    if current_kc ~= nil then
        kclabel.content = tostring(format_int(current_kc))
    end
    updateBossIcon(boss_icon)

    local pr_ticks = var.VarClient.TIMED_KILL_TARGET.value or 0
    local pr_total_seconds = pr_ticks * 6
    local pr_hours = pr_total_seconds // 36000
    local pr_minutes = (pr_total_seconds // 600) % 60
    local pr_seconds_rounded = (pr_total_seconds // 10) % 60
    local pr_fraction = pr_total_seconds % 10

    if pr_minutes == 0 and pr_hours == 0 then
        prlabel.content = string.format("%d.%d%s", pr_seconds_rounded, pr_fraction, "s")
    elseif pr_hours == 0 then
        prlabel.content = string.format("%d:%02d.%d", pr_minutes, pr_seconds_rounded, pr_fraction)
    else
        prlabel.content = string.format(
            "%d:%02d:%02d.%d",
            pr_hours,
            pr_minutes,
            pr_seconds_rounded,
            pr_fraction
        )
    end


    local total_seconds = currentBossTimer * 6
    local hours = total_seconds // 36000
    local minutes = (total_seconds // 600) % 60
    local seconds_rounded = (total_seconds // 10) % 60
    local fraction = total_seconds % 10

    if minutes == 0 and hours == 0 then
        timerlabel.content = string.format("%d.%d%s", seconds_rounded, fraction, "s")
    elseif hours == 0 then
        timerlabel.content = string.format("%d:%02d.%d", minutes, seconds_rounded, fraction)
    else
        timerlabel.content = string.format(
            "%d:%02d:%02d.%d",
            hours,
            minutes,
            seconds_rounded,
            fraction
        )
    end


    if currentBossTimer == pr_ticks and pr_ticks ~= 0 then
        timerlabel.colour = colour6
    elseif currentBossTimer + 1 == pr_ticks then
        timerlabel.colour = colour5
    elseif currentBossTimer + 2 == pr_ticks then
        timerlabel.colour = colour4
    elseif currentBossTimer + 3 == pr_ticks then
        timerlabel.colour = colour3
    elseif currentBossTimer + 4 == pr_ticks then
        timerlabel.colour = colour2
    elseif currentBossTimer + 5 == pr_ticks then
        timerlabel.colour = colour1
    end
end

function BossTimerUI.Reset()
    timerlabel = nil
    prlabel = nil
    kclabel = nil
    timer_icon = nil
    pr_icon = nil
    kc_icon = nil
    horizontalLine = nil
    horizontalLine2 = nil
    displayedBossIcon = nil
    labelsCreated = false
    BossCalculation.Reset()
end

function BossTimerUI.IsCreated()
    return labelsCreated
end

return BossTimerUI
