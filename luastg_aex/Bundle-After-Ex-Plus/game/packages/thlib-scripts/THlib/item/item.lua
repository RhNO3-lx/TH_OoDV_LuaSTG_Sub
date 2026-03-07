LoadTexture('item', 'THlib/item/item.png')
LoadImageGroup('item', 'item', 0, 0, 32, 32, 2, 5, 8, 8)
LoadImageGroup('item_up', 'item', 64, 0, 32, 32, 2, 5)
SetImageState('item8', 'mul+add', Color(0xC0FFFFFF))
LoadTexture('bonus1', 'THlib/item/item.png')
LoadTexture('bonus2', 'THlib/item/item.png')
LoadTexture('bonus3', 'THlib/item/item.png')

lstg.var.collectingitem = 0

---! 新增生命与bomb上限定义
lstg.var.LifeExtendPoint=100
lstg.var.BombExtendPoint=100
lstg.var.LifechipPoint=30
lstg.var.BombchipPoint=30
lstg.var.LifeMax=7
lstg.var.LifeMax=7
lstg.var.PowerMax=400
lstg.var.PowerExtendPoint=100
lstg.var.MinPower=0

---! 改用血条和bomb系统
---! use lstg.var.chip, lstg.var.bombchip to idicate unfilled life or bomb
lstg.var.MissBombCompensate=2
lstg.var.MissPowerPenality=30

function LifeExtendCheck()
    ---! 生命上限检测 RhNO3-lx
    if lstg.var.chip >= lstg.var.LifeExtendPoint then
        lstg.var.lifeleft = lstg.var.lifeleft + 1
        lstg.var.chip = lstg.var.chip - lstg.var.LifeExtendPoint
        PlaySound('extend', 0.5)
        New(hinter, 'hint.extend', 0.6, 0, 112, 15, 120)
    end
    if lstg.var.lifeleft >= lstg.var.LifeMax then
        lstg.var.lifeleft = lstg.var.LifeMax
        lstg.var.chip = 0
    end
end

function BombExtendCheck()
    ---! bomb上限检测 RhNO3-lx 
    if lstg.var.bombchip >= lstg.var.BombExtendPoint then
        lstg.var.bomb = lstg.var.bomb + 1
        lstg.var.bombchip = lstg.var.bombchip - lstg.var.BombExtendPoint
        PlaySound('cardget', 0.8)
    end
    if lstg.var.bomb >= lstg.var.LifeMax then
        lstg.var.bomb = lstg.var.LifeMax
        lstg.var.bombchip = 0
    end
end

item = Class(object)

---! 定义了不直接死亡的掉血效果，未完成
---@param v number 掉血量
---@param RemoveBulletRadius number 掉血时生成的消弹圈大小
---@param is_PlaySound boolean|nil 是否播放掉血音效，不一定是传统的biu
---@param TriggerDeath boolean|nil 是否【有可能】触发死亡判定
function item.LifeShrinkCheck(v,TriggerDeath,is_PlaySound,RemoveBulletRadius)
    lstg.var.chip_bonus = false
    if lstg.var.sc_bonus then
        lstg.var.sc_bonus = 0
    end
    player.protect = 210
    if v <= lstg.var.chip or not TriggerDeath then
        lstg.var.chip = lstg.var.chip - v
        New(bullet_cleaner, player.x, player.y, RemoveBulletRadius, 0, 60, false, false, 0)
        if lstg.var.chip < 0 then -- TriggerDeath = false
            lstg.var.chip = 0
        end
        if is_PlaySound then
            PlaySound("se_immune", 0.5)
        end
    else
        if is_PlaySound then
            PlaySound("pldead00", 0.5)
        end
        lstg.var.chip = lstg.var.LifeExtendPoint+lstg.var.chip-v
        lstg.var.sc_bonus=0
        lstg.var.bomb = max(lstg.var.bomb, lstg.var.MissBombCompensate)
        player.death = 100
    end
    ---! todo:掉血时的逻辑
    --- 若v=<lstg.var.chip，或TriggerDeath为false,直接扣除血量，生成消弹圈
    --- 若v>lstg.var.chip，且TriggerDeath为true，则触发死亡判定,就是发出biu的那个音效的效果
    --- （我暂时还不知道如何触发死亡事件，另外，如果找到了，也希望将其改为：仅在原地播放一遍那个特效，而不是禁用玩家操作，强制让自机从屏幕下方冒出来）
    --- （在解决完这个问题之后，貌似也可以找到禁用玩家操作的方法，你可以分享在群里，因为咱们前几个stage理论上来说是会适时禁用玩家的shoot和bomb的）
    --- done
end

function item:init(x, y, t, v, angle)
    x = min(max(x, lstg.world.l + 8), lstg.world.r - 8)
    self.x = x
    self.y = y
    angle = angle or 90
    v = v or 1.5
    SetV(self, v, angle)
    self.v = v
    self.group = GROUP_ITEM
    self.layer = LAYER_ITEM
    self.bound = false
    self.img = 'item' .. t
    self.imgup = 'item_up' .. t
    self.attract = 0
end

function item:render()
    if self.y > lstg.world.t then
        Render(self.imgup, self.x, lstg.world.t - 8)
    else
        object.render(self)
    end
end

function item:frame()
    local player = self.target
    if self.timer < 24 then
        self.rot = self.rot + 45
        self.hscale = (self.timer + 25) / 48
        self.vscale = self.hscale
        if self.timer == 22 then
            self.vy = min(self.v, 2)
            self.vx = 0
        end
    elseif self.attract > 0 then
        local a = Angle(self, player)
        self.vx = self.attract * cos(a) + player.dx * 0.5
        self.vy = self.attract * sin(a) + player.dy * 0.5
    else
        self.vy = max(self.dy - 0.03, -1.7)
    end
    if self.y < lstg.world.boundb then
        Del(self)
    end
    if self.attract >= 8 then
        self.collected = true
    end
end

function item:colli(other)
    if other == player then
        if self.class.collect then
            self.class.collect(self, other)
        end
        Kill(self)
        PlaySound('item00', 0.3, self.x / 200)
    end
end

function GetPower(v)
    local before = int(lstg.var.power / lstg.var.PowerExtendPoint)
    lstg.var.power = min(lstg.var.PowerMax, lstg.var.power + v)
    local after = int(lstg.var.power / lstg.var.PowerExtendPoint)
    if after > before then
        PlaySound('powerup1', 0.5)
    end
    if lstg.var.power >= lstg.var.PowerMax then
        lstg.var.score = lstg.var.score + v * lstg.var.PowerExtendPoint
    end
    --    if lstg.var.power==500 then
    --        for i,o in ObjList(GROUP_ITEM) do
    --            if o.class==item_power or o.class==item_power_large then
    --                o.class=item_faith
    --                o.img='item5'
    --                o.imgup='item_up5'
    --                New(bubble,'parimg12',o.x,o.y,16,0.5,1,Color(0xFF00FF00),Color(0x0000FF00),LAYER_ITEM+50)
    --            end
    --        end
    --    end
end

item_power = Class(item)
function item_power:init(x, y, v, a)
    item.init(self, x, y, 1, v, a)
end
function item_power:collect()
    GetPower(1)
end

item_power_large = Class(item)
function item_power_large:init(x, y, v, a)
    item.init(self, x, y, 6, v, a)
end
function item_power_large:collect()
    GetPower(100)
end

item_power_full = Class(item)
function item_power_full:init(x, y)
    item.init(self, x, y, 4)
end
function item_power_full:collect()
    GetPower(400)
end

item_extend = Class(item)
function item_extend:init(x, y)
    item.init(self, x, y, 7)
end
function item_extend:collect()
    lstg.var.lifeleft = lstg.var.lifeleft + 1
    PlaySound('extend', 0.5)
    if lstg.var.lifeleft <= lstg.var.LifeMax then
        New(hinter, 'hint.extend', 0.6, 0, 112, 15, 120)
    end
    ---added
    LifeExtendCheck()
end

item_chip = Class(item)
function item_chip:init(x, y)
    item.init(self, x, y, 3)
    --    PlaySound('bonus',0.8)
end
function item_chip:collect()
    lstg.var.chip = lstg.var.chip + lstg.var.LifechipPoint
    ---!added
    LifeExtendCheck()
end

item_bombchip = Class(item)
function item_bombchip:init(x, y)
    item.init(self, x, y, 9)
    --    PlaySound('bonus2',0.8)
end
function item_bombchip:collect()
    lstg.var.bombchip = lstg.var.bombchip + 1
    ---! added
    BombExtendCheck()
end

item_bomb = Class(item)
function item_bomb:init(x, y)
    item.init(self, x, y, 10)
end
function item_bomb:collect()
    lstg.var.bomb = lstg.var.bomb + 1
    if lstg.var.bomb <= lstg.var.LifeMax then
        PlaySound('cardget', 0.8)
    end
    BombExtendCheck()
end

item_faith = Class(item)
function item_faith:init(x, y)
    item.init(self, x, y, 5)
end
function item_faith:collect()
    --local var = lstg.var
    --New(float_text, 'item', '10000', self.x, self.y + 6, 0.75, 90, 60, 0.5, 0.5, Color(0x8000C000), Color(0x0000C000))
    --var.faith = var.faith + 100
    lstg.var.BombchipPoint=lstg.var.BombchipPoint+1
    BombExtendCheck()
end

---! todo: 消弹时不生成
item_faith_minor = Class(object)
function item_faith_minor:init(x, y)
    self.x = x
    self.y = y
    self.img = 'item' .. 8
    self.group = GROUP_ITEM
    self.layer = LAYER_ITEM
    if not BoxCheck(self, lstg.world.l, lstg.world.r, lstg.world.b, lstg.world.t) then
        RawDel(self)
    end
    self.vx = ran:Float(-0.15, 0.15)
    self._vy = ran:Float(3.25, 3.75)
    self.flag = 1
    self.attract = 0
    self.bound = false
    self.is_minor = true
    self.target = player
end
function item_faith_minor:frame()
    local player = self.target
    if player.death > 80 and player.death < 90 then
        self.flag = 0
        self.attract = 0
    end
    if self.timer < 45 then
        self.vy = self._vy - self._vy * self.timer / 45
    end
    if self.timer >= 54 and self.flag == 1 then
        SetV(self, 8, Angle(self, player))
    end
    if self.timer >= 54 and self.flag == 0 then
        if self.attract > 0 then
            local a = Angle(self, player)
            self.vx = self.attract * cos(a) + player.dx * 0.5
            self.vy = self.attract * sin(a) + player.dy * 0.5
        else
            self.vy = max(self.dy - 0.03, -2.5)
            self.vx = 0
        end
        if self.y < lstg.world.boundb then
            Del(self)
        end
    end
end
item_faith_minor.colli = item.colli
function item_faith_minor:collect()
    local var = lstg.var
    var.faith = var.faith + 4
    var.score = var.score + 500
end

---! 在这里把point给改成小的残机碎片
item_point = Class(item)
function item_point:init(x, y)
    item.init(self, x, y, 2)
end
function item_point:collect()
    local var = lstg.var
    -- if self.attract == 8 then
    --     New(float_text, 'item', var.pointrate, self.x, self.y + 6, 0.75, 90, 60, 0.5, 0.5, Color(0x80FFFF00), Color(0x00FFFF00))
    --     var.score = var.score + var.pointrate
    -- else
    --     New(float_text, 'item', int(var.pointrate / 20) * 10, self.x, self.y + 6, 0.75, 90, 60, 0.5, 0.5, Color(0x80FFFFFF), Color(0x00FFFFFF))
    --     var.score = var.score + int(var.pointrate / 20) * 10
    -- end

    var.LifechipPoint = var.LifechipPoint + 1
    LifeExtendCheck()
end

function item.DropItem(x, y, drop)
    local m
    if drop[1] >= 400 then
        m = 1
    else
        m = int(drop[1] / 100) + drop[1] % 100
    end
    local n = m + drop[2] + drop[3]
    if n < 1 then
        return
    end
    local r = sqrt(n - 1) * 5
    if drop[1] >= 400 then
        local r2 = sqrt(ran:Float(1, 4)) * r
        local a = ran:Float(0, 360)
        New(item_power_full, x + r2 * cos(a), y + r2 * sin(a))
    else
        local drop4 = int(drop[1] / 100)
        local drop1 = drop[1] % 100
        for i = 1, drop4 do
            local r2 = sqrt(ran:Float(1, 4)) * r
            local a = ran:Float(0, 360)
            New(item_power_large, x + r2 * cos(a), y + r2 * sin(a))
        end
        for i = 1, drop1 do
            local r2 = sqrt(ran:Float(1, 4)) * r
            local a = ran:Float(0, 360)
            New(item_power, x + r2 * cos(a), y + r2 * sin(a))
        end
    end
    for i = 1, drop[2] do
        local r2 = sqrt(ran:Float(1, 4)) * r
        local a = ran:Float(0, 360)
        New(item_faith, x + r2 * cos(a), y + r2 * sin(a))
    end
    for i = 1, drop[3] do
        local r2 = sqrt(ran:Float(1, 4)) * r
        local a = ran:Float(0, 360)
        New(item_point, x + r2 * cos(a), y + r2 * sin(a))
    end
end

item.sc_bonus_max = 2000000
item.sc_bonus_base = 1000000

function item:StartChipBonus()
    self.chip_bonus = true
    self.bombchip_bonus = true
end

function item:EndChipBonus(x, y)
    if self.chip_bonus and self.bombchip_bonus then
        New(item_chip, x - 20, y)
        New(item_bombchip, x + 20, y)
    else
        if self.chip_bonus then
            New(item_chip, x, y)
        end
        if self.bombchip_bonus then
            New(item_bombchip, x, y)
        end
    end
end

function item.PlayerInit()
    lstg.var.power = 100
    lstg.var.lifeleft = 2
    lstg.var.bomb = 3
    lstg.var.bonusflag = 0
    lstg.var.chip = 0
    lstg.var.faith = 0
    lstg.var.graze = 0
    lstg.var.score = 0
    lstg.var.score_tmp = 0
    lstg.var.score_draw = 0
    lstg.var.bombchip = 0
    lstg.var.coun_num = 0
    lstg.var.pointrate = item.PointRateFunc(lstg.var)
    lstg.var.collectitem = { 0, 0, 0, 0, 0, 0 }
    lstg.var.itembar = { 0, 0, 0 }
    lstg.var.block_spell = false
    lstg.var.chip_bonus = false
    lstg.var.bombchip_bonus = false
    lstg.var.init_player_data = true
end
------------------------------------------
function item.PlayerReinit()
    lstg.var.power = 400
    lstg.var.lifeleft = 2
    lstg.var.chip = 0
    lstg.var.bomb = 3
    lstg.var.bomb_chip = 0
    lstg.var.block_spell = false
    lstg.var.init_player_data = true
    lstg.var.coun_num = min(9, lstg.var.coun_num + 1)
    lstg.var.score = lstg.var.coun_num
end
------------------------------------------
--HZC的收点系统
---! todo:禁用收点奖励系统
---! todo:在合适的时机调整上线收点界
function item.playercollect(n)
    New(tasker, function()
        local z = 0
        local Z = 0
        local var = lstg.var
        local f = nil
        local maxpri = -1
        for i, o in ObjList(GROUP_ITEM) do
            if o.attract >= 8 and not o.collecting and not o.is_minor then
                local dx = player.x - o.x
                local dy = player.y - o.y
                local pri = abs(dy) / (abs(dx) + 0.01)
                if pri > maxpri then
                    maxpri = pri
                    f = o
                end
                o.collecting = true
            end
        end
        for i = 1, 300 do
            if not (IsValid(f)) then
                break
            end
            task.Wait(1)
        end
        z = lstg.var.collectitem[n]
        -- local x = player.x
        -- local y = player.y
        -- if z >= 0 and z < 40 then
        --     Z = 1.0
        -- elseif z < 60 then
        --     Z = 1.5
        -- elseif z < 80 then
        --     Z = 2.4
        -- elseif z < 100 then
        --     Z = 3.6
        -- elseif z < 120 then
        --     Z = 5.0
        -- elseif z >= 120 then
        --     Z = 8.0
        -- end
        -- if z >= 5 and z < 20 then
        --     task.Wait(15)
        --     New(float_text2, 'bonus', 'NO BONUS', x, y + 60, 0, 90, 120, 0.5, 0.5, Color(0xF0B0B0B0), Color(0x00B0B0B0))
        -- elseif z >= 20 and z < 40 then
        --     PlaySound('pin00', 0.8)
        --     task.Wait(15)
        --     New(float_text2, 'bonus', string.format('BONUS', Z), x, y + 70, 0, 120, 120, 0.5, 0.5, Color(0xFF29E8E8), Color(0x0029E8E8))
        --     New(float_text2, 'bonus', string.format('%d X %.1f', z * 20, Z), x, y + 60, 0, 120, 120, 0.5, 0.5, Color(0xFF29E8E8), Color(0x0029E8E8))
        --     var.faith = var.faith + Z * z * 20
        -- elseif z >= 40 and z < 60 then
        --     PlaySound('pin00', 0.8)
        --     task.Wait(15)
        --     New(float_text2, 'bonus', string.format('BONUS', Z), x, y + 70, 0, 120, 120, 0.5, 0.5, Color(0xFF29E8E8), Color(0x0029E8E8))
        --     New(float_text2, 'bonus', string.format('%d X %.1f', z * 20, Z), x, y + 60, 0, 120, 120, 0.5, 0.5, Color(0xFF29E8E8), Color(0x0029E8E8))
        --     var.faith = var.faith + Z * z * 20
        -- elseif z >= 60 and z < 80 then
        --     PlaySound('pin00', 0.8)
        --     task.Wait(15)
        --     New(float_text2, 'bonus', string.format('BONUS', Z), x, y + 70, 0, 120, 120, 0.5, 0.5, Color(0xFF44FFA1), Color(0x0044FFA1))
        --     New(float_text2, 'bonus', string.format('%d X %.1f', z * 20, Z), x, y + 60, 0, 120, 120, 0.5, 0.5, Color(0xFF44EEA1), Color(0x0044EEA1))
        --     var.faith = var.faith + Z * z * 20
        -- elseif z >= 80 and z < 100 then
        --     PlaySound('pin00', 0.8)
        --     task.Wait(15)
        --     New(float_text2, 'bonus', string.format('BONUS', Z), x, y + 70, 0, 120, 120, 0.5, 0.5, Color(0xFF44FFA1), Color(0x0044FFA1))
        --     New(float_text2, 'bonus', string.format('%d X %.1f', z * 20, Z), x, y + 60, 0, 120, 120, 0.5, 0.5, Color(0xFF44FFA1), Color(0x0044FFA1))
        --     var.faith = var.faith + Z * z * 20
        -- elseif z >= 100 and z < 120 then
        --     PlaySound('pin00', 0.8)
        --     task.Wait(15)
        --     New(float_text2, 'bonus', string.format('BONUS', Z), x, y + 70, 0, 120, 120, 0.5, 0.5, Color(0xFFFFFF00), Color(0x00FFFF00))
        --     New(float_text2, 'bonus', string.format('%d X %.1f', z * 20, Z), x, y + 60, 0, 120, 120, 0.5, 0.5, Color(0xFFFFFF00), Color(0x00FFFF00))
        --     var.faith = var.faith + Z * z * 20
        -- elseif z >= 120 then
        --     PlaySound('pin00', 0.8)
        --     task.Wait(15)
        --     New(float_text2, 'bonus', string.format('BONUS', Z), x, y + 70, 0, 120, 120, 0.5, 0.5, Color(0xFFFF4422), Color(0x00FF4422))
        --     New(float_text2, 'bonus', string.format('%d X %.1f', z * 20, Z), x, y + 60, 0, 120, 120, 0.5, 0.5, Color(0xFFFF4422), Color(0x00FF4422))
        --     var.faith = var.faith + Z * z * 20
        -- end
        lstg.var.collectitem[n] = 0
    end)

end
-----------------------------
---
---! miss的行为居然是在这里定义的？
---! 仅仅是兼容原有逻辑的东西，咱们尽量避免主动调用
function item:PlayerMiss()
    lstg.var.chip_bonus = false
    if lstg.var.sc_bonus then
        lstg.var.sc_bonus = 0
    end
    player.protect = 300
    lstg.var.lifeleft = lstg.var.lifeleft - 1
    lstg.var.power = math.max(lstg.var.power - lstg.var.MissPowerPenality, lstg.var.MinPower)
    lstg.var.bomb = max(lstg.var.bomb, lstg.var.MissBombCompensate)
    -- if lstg.var.lifeleft > 0 then
    --     for i = 1, 7 do
    --         local a = 90 + (i - 4) * 18 + self.x * 0.26
    --         New(item_power, self.x, self.y + 10, 3, a)
    --     end
    -- else
    --     New(item_power_full, self.x, self.y + 10)
    -- end
end
function item.PlayerSpell()
    if lstg.var.sc_bonus then
        lstg.var.sc_bonus = 0
    end
    lstg.var.bombchip_bonus = false
end

function item.PlayerGraze()
    lstg.var.graze = lstg.var.graze + 1
    --    lstg.var.score=lstg.var.score+50
end

function item.PointRateFunc(var)
    local r = 10000 + int(var.graze / 10) * 10 + int(var.faith / 10) * 10
    return r
end
