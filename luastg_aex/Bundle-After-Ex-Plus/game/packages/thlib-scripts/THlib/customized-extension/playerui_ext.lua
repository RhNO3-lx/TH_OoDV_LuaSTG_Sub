---! 在这里添加player ui杂项的渲染支持
---! 调用时机由编辑器内的关卡进程中决定，手动渲染player中的物体

PlayerUIType={}
PlayerUIType.Life=1
PlayerUIType.Bomb=2
PlayerUIType.Power=3
PlayerUIType.BackGround=4

lstg.var.ShowLife=true
lstg.var.ShowBomb=false
lstg.var.ShowPower=true
lstg.var.ShowBackground=true

---@param tex string @图片名
---@param x number @x坐标
---@param y number @y坐标
---@param rot number @起始角度
---@param la number @总角度
function RenderRingEx(tex,x, y, rot, la, r1, r2, n)
    n=n or 360
    local da = la / n
    for i = 1, n do
        local a = rot + da * i
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
    if IsValid(player)~=true then
        print("warning: playerui_obj is not valid")
        return
    end
    local attri={}
    attri.blendmode="mul+add"
    if type==PlayerUIType.Life then
        attri.alpha=0.75
        attri.r1=44
        attri.r2=50
        attri.c=Color(255*attri.alpha,183,18,185)
        attri.la=lstg.var.lifeleft*360/lstg.var.LifeMax+lstg.var.LifechipPoint*360/lstg.var.LifeExtendPoint/lstg.var.LifeMax
        
    elseif type==PlayerUIType.Bomb then
        attri.alpha=0.75
        attri.r1=44
        attri.r2=50
        attri.c=Color(255*attri.alpha,6,71,144)
        attri.la=lstg.var.bombleft*360/lstg.var.bombmax+lstg.var.bombchip*360/lstg.var.bombextend/lstg.var.bombmax
    elseif type==PlayerUIType.Power then
        attri.alpha=0.5
        attri.r1=50
        attri.r2=54
        attri.c=Color(255*attri.alpha,237,68,64)
        attri.la=lstg.var.powerleft*360/lstg.var.powermax
    elseif type==PlayerUIType.BackGround then
        attri.alpha=0.25
        attri.r1=43
        attri.r2=51
        attri.c=Color(255*attri.alpha,76,168,255)
        attri.la=360
    end
    ---! 血条边框
    SetImageState("white", attri.blendmode, attri.c)
    RenderRingEx("white", player.x, player.y, 0,attri.la,attri.r1, attri.r2)
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