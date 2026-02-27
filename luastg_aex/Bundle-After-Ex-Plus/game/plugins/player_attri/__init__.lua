-- 自机拓展，

---! do player file to add it to global var: player_list
---! this part indeed works
---! add our own logic here
lstg.plugin.RegisterEvent("afterTHlib", "Player Extensions", 100, function()
    lstg.DoFile("renseki/renseki.lua")
    --lstg.DoFile("THlib/player/marisa/marisa.lua")
end)
