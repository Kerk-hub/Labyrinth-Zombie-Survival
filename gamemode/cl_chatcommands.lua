
--Here you can add more client side commands for players to use.

local Commands = {
    ["!guide"] = function(pl)
        pl:SendLua('gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=401130458")') --Generic ZS guide until I make my own for Labyrinth
        return ""
    end,

    ["!discord"] = function(pl)
        pl:SendLua('gui.OpenURL("https://discord.gg/V9JGECTaQW")')
        return ""
    end
}

function GM:PlayerSay(pl, text, teamchat)
    local LowerText = string.lower(text)

    local cmd = Commands[LowerText]
    if cmd then
        return cmd(pl)
    end

    return text
end