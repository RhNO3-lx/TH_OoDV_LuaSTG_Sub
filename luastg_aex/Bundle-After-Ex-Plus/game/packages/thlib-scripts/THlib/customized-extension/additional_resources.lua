
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

for i,v in ipairs(EmoBubble) do
    LoadAnimation("emo_"..v,"emo_bubble",0,32*(i-1),32,32,8,1,6)
end