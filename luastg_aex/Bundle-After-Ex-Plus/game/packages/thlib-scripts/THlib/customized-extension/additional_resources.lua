
LoadMusic("stage1","THlib/music/stage1.ogg",81.23,73.95)
SetBGMVolume("stage1",0.7)

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