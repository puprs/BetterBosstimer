local CombatStyle= {}

local weaponCombatStyles = {
    [1] = "magic",
    [5] = "melee",
    [6] = "melee",
    [7] = "barehanded",
    [8] = "ranged",
    [9] = "ranged",
    [10] = "ranged",
    [37] = "necromancy",
}

function CombatStyle.checkEquippedMainhand()
    local CurrentStyle = var.VarPlayer["COMBATV2_MAINHAND_STYLE"].value
    local combatStyle = weaponCombatStyles[CurrentStyle]
    
    return combatStyle
end

return CombatStyle
