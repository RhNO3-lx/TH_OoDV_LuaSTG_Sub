---! 在这里添加player ui杂项的渲染支持
---! 调用时机由编辑器内的关卡进程中决定，手动渲染player中的物体

LoadTexture("new_lifebomb","THlib/UI/life-bomb.png")
LoadImage("new_life","new_lifebomb",0,0,100,100)
LoadImage("new_bomb","new_lifebomb",0,100,100,100)
SetImageState("new_life","mul+add",Color(255,255,255,255))
SetImageState("new_bomb","mul+add",Color(255,255,255,255))

for i=0,4 do
    LoadImage("new_life"..i,"new_lifebomb",100*(i+1),0,100,100)
    LoadImage("new_bomb"..i,"new_lifebomb",100*(i+1),100,100,100)
    SetImageState("new_life"..i,"mul+add",Color(255,255,255,255))
    SetImageState("new_bomb"..i,"mul+add",Color(255,255,255,255))
end

PlayerUI={}
PlayerUI.Life=1
PlayerUI.Bomb=2
PlayerUI.Power=3
PlayerUI.Background=4

lstg.var.ShowLife=true
lstg.var.ShowBomb=true
lstg.var.ShowPower=true
lstg.var.ShowBackground=true

lstg.var.UseLegacyPlayerUI=true

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

local function DrawText(str,cx,cy,co_top,co_layer,size)
    --RenderTTF2("menuttf",str,cx,cx,cy,cy,size,co_top)
    local delta=0.5
    local font="dialog"
    RenderTTF2(font,str,cx+delta,cx+delta,cy+delta,cy+delta,size,co_layer)
    RenderTTF2(font,str,cx-delta,cx-delta,cy+delta,cy+delta,size,co_layer)
    RenderTTF2(font,str,cx+delta,cx+delta,cy-delta,cy-delta,size,co_layer)
    RenderTTF2(font,str,cx-delta,cx-delta,cy-delta,cy-delta,size,co_layer)

    RenderTTF2(font,str,cx,cx,cy,cy,size,co_top)
end
---@param type number @PlayerUIType.Life | PlayerUIType.Bomb | PlayerUIType.Power | PlayerUIType.BackGround
---! 在 on render中调用它
---! 插到UI.lua里使用
---! 最好手动创建一个物体来使用，按照图层与渲染统一管理的逻辑来使用它
function PutPlayerUI(type)
    if lstg.var.UseLegacyPlayerUI then 
        local OpacityChange=1
        if IsValid(lstg.player)~=true then
            OpacityChange=1
            print("invalid")
        else
            -- print(player.x)
            -- print(x)
            -- print(player.y)
            -- print(y)
            local player_scrx,player_scry=GetPlayerScr()
            --print(x,y,player_scrx,player_scry)
            local r=Dist(player_scrx,player_scry,60,25)
            local sr=220
            local sr2=140
            if r<=sr and r>=sr2 then
                OpacityChange=1-(sr-r)/sr*1.8
            elseif r<sr2 then
                OpacityChange=1-(sr-sr2)/sr*1.8
            end
        end

        SetViewMode("ui")
        local cx,cy=GetPlayerScr()
        local sc=0.14
        local sx_life,sy_life=20,40
        local dy=-18
        local dx=14
        if type==PlayerUI.Power then
            SetImageState("white2", "mul+add", Color(0.5*255,177,28,24))
            RenderRingEx("white2", cx,cy, 90,lstg.var.power%lstg.var.PowerExtendPoint*360/lstg.var.PowerExtendPoint,51, 54,-1)
            -- DrawText("next power level:", sx_life-5, sy_life+2*dy+8, Color(255*OpacityChange,255,168,155), Color(105*OpacityChange,0,0,0), 0.75 )
            -- DrawText(lstg.var.power.."%", sx_life+7.5*dx, sy_life+2*dy+8, Color(255*OpacityChange,255,228,195), Color(105*OpacityChange,0,0,0), 0.75 )
        elseif type==PlayerUI.Life then
            local n=lstg.var.lifeleft
            SetImageState("new_life","mul+add",Color(255*OpacityChange,255,255,255))
            for i=1,n do
                Render("new_life", sx_life+dx*(i-1), sy_life, 0, sc, sc)
            end
            if n<lstg.var.LifeMax then
                local n_residual=lstg.var.chip/lstg.var.LifeExtendPoint
                SetImageState("new_life"..math.floor(n_residual*5),"mul+add",Color(255*OpacityChange,255,255,255))
                Render("new_life"..math.floor(n_residual*5), sx_life+dx*n, sy_life, 0, sc, sc)
            end
            DrawText(lstg.var.chip.."%", sx_life+7.5*dx, sy_life+8, Color(255*OpacityChange,255,170,220), Color(105*OpacityChange,0,0,0), 0.75*sc/0.16 )
        elseif type==PlayerUI.Bomb then
            local n=lstg.var.bomb
            SetImageState("new_bomb","mul+add",Color(255*OpacityChange,255,255,255))
            for i=1,n do
                Render("new_bomb", sx_life+dx*(i-1), sy_life+dy, 0, sc, sc)
            end
            if n<lstg.var.LifeMax then
                local n_residual=lstg.var.bombchip/lstg.var.BombExtendPoint
                SetImageState("new_bomb"..math.floor(n_residual*5),"mul+add",Color(255*OpacityChange,255,255,255))
                Render("new_bomb"..math.floor(n_residual*5), sx_life+dx*n, sy_life+dy, 0, sc, sc)
            end
            DrawText(lstg.var.bombchip.."%", sx_life+7.5*dx, sy_life+dy+8, Color(255*OpacityChange,150,230,250), Color(105*OpacityChange,0,0,0), 0.75*sc/0.16 )
        elseif type==PlayerUI.Background then
        end
        
    else
        SetViewMode("ui")
        if IsValid(player)~=true then
            print("warning: playerui_obj is not valid")
            return
        end
        local attri={}
        attri.blendmode="mul+add"
        local a_residual=nil
        local residual_co=nil

        if type==PlayerUI.Life then
            attri.alpha=0.75
            attri.r1=44
            attri.r2=50
            attri.c=Color(255*attri.alpha,155,0,70)
            attri.la=lstg.var.lifeleft*360/lstg.var.LifeMax

            a_residual=lstg.var.chip*360/lstg.var.LifeExtendPoint/lstg.var.LifeMax
            residual_co=Color(attri.c.a,attri.c.r*0.6,attri.c.g*0.6,attri.c.b*0.6)
            --print("life.la"..attri.la)
            
        elseif type==PlayerUI.Bomb then
            attri.alpha=0.95
            attri.r1=44
            attri.r2=50
            attri.c=Color(255*attri.alpha,0,70,150)
            attri.la=lstg.var.bomb*360/lstg.var.LifeMax

            a_residual=lstg.var.bombchip*360/lstg.var.BombExtendPoint/lstg.var.LifeMax
            residual_co=Color(attri.c.a,attri.c.r*0.6,attri.c.g*0.6,attri.c.b*0.6)

            --print("bomb.la"..attri.la)
        elseif type==PlayerUI.Power then
            attri.alpha=0.5
            attri.r1=51
            attri.r2=54
            attri.c=Color(255*attri.alpha,177,28,24)
            attri.la=lstg.var.power%lstg.var.PowerExtendPoint*360/lstg.var.PowerExtendPoint
        elseif type==PlayerUI.Background then
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

        ---！渲染血条雷条不满一格的部分
        if a_residual~=nil and residual_co~=nil then
            SetImageState("white2", attri.blendmode, residual_co)
            RenderRingEx("white2", cx,cy, 90-attri.la,a_residual,attri.r1, attri.r2,-1)
        end
        ---! 渲染血条
        SetViewMode("world")
    end
    SetViewMode("world")
end

---！渲染节点
function PutPlayerUIBar()
    if lstg.var.UseLegacyPlayerUI then return end
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