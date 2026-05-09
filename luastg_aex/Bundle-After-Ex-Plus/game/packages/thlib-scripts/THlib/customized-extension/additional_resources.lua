-- LoadMusic("menu", 'THlib/music/信息之渊 ~ Data Abyss.ogg', 91.095, 91.095)
-- --SetBGMVolume("menu",0.7)
-- LoadMusic("bgm_stage1","THlib/music/星罗深海 ~ Drowning in Data.ogg",82.154,73.846)
-- --SetBGMVolume("bgm_stage1",0.7)
-- LoadMusic("bgm_stage2", "THlib/music/摇曳潜行 ~ Learning in Attractors.ogg",145.654,132.414)
-- LoadMusic("bgm_stage4a","THlib/music/碎梦的回廊 ~ Undefined and Missing Ideas.ogg",282.4615,141.2308)
-- LoadMusic("bgm_ending", "THlib/music/星涟心迹 ~ Starlit Cognition.ogg",103.385,103.385)
-- LoadMusic("bgm_staff", "THlib/music/数字生命 ~ Artificial Dream.ogg",113.778,113.778)
-- LoadMusic("bgm_stage3","THlib/music/踏入未知的无尽幻想 ~ Stepped Into Utopia.ogg",174.0000,163.3333)

-- MusicRecord("bgm_stage4b","THlib/music/上海アリス幻樂団 - 綿月のスペルカード ~ 神海戦.ogg",297.820,148.574)
-- LoadMusicRecord("bgm_stage4b")
-- -- LoadMusic("bgm_stage4b","THlib/music/上海アリス幻樂団 - 綿月のスペルカード ~ 神海戦.ogg",297.820,148.574)

-- LoadMusic('bgm_lastword','THlib\\music\\spellcard.ogg',75,0xc36e80/44100/4)

--#region music extension zone
local MusicList={
    {name="menu",path='THlib/music/信息之渊 ~ Data Abyss.ogg',loopend=91.095,looplength=91.095},
    {name="bgm_stage1",path='THlib/music/星罗深海 ~ Drowning in Data.ogg',loopend=82.154,looplength=73.846},
    {name="bgm_stage2",path='THlib/music/摇曳潜行 ~ Learning in Attractors.ogg',loopend=145.654,looplength=132.414},
    {name="bgm_stage4a",path='THlib/music/碎梦的回廊 ~ Undefined and Missing Ideas.ogg',loopend=282.4615,looplength=141.2308},
    {name="bgm_ending",path='THlib/music/星涟心迹 ~ Starlit Cognition.ogg',loopend=103.385,looplength=103.385},
    {name="bgm_staff",path='THlib/music/数字生命 ~ Artificial Dream.ogg',loopend=113.778,looplength=113.778},
    {name="bgm_stage3",path='THlib/music/踏入未知的无尽幻想 ~ Stepped Into Utopia.ogg',loopend=174.0000,looplength=163.3333},
    {name="bgm_stage4b",path='THlib/music/上海アリス幻樂団 - 綿月のスペルカード ~ 神海戦.ogg',loopend=297.820,looplength=148.574},
    {name="bgm_lastword",path='THlib\\music\\spellcard.ogg',loopend=75,looplength=0xc36e80/44100/4},
    {name="bgm_staff_full",path='THlib/music/翔鹤-full.ogg',loopend=206,looplength=206}
}

for i,v in ipairs(MusicList) do
    MusicRecord(v.name,v.path,v.loopend,v.looplength)
    LoadMusicRecord(v.name)
end
--#endregion

---#region emo bubble extension zone
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
--#endregion

--#region sound effect extension zone
---! soundeffect extension zone
LoadSound("se_immune","THlib/se_ext/se_immune.wav")
LoadSound("se_poison","THlib/se_ext/Poison.ogg")
LoadSound("se_heal","THlib/se_ext/se_heal.ogg")
LoadSound("se_broaden","THlib/se_ext/se_broaden_horizon.ogg")
LoadSound("se_fusion","THlib/se_ext/se_fusion.ogg")
LoadSound("se_water","THlib/se_ext/Water1.ogg")

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

--#endregion