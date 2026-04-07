LoadMusic("menu", 'THlib/music/信息之渊 ~ Data Abyss.ogg', 91.095, 91.095)
--SetBGMVolume("menu",0.7)
LoadMusic("bgm_stage1","THlib/music/星罗深海 ~ Drowning in Data.ogg",82.154,73.846)
--SetBGMVolume("bgm_stage1",0.7)
LoadMusic("bgm_stage2", "THlib/music/摇曳潜行 ~ Learning in Attractors.ogg",145.654,132.414)
LoadMusic("bgm_stage4a","THlib/music/碎梦的回廊 ~ Undefined and Missing Ideas.ogg",282.4615,141.2308)
LoadMusic("bgm_ending", "THlib/music/星涟心迹 ~ Starlit Cognition.ogg",103.385,103.385)
LoadMusic("bgm_staff", "THlib/music/数字生命 ~ Artificial Dream.ogg",113.778,113.778)
LoadMusic('bgm_lastword','THlib\\music\\spellcard.ogg',75,0xc36e80/44100/4)
LoadTexture("emo_bubble","THlib/emo_bubble/Balloon.png")

EmoBubble={
    "shock",
    "question",
    "happy",
    "love",
    "angry",
    "wordless",
    "confuse",
    "silent",
    "lightbulb",
    "sleep"
}

EmoBubble.FrameLast=10
for i,v in ipairs(EmoBubble) do
    LoadAnimation("emo_"..v,"emo_bubble",0,32*(i-1),32,32,8,1,EmoBubble.FrameLast)
end

---! soundeffect extension zone
LoadSound("se_immune","THlib/se_ext/se_immune.wav")
LoadSound("se_poison","THlib/se_ext/Poison.ogg")
LoadSound("se_heal","THlib/se_ext/se_heal.ogg")
LoadSound("se_broaden","THlib/se_ext/se_broaden_horizon.ogg")
LoadSound("se_fusion","THlib/se_ext/se_fusion.ogg")

---from dnh

DNHSoundList={
    "dnh_alert_n1",
    "dnh_alert_n2",
    "dnh_alertline",
    "dnh_ice",
    "dnh_pause",
    "dnh_release"
}

for i,v in ipairs(DNHSoundList) do
    LoadSound(v,"THlib/se_ext/dnh/"..v..".wav")
end