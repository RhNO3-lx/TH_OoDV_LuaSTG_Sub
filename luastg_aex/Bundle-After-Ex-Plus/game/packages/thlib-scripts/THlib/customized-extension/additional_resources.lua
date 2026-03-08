
LoadMusic("bgm_stage1","THlib/music/星罗深海 ~ Drowning in Data.ogg",151.384615,73.846154)
--SetBGMVolume("bgm_stage1",0.7)

LoadMusic("menu", 'THlib/music/title.ogg', 126.171, 126.171)
--SetBGMVolume("menu",0.7)

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