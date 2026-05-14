---! 在这里添加player ui杂项的渲染支持
---! 调用时机由编辑器内的关卡进程中决定，手动渲染player中的物体

PlayerUI={}
PlayerUI.Life=1
PlayerUI.Bomb=2
PlayerUI.Power=3
PlayerUI.BackGround=4

lstg.var.ShowLife=true
lstg.var.ShowBomb=true
lstg.var.ShowPower=true
lstg.var.ShowBackground=true

LoadImage('white2', 'misc', 56, 8, 16, 16)
---@param tex string @图片名
---@param x number @x坐标
---@param y number @y坐标
---@param rot number @起始角度
---@param la number @总角度
---@param dir number @1为顺时针，-1为逆时针
function RenderRingEx(tex,x, y, rot, la, r1, r2, dir,n)
    dir=dir or -1
    n=n or 360
    local da = la / n
    for i = 1, n do
        local a = rot + da * i*dir
        Render4V(tex,
                r1 * cos(a + da) + x, r1 * sin(a + da) + y, 0.5,
                r2 * cos(a + da) + x, r2 * sin(a + da) + y, 0.5,
                r2 * cos(a) + x, r2 * sin(a) + y, 0.5,
                r1 * cos(a) + x, r1 * sin(a) + y, 0.5)
    end
end

---@param type number @PlayerUIType.Life | PlayerUIType.Bomb | PlayerUIType.Power | PlayerUIType.BackGround
---! 在 on render中调用它
---! 插到UI.lua里使用
---! 最好手动创建一个物体来使用，按照图层与渲染统一管理的逻辑来使用它
function PutPlayerUI(type)
    SetViewMode("ui")
    if IsValid(player)~=true then
        print("warning: playerui_obj is not valid")
        return
    end
    local attri={}
    attri.blendmode="mul+add"
    if type==PlayerUI.Life then
        attri.alpha=0.75
        attri.r1=44
        attri.r2=50
        attri.c=Color(255*attri.alpha,125,0,105)
        attri.la=lstg.var.lifeleft*360/lstg.var.LifeMax+lstg.var.chip*360/lstg.var.LifeExtendPoint/lstg.var.LifeMax
        --print("life.la"..attri.la)
        
    elseif type==PlayerUI.Bomb then
        attri.alpha=0.95
        attri.r1=44
        attri.r2=50
        attri.c=Color(255*attri.alpha,0,70,120)
        attri.la=lstg.var.bomb*360/lstg.var.LifeMax+lstg.var.bombchip*360/lstg.var.BombExtendPoint/lstg.var.LifeMax
        --print("bomb.la"..attri.la)
    elseif type==PlayerUI.Power then
        attri.alpha=0.5
        attri.r1=50
        attri.r2=54
        attri.c=Color(255*attri.alpha,177,28,24)
        attri.la=lstg.var.power%lstg.var.PowerExtendPoint*360/lstg.var.PowerExtendPoint
    elseif type==PlayerUI.BackGround then
        attri.alpha=0.15
        attri.r1=43
        attri.r2=51
        attri.c=Color(255*attri.alpha,36,128,215)
        attri.la=360
    end
    ---! 血条边框
    SetImageState("white2", attri.blendmode, attri.c)
    local cx,cy=GetPlayerScr()
    RenderRingEx("white2", cx,cy, 90,attri.la,attri.r1, attri.r2,-1)
    SetViewMode("world")
end

function PutPlayerUIBar()
    SetViewMode("ui")
    if IsValid(player)~=true then
        print("warning: playerui_obj is not valid")
        return
    end

    local attri={}
    attri.blendmode="mul+add"
    attri.alpha=0.7
    attri.r1=44
    attri.r2=50
    attri.c=Color(255*attri.alpha,0,155,165)

    local n_bomb=lstg.var.bomb
    local n_life=lstg.var.lifeleft
    if not lstg.var.ShowBomb then n_bomb=0 end
    local n=max(n_bomb,n_life)
    --print("n:"..n.."lstg.var.bomb:"..lstg.var.bomb.."lstg.var.lifeleft:"..lstg.var.lifeleft)

    local da=1
    local offset=1
    local cx,cy=GetPlayerScr()
    SetImageState("white2", attri.blendmode, attri.c)
    for i=1,n do
        local ac=-i*360/lstg.var.LifeMax
        RenderRingEx("white2", cx,cy, offset+90+ac-da,2*da,attri.r1, attri.r2,1,4)
    end
end
--[[
    ---! 绘制新的自机ui
    if IsValid(lstg.player) then
        if lstg.var.ShowLife then
            PutPlayerUI(PlayerUIType.Life)
        end
        if lstg.var.ShowPower then
            PutPlayerUI(PlayerUIType.Power)
        end
        if lstg.var.ShowPoint then
            PutPlayerUI(PlayerUIType.Point)
        end
    end
]]