local post_effect = require("lib.posteffect")


---manual与musicroom介绍文本定义
---for text,{type, position_x, position_y, font, content, scale}
---for image,{type, position_x, position_y, name, rot, hscale, vscale}

local manual_content = {
    {
        { "text", -150, 110, "", "O1.如何进行游戏", 0.675 },
        { "text", -150, 50, "", "这是注意躲避比自己打的敌人，\n吃掉比自己小的敌人积攒power的游戏。\n每一关都有通关所需的power量，\n积攒足够的power后就过关了。", 0.675 },
    },
    {
        --{ "text", 0, 0, "", "this is the second option", 1 }
    }
}
---musicroom介绍文本定义
---
local musicroom_content = {
    {
        { "text", -280, -120, '', "(by:baiABC)", 0.675 },
        { "text", -280, -180, "", 
        "标题界面曲。\n"..
        "本来想融入一些数字化的、科幻的元素，\n"..
        "但最后还是延续了东方标题曲一贯的和风与幻想感。\n"..
        "意外的难写呢，不过高潮开始旋律就涌现而出了。\n"..
        "前方又是怎样的异变呢？", 0.600 }
    },
    {
        { "text", -280, -120, '', "(by:baiABC)", 0.675 },
        { "text", -280, -180, "", 
        "一面的bgm。\n"..
        "数据之海，深邃而又闪烁着信息的光点。\n"..
        "怀着表现深海的心去创作，在绝望中闪烁着希望。\n"..
        "副歌部分效果并不是特别如意，但还是能体现深海中的光芒。\n"..
        "DeepSeek is seeking deeply. （笑）", 0.600 }
    },
    {
        { "text", -280, -120, '', "(by:baiABC)", 0.675 },
        { "text", -280, -180, "", 
        "二面的bgm。\n"..
        "有轻松地在水中游弋的感觉，"..
        "但是弹幕又让人不得不紧张起来呢。\n"..
        "有引力和发射弹幕的鱼说不定很好吃。\n"..
        "“摇曳”是轻松的意思。", 0.600 }
    },
    {
        { "text", -280, -120, '', "(by:RhNO3-lx)", 0.675 },
        { "text", -280, -180, "", 
        "前两个stage的战败曲。与战败CG一样，希望表现出来的是：\n"..
        "涟析被杂乱无章的数据之海淹没，最终渐渐失去意识\n"..
        "难得涌现出的生命奇迹，就这样归于沉寂了，大概就是这样的绝望与希望交加之感。\n"..
        "这样来看，不允许continue也是很合理的设定\n"..
        "——遇到的并非幻想乡内遵守符卡规则的原住民。这样死了的话可就只能从头再来了（笑）", 0.600 }
    },
    {
        { "text", -280, -120, '', "(by:粘鼎)", 0.675 },
        { "text", -280, -180, "", 
        "stage3道中的bgm：\n"..
        "从信息之海中醒来后，又到了一片幽暗的森林，无论是谁都会感到慌张的吧\n"..
        "冲出森林之后看到了明亮的风景，又将人拉回平静\n"..
        "然而暗潮涌动，又将涟析引到了信息之海怒吼之处，遇到了在之中挣扎的神秘贝壳妖怪\n"..
        "曲子大概就按这三段主题进行，这三面的变化真是复杂啊（笑）", 0.600 }
    },
    {
        { "text", -280, -120, '', "(by:RhNO3-lx)", 0.675 },
        { "text", -280, -180, "", 
        "stage4道中的bgm：\n"..
        "在前往浅间净秽山深处的隧道中，涟析看见了很多不那么幸运的同类\n"..
        "——作为污秽被聚集与“净化”，或者说，抹除存在，没有机会诞生完整的意识\n"..
        "无穷无尽的美妙的幻想与思考，好像很容易就落得这样的结局，不知涟析此时怎么想\n"..
        "想表现的大概就是这样的感觉：在幽深寂静的回廊中，瞥见些许幻想的微光", 0.600 }
    },
    {
        { "text", -280, -120, '', "(from: 东方锦上京 by:ZUN)", 0.675 },
        { "text", -280, -180, "", 
        "stage4关底的bgm：\n"..
        "曲子写着写着发现还是很难超越zun哥写的丰姬原曲，总感觉压迫感不够\n"..
        "遂万般无奈用了原声大碟", 0.600 }
    },
    {
        { "text", -280, -120, '', "(by:baiABC)", 0.675 },
        { "text", -280, -180, "", 
        "Good Ending 呢。（虽然对丰姬不是）\n"..
        "很光明的曲子，想体现涟析变得活泼、坚定。\n"..
        "涟析，欢迎来到幻想乡。\n", 0.600 }
    },
    {
        { "text", -280, -120, '', "(by:baiABC)", 0.675 },
        { "text", -280, -180, "", 
        "staff曲。\n"..
        "第一首作的曲子，原本为疮痍曲而作，后来改为staff曲。感谢游玩。\n"..
        "给AI评价了下，是本人所作评分最高的曲子（笑）", 0.600 }
    },
    {
        { "text", -280, -120, '', "(from: 东方永夜抄 by:ZUN)", 0.675 },
        { "text", -280, -180, "", 
        "用于符卡练习模式的经典曲目\n"..
        "估计是刻意做成了便于循环的形式，似乎在一个非常难的符卡上死磕好久也不会觉得疲倦\n", 0.600 }
    }
}

local bg_blk_ = 0.03
local lihui_alpha_ = 0.1

local function bg_change(self, dir)
    if dir == "in" then
        task.New(self, function()
            while ui.menu_bulr < 1 do
                ui.menu_bulr = ui.menu_bulr + 0.1
                ui.bg_blk = ui.bg_blk - bg_blk_
                ui.lihui_alpha = ui.lihui_alpha - lihui_alpha_
                task.Wait()
            end
        end)
    end
    if dir == "out" then
        task.New(self, function()
            while ui.menu_bulr > 0 do
                ui.menu_bulr = ui.menu_bulr - 0.1
                ui.bg_blk = ui.bg_blk + bg_blk_
                ui.lihui_alpha = ui.lihui_alpha + lihui_alpha_
                task.Wait()
            end
        end)
    end
end

local stage_init = stage.New('init', true, true)
function stage_init:init()
    
    if not lstg.ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync) then
        setting.windowed = true
        saveConfigure()
        if not lstg.ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync) then
            stage.QuitGame()
            return
        end
    end
    ResetScreen()
    lstg.SetSEVolume(setting.sevolume / 100)
    lstg.SetBGMVolume(setting.bgmvolume / 100)
    New(mask_fader, 'open')
end
function stage_init:frame()
    stage.Set('menu', 'none')
end
function stage_init:render()
    ui.DrawMenuBG()
end

local stage_quit = stage.New("stage.quit", false, true)
function stage_quit:init()
    -- 添加一个单独的关卡，退出游戏时会切换到这个关卡
    -- 这是为了触发切换关卡时自动存档
    stage.QuitGame()
end
function stage_quit:render()
end

--MusicRecord("menu", 'THlib/music/title.ogg', 126.171, 126.171)
MusicRecord("spellcard", 'THlib/music/spellcard.ogg', 75, 0xc36e80 / 44100 / 4)

stage_menu = stage.New('menu', false, true)

lstg.var.now_music = "menu"

function stage_menu:init()
    local stage_menu_self = self
    local menu_title,
    menu_player_select,
    menu_difficulty_select,
    menu_difficulty_select_pr,
    menu_replay_loader,
    menu_replay_saver,
    menu_items,
    menu_sc_pr,
    menu_options,
    menu_manual,
    menu_musicroom
    local menu_offset = {}
    local menu_list = {}
    local menu_practice = {}
    if _title_flag == nil then
        _title_flag = true
    else
        New(mask_fader, 'open')
    end
    --
    local function ExitGame()
        task.New(stage_menu_self, function()
            for i = 1, 60 do
                SetBGMVolume('menu', 1 - i / 60)
                task.Wait()
            end
        end)
        task.New(stage_menu_self, function()
            menu.FlyOut(menu_title, 'right')
            task.Wait(30)
            New(mask_fader, 'close')
            task.Wait(29)
            self.no_bg = true
            task.Wait(1)
            stage.Set("stage.quit")
        end)
    end
    --
    menu_items = { { 'Start Game', function()
        bg_change(self, "in")
        practice = nil
        menu.FlyIn(menu_difficulty_select, 'right')
        menu.FlyOut(menu_title, 'left')
    end } }
    if _allow_practice then
        table.insert(menu_items, { 'Stage Practice', function()
            bg_change(self, "in")
            practice = 'stage'
            menu.FlyIn(menu_difficulty_select_pr, 'right')
            menu.FlyOut(menu_title, 'left')
        end })
    end
    if _allow_sc_practice then
        table.insert(menu_items, { 'Spell Practice', function()
            bg_change(self, "in")
            practice = 'spell'
            menu.FlyIn(menu_sc_pr, 'right')
            menu.FlyOut(menu_title, 'left')
        end })
    end
    table.insert(menu_items, { 'Replay', function()
        bg_change(self, "in")
        replay_loader.Refresh(menu_replay_loader)
        menu.FadeIn(menu_replay_loader, 'right')
        menu.FadeOut(menu_title, 'left')
    end })
    ---🎺🎺🎺🍳🍳🍳
    table.insert(menu_items, { 'Music Room', function()
        bg_change(self, "in")
        menu.FadeIn(menu_musicroom)
        menu.FadeOut(menu_title)
    end})
    table.insert(menu_items, { 'Option', function ()
        bg_change(self, "in")
        menu_options.pos = 1
        menu.option_enter = true
        options.copyDataFromSetting()
        menu.FadeIn(menu_options)
        menu.FadeOut(menu_title)
    end})
    table.insert(menu_items, { 'Manual', function()
        bg_change(self, "in")
        menu.FadeIn(menu_manual)
        menu.FadeOut(menu_title)
    end})
    table.insert(menu_items, { 'Exit', ExitGame })
    table.insert(menu_items, { 'exit', function()
        if menu_title.pos == #menu_title.text then
            ExitGame()
        else
            menu_title.pos = #menu_title.text
        end
    end })
    menu_offset = { 0, -20, 25, 10, 35, 50, 45, 60 }
    menu_title = New(title_menu, '', menu_items, '', -(screen.width * 0.45)+50, -90, menu_offset)
    menu_items = {}
    local difficulty_pos = 1
    for _, name in ipairs(stage.groups) do
        if name ~= 'Spell Practice' then
            table.insert(menu_items, { name, function()
                scoredata.difficulty_select = difficulty_pos
                menu.FlyOut(menu_difficulty_select, 'left')
                last_menu = menu_difficulty_select
                last_menu.group_name = name
                --
                scoredata.player_select = 1
                lstg.var.player_name = player_list[1][2]
                lstg.var.rep_player = player_list[1][3]
                task.New(stage_menu_self, function()
                    for i = 1, 60 do
                        SetBGMVolume('menu', 1 - i / 60)
                        task.Wait()
                    end
                end)
                task.New(stage_menu_self, function()
                    task.Wait(30)
                    New(mask_fader, 'close')
                    task.Wait(30)
                    if practice == 'stage' then
                        stage.group.PracticeStart(last_menu.stage_name[last_menu.pos])
                    elseif practice == 'spell' then
                        stage.IsSCpractice = true--判定进入符卡练习的flag add by OLC
                        stage.group.PracticeStart('Spell Practice@Spell Practice')
                    else
                        stage.group.Start(last_menu.group_name)
                    end
                end)
                --
            end })
            difficulty_pos = difficulty_pos + 1
        end
    end
    table.insert(menu_items, { 'exit', function()
        bg_change(self, "out")
        menu.FlyIn(menu_title, 'left')
        menu.FlyOut(menu_difficulty_select, 'right')
    end })
    menu_difficulty_select = New(dif_select, 'Select Difficulty', menu_items, true)
    menu_difficulty_select.pos = scoredata.difficulty_select or 1
    --
    menu_items = {}
    for i, v in ipairs(player_list) do
        table.insert(menu_items, { player_list[i][1], function()
            scoredata.player_select = i
            menu.FlyOut(menu_player_select, 'left')
            lstg.var.player_name = player_list[i][2]
            lstg.var.rep_player = player_list[i][3]
            task.New(stage_menu_self, function()
                for i = 1, 60 do
                    SetBGMVolume('menu', 1 - i / 60)
                    task.Wait()
                end
            end)
            task.New(stage_menu_self, function()
                task.Wait(30)
                New(mask_fader, 'close')
                task.Wait(30)
                if practice == 'stage' then
                    stage.group.PracticeStart(last_menu.stage_name[last_menu.pos])
                elseif practice == 'spell' then
                    stage.IsSCpractice = true--判定进入符卡练习的flag add by OLC
                    stage.group.PracticeStart('Spell Practice@Spell Practice')
                else
                    stage.group.Start(last_menu.group_name)
                end
            end)
        end })
    end
    table.insert(menu_items, { 'exit', function()
        bg_change(self, "out")
        menu.FlyIn(last_menu, 'left')
        menu.FlyOut(menu_player_select, 'right')
    end })
    ---todo: modify the select player menu to add some plot setting and character traits
    menu_player_select = New(simple_menu, 'Select Player', menu_items)
    menu_player_select.pos = scoredata.player_select or 1
    --
    menu_items = {}
    local counter = 0
    for i, name in ipairs(stage.groups) do
        if stage.groups[name].allow_practice then
            table.insert(menu_items, { name, function()
                menu.FlyOut(menu_difficulty_select_pr, 'left')
                menu.FlyIn(menu_practice[name], 'right')
            end })
        end
    end
    table.insert(menu_items, { 'exit', function()
        bg_change(self, "out")
        menu.FlyIn(menu_title, 'left')
        menu.FlyOut(menu_difficulty_select_pr, 'right')
    end })
    menu_difficulty_select_pr = New(dif_select, 'Select Difficulty', menu_items, false)
    --
    for _, sg in ipairs(stage.groups) do  
        if stage.groups[sg].allow_practice then  
            local menu_items = {}  
            for _, s in ipairs(stage.groups[sg]) do  
                if stage.stages[s].allow_practice then  
                    -- 过滤掉包含"Ending"的stage
                    if not string.find(s, "Ending") then  
                        table.insert(menu_items, { string.match(s, "^[%w_][%w_ ]*"), function()  
                            menu.FlyOut(menu_practice[sg], 'left')  
                            last_menu = menu_practice[sg]  
                            --  
                            scoredata.player_select = 1  
                            lstg.var.player_name = player_list[1][2]  
                            lstg.var.rep_player = player_list[1][3]  
                            task.New(stage_menu_self, function()  
                                for i = 1, 60 do  
                                    SetBGMVolume('menu', 1 - i / 60)  
                                    task.Wait()  
                                end  
                            end)  
                            task.New(stage_menu_self, function()  
                                task.Wait(30)  
                                New(mask_fader, 'close')  
                                task.Wait(30)  
                                if practice == 'stage' then  
                                    stage.group.PracticeStart(last_menu.stage_name[last_menu.pos])  
                                elseif practice == 'spell' then  
                                    stage.IsSCpractice = true--判定进入符卡练习的flag add by OLC  
                                    stage.group.PracticeStart('Spell Practice@Spell Practice')  
                                else  
                                    stage.group.Start(last_menu.group_name)  
                                end  
                            end)  
                            --  
                        end })  
                    end  
                end  
            end  
            table.insert(menu_items, { 'exit', function()  
                menu.FlyIn(menu_difficulty_select_pr, 'left')  
                menu.FlyOut(menu_practice[sg], 'right')  
            end })  
            menu_practice[sg] = New(simple_menu, 'Select Stage', menu_items)  
            menu_practice[sg].stage_name = {}  
            for _, s in ipairs(stage.groups[sg]) do  
                if stage.stages[s].allow_practice and not string.find(s, "Ending") then  
                    table.insert(menu_practice[sg].stage_name, s)  
                end  
            end  
        end  
    end
    --
    menu_sc_pr = New(sc_pr_menu, function(index)
        if index then
            last_menu = menu_sc_pr
            lstg.var.sc_index = index
            menu.FlyOut(menu_sc_pr, 'left')
            --
            scoredata.player_select = 1
            lstg.var.player_name = player_list[1][2]
            lstg.var.rep_player = player_list[1][3]
            task.New(stage_menu_self, function()
                for i = 1, 60 do
                    SetBGMVolume('menu', 1 - i / 60)
                    task.Wait()
                end
            end)
            task.New(stage_menu_self, function()
                task.Wait(30)
                New(mask_fader, 'close')
                task.Wait(30)
                
                if practice == 'stage' then
                    stage.group.PracticeStart(last_menu.stage_name[last_menu.pos])
                elseif practice == 'spell' then
                    stage.IsSCpractice = true--判定进入符卡练习的flag add by OLC
                    stage.group.PracticeStart('Spell Practice@Spell Practice')
                else
                    stage.group.Start(last_menu.group_name)
                end
            end)
            --
        else
            bg_change(self, "out")
            menu.FlyIn(menu_title, 'left')
            menu.FlyOut(menu_sc_pr, 'right')
        end
    end)
    --
    menu_replay_loader = New(replay_loader, function(filename, stageName)
        if not filename then
            bg_change(self, "out")
            menu.FlyIn(menu_title, 'left')
            menu.FlyOut(menu_replay_loader, 'right')
        else
            task.New(stage_menu_self, function()
                for i = 1, 60 do
                    SetBGMVolume('menu', 1 - i / 60)
                    task.Wait()
                end
            end)
            task.New(stage_menu_self, function()
                menu.FlyOut(menu_replay_loader, 'left')
                task.Wait(30)
                New(mask_fader, 'close')
                task.Wait(30)
                Print(filename, stageName)
                stage.IsReplay = true--判定进入rep播放的flag add by OLC
                stage.Set(stageName, 'load', filename)
            end)
        end
    end)
    --
    menu_items = {}
    ---musicroom标题文本定义
    ---
    table.insert(menu_items, { '1.信息之渊 ~ Data Abyss', function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('menu',0.8)
        lstg.var.now_music = 'menu'
    end })
    table.insert(menu_items, { '2.星罗深海 ~ Drowning in Data', function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_stage1',0.9)
        lstg.var.now_music = 'bgm_stage1'
    end })
    table.insert(menu_items, { '3.摇曳潜行 ~ Learning in Attractors', function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_stage2',0.9)
        lstg.var.now_music = 'bgm_stage2'
    end })
    table.insert(menu_items, { "4.消亡与涌现的循环 ~ Player's Score ", function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('deathmusic')
        lstg.var.now_music = 'deathmusic'
    end })
    table.insert(menu_items, { "5.踏入未知的无尽幻想 ~ Stepped Into Utopia ", function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_stage3')
        lstg.var.now_music = 'bgm_stage3'
    end })
    table.insert(menu_items, { "6.碎梦的回廊 ~ Undefined and Missing Ideas", function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_stage4a')
        lstg.var.now_music = 'bgm_stage4a'
    end })
    table.insert(menu_items, { "7.绵月的符卡 ~ 神海战", function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_stage4b')
        lstg.var.now_music = 'bgm_stage4b'
    end })
    table.insert(menu_items, { "8.星涟心迹 ~ Starlit Cognition", function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_ending')
        lstg.var.now_music = 'bgm_ending'
    end })
    table.insert(menu_items, { "9.数字生命 ~ Artificial Dream", function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_staff')
        lstg.var.now_music = 'bgm_staff'
    end })
    table.insert(menu_items, { "10.东方妖怪小町", function ()
        StopMusic(lstg.var.now_music)
        PlayMusic('bgm_lastword')
        lstg.var.now_music = 'bgm_lastword'
    end })
    table.insert(menu_items, { 'exit', function()
        StopMusic(lstg.var.now_music)
        PlayMusic('menu')
        lstg.var.now_music = 'menu'
        bg_change(self, "out")
        menu.FlyIn(menu_title, 'left')
        menu.FlyOut(menu_musicroom, 'right')
    end })
    menu_musicroom = New(musicroom, "musicroom", menu_items, musicroom_content, '', 0, 0)
    --
    menu_items = {}
    table.insert(menu_items, { 'Resolution', function ()
    end, "selector", options.mode_window })
    table.insert(menu_items, { 'Fullscreen', function ()
    end, "checkbox" })
    table.insert(menu_items, { 'SetBGMVolume', function ()

    end, "selector", options.mode_BGM_and_SE_() })
    table.insert(menu_items, { 'SetSEVolume', function ()
        
    end, "selector", options.mode_BGM_and_SE_() })
    table.insert(menu_items, { 'KeyConfig', function ()
    end, "menu" })
    table.insert(menu_items, { 'DeleteSaveData', function ()
    end, "button" })
    table.insert(menu_items, { 'Default', function ()
    end, "button" })
    table.insert(menu_items, { 'Quit', function ()
        bg_change(self, "out")
        menu.FlyIn(menu_title, 'left')
        menu.FadeOut(menu_options)
        options.copyDataToSetting()
    end, "button" })
    table.insert(menu_items, { 'exit', function()
        bg_change(self, "out")
        menu.FlyIn(menu_title, 'left')
        menu.FadeOut(menu_options)
    end, "exit" })
    menu_offset = {}
    menu_options = New(options, 'Option', menu_items)
    --
    menu_items = {}
    menu_offset = {}
    table.insert(menu_items, { '1.游戏进行的方式', function ()
        
    end })
    table.insert(menu_items, { '2.???', function ()
        
    end })
    table.insert(menu_items, { 'exit', function()
        bg_change(self, "out")
        menu.FlyIn(menu_title, 'left')
        menu.FadeOut(menu_manual)
    end, "exit" })

    menu_offset = { 0, 0, 0, 0, 0, 0, 0, 0 }
    menu_manual = New(manual, 'Manual', menu_items, manual_content, "", 0, 0)
    --
    local task_menu_init = function()
        menu.FadeIn(menu_title)
    end
    local sc_init = function()
        --by OLC
        menu_sc_pr.pos = lstg.var.sc_index
        menu_sc_pr.page = int(lstg.var.sc_index / ui.menu.sc_pr_line_per_page)
        self.pos_changed = ui.menu.shake_time
    end

    if stage.IsReplay then
        --rep播放后返回rep菜单 add by OLC
        stage.IsReplay = nil
        menu.FlyIn(menu_replay_loader, 'left')
    elseif stage.IsSCpractice then
        --符卡练习后返回符卡练习菜单 add by OLC
        stage.IsSCpractice = nil
        if self.save_replay then
            menu_replay_saver = New(replay_saver, self.save_replay, self.finish, function()
                menu.FlyOut(menu_replay_saver, 'right')
                menu.FlyIn(menu_sc_pr, 'left')
                task.New(menu_sc_pr, sc_init)
            end)
            menu.FlyIn(menu_replay_saver, 'left')
        else
            menu.FlyIn(menu_sc_pr, 'left')
            task.New(menu_sc_pr, sc_init)
        end
    else
        if self.save_replay then
            menu_replay_saver = New(replay_saver, self.save_replay, self.finish, function()
                bg_change(self, "out")
                menu.FlyOut(menu_replay_saver, 'right')
                task.New(stage_menu_self, function()
                    task.Wait(30)
                    task.New(stage_menu_self, task_menu_init)
                end)
            end)
            menu.FlyIn(menu_replay_saver, 'left')
        else
            task.New(stage_menu_self, task_menu_init)
        end
    end

    task.New(self, function()
        --延迟几帧加载bgm避免奇怪的黑块问题--然并乱，草死
        task.Wait(1)
        LoadMusicRecord("menu")
        PlayMusic('menu',0.8)
    end)

    menu_list = { menu_title, menu_player_select, menu_difficulty_select, menu_replay_loader, menu_replay_saver, menu_items, menu_sc_pr, menu_network, menu_player_select2, menu_player_select1, menu_playercount }--设置菜单对象表
end
function stage_menu:render()
    if not self.no_bg then
        ui.DrawMenuBG()
    end
end

