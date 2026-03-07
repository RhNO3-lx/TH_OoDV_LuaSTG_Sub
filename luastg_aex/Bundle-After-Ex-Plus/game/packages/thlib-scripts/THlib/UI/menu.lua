menu = {}

function menu:FlyIn(dir)
    self.alpha = 1
    if dir == 'left' then
        self.x = screen.width * 0.5 - screen.width
    elseif dir == 'right' then
        self.x = screen.width * 0.5 + screen.width
    end
    task.Clear(self)
    task.New(self, function()
        task.MoveTo(screen.width * 0.5, self.y, 30, 2)
        self.locked = false
    end)
end

function menu:FlyOut(dir)
    local x
    if dir == 'left' then
        x = screen.width * 0.5 - screen.width
    elseif dir == 'right' then
        x = screen.width * 0.5 + screen.width
    end
    task.Clear(self)
    if not self.locked then
        task.New(self, function()
            self.locked = true
            task.MoveTo(x, self.y, 30, 1)
        end)
    end
end

function menu:FadeIn()
    self.x = screen.width * 0.5
    task.Clear(self)
    task.New(self, function()
        for i = 0, 29 do
            self.alpha = i / 29
            task.Wait()
        end
        self.locked = false
    end)
end

function menu:FadeOut()
    task.Clear(self)
    if not self.locked then
        task.New(self, function()
            self.locked = true
            for i = 29, 0, -1 do
                self.alpha = i / 29
                task.Wait()
            end
        end)
    end
end

function menu:MoveTo(x1, y1, x2, y2, t, mode)
    self.x = x1 or self.x
    self.y = y1 or self.y
    task.Clear(self)
    task.New(self, function()
        task.MoveTo(x2 or self.x, y2 or self.y, t, mode)
    end)
end

sc_pr_menu = Class(object)

function sc_pr_menu:init(exit_func)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.exit_func = exit_func
    self.x = screen.width * 0.5 + screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.npage = max(int((#_sc_table - 1) / ui.menu.sc_pr_line_per_page) + 1, 1)
    self.page = 0
    self.pos = 1
    self.pos_changed = 0
end

function sc_pr_menu:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if GetLastKey() == setting.keys.up then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    if GetLastKey() == setting.keys.down then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
        self.pos_changed = ui.menu.shake_time
    end
    self.pos = (self.pos + ui.menu.sc_pr_line_per_page - 1) % ui.menu.sc_pr_line_per_page + 1
    if GetLastKey() == setting.keys.left then
        self.page = self.page - 1
        self.pos_changed = ui.menu.shake_time
        PlaySound('select00', 0.3)
    end
    if GetLastKey() == setting.keys.right then
        self.page = self.page + 1
        self.pos_changed = ui.menu.shake_time
        PlaySound('select00', 0.3)
    end
    self.page = (self.page + self.npage) % self.npage
    if KeyIsPressed 'shoot' then
        local index = self.pos + self.page * ui.menu.sc_pr_line_per_page
        if _sc_table[index] then
            if self.exit_func then
                self.exit_func(index)
            end
            PlaySound('ok00', 0.3)
        else
            PlaySound('invalid', 0.5)
        end
    elseif KeyIsPressed 'spell' then
        PlaySound('cancel00', 0.3)
        if self.exit_func then
            self.exit_func(nil)
        end
    end
end

function sc_pr_menu:render()
    --[[
        ui.DrawMenu('View Replay',self.text,self.pos,self.x,self.y+ui.menu.line_height,self.alpha,self.timer,self.pos_changed)
        SetFontState('menu','',Color(self.alpha*255,unpack(ui.menu.title_color)))
        RenderText('menu',string.format('<-  page %d/%d  ->',self.page+1,self.npage),self.x,self.y-5.5*ui.menu.line_height,ui.menu.font_size,'centerpoint')
        --]]
    SetViewMode('ui')
    SetImageState('white', '', Color(0xC0000000))
    RenderRect('white', self.x - ui.menu.sc_pr_width * 0.5 - ui.menu.sc_pr_margin,
            self.x + ui.menu.sc_pr_width * 0.5 + ui.menu.sc_pr_margin,
            self.y - ui.menu.sc_pr_line_height * (ui.menu.sc_pr_line_per_page + 2) * 0.5 - ui.menu.sc_pr_margin,
            self.y + ui.menu.sc_pr_line_height * (ui.menu.sc_pr_line_per_page + 2) * 0.5 + ui.menu.sc_pr_margin)
    local text1 = {}
    local text2 = {}
    local offset = self.page * ui.menu.sc_pr_line_per_page
    for i = 1, ui.menu.sc_pr_line_per_page do
        if _sc_table[i + offset] then
            text1[i] = _editor_class[_sc_table[i + offset][1]].name
            text2[i] = _sc_table[i + offset][2]
        else
            text1[i] = '---'
            text2[i] = '---'
        end
    end
    ui.DrawMenuTTF('sc_pr', '', text1, self.pos, self.x - ui.menu.sc_pr_width * 0.5, self.y, self.alpha, self.timer, self.pos_changed, 'left')
    ui.DrawMenuTTF('sc_pr', '', text2, self.pos, self.x + ui.menu.sc_pr_width * 0.5, self.y, self.alpha, self.timer, self.pos_changed, 'right')
    RenderTTF('sc_pr', 'Spell Practice', self.x, self.x, self.y + (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, self.y + (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, Color(self.alpha * 255, unpack(ui.menu.title_color)), 'centerpoint')
    RenderTTF('sc_pr', string.format('<-  page %d/%d  ->', self.page + 1, self.npage), self.x, self.x, self.y - (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, self.y - (ui.menu.sc_pr_line_per_page + 1) * ui.menu.sc_pr_line_height * 0.5, Color(self.alpha * 255, unpack(ui.menu.title_color)), 'centerpoint')
end
------------------------------------------------------------

simple_menu = Class(object)

function simple_menu:init(title, content, keyslot, offx)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.offx = offx or 0
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.title = title
    self.content = content
    self.text = {}
    self.func = {}
    for i = 1, #content do
        self.text[i] = content[i][1]
        self.func[i] = content[i][2]
    end
    self.pos = 1
    self.pos_pre = 1
    self.pos_changed = 0
    self.no_pos_change = false
    self.keyslot = keyslot
    if content[#content][1] == 'exit' then
        self.exit_func = content[#content][2]
        self.text[#content] = nil
        self.func[#content] = nil
    end
end

function simple_menu:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if GetLastKey(self.keyslot) == setting.keys.up and (not self.no_pos_change) then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.down and (not self.no_pos_change) then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    self.pos = (self.pos - 1 + #(self.text)) % (#(self.text)) + 1
    if KeyIsPressed('shoot', self.keyslot) and self.func[self.pos] then
        self.func[self.pos]()
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell', self.keyslot) and self.exit_func then
        self.exit_func()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos
end

function simple_menu:render()
    SetViewMode('ui')
    ui.DrawMenuTTF("menuttf", self.title, self.text, self.pos, self.x + self.offx, self.y, self.alpha, self.timer, self.pos_changed)
end
------------------------------------------------------------
title_menu = Class(object)

---@class text_offx : table
function title_menu:init(title, content, keyslot, offx, offy, text_offx)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.text_offx = text_offx
    self.offx = offx or 0
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5 + (offy or 0)
    self.bound = false
    self.locked = true
    self.title = title
    self.content = content
    self.text = {}
    self.func = {}
    for i = 1, #content do
        self.text[i] = content[i][1]
        self.func[i] = content[i][2]
    end
    self.pos = 1
    self.pos_pre = 1
    self.pos_changed = 0
    self.no_pos_change = false
    self.keyslot = keyslot
    if content[#content][1] == 'exit' then
        self.exit_func = content[#content][2]
        self.text[#content] = nil
        self.func[#content] = nil
    end
end

function title_menu:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if GetLastKey(self.keyslot) == setting.keys.up and (not self.no_pos_change) then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.down and (not self.no_pos_change) then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    self.pos = (self.pos - 1 + #(self.text)) % (#(self.text)) + 1
    if KeyIsPressed('shoot', self.keyslot) and self.func[self.pos] then
        self.func[self.pos]()
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell', self.keyslot) and self.exit_func then
        self.exit_func()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos
end

function title_menu:render()
    SetViewMode('ui')
    ui.DrawMenuTTF('menuttf', self.title, self.text, self.pos, self.x + self.offx, self.y, self.alpha, self.timer, self.pos_changed, self.text_offx, "left")
end
------------------------------------------------------------

simple_image = Class(object)
function simple_image:init(img, size)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.img = img
    self.hscale = size
    self.vscale = size
    self.x = screen.width * 0.5 - 448
    self.y = screen.height * 0.5
    self.alpha = 1
end
function simple_image:frame()
    task.Do(self)
end
function simple_image:render()
    SetViewMode('ui')
    SetImageState(self.img, '', Color(self.alpha * 255, 255, 255, 255))
    object.render(self)
end

------------------------------------------------------------

LoadTTF("replayfnt", 'assets/font/SourceHanSansCN-Bold.otf', 30)
LoadImageFromFile('replay_title', 'THlib/UI/replay_title.png')
LoadImageFromFile('save_rep_title', 'THlib/UI/save_rep_title.png')

local REPLAY_USER_NAME_MAX = 8
local REPLAY_DISPLAY_FORMAT1 = "%02d %s %" .. tostring(REPLAY_USER_NAME_MAX) .. "s %012d"
local REPLAY_DISPLAY_FORMAT2 = "%02d ----/--/-- --:--:-- %" .. tostring(REPLAY_USER_NAME_MAX) .. "s %012d"

local function FetchReplaySlots()
    local ret = {}
    ext.replay.RefreshReplay()

    for i = 1, ext.replay.GetSlotCount() do
        local text = {}
        local slot = ext.replay.GetSlot(i)
        if slot then
            -- 使用第一关的时间作为录像时间
            local date = os.date("!%Y/%m/%d", slot.stages[1].stageDate + setting.timezone * 3600)

            -- 统计总分数
            local totalScore = 0
            local diff, stage_num = 0, 0
            local tmp
            for i, k in ipairs(slot.stages) do
                totalScore = totalScore + slot.stages[i].score
                diff = string.match(k.stageName, '^.+@(.+)$')
                tmp = string.match(k.stageName, '^(.+)@.+$')
                if string.match(tmp, '%d+') == nil then
                    stage_num = tmp
                else
                    stage_num = 'St' .. string.match(tmp, '%d+')
                end
            end
            if diff == 'Spell Practice' then
                diff = 'SpellCard'
            end
            if tmp == 'Spell Practice' then
                stage_num = 'SC'
            end
            if slot.group_finish == 1 then
                stage_num = 'All'
            end
            text = { string.format('No.%02d', i), slot.userName, date, slot.stages[1].stagePlayer, diff, stage_num }
        else
            text = { string.format('No.%02d', i), '--------', '----/--/--', '--------', '--------', '---' }
        end
        --[[
                    text = string.format(REPLAY_DISPLAY_FORMAT1, i, date, slot.userName, totalScore)
                else
                    text = string.format(REPLAY_DISPLAY_FORMAT2, i, "N/A", 0)
                end
            ]]
        table.insert(ret, text)
    end
    return ret
end

------------------replay_saver-------------------------
local _keyboard = {}
do
    for i = 65, 90 do
        table.insert(_keyboard, i)
    end
    for i = 97, 122 do
        table.insert(_keyboard, i)
    end
    for i = 48, 57 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 43, 45, 61, 46, 44, 33, 63, 64, 58, 59, 91, 93, 40, 41, 95, 47, 123, 125, 124, 126, 94 }) do
        table.insert(_keyboard, i)
    end
    for i = 35, 38 do
        table.insert(_keyboard, i)
    end
    for _, i in ipairs({ 42, 92, 127, 34 }) do
        table.insert(_keyboard, i)
    end
end

replay_saver = Class(object)

function replay_saver:init(stages, finish, exitCallback)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5

    self.locked = true
    self.finish = finish or 0
    self.stages = stages
    self.exitCallback = exitCallback

    self.shakeValue = 0

    self.state = 0
    self.state1Selected = 1
    self.state1Text = FetchReplaySlots()
    self.state2CursorX = 0
    self.state2CursorY = 0
    self.state2UserName = ""
end

function replay_saver:frame()
    task.Do(self)
    if self.locked then
        return
    end

    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 跳转到录像保存状态
            self.state = 1
            --self.state2CursorX = 0
            --self.state2CursorY = 0
            --self.state2UserName = ""
            --由OLC修改，保存rep时菜单用来记录名称的参数
            if scoredata.repsaver == nil then
                scoredata.repsaver = ""
            end
            self.state2UserName = scoredata.repsaver
            if self.state2UserName ~= "" then
                self.state2CursorX = 12
                self.state2CursorY = 6
            else
                self.state2CursorX = 0
                self.state2CursorY = 0
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state2CursorY = self.state2CursorY - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state2CursorY = self.state2CursorY + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.left then
            self.state2CursorX = self.state2CursorX - 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.right then
            self.state2CursorX = self.state2CursorX + 1
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            if self.state2CursorX == 12 and self.state2CursorY == 6 then
                if self.state2UserName == "" then
                    self.state2UserName = "Anonymous"
                else
                    --由OLC添加，保存rep时菜单用来记录名称的参数
                    scoredata.repsaver = self.state2UserName
                    SaveScoreData()
                end

                -- 保存录像
                ext.replay.SaveReplay(self.stages, self.state1Selected, self.state2UserName, self.finish)

                if self.exitCallback then
                    self.exitCallback()
                end
                PlaySound("extend", 0.5)
            end

            if #self.state2UserName == REPLAY_USER_NAME_MAX then
                self.state2CursorX = 12
                self.state2CursorY = 6
            elseif self.state2CursorX == 11 and self.state2CursorY == 6 then
                if #self.state2UserName == 0 then
                    self.state = 0
                else
                    self.state2UserName = string.sub(self.state2UserName, 1, -2)
                end
                PlaySound('cancel00', 0.3)
            elseif self.state2CursorX == 10 and self.state2CursorY == 6 then
                local char = string.char(0x20)
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            else
                local char = string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1])
                self.state2UserName = self.state2UserName .. char
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if #self.state2UserName == 0 then
                self.state = 0
            else
                self.state2UserName = string.sub(self.state2UserName, 1, -2)
            end
            --			self.state = 0
            PlaySound('cancel00', 0.3)
        end

        self.state2CursorX = (self.state2CursorX + 13) % 13
        self.state2CursorY = (self.state2CursorY + 7) % 7
    end
end

function replay_saver:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
                "replayfnt",
                "save_rep_title",
                self.state1Text,
                self.state1Selected,
                self.x,
                self.y,
                1,
                self.timer,
                self.shakeValue
        )
    elseif self.state == 1 then
        Render("save_rep_title", self.x, self.y + ui.menu.sc_pr_line_height + 15 * ui.menu.sc_pr_line_height * 0.5)
        ---- 绘制键盘
        -- 未选中按键
        SetFontState("replay", "", Color(255, unpack(ui.menu.unfocused_color)))
        for x = 0, 12 do
            for y = 0, 6 do
                if x ~= self.state2CursorX or y ~= self.state2CursorY then
                    --[[					RenderText(
                                            "replay",
                                            string.char(0x20 + y * 12 + x),
                                            self.x + (x - 5.5) * ui.menu.char_width,
                                            self.y - (y - 3.5) * ui.menu.line_height,
                                            ui.menu.font_size,
                                            'centerpoint'
                                        )]]
                    RenderText(
                            "replay",
                            string.char(_keyboard[y * 13 + x + 1]),
                            self.x + (x - 5.5) * ui.menu.char_width,
                            self.y - (y - 3.5) * ui.menu.line_height,
                            ui.menu.font_size,
                            'centerpoint'
                    )
                end
            end
        end
        -- 激活按键
        local color = {}
        local k = cos(self.timer * ui.menu.blink_speed) ^ 2
        for i = 1, 3 do
            color[i] = ui.menu.focused_color1[i] * k + ui.menu.focused_color2[i] * (1 - k)
        end
        SetFontState("replay", "", Color(255, unpack(color)))
        RenderText(
                "replay",
                string.char(_keyboard[self.state2CursorY * 13 + self.state2CursorX + 1]),
                self.x + (self.state2CursorX - 5.5) * ui.menu.char_width + ui.menu.shake_range * sin(ui.menu.shake_speed * self.shakeValue),
                self.y - (self.state2CursorY - 3.5) * ui.menu.line_height,
                ui.menu.font_size,
                "centerpoint"
        )

        -- 标题
        SetFontState("replay", "", Color(255, unpack(ui.menu.title_color)))
        RenderText("replay", self.state2UserName, self.x, self.y - 5.5 * ui.menu.line_height, ui.menu.font_size, "centerpoint")
    end
end
----------------------------------------------------------------------------
-------------------------replay_loader--------------------------------------
replay_loader = Class(object)

function replay_loader:init(exitCallback)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.bound = false
    self.x = screen.width * 0.5 + screen.width
    self.y = screen.height * 0.5

    -- 是否可操作
    self.locked = true

    self.exitCallback = exitCallback

    self.shakeValue = 0

    self.state = 0
    self.state1Selected = 1
    self.state1Text = {}
    self.state2Selected = 1
    self.state2Text = {}

    replay_loader.Refresh(self)
end

function replay_loader:Refresh()
    self.state1Text = FetchReplaySlots()
end

function replay_loader:frame()
    task.Do(self)
    if self.locked then
        return
    end

    if self.shakeValue > 0 then
        self.shakeValue = self.shakeValue - 1
    end

    -- 控制逻辑
    if self.state == 0 then
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state1Selected = max(1, self.state1Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state1Selected = min(ext.replay.GetSlotCount(), self.state1Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 构造关卡列表
            local slot = ext.replay.GetSlot(self.state1Selected)
            if slot ~= nil then
                self.state = 1
                self.state2Text = {}
                self.state2Selected = 1
                self.shakeValue = ui.menu.shake_time

                for i, v in ipairs(slot.stages) do
                    local stage = string.match(v.stageName, '^(.+)@.+$')
                    local score = string.format("%012d", v.score)
                    table.insert(self.state2Text, { stage, score })
                end
                PlaySound('ok00', 0.3)
            end
        elseif KeyIsPressed("spell") then
            if self.exitCallback then
                self.exitCallback()
            end
            PlaySound('cancel00', 0.3)
        end
    elseif self.state == 1 then
        local slot = ext.replay.GetSlot(self.state1Selected)
        local lastKey = GetLastKey()
        if lastKey == setting.keys.up then
            self.state2Selected = max(1, self.state2Selected - 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif lastKey == setting.keys.down then
            self.state2Selected = min(#slot.stages, self.state2Selected + 1)
            self.shakeValue = ui.menu.shake_time
            PlaySound('select00', 0.3)
        elseif KeyIsPressed("shoot") then
            -- 转场
            local slot = ext.replay.GetSlot(self.state1Selected)
            if self.exitCallback then
                self.exitCallback(slot.path, slot.stages[self.state2Selected].stageName)
            end
            PlaySound('ok00', 0.3)
        elseif KeyIsPressed("spell") then
            self.shakeValue = ui.menu.shake_time
            self.state = 0
        end
    end
end

function replay_loader:render()
    SetViewMode('ui')
    if self.state == 0 then
        ui.DrawRepText(
                "replayfnt",
                "replay_title",
                self.state1Text,
                self.state1Selected,
                self.x,
                self.y,
                1,
                self.timer,
                self.shakeValue
        )
    elseif self.state == 1 then
        ui.DrawRepText2(
                "replayfnt",
                "replay_title",
                self.state2Text,
                self.state2Selected,
                self.x,
                self.y + 120,
                1,
                self.timer,
                self.shakeValue,
                "center")
    end
end
--------------------------------------------------------------------------------------------
-------------------------------musicroom----------------------------------------------------
musicroom = Class(object)

function musicroom:init(title, item, content, keyslot, offx, offy)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 0
    self.offx = offx or 0
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.title = title
    self.item = item
    self.content = manual.createContent(content)
    self.text = {}
    self.func = {}
    for i = 1, #item do
        self.text[i] = item[i][1]
        self.func[i] = item[i][2]
    end
    self.pos = 1
    self.pos_pre = 1
    self.last_pos = self.pos
    self.pos_changed = 0
    self.no_pos_change = false
    self.keyslot = keyslot
    if item[#item][1] == 'exit' then
        self.exit_func = item[#item][2]
        self.text[#item] = nil
        self.func[#item] = nil
    end
end

function musicroom:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if GetLastKey(self.keyslot) == setting.keys.up and (not self.no_pos_change) then
        self.last_pos = self.pos
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.down and (not self.no_pos_change) then
        self.last_pos = self.pos
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    self.pos = (self.pos - 1 + #(self.text)) % (#(self.text)) + 1
    if KeyIsPressed('shoot', self.keyslot) and self.func[self.pos] then
        self.func[self.pos]()
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell', self.keyslot) and self.exit_func then
        self.exit_func()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos
end

local offy = 50
local offTimer = 0
local alpha = 0
function musicroom:render()
    SetViewMode('ui')
    ui.DrawMusicTTF('menuttf', self.title, self.text, self.content[self.pos], self.pos, self.x + self.offx, self.y, self.alpha, self.timer, 0, "left")
end

function musicroom.createContent(content)
    local _content = {}
    local con = {}
    for i, v in ipairs(content) do
        con = {}
        con.x = {}
        con.y = {}
        con.type = {}
        con.text = {}
        con.font = {}
        con.name = {}
        con.rot = {}
        con.hscale = {}
        con.vscale = {}
        content.scale = {}
        con.length = 0
        for j, _ in ipairs(v) do
            con.x[j] = _[2]
            con.y[j] = _[3]
            if _[1] == "text" then
                con.type[j] = "text"
                if _[4] == "" then
                    con.font[j] = 'menuttf'
                else
                    con.font[j] = _[4]
                end
                con.text[j] = _[5]
                con.scale[j] = _[6]
            elseif _[1] == "image" then
                con.type[j] = "image"
                con.name[j] = _[4]
                con.rot[j] = _[5]
                con.hscale[j] = _[6]
                con.vscale[j] = _[7]
            end
            con.length = con.length + 1
        end
        table.insert(_content, con)
    end
    return _content
end
----------------------------------------------------------------------------
-------------------------options--------------------------------------------
options = Class(object)


local last_setting = {
    resx = setting.resx,
    resy = setting.resy,
    windowed = setting.windowed,
    vsync = setting.vsync,
    sevolume = setting.sevolume,
    bgmvolume = setting.bgmvolume,
    auto_shoot = setting.auto_shoot or false,
    auto_bomb = setting.auto_bomb or false
}

options.mode_window = {
        -- legacy
        {  640,  480, 60, 1 },
        {  800,  600, 60, 1 },
        {  960,  720, 60, 1 },
        { 1024,  768, 60, 1 },
        { 1280,  960, 60, 1 },
        { 1600, 1200, 60, 1 },
        { 1920, 1440, 60, 1 },
}

function options.mode_BGM_and_SE_()
    local mode = {}
    for i = 1, 21 do
        mode[i] = (i - 1) * 5
    end
    return mode
end


local function applySetting(screenChange)
    if screenChange then
        if not lstg.ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync) then
            setting.windowed = true
            saveConfigure()
            if not lstg.ChangeVideoMode(setting.resx, setting.resy, setting.windowed, setting.vsync) then
                stage.QuitGame()
                return
            end
        end
        ResetScreen()
    end
    lstg.SetSEVolume(setting.sevolume / 100)
    lstg.SetBGMVolume(setting.bgmvolume / 100)
    saveConfigure()
end

function options.copyDataToSetting()
    local screenChange = false
    if last_setting.resx ~= setting.resx or
    last_setting.resy ~= setting.resy or
    last_setting.windowed ~= setting.windowed then
        screenChange = true
    end
    setting.resx = last_setting.resx
    setting.resy = last_setting.resy
    setting.windowed = last_setting.windowed
    setting.vsync = last_setting.vsync
    setting.sevolume = last_setting.sevolume
    setting.bgmvolume = last_setting.bgmvolume
    setting.auto_shoot = last_setting.auto_shoot
    setting.auto_bomb = last_setting.auto_bomb
    applySetting(screenChange)
end

function options.copyDataFromSetting()
    last_setting.resx = setting.resx
    last_setting.resy = setting.resy
    last_setting.windowed = setting.windowed
    last_setting.vsync = setting.vsync
    last_setting.sevolume = setting.sevolume
    last_setting.bgmvolume = setting.bgmvolume
end

function options:copyDataToLastSetting()
    last_setting.resx = self.control.content["Resolution"][self.control.index["Resolution"]][1]
    last_setting.resy = self.control.content["Resolution"][self.control.index["Resolution"]][2]
    last_setting.windowed = not self.control.data["Fullscreen"]
    last_setting.bgmvolume = self.control.content["SetBGMVolume"][self.control.index["SetBGMVolume"]]
    last_setting.sevolume = self.control.content["SetSEVolume"][self.control.index["SetSEVolume"]]
    last_setting.auto_shoot = self.control.data["AutoShoot"]
    last_setting.auto_bomb = self.control.data["AutoBomb"]
end

function options:setDefault()
    self.control.data["Resolution"] = "1280x960"
    self.control.index["Resolution"] = 5
    self.control.data["Fullscreen"] = false
    self.control.data["SetBGMVolume"] = 100
    self.control.index["SetBGMVolume"] = 21
    self.control.data["SetSEVolume"] = 80
    self.control.index["SetSEVolume"] = 17
    self.control.data["AutoShoot"] = false
    self.control.data["AutoBomb"] = false
    options.copyDataToLastSetting(self)
    options.copyDataToSetting()
end

local mode_window_index = 1
local mode_window_name = {}
local function updateDisplayMode()
        local cfg = last_setting

        mode_window_index = 0
        for i, v in ipairs(options.mode_window) do
            if v[1] == cfg.resx and v[2] == cfg.resy then
                mode_window_index = i
                break
            end
        end
        if mode_window_index == 0 then
            for i, v in ipairs(mode_window) do
                if v[1] == cfg.resx or v[2] == cfg.resy then
                    mode_window_index = i
                    break
                end
            end
        end
        if mode_window_index == 0 then
            mode_window_index = 1 -- fallback
        end

        mode_window_name = {}
        for i, v in ipairs(options.mode_window) do
            mode_window_name[i] = string.format("%dx%d", v[1], v[2])
        end
end

function options:updateData()
    local cfg = last_setting
    self.control.data["Resolution"] = mode_window_name[self.control.index["Resolution"]]
    self.control.data["Fullscreen"] = self.control.data["Fullscreen"]
    self.control.data["SetBGMVolume"] = self.control.content["SetBGMVolume"][self.control.index["SetBGMVolume"]] .. "%"
    self.control.data["SetSEVolume"] = self.control.content["SetSEVolume"][self.control.index["SetSEVolume"]] .. "%"
    self.control.data["AutoShoot"] = self.control.data["AutoShoot"]
    self.control.data["AutoBomb"] = self.control.data["AutoBomb"]
end

function options:updateLastSetting()
    last_setting.resx = self.control.content["Resolution"][self.control.index["Resolution"]][1]
    last_setting.resy = self.control.content["Resolution"][self.control.index["Resolution"]][2]
    last_setting.bgmvolume = self.control.content["SetBGMVolume"][self.control.index["SetBGMVolume"]]
end

option_enter = true
function options:init(title, content, keyslot, offx)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.offx = offx or 0
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.title = title
    self.content = content
    self.control = {}
    options.createControl(self)
    options.initControl(self)
    self.pos = 1
    self.pos_pre = 1
    self.pos_changed = 0
    self.no_pos_change = false
    self.keyslot = keyslot
    if content[#content][1] == 'exit' then
        self.exit_func = content[#content][2]
    end
end

function options:Refresh()
    copyDataFromSetting()
    --self.state1Text = OptionsRefresh()
end

function options:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if GetLastKey(self.keyslot) == setting.keys.up and (not self.no_pos_change) then
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.down and (not self.no_pos_change) then
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.left and (not self.no_pos_change) then
        if self.control.changeFuc[self.control.text[self.pos]] ~= nil then
            self.control.changeFuc[self.control.text[self.pos]]("left")
            options.copyDataToLastSetting(self)
            options.copyDataToSetting()
        end
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.right and (not self.no_pos_change) then
        if self.control.changeFuc[self.control.text[self.pos]] ~= nil then
            self.control.changeFuc[self.control.text[self.pos]]("right")
            options.copyDataToLastSetting(self)
            options.copyDataToSetting()
        end
        PlaySound('select00', 0.3)
    end
    
    self.pos = (self.pos - 1 + #(self.control.text)) % (#(self.control.text)) + 1
    if KeyIsPressed('shoot', self.keyslot) and self.control.func[self.control.text[self.pos]] then
        if self.control.text[self.pos] == "Default" then
            options.setDefault(self)
        else
            self.control.func[self.control.text[self.pos]]()
        end
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell', self.keyslot) and self.exit_func then
        self.exit_func()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos
end

function options:render()
    SetViewMode('ui')
    options.updateData(self)
    ui.DrawOptionTTF('menuttf', self.title, self.control.text, self.control.type, self.control.data, self.pos, self.x + self.offx, self.y, self.alpha, self.timer, self.pos_changed)
    --ui.DrawOptionTTF('menuttf', self.title, self.text, self.type, self.data, self.pos, self.x + self.offx, self.y, self.alpha, self.timer, self.pos_changed)
end

function options:createControl()
    local control = {}
    self.control.text = {}
    self.control.func = {}
    self.control.type = {}
    self.control.index = {}
    self.control.data = {}
    self.control.content = {}
    self.control.changeFuc = {}
    for i = 1, #self.content do
        if self.content[i][3] == "selector" then
            self.control.text[i] = self.content[i][1]
            self.control.func[self.control.text[i]] = self.content[i][2]
            self.control.type[self.control.text[i]] = self.content[i][3]
            self.control.index[self.control.text[i]] = 1
            self.control.data[self.control.text[i]] = "nil"
            self.control.content[self.control.text[i]] = self.content[i][4]
            self.control.changeFuc[self.control.text[i]] = function (dir)
                if dir == "left" and self.control.index[self.control.text[i]] ~= 1 then
                    self.control.index[self.control.text[i]] = self.control.index[self.control.text[i]] - 1
                elseif dir == "right" and self.control.index[self.control.text[i]] ~= #self.control.content[self.control.text[i]] then
                    self.control.index[self.control.text[i]] = self.control.index[self.control.text[i]] + 1
                end
            end
        elseif self.content[i][3] == "checkbox" then
            self.control.text[i] = self.content[i][1]
            self.control.func[self.control.text[i]] = self.content[i][2]
            self.control.type[self.control.text[i]] = self.content[i][3]
            self.control.data[self.control.text[i]] = false
            self.control.changeFuc[self.control.text[i]] = function (dir)
                if dir == "left" and self.control.data[self.control.text[i]] == false then
                    self.control.data[self.control.text[i]] = true
                elseif dir == "right" and self.control.data[self.control.text[i]] == true then
                    self.control.data[self.control.text[i]] = false
                end
            end
        elseif self.content[i][3] == "button" then
            self.control.text[i] = self.content[i][1]
            self.control.func[self.control.text[i]] = self.content[i][2]
            self.control.type[self.control.text[i]] = self.content[i][3]
        else
            --啥都不干
        end
    end
end

function options:initControl()
    local cfg = setting
    updateDisplayMode()
    self.control.data["Resolution"] = mode_window_name[mode_window_index]
    self.control.index["Resolution"] = mode_window_index
    self.control.data["Fullscreen"] = not cfg.windowed
    self.control.data["SetBGMVolume"] = cfg.bgmvolume
    for i in ipairs(self.control.content["SetBGMVolume"]) do
        if self.control.content["SetBGMVolume"][i] == cfg.bgmvolume then
            self.control.index["SetBGMVolume"] = i
        end
    end
    self.control.data["SetSEVolume"] = cfg.bgmvolume
    for i in ipairs(self.control.content["SetSEVolume"]) do
        if self.control.content["SetSEVolume"][i] == cfg.sevolume then
            self.control.index["SetSEVolume"] = i
        end
    end
    self.control.data["AutoShoot"] = cfg.auto_shoot or false
    self.control.data["AutoBomb"] = cfg.auto_bomb or false
    
end


----------------------------------------------------------------------------
------------------------------------manual----------------------------------
manual = Class(object)

function manual:init(title, item, content, keyslot, offx, offy)
    self.layer = LAYER_TOP
    self.group = GROUP_GHOST
    self.alpha = 1
    self.offx = offx or 0
    self.x = screen.width * 0.5 - screen.width
    self.y = screen.height * 0.5
    self.bound = false
    self.locked = true
    self.title = title
    self.item = item
    self.content = manual.createContent(content)
    self.text = {}
    self.func = {}
    for i = 1, #item do
        self.text[i] = item[i][1]
        self.func[i] = item[i][2]
    end
    self.pos = 1
    self.pos_pre = 1
    self.last_pos = self.pos
    self.pos_changed = 0
    self.no_pos_change = false
    self.keyslot = keyslot
    if item[#item][1] == 'exit' then
        self.exit_func = item[#item][2]
        self.text[#item] = nil
        self.func[#item] = nil
    end
end

function manual:frame()
    task.Do(self)
    if self.locked then
        return
    end
    if GetLastKey(self.keyslot) == setting.keys.up and (not self.no_pos_change) then
        self.last_pos = self.pos
        self.pos = self.pos - 1
        PlaySound('select00', 0.3)
    end
    if GetLastKey(self.keyslot) == setting.keys.down and (not self.no_pos_change) then
        self.last_pos = self.pos
        self.pos = self.pos + 1
        PlaySound('select00', 0.3)
    end
    self.pos = (self.pos - 1 + #(self.text)) % (#(self.text)) + 1
    if KeyIsPressed('shoot', self.keyslot) and self.func[self.pos] then
        self.func[self.pos]()
        PlaySound('ok00', 0.3)
    elseif KeyIsPressed('spell', self.keyslot) and self.exit_func then
        self.exit_func()
        PlaySound('cancel00', 0.3)
    end
    if self.pos_changed > 0 then
        self.pos_changed = self.pos_changed - 1
    end
    if self.pos_pre ~= self.pos then
        self.pos_changed = ui.menu.shake_time
    end
    self.pos_pre = self.pos
end

local offy = 50
local offTimer = 0
local alpha = 0
function manual:render()
    SetViewMode('ui')
    ui.DrawManualTTF('menuttf', self.title, self.text, self.content[self.pos], self.pos, self.x + self.offx, self.y, self.alpha, self.timer, 0, "left")
    if self.last_pos ~= self.pos then
        self.locked = true
        ui.DrawManualContent(self.x, self.y + (-offTimer) * (self.pos - self.last_pos) / math.abs(self.pos - self.last_pos), self.content[self.last_pos], 1 - alpha, ui.menu.focused_color1)
        ui.DrawManualContent(self.x, self.y + (offy - offTimer) * (self.pos - self.last_pos) / math.abs(self.pos - self.last_pos), self.content[self.pos], alpha, ui.menu.focused_color1)
        alpha = alpha + 0.05
        offTimer = offTimer + 2.5
        if alpha >= 1 then
            self.locked = false
            self.last_pos = self.pos
            offTimer = 0
            alpha = 0
        end
    else
        ui.DrawManualContent(self.x, self.y, self.content[self.pos], self.alpha, ui.menu.focused_color1)
    end
end

function manual.createContent(content)
    local _content = {}
    local con = {}
    for i, v in ipairs(content) do
        con = {}
        con.x = {}
        con.y = {}
        con.type = {}
        con.text = {}
        con.font = {}
        con.name = {}
        con.rot = {}
        con.hscale = {}
        con.vscale = {}
        con.scale = {}
        con.length = 0
        for j, _ in ipairs(v) do
            con.x[j] = _[2]
            con.y[j] = _[3]
            if _[1] == "text" then
                con.type[j] = "text"
                if _[4] == "" then
                    con.font[j] = 'menuttf'
                else
                    con.font[j] = _[4]
                end
                con.text[j] = _[5]
                con.scale[j] = _[6]
            elseif _[1] == "image" then
                con.type[j] = "image"
                con.name[j] = _[4]
                con.rot[j] = _[5]
                con.hscale[j] = _[6]
                con.vscale[j] = _[7]
            end
            con.length = con.length + 1
        end
        table.insert(_content, con)
    end
    return _content
end