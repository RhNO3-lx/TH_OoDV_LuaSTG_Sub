local dir="" --"extensions\\Trestone_Resources\\Others\\"

local SPELLCARD_LEFT_PATH   = dir..'Trestone_Cardleft.png'
local BOSSMARK_PATH         = dir..'Trestone_Mark.png'
local ATTACK_RING_PATH      = dir..'Trestone_BossRing.png'
local SPELLNAME_BG_PATH     = dir..'Trestone_SpellName_BG.png'

LoadTexture("boss_sc_left", SPELLCARD_LEFT_PATH)
LoadTexture("boss_mark", BOSSMARK_PATH)
LoadTexture("boss_att_ring", ATTACK_RING_PATH )
LoadTexture("boss_scname_bg", SPELLNAME_BG_PATH)

LoadImage("boss_left_star", "boss_sc_left", 0, 0, 32, 32)
LoadImage("boss_mark_point", "boss_mark", 0, 0, 65, 16)
LoadImage("boss_scn_bg", "boss_scname_bg", 0, 0, 256, 36)
LoadImageGroup("boss_att_ring1", "boss_att_ring", 80, 0, 16, 8, 1, 16)
for i = 1, 16 do
    SetImageState("boss_att_ring1" .. i, "mul+add", Color(0x80FFFFFF))
end
LoadImageGroup("boss_att_ring2", "boss_att_ring", 48, 0, 16, 8, 1, 16)
for i = 1, 16 do
    SetImageState("boss_att_ring2" .. i, "mul+add", Color(0x80FFFFFF))
end

--boss 信息板
function Trestone_BossInfo_Apply(target, lcount)
    target.Trestone_BossInfo = New(Trestone_BossInfo, target, lcount)
end

Trestone_BossInfo = Class(object)
function Trestone_BossInfo:init(target, lcount)
    self.ui = target.ui
    if target.__hpbartype2 and int(target.__hpbartype2 / 10) == 2 then
        self.x, self.y = -185, lstg.world.t - 10
    else
        self.x, self.y = -185, lstg.world.t
    end
    self.t = 0
    self.mt = 15
    self.txtaph = 0
    self.staraph = 0
    self.lcount = lcount
    self.stardx = 15
    self.stardy = 15
    self.target = target
    self.layer = LAYER_TOP + 3
end

function Trestone_BossInfo:frame()
    local _ui = self.ui
    local boss = self.target
    if not (IsValid(boss)) then
        return
    end

    local tm = self.timer
    if tm <= 60 then
        local aph = math.rad(tm * 90 / 60)
        self.txtaph = math.sin(aph) * 255
    elseif tm <= 120 then
        local aph = math.rad((tm - 60) * 90 / 60)
        self.staraph = math.sin(aph) * 255
    end

    local x, y
    if boss.__hpbartype2 and int(boss.__hpbartype2 / 10) == 2 then
        x, y = -185, lstg.world.t - 10
    else
        x, y = -185, lstg.world.t
    end
    if _ui.drawhp and _ui.hpbar and _ui.hpbar._mode ~= -1 and ui.lstg_weekly then
        y = y - 20
    end
    local xx,yy = self.x, self.y
    self.x = self.x + (x - xx) * 0.10
    self.y = self.y + (y - yy) * 0.10
    local bscl = boss.sc_left
    if self.sc_left == nil then
        self.sc_left = bscl
    end
    if self.sc_left > bscl then
        self.t = self.t + self.mt * (self.sc_left - bscl)
        self.sc_left = bscl
    end
    if self.t > 0 then
        self.t = self.t - 1
    end
end

function Trestone_BossInfo:render()
    local boss =  self.target
    if not (IsValid(boss)) then
        return
    end
    local dy = (boss.ui_slot - 1) * 44
    local x, y = self.x, self.y - dy
    local anisc = int(self.t / self.mt)
    local sc_left = self.sc_left + anisc
    RenderTTF('boss_name', boss.name, x, x, y, y, Color(self.txtaph, 0, 0, 0), "noclip")
    x = x - 1
    y = y + 1
    RenderTTF('boss_name', boss.name, x, x, y, y, Color(self.txtaph, 147, 202, 104), "noclip")
    local lcount = self.lcount
    local sdx, sdy = self.stardx, self.stardy
    local m = int((sc_left - 1) / 8)
    local m2 = sc_left - 1 - 8 * m
    x = self.x - 8
    y = self.y - 22 - dy
    if m >= 0 then
        SetImageState("boss_left_star", "", Color(self.staraph, 255, 255, 255))
        for i = 0, m - 1 do
            for j = 1, lcount do
                Render('boss_left_star', x + j * sdx, y - i * sdy, 0, 0.5)
            end
        end
        y = y - m * sdy
        for i = 1, m2 do
            Render("boss_left_star", x + i * sdx, y, 0, 0.5)
        end
        local t, at, x2, y2
        t = self.mt - (self.t - anisc * self.mt)
        at = self.mt
        if self.t > 0 then
            x2 = x + (m2 + 1) * sdx
            y2 = y
            SetImageState("boss_left_star", "",
                    Color(255 * (1 - (t / at)), 255, 255, 255))
            Render("boss_left_star", x2, y2, 0, 0.5 + (t / at) * 0.5)
        end
    end
end

--boss 法阵
function Trestone_Boss_Magic_Apply(target, tm)
    target.Trestone_Boss_Magic = New(Trestone_Boss_Magic, target, tm)
end

Trestone_Boss_Magic = Class(object)
function Trestone_Boss_Magic:init(target, tm)
    self.target = target
    self.layer = LAYER_ENEMY - 2
    self.bound = false

    self.x, self.y = target.x, target.y

    self.t = 0
    self.tm = max(1, tm or 60)
    self.range = 0

    self.size = 1
    self.swing = 0
    self._aph = 128
    self.current_aph = self._aph
    self.hide=false
end

function Trestone_Boss_Magic:frame()
    local boss = self.target
    if IsValid(boss) then
        self.x = boss.x
        self.y = boss.y
    else
        Del(self)
        return
    end

    self.swing = self.swing + 0.005
    self.size = 1 + 0.05 * math.sin(self.swing)

    local now_open = (boss.magichide ~= true)

    if now_open then
        self.t = math.min(self.tm, self.t + 1)
    else
        self.t = math.max(0, self.t - 1.25)
    end

    local progress = math.rad(self.t / self.tm * 90)
    self.range = math.sin(progress)

    if boss.timespell == true then
        self.current_aph = math.max(self._aph / 2, self.current_aph - self._aph / 120)
    else
        self.current_aph = math.min(self._aph, self.current_aph + self._aph / 120)
    end
end

function Trestone_Boss_Magic:render()
    if self.hide then return end

    local boss = self.target
    if not IsValid(boss) then
        return
    end

    local size = self.size * self.range * (boss.aura_scale or 1)
    if size <= 0 then return end

    for i = 1, 25 do
        SetImageState("boss_aura_3D" .. i, "mul+add", Color(self.current_aph, 255, 255, 255))
    end
    Render("boss_aura_3D" .. boss.ani % 25 + 1, boss.x, boss.y, boss.ani * 0.75,
            0.92 * size, (0.8 + 0.12 * sin(90 + boss.ani * 0.75)) * size)
    for i = 1, 25 do
        SetImageState("boss_aura_3D" .. i, "mul+add", Color(128, 255, 255, 255))
    end
end

--boss标记
function Trestone_Boss_Mark_Apply(target)
    target.Trestone_Boss_Mark = New(Trestone_Boss_Mark, target)
end

Trestone_Boss_Mark = Class(object)

function Trestone_Boss_Mark:init(target)
    self.layer = LAYER_TOP + 5
    self.group = GROUP_GHOST
    self.target = target
    self.bound = false
    self.EnemyIndicater = 255
    self.scale = 1

    self.fade_timer = 0
    self.fade_total = 0
    self.was_hidden = false
    self.appear_count = 0
end

function Trestone_Boss_Mark:frame()
    self.y = lstg.world.b - 8
    local b = self.target
    if not (IsValid(b)) then
        return
    end

    if self.appear_count < 60 then
        self.appear_count = self.appear_count + 1
    end

    local should_hide = b.markhide or b.hp <= 0

    if should_hide ~= self.was_hidden then
        self.was_hidden = should_hide
        self.fade_timer = 0
        self.fade_total = 20
    elseif self.fade_timer < self.fade_total then
        self.fade_timer = self.fade_timer + 1
    end

    if b.hp >= 0 then
        self.EnemyIndicater = self.EnemyIndicater + (max(0, (b.maxhp / 2 - b.hp))) / (b.maxhp / 2) * 90
    end
end

function Trestone_Boss_Mark:render()
    local b = self.target
    if not (IsValid(b)) then
        return
    end

    local fade_ratio = 1.0

    if self.appear_count < 60 then
        fade_ratio = self.appear_count / 60
    else
        if self.fade_total > 0 then
            local progress = min(self.fade_timer / self.fade_total, 1.0)
            if self.was_hidden then
                fade_ratio = 1.0 - progress
            else
                fade_ratio = progress
            end
        else
            fade_ratio = self.was_hidden and 0 or 1
        end
    end

    if fade_ratio <= 0 then
        return
    end

    local w = lstg.world
    local scale = self.scale
    SetRenderRect(w.l, w.r, w.b - max(16 * scale, 0), w.t,
                  w.scrl, w.scrr, w.scrb - max(16 * scale, 0), w.scrt)

    local x, y = b.x, self.y
    local distsub = 1
    local players
    if Players then
        players = Players(b)
    else
        players = { player }
    end
    for _, p in pairs(players) do
        if IsValid(p) then
            distsub = min((1 - (min(abs(x - p.x), 64) / 128)), distsub)
        end
    end

    local hpsub = (sin(self.EnemyIndicater + 270) + 1) * 0.125
    local base_alpha = (1 - distsub * 0.6 - hpsub)
    local final_alpha = base_alpha * fade_ratio * 255
    final_alpha = max(0, min(255, final_alpha))

    SetImageState("boss_mark_point", "", Color(final_alpha, 255, 255, 255))
    Render("boss_mark_point", x, y, 0, self.scale)
    SetViewMode "world"
end

--boss 符卡环
function Trestone_Boss_Attack_Ring_Apply(target, _aph, range)
    target.Trestone_Boss_Attack_Ring = New(Trestone_Boss_Attack_Ring, target, _aph, range)
end

Trestone_Boss_Attack_Ring = Class(object)
function Trestone_Boss_Attack_Ring:init(target, _aph, range)
    self.target = target
    self.layer = LAYER_ENEMY - 1
    self.bound = false

    self.x, self.y = target.x, target.y
    self._aph = min(_aph or 144, 144)
    self.range = range or 164
    self.current_aph = self._aph
end

function Trestone_Boss_Attack_Ring:frame()
    local boss = self.target

    if IsValid(boss) then
        self.x = boss.x
        self.y = boss.y
    else
        Del(self)
        return
    end

    if boss.timespell == true then
        self.current_aph = math.max(self._aph / 2, self.current_aph - self._aph / 120)
    else
        self.current_aph = math.min(self._aph, self.current_aph + self._aph / 120)
    end

    if boss.ringkill == true then
        Del(self)
    end
end

function Trestone_Boss_Attack_Ring:render()
    local boss = self.target
    if not IsValid(boss) or not IsValid(_boss) then ---revised by RhNO3-lx,对_boss也需判空
        Del(self)
        return
    end
    SetViewMode"world"
    local extend_rate = 1 + 16 / 60
    local alpha = min(self.current_aph, self.timer*1.5)
    local exr1 = -0.5
    local bold = 2
    local main_radius = self.range
    local timer, rov, cut, flag = _boss.timer, 4, 48, 1
    local pause = ext.pause_menu
    if pause and pause.IsKilled and pause:IsKilled() then
	    pause = false
    end
    local ringx = boss._sc_ring_x or boss.x
    local ringy = boss._sc_ring_y or boss.y
    if not pause then
	    local minspeed = self._sc_ring_minspeed or 0.5
	    local ratespeed = self._sc_ring_ratespeed or 0.08
	    local speed = Dist(ringx, ringy, boss.x, boss.y)
	    local angle = Angle(ringx, ringy, boss.x, boss.y)
	    speed = min(speed, max(speed * ratespeed, minspeed))
	    ringx = ringx + speed * cos(angle)
	    ringy = ringy + speed * sin(angle)
    end
    boss._sc_ring_x = ringx
    boss._sc_ring_y = ringy
    if not _boss.__is_waiting and _boss.__draw_sc_ring then
	    for i = 1, 16 do
			SetImageState('boss_att_ring1' .. i, 'mul+add', Color(alpha, 255, 255, 255))
	    end
    if timer < 90 then
	    if boss.fxr and boss.fxg and boss.fxb then
		    local of = 1 - timer / 180
		    for i = 1, 16 do
		        SetImageState('boss_att_ring2' .. i, 'mul+add',
		                Color(1.9 * alpha, boss.fxr * of, boss.fxg * of, boss.fxb * of))
	        end
	    else
		    for i = 1, 16 do
			    SetImageState('boss_att_ring2' .. i, 'mul+add',Color(alpha, 255, 255, 255))
		    end
	    end
	    misc.RenderRing('boss_att_ring1', ringx, ringy,
	    timer * (main_radius / 90) + main_radius * 1.5 * sin(timer * 2) + 14 + exr1 + bold,
	    timer * (main_radius / 90) + main_radius * 1.5 * sin(timer * 2) - 2 + exr1,
	            -boss.ani * rov, cut, 16)
	    misc.RenderRing('boss_att_ring2', ringx, ringy,
	            90 + ((main_radius - 90) / 90) * timer + 4,
	            -main_radius + (1 - cos(timer) ^ 2) * (main_radius * 2 - 12) - bold,
	            boss.ani * rov, cut, 16)
	    else
		    if boss.fxr and boss.fxg and boss.fxb then
			    for i = 1, 16 do
				    SetImageState('boss_att_ring2' .. i, 'mul+add',Color(1.9 * alpha, boss.fxr / 2, boss.fxg / 2, boss.fxb / 2))
			    end
		    else
			    for i = 1, 16 do
				    SetImageState('boss_att_ring2' .. i, 'mul+add',Color(alpha, 255, 255, 255))
			    end
		    end
	    local t = _boss.t3 * extend_rate
	    misc.RenderRing('boss_att_ring1', ringx, ringy,
	            (t - timer * 1.08) / (t - 90) * main_radius + 14 + exr1 + bold,
	            (t - timer * 1.08) / (t - 90) * main_radius - 2 + exr1,
	            -boss.ani * rov, cut, 16)
	    misc.RenderRing('boss_att_ring2', ringx, ringy,
	            (t - timer) / (t - 90) * main_radius + 4,
	            (t - timer) / (t - 90) * main_radius - 12 - bold,
	            boss.ani * rov, cut, 16)
	    end
    end
end

--boss 计时器
function Trestone_Boss_TimeCounter_Apply(target)
    target.Trestone_Boss_TimeCounter = New(Trestone_Boss_TimeCounter, target)
end

Trestone_Boss_TimeCounter = Class(object)
function Trestone_Boss_TimeCounter:init(target)
    self.ui = target.ui
    self.target = target
    local boss = target
    if boss.__hpbartype2 and int(boss.__hpbartype2 / 10) == 2 then
        self.x, self.y = 176, lstg.world.t - 10
        self.oldstyle = true
    else
        self.x, self.y = 2, lstg.world.t - 37
        self.oldstyle = false
    end
    self.scale = 0.5
    self.scalewarning = 1
    self.scalewarning_current = 1.0
    self.scalewarning_1 = 1.25
    self.scalewarning_2 = 1.5
    self.yoffset = 0
    self.yoffsettemp = 0
    self.yoffsetmax = 24
    self.yoffsetspeedrate = 0.54
    self.open = false
    self.t1 = 10
    self.t2 = 5
    self.sound = true
    self.flag = 0
    self.cd1 = 0
    self.cd2 = 0
    self.layer = LAYER_TOP
    self.timehide = target.timehide or false
end

function Trestone_Boss_TimeCounter:frame()
    local _ui = self.target.ui
    local b = self.target
    if not (IsValid(b)) then
        return
    end
    assert(self.t2 <= self.t1, "time counter's t1 > t2 must be satisfied.")
    local x, y
    if b.__hpbartype2 and int(b.__hpbartype2 / 10) == 2 then
        x, y = 176, lstg.world.t - 10
        self.oldstyle = true
    else
        x, y = 2, lstg.world.t - 32
        self.oldstyle = false
    end
    if _ui.drawhp and _ui.hpbar and _ui.hpbar._mode ~= -1 and ui.lstg_weekly then
        y = y - 20
    end
    self.x = self.x + (x - self.x) * 0.1
    self.y = self.y + (y - self.y) * 0.1
    if _ui.countdown and self.sound then
        if _ui.countdown > self.t2 and _ui.countdown <= self.t1 and _ui.countdown % 1 == 0 then
            PlaySound("timeout", 0.6)
            self.scalewarning = self.scalewarning_1
            self.scalewarning_current = self.scalewarning_1
        end
        if _ui.countdown > 0 and _ui.countdown <= self.t2 and _ui.countdown % 1 == 0 then
            PlaySound("timeout2", 0.8)
            self.scalewarning = self.scalewarning_2
            self.scalewarning_current = self.scalewarning_2
        end
    end
    if not (self.open) then
        if not (b.__is_waiting) and b.is_combat then
            if b.is_sc then
                self.yoffsettemp = self.yoffsetmax
            else
                self.yoffsettemp = 0
            end
            self.open = true
        end
    elseif (b.__is_waiting and (lstg.player.dialog or not self.ui.drawtimesaver)) or (not (b.is_combat) and (lstg.player.dialog or not self.ui.drawtimesaver)) then
        self.open = false
        self.ui.drawtimesaver = nil
    end
    if self.open then
        if b.is_sc then
            self.yoffsettemp = max(0, self.yoffsettemp - 1 * self.yoffsetspeedrate)
            local s = self.yoffsettemp / self.yoffsetmax
            self.yoffset = (s * s) * self.yoffsetmax
        else
            self.yoffsettemp = min(self.yoffsetmax, self.yoffsettemp + 1 * self.yoffsetspeedrate)
            local s = self.yoffsettemp / self.yoffsetmax
            self.yoffset = (s * s) * self.yoffsetmax
        end

        if not self.ui.drawtimesaver or _ui.countdown ~= 0 then
            self.cd1 = _ui.countdown
        end

        if not b.is_combat and self.ui.drawtimesaver and not lstg.player.dialog then
            self.cd1 = self.ui.drawtimesaver
        end

        self.cd2 = (self.cd1 - int(self.cd1)) * 100
        local players
        if Players then
            players = Players(b)
        else
            players = { player }
        end
        local _flag = false
        for _, p in pairs(players) do
            if IsValid(p) and Dist(p.x, p.y, self.x, self.y) <= 70 then
                _flag = true
                break
            end
        end
        if _flag then
            self.flag = self.flag + 1
        else
            self.flag = self.flag - 1
        end
        self.flag = min(max(0, self.flag), 18)
    else
        self.flag = 0
    end
    if self.scalewarning > 1 then
        self.scalewarning = self.scalewarning - (self.scalewarning_current - 1.0) * 0.2
    else
        self.scalewarning = 1
        self.scalewarning_current = 1.0
    end
end

function Trestone_Boss_TimeCounter:render()
    local boss = self.target
    if not (IsValid(boss)) or self.timehide then
        return
    end
    if self.open then
        local alpha1 = 1 - self.flag / 30
        local cd1, cd2 = max(self.cd1, 0), max(self.cd2, 0)
        local dy = (boss.ui_slot - 1) * 44
        local x = self.x
        local y1
        if self.oldstyle then
            y1 = self.y - dy
        else
            y1 = self.y + self.yoffset - dy
        end
        local y2 = y1 - 3
        local scalew = self.scalewarning
        local scale1 = self.scale
        local scale2 = scale1 * 0.6
        if cd1 >= self.t1 then
            SetFontState("time", "", Color(alpha1 * 255, 255, 255, 255))
        elseif cd1 >= self.t2 then
            SetFontState("time", "", Color(alpha1 * 255, 255, 144, 144))
        else
            SetFontState("time", "", Color(alpha1 * 255, 255, 48, 48))
        end
        if self.cd1 >= 99.99 then
            cd1 = 99
            cd2 = 99
        end
        if cd1 >= self.t1 then
            RenderText("time", string.format("%2d", int(cd1)) .. ".", x, y1, scale1, "vcenter", "right")
            RenderText("time", string.format("%d%d", min(9, cd2 / 10), min(9, cd2 % 10)), x, y2, scale2, "vcenter", "left")
        else
            RenderText("time", string.format("0%d", min(99.99, int(cd1))) .. " ", x, y1, scale1 * scalew, "vcenter", "right")
            RenderText("time", ".", x, y1, scale1, "vcenter", "right")
            RenderText("time", string.format("%d%d", min(9, cd2 / 10), min(9, cd2 % 10)), x, y2, scale2, "vcenter", "left")
        end
    end
end

--boss 符卡名
function Trestone_SpellName_BG_Apply(target, name, score, tm)
    target.Trestone_SpellName_BG = New(Trestone_SpellName_BG, target, name, score, tm)
end

Trestone_SpellName_BG = Class(object)
function Trestone_SpellName_BG:init(target, name, score, tm)
    if score == nil then
        score = true
    end
    self.layer = LAYER_TOP + 1
    self.boss = target
    self.name = name or ""
    self.score = score
    self.xp = -8
    self.yp = 0
    self.tm = tm or 99999
    if self.name == "" then
        RawDel(self)
    end
    self.x = 192
    if ui.lstg_weekly then
        self.y = lstg.world.t - 5
    else
        self.y = lstg.world.t + 12
    end
    self.ybot = 380
    self.xoffset = 200
    self.xoffset2 = 0
    self.yoffset = -self.ybot
    local b = self.boss
    if boss.__hpbartype2 and int(boss.__hpbartype2 / 10) == 2 then
        self.yp = -8
    end
    self.bound = false
    self.flag = 0
    self._scale = 1
    self._scale2 = 1
    self._alpha = 0
    self.talpha = 0
    self.talpha2 = 0
    self.scbgdel = target.scbgdel or false
end

function Trestone_SpellName_BG:frame()
    if ui.lstg_weekly then
        self.y = lstg.world.t - 5
    else
        self.y = lstg.world.t + 12
    end
    local boss = self.boss
    local _ui = boss.ui
    local sc_hist = 0
    if (self.scbgdel or self.timer > self.tm) and not self.death then
        self.death = true
        self.timer = -1
        self.explodeFlag = nil
    end

    if self.death and self.timer > 60 then
         RawDel(self)
         return
    end
    if IsValid(boss) then
        sc_hist = boss._sc_hist
        if not self.scbgdel then 
             self.scbgdel = self.boss.scbgdel or false 
        end
    end
    if IsValid(_ui) then
        sc_hist = _ui.sc_hist
    end
    self.sc_hist = sc_hist
    self.sc_hist = sc_hist
    local t, t1, t2, ct, t3 = 60, 30, 30, 10, 40
    local etc = abs(t2 - t3) - 0
    if IsValid(boss) then
        local dy = (boss.ui_slot - 1) * 45
        self._dy = dy
        local bonus
        if boss.sc_bonus then
            bonus = string.format("0%.0f", boss.sc_bonus - boss.sc_bonus % 10)
        else
            bonus = "FAILED"
        end
        self.bonus = bonus
        local players
        if Players then
            players = Players(boss)
        else
            players = { player }
        end
        local _flag = false
        local x = self.x
        local y = self.y + self.yoffset + dy
        for _, p in pairs(players) do
            if IsValid(p) and abs(p.x - x) <= 180
                    and abs(p.y - y) <= 60
                    and self.timer > 100 + etc + t1 then
                _flag = true
                break
            end
        end
        if _flag then
            self.flag = self.flag + 1
        else
            self.flag = self.flag - 1
        end
    else
        self.flag = 0
    end
    self.flag = min(max(0, self.flag), 18)
    if not (self.death) then
        if self.timer > 30 then
            self.xoffset = max(self.xoffset - 10, 0)
        end
        self.xoffset2 = 0
        local _t = self.timer - 60
        local _t1 = 100 + etc
        local _t2 = _t1 + t1
        local _t3 = 60 + etc
        local _t4 = _t3 + t
        local _t5 = t3 - ct
        local _t6 = _t5 + t2
        if self.timer > _t1 and self.timer < _t2 then
            self.talpha = min(self.talpha + (1 / t1), 1)
        end
        if self.timer > _t3 and self.timer < _t4 then
            local tmp = (90 / t) * (_t - etc)
            self.yoffset = -self.ybot + (self.ybot + self.yp) * sin(tmp * sin(tmp))
        end
        if self.timer > _t5 and self.timer < _t6 then
            self.talpha2 = min(self.talpha2 + (1 / t2), 1)
            self._scale2 = max(1 - sin((90 / t2) * (self.timer - t3 + ct)), 0)
        end
        if self.timer < t3 then
            self._scale = max(150 - 120 * sin((90 / t3) * self.timer), 30) / 30
        end
        self._alpha = min(self.timer / t3, 1)
    else
        if IsValid(boss) and boss.is_exploding and not (self.explodeFlag) then
            self.timer = -60
            self.explodeFlag = true
        end
        if self.timer > 0 then
            self.xoffset = min(self.xoffset + 8 + self.xp, 220) 
        end
        
        self.xoffset2 = self.xoffset
        self._scale = 1
        local fade_start = 30
        local fade_duration = 30
        
        if self.timer >= fade_start then
            local progress = (self.timer - fade_start) / fade_duration
            self._alpha = max(1 - progress, 0)
        else
            self._alpha = 1
        end
        if IsValid(boss) and boss.is_exploding and not (self.explodeFlag) then
            if not self.scbgdel_trigger then 
                 self.timer = -60
                 self.explodeFlag = true
            end
        end
        
        if self.timer > 60 then
            RawDel(self)
        end
    end
end

function Trestone_SpellName_BG:render()
    local b = self.boss
    local sc_hist = self.sc_hist or { 0, 0 }
    local bonus = self.bonus
    local dy = self._dy
    local x = self.x + self.xoffset + self.xp
    local y = self.y + self.yoffset - dy + self.yp
    local alpha = 1 - self.flag / 30
    local alpha2 = alpha * self._alpha
    local s = GetImageScale()
    SetImageState("boss_scn_bg", "",
            Color(alpha * 255 * self.talpha2 * alpha2, 255, 255, 255))
    x = self.x + self.xoffset2
    Render("boss_scn_bg", x-128, y-20, 0, 1 + 0.5 * self._scale2)
    x = self.x + self.xoffset2 + self.xp
    y = y - 10
    SetImageScale(s * self._scale)
    local d = sqrt(2)
    local _x, _y
    for i = 0, 8 do
        _x = x + d * cos(i * 45)
        _y = y + d * sin(i * 45)
        RenderTTF("sc_name", self.name,
                _x, _x, _y - 2, _y - 2,
                Color(alpha2 * 255, 0, 0, 0),
                "right", "noclip")
    end
    RenderTTF("sc_name", self.name,
            x, x, y - 2, y - 2,
            Color(alpha2 * 255, 255, 255, 255),
            "right", "noclip")
    SetImageScale(s)
    local a = alpha * 255 * self.talpha
    if self.score then
        local fontsize = 0.5
        local xm, ym = 4, -1
        x = self.x + self.xoffset - 5 + self.xp
        y = self.y - dy - 31 + self.yp
        SetFontState("bonus2", "", Color(a, 0, 0, 0))
        SetImageState("cardui_history", "", Color(a, 255, 255, 255))
        SetImageState("cardui_bonus", "", Color(a, 255, 255, 255))
        Render("cardui_history", x - 63 + self.xp, y - 6 + self.yp, 0, 0.5)
        Render("cardui_bonus", x - 156 + self.xp, y - 6 + self.yp, 0, 0.5)
        SetFontState("bonus2", "", Color(a, 255, 255, 255))

        if not (self.death) or (self.death and IsValid(b) and b.is_exploding and self.timer <= 0) then
            x = x + xm + 4 + self.xp
            y = y + ym + self.yp
            if bonus ~= "FAILED" then
                RenderText("bonus2", bonus, x - 90, y, fontsize, "right")
            else
                SetImageState("sc_failed", "", Color(a, 255, 255, 255))
                Render("sc_failed", x - 108, y - ym - 6, 0, fontsize)
            end
            if self.yp == 0 then
                if sc_hist[2] < 100 then
                    x = x - 8
                    RenderText("bonus2", string.format("%02d/%02d", sc_hist[1], sc_hist[2]), x, y, fontsize, "right")
                elseif sc_hist[1] <= 99 then
                    x = x - 8
                    RenderText("bonus2", string.format("%02d/99+", sc_hist[1], sc_hist[2]), x, y, fontsize, "right")
                elseif sc_hist[1] > 99 then
                    SetImageState("sc_master", "", Color(a, 255, 255, 255))
                    Render("sc_master", x - 29, y - ym - 7, 0, fontsize)
                end
            else
                x = x - 52
                RenderText("bonus2", string.format("%02d/%02d", sc_hist[1], sc_hist[2]), x, y, fontsize, "left")
            end
        end
    end
end

function Trestone_SpellName_BG:kill()
    self.class.del(self)
end

function Trestone_SpellName_BG:del()
    PreserveObject(self)
    if not (self.death) then
        self.death = true
        self.timer = -1
    end
end

---added by RhNO3-lx
---显示血条
function RhNO3_lx_hp_bar_Apply(target)
    target.RhNO3_lx_hp_bar = New(RhNO3_lx_hp_bar, target)
end

RhNO3_lx_hp_bar = Class(object)
function RhNO3_lx_hp_bar:init(target)
    self.bound=false
    self.tar = target
    self.layer=LAYER_ENEMY+5
    self.group=GROUP_GHOST
    self.img='img_void'
    assert(IsValid(self.tar),"赋给hpbar的目标不得为空")
    self.x=self.tar.x
    self.y=self.tar.y
    self.alp=255

end

function RhNO3_lx_hp_bar:frame()
    ---有必要吗？
    if Dist(self,player)<=100 then
        self.alp=120
    else
        self.alp=255
    end
    task.Do(self)
    if not IsValid(self.tar) then
        task.New(self,function()
            local init_alp=self.alp
            for i=1,60 do
                task.Wait(1)
                self.alp=init_alp*(60-i)/60
            end
            Del(self)
        end)
    else
        --self.hp=self.tar.hp
        --self.maxhp=self.tar.maxhp
        self.x=self.tar.x
        self.y=self.tar.y
        --self.img='img_void'
    end
    
end

function RhNO3_lx_hp_bar:del()
    print("del hp bar")
    object:del()
end
function RhNO3_lx_hp_bar:render()
    local b = self.tar.bs
    
    if IsValid(b)then
        local alpha1 = 1 - b.hp_flag / 30
        ---! 血条边框
        SetImageState("base_hp", "", Color(alpha1 * 255, 255, 0, 0))
        ---! 指示实际生命值的血条
        SetImageState("hpbar1", "", Color(alpha1 * 255, 255, 255, 255))
        ---! 衬底用的血条
        SetImageState("hpbar2", "", Color(0, 255, 255, 255))
        SetImageState("life_node", "", Color(alpha1 * 255, 255, 255, 255))
        -- print("rendering hp bar")

        local mode = b.__hpbartype
        if mode == -1 then
        elseif mode == 0 or mode == 3 then -- 完整血条
            misc.Renderhpbar(self.x, self.y, 90, 360, 60, 64, 360, 1)
            misc.Renderhp(self.x, self.y, 90, 360, 60, 64, 360, b.hpbarlen * min(1, b.__hpbar_timer / 60))
            Render("base_hp", self.x, self.y, 0, 0.274, 0.274)
            Render("base_hp", self.x, self.y, 0, 0.256, 0.256)
            if b.sp_point and #b.sp_point ~= 0 then
                for i = 1, #b.sp_point do
                    Render("life_node", self.x + 61 * cos(b.sp_point[i]), self.y + 61 * sin(b.sp_point[i]), b.sp_point[i] - 90, 0.5)
                    
                end
                -- print("rendering sp point ")
            end
            if b._sp_point_auto and #b._sp_point_auto ~= 0 then
                local p, a
                for i = 1, #b._sp_point_auto do
                    p = b._sp_point_auto[i]
                    a = 90 - (p.dmg / b.maxhp) * 360
                    Render("life_node", b.x + 61 * cos(a), b.y + 61 * sin(a), a - 90, 0.5)
                end
            end
        elseif mode == 2 then
            misc.Renderhpbar(self.x, self.y, 90, 360, 60, 64, 360, 1)
            misc.Renderhp(self.x, self.y, 90, b.lifepoint - 90, 60, 64, b.lifepoint - 88, b.hpbarlen)
            Render("base_hp", self.x, self.y, 0, 0.274, 0.274)
            Render("base_hp", self.x, self.y, 0, 0.256, 0.256)
        elseif mode == 1 then
            misc.Renderhpbar(self.x, self.y, 90, 360, 60, 64, 360, 1)
            if b.timer <= 60 then
                misc.Renderhp(self.x, self.y, 90, 360, 60, 64, 360, b.hpbarlen * min(1, b.__hpbar_timer / 60))
            else
                misc.Renderhp(self.x, self.y, 90, b.lifepoint - 90, 60, 64, b.lifepoint - 88, 1)
                misc.Renderhp(self.x, self.y, b.lifepoint, 450 - b.lifepoint, 60, 64, 450 - b.lifepoint, b.hpbarlen)
            end
            Render("base_hp", self.x, self.y, 0, 0.274, 0.274)
            Render("base_hp", self.x, self.y, 0, 0.256, 0.256)
            Render("life_node", self.x + 61 * cos(b.lifepoint), self.y + 61 * sin(b.lifepoint), b.lifepoint - 90, 0.55)
            SetFontState("bonus", "", Color(255, 255, 255, 255))
        end

        -- if b.show_hp then
        --     SetFontState("bonus", "", Color(255, 0, 0, 0))
        --     RenderText("bonus", int(max(0, b.hp)) .. "/" .. b.maxhp, b.x - 1, b.y - 40 - 1, 0.6, "centerpoint")
        --     SetFontState("bonus", "", Color(255, 255, 255, 255))
        --     RenderText("bonus", int(max(0, b.hp)) .. "/" .. b.maxhp, b.x, b.y - 40, 0.6, "centerpoint")
        -- end
    end
end

function RhNO3_lx_boss_explode(tar)
    assert(IsValid(tar),"目标为空")
    local b = tar

    task.New(b, function()
            local lifetime, l
            local v=1.5
            local sign=ran:Sign(-1,1)
            local angle = ran:Float(-95, -85)+sign*90
            if not b.__dieinstantly then
                for i = 1, 60 do
                    v = v * 0.98
                    b.vx = sign * v * cos(angle)
                    b.vy = v * sin(angle)
                    b.hp = 0
                    b.timer = b.timer - 1
                    lifetime = ran:Int(60, 90)
                    l = ran:Float(100, 250)
                    New(boss_death_ef_unit, b.x, b.y, l / lifetime, ran:Float(0, 360), lifetime, ran:Float(2, 3))
                    task.Wait(1)
                end
            end
            PlaySound("enep01", 0.5, b.x / 256)
            New(deatheff, b.x, b.y, 'first')
            New(deatheff, b.x, b.y, 'second')
            New(boss_death_ef, b.x, b.y)
            ---!注意：改了这里可能会导致一些奇怪的bug
            b.killed = true
            Del(b)
            end)
end