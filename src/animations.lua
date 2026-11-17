local Animations = {}

local activeFrames
local animationActive = false
local animationFrame = 1
local animationTick = 0
local animationFrameDelay = 0
local danceSprite
local danceContainer

local function updateDanceContainerLayout(parent)
    if danceContainer == nil or parent == nil then
        return
    end

    local containerSize = math.floor(parent.height * 0.5)
    local x = math.floor((parent.width - containerSize) * 0.5)
    local y = math.floor((parent.height - containerSize) * 0.5)

    danceContainer:SetSize(containerSize, containerSize)
    danceContainer:SetPos(x, y)
end

local function loadFrames(resourceGroup, resourceName, frameCount, prefix, allowMissing)
    local frames = {}
    prefix = prefix or "frame_"

    if resourceGroup == nil then
        error("Animation resource group was not loaded: " .. resourceName)
    end

    for i = 1, frameCount do
        local frame = resourceGroup[prefix .. i]
        if frame == nil and not allowMissing then
            error("Missing animation resource: " .. prefix .. i)
        end
        if frame ~= nil then
            frames[#frames + 1] = frame
        end
    end

    if #frames == 0 then
        error("No animation frames found: " .. resourceName)
    end

    return frames
end

local animations = {
    osrsDance = {
        frames = loadFrames(Plugin.resources.universal.osrsdance, "osrsdance", 97),
        frameDelay = 2,
    },

    clawsAnim = {
        frames = loadFrames(Plugin.resources.melee.dragon_claws, "claws", 111, "claws_"),
        frameDelay = 1,
    },

    dbowAnim = {
        frames = loadFrames(Plugin.resources.range.dark_bow, "dbow", 95, "dbow_"),
        frameDelay = 1,
    },
    fsoaAnim = {
        frames = loadFrames(Plugin.resources.mage.fsoa, "fsoa", 159, "fsoa_"),
        frameDelay = 1,
    },
    fireworksAnim = {
        frames = loadFrames(Plugin.resources.universal.fireworks, "fireworks", 151, "firework_"),
        frameDelay = 1,
    },
}

local animationByCombatStyle = {
    melee = "clawsAnim",
    ranged = "dbowAnim",
    magic = "fsoaAnim",
    barehanded = "fireworksAnim",
    necromancy = "fireworksAnim",
}


local function ensureSprite(parent)
    if danceContainer ~= nil then
        return true
    end

    if parent == nil then
        return false
    end

    danceContainer = ui.Layer.new(parent)

    -- Make a square whose width and height are both 50% of the parent's
    -- height, then centre it on the parent.
    updateDanceContainerLayout(parent)

    -- Recalculate the square if the game window is resized.
    parent:Subscribe(ui.Hook.ONRESIZE, "animationResize",
        function ()
            updateDanceContainerLayout(parent)
        end)
    danceContainer.clickthrough = true

    danceSprite = ui.Sprite.new(danceContainer)
    danceSprite:SetSize(0, 0, 1.0, 1.0)
    danceSprite.clickthrough = true
    danceSprite:MoveToFront()

    return true
end

function Animations.Play(name, parent)
    local animation = animations[name]
    if animation == nil then
        return
    end

    if not ensureSprite(parent) then
        return
    end

    activeFrames = animation.frames
    animationFrameDelay = animation.frameDelay
    animationActive = true
    animationFrame = 1
    animationTick = 0

    danceSprite.hidden = false
    danceSprite.sprite = activeFrames[animationFrame]
end

function Animations.PlayForCombatStyle(combatStyle, parent)
    local animationName = animationByCombatStyle[combatStyle]
    if animationName == nil then
        return
    end

    if math.random(15) == 1 then
        Animations.Play("osrsDance", parent)
        return
    end

    Animations.Play(animationName, parent)
end

function Animations.Update()
    if not animationActive or danceSprite == nil or activeFrames == nil then
        return
    end

    animationTick = animationTick + 1

    if animationTick < animationFrameDelay then
        return
    end

    animationTick = 0
    animationFrame = animationFrame + 1

    if animationFrame > #activeFrames then
        animationActive = false
        danceSprite.hidden = true
    else
        danceSprite.sprite = activeFrames[animationFrame]
    end
end

return Animations
