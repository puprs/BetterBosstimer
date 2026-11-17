local BossData = require("src/bosses")

local BossCalculation = {}

local cachedBossInstanceId
local cachedBoss
local hasCachedBossInstance = false
local current_kc
local boss_icon

-- bosses with a unique value that displays
-- bosses 1
local unique__instance_values = {
    1, 3, 6, 10, 11, 12, 13, 16, 17, 18, 19, 21, 22, 27, 28, 29, 30, 44, 47, 48, 53, 55, 56, 57, 500, 501,
}

-- bosses with a nm and hm. same instance. diff unique id.
-- bosses 2
local unique_ids_by_current_boss = {
    [5] = {2, 19},       -- Zilyana
    [8] = {1, 16},       -- General Graardor
    [9] = {22, 21},      -- Giant Mole
    [14] = {4, 18},      -- Kree'arra
    [15] = {3, 17},      -- K'ril
    [23] = {24, 27},     -- Twin Furies
    [24] = {23, 30},     -- Vindicta
    [25] = {25, 29},     -- Gregorovic
    [26] = {26, 28},     -- Helwyr
    [43] = {56, 57},     -- Arch-Glacor
    [49] = {64, 65},     -- Zemouregal & Vorkath
}

-- bosses with nm and hm. same instance. same unique id. diff boss name
-- bosses 3
local boss_names_by_current_boss = {
    [42] = {"Kerapac", "Kerapac (HM)"},
    [45] = {"TzKal-Zuk", "TzKal-Zuk (Hard Mode)"},
}

-- check nm/hm with dungeon difficulty mode. 0 = nm. 1 - hm
-- bosses 4
local dungeon_difficulty_modes_by_current_boss = {
    [50] = {0, 1}, -- Vermyx
    [51] = {0, 1}, -- Kezalam
    [52] = {0, 1}, -- Nakatra
}

-- check size with dungeon progress group size
-- bosses 5
local group_size_current_boss_ids = {
    [31] = true, -- The Sanctum Guardian
    [32] = true, -- Masuta the Ascended
    [33] = true, -- Seiryu
    [34] = true, -- Astellarn
    [35] = true, -- Verak Lith
    [36] = true, -- Black Stone Dragon
    [37] = true, -- Crassian Leviathan
    [38] = true, -- Taraket
    [39] = true, -- The Ambassador
    [46] = true, -- Zamorak
}


--functions

-- check if value exists
local function IsUniqueInstanceValue(value)
    for _, uniqueValue in ipairs(unique__instance_values) do
        if uniqueValue == value then
            return true
        end
    end

    return false
end

-- find boss by boss instance current boss
local function FindBossByCurrentBoss(currentBossId)
    for _, boss in ipairs(BossData.boss_instances) do
        if boss.boss_instance_current_boss == currentBossId then
            return boss
        end
    end

    return nil
end

-- find a boss row by uniqueid
local function FindBossByUniqueId(uniqueId)
    for _, boss in ipairs(BossData.boss_instances) do
        if boss.unique_id == uniqueId then
            return boss
        end
    end

    return nil
end

--read current bossinstancestruct
local function GetCurrentBossStruct()
    local bossVar = var.VarPlayer.BOSS_INSTANCE_STRUCT

    return bossVar and bossVar.value
end

-- read name and id from current bossinstancestruct
local function GetCurrentBossStructValue(paramName)
    local bossStruct = GetCurrentBossStruct()
    local parameter = config.Param[paramName]

    if bossStruct and parameter and bossStruct:HasParam(parameter) then
        return bossStruct:GetParamValue(parameter)
    end

    return nil
end


-- check ids
-- bosses 2
local function FindBossWithSharedCurrentBoss(currentBossId)
    local possibleUniqueIds = unique_ids_by_current_boss[currentBossId]

    if not possibleUniqueIds then
        return nil
    end

    local currentUniqueId =
        GetCurrentBossStructValue("BOSS_INSTANCE_UNIQUE_ID")

    if currentUniqueId == nil then
        return nil
    end

    for _, possibleUniqueId in ipairs(possibleUniqueIds) do
        if possibleUniqueId == currentUniqueId then
            return FindBossByUniqueId(currentUniqueId)
        end
    end

    return nil
end

-- check names
-- bosses 3
local function FindBossWithSharedBossName(currentBossId)
    local possibleBossNames = boss_names_by_current_boss[currentBossId]

    if not possibleBossNames then
        return nil
    end

    local currentBossName =
        GetCurrentBossStructValue("BOSS_INSTANCE_BOSS_NAME")

    if currentBossName == nil then
        return nil
    end

    for _, possibleBossName in ipairs(possibleBossNames) do
        if possibleBossName == currentBossName then
            for _, boss in ipairs(BossData.boss_instances) do
                if boss.boss_instance_current_boss == currentBossId
                    and boss.boss_name == currentBossName then
                    return boss
                end
            end

            return nil
        end
    end

    return nil
end

-- check difficulty modes nakatra
-- bosses 4
local function FindBossWithDifficultyMode(currentBossId)
    local possibleDifficultyModes =
        dungeon_difficulty_modes_by_current_boss[currentBossId]

    if not possibleDifficultyModes then
        return nil
    end

    local difficultyModeVar = var.VarPlayer.DUNGEON_PROGRESS_DIFFICULTY_MODE
    local currentDifficultyMode =
        difficultyModeVar and tonumber(difficultyModeVar.value)

    if currentDifficultyMode == nil then
        return nil
    end

    for _, possibleDifficultyMode in ipairs(possibleDifficultyModes) do
        if possibleDifficultyMode == currentDifficultyMode then
            for _, boss in ipairs(BossData.boss_instances) do
                local bossDifficultyMode =
                    tonumber(boss.DUNGEON_PROGRESS_DIFFICULTY_MODE)

                if boss.boss_instance_current_boss == currentBossId
                    and bossDifficultyMode == currentDifficultyMode then
                    return boss
                end
            end

            return nil
        end
    end

    return nil
end

-- check elite dung group size
-- bosses 5
local function FindBossWithGroupSize(currentBossId)
    if not group_size_current_boss_ids[currentBossId] then
        return nil
    end

    local groupSizeVar = var.VarPlayer.DUNGEON_PROGRESS_GROUP_SIZE
    local currentGroupSize = groupSizeVar and tonumber(groupSizeVar.value)

    if currentGroupSize == nil then
        return nil
    end

    local wantedGroupSize


    if currentGroupSize == 0 or currentGroupSize == 1 then
        wantedGroupSize = "Solo"
    elseif currentGroupSize > 1 then
        wantedGroupSize = "Group"
    else
        return nil
    end

    for _, boss in ipairs(BossData.boss_instances) do
        if boss.boss_instance_current_boss == currentBossId
            and boss.DUNGEON_PROGRESS_GROUP_SIZE == wantedGroupSize then
            return boss
        end
    end

    return nil
end

-- compare pr (plz dont have the same pr)
-- bosses 6 rago
local function FindBossWithTimedKillTarget(currentBossId)
    if currentBossId ~= 20 then
        return nil
    end

    local timedKillTargetVar = var.VarClient.TIMED_KILL_TARGET
    local normalPersonalBestVar = var.VarPlayer.BOSS_INSTANCE_SCORES_VORAGO
    local hardPersonalBestVar = var.VarPlayer.BOSS_INSTANCE_SCORES_VORAGO_HARD

    if not timedKillTargetVar
        or not normalPersonalBestVar
        or not hardPersonalBestVar then
        return nil
    end

    local timedKillTarget = timedKillTargetVar.value
    local normalPersonalBest = normalPersonalBestVar.value
    local hardPersonalBest = hardPersonalBestVar.value
    local wantedMode

    if timedKillTarget == normalPersonalBest then
        wantedMode = "normal"
    elseif timedKillTarget == hardPersonalBest then
        wantedMode = "hard"
    else
        return nil
    end

    for _, boss in ipairs(BossData.boss_instances) do
        if boss.boss_instance_current_boss == currentBossId
            and boss.mode == wantedMode then
            return boss
        end
    end

    return nil
end

-- check hp via the ui
-- bosses 7 raksha
local function FindBossWithActiveInfoValue(currentBossId)
    if currentBossId ~= 40 then
        return nil
    end

    local activeInfoVar = var.VarPlayer.ACTIVITY_PROGRESS_BAR_ACTIVE_INFO_2

    if not activeInfoVar then
        return nil
    end

    local activeInfoValue = tonumber(activeInfoVar.value)
    local wantedSize

    if activeInfoValue and activeInfoValue > 850000 then
        wantedSize = "duo"
    else
        wantedSize = "solo"
    end

    for _, boss in ipairs(BossData.boss_instances) do
        if boss.boss_instance_current_boss == currentBossId
            and boss.size == wantedSize then
            return boss
        end
    end

    return nil
end

-- bosses 8 amascut gkb enrage
local function FindBossWithEnrageValue(currentBossId)
    if currentBossId ~= 54 and currentBossId ~= 58 then
        return nil
    end

    local enrageVar =
        var.VarPlayer.ACTIVITY_PROGRESS_BAR_EXTENSION_INFO_BOX_2_VALUE

    if not enrageVar then
        return nil
    end

    local enrageValue = tonumber(enrageVar.value)
    local wantedEnrageMode

    if enrageValue and enrageValue > 1 then
        wantedEnrageMode = "yes"
    else
        wantedEnrageMode = "no"
    end

    for _, boss in ipairs(BossData.boss_instances) do
        if boss.boss_instance_current_boss == currentBossId
            and boss.enrage == wantedEnrageMode then
            return boss
        end
    end

    return nil
end



local function FindBossForCurrentInstance(currentBossId)
    -- bosses 1 unique instance value
    if IsUniqueInstanceValue(currentBossId) then
        return FindBossByCurrentBoss(currentBossId)
    end

    -- bosses 2 unique id
    local boss = FindBossWithSharedCurrentBoss(currentBossId)

    -- bosses 3 unique name
    if not boss then
        boss = FindBossWithSharedBossName(currentBossId)
    end

    -- bosses 4 nakatra difficulty mode
    if not boss then
        boss = FindBossWithDifficultyMode(currentBossId)
    end

    -- bosses 5 elite dung size
    if not boss then
        boss = FindBossWithGroupSize(currentBossId)
    end

    -- bosses 6 rago pr
    if not boss then
        boss = FindBossWithTimedKillTarget(currentBossId)
    end

    -- bosses 7 enrage
    if not boss then
        boss = FindBossWithEnrageValue(currentBossId)
    end

    -- bosses 8 raksha
    if not boss then
        boss = FindBossWithActiveInfoValue(currentBossId)
    end

    return boss
end


-- read kc from boss table row
local function ReadCurrentKC(boss)
    if not boss or not boss.kc_var then
        return nil
    end

    -- use string  in command
    local kcVar = var.VarPlayer[boss.kc_var]

    if not kcVar then
        return nil
    end

    return kcVar.value
end


-- get kc
-- only check for new boss if boss is different
local function GetCurrentKC()
    -- get current boss
    local bossVar = var.VarPlayer.BOSS_INSTANCE_CURRENT_BOSS
    if not bossVar then return nil, nil end
    local id = bossVar.value
        -- if value is new or different, run rules
    if not hasCachedBossInstance or id ~= cachedBossInstanceId then
        cachedBossInstanceId = id
        cachedBoss = FindBossForCurrentInstance(id)
        boss_icon = cachedBoss and cachedBoss.icon or nil
        hasCachedBossInstance = (cachedBoss ~= nil)   -- retry next tick if unresolved
    end
    -- read kc from cached boss
    current_kc = ReadCurrentKC(cachedBoss)
     -- return current kc and icon value for nm/hm
    return current_kc, boss_icon
end



function BossCalculation.Reset()
    hasCachedBossInstance = false
    cachedBossInstanceId = nil
    cachedBoss = nil
    boss_icon = nil
    current_kc = nil
end





function BossCalculation.Run()
    return GetCurrentKC()
end

return BossCalculation
