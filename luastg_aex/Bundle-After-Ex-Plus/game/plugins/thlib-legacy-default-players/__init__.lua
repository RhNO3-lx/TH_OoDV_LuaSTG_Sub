-- 自机拓展，灵梦，魔理沙

---! do player file to add it to global var: player_list
---! this part indeed works
lstg.plugin.RegisterEvent("afterTHlib", "Player Extensions", 100, function()
    lstg.DoFile("THlib/player/reimu/reimu.lua")
    lstg.DoFile("THlib/player/marisa/marisa.lua")
end)
