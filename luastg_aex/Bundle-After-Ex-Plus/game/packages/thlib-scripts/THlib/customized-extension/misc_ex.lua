---! 定义各种有用的小工具
misc_ex = {}
local cl=require("THlib.customized-extension.player_death_effect")
-- local hs=require("laboratory.shader.HSLShift")

---! 用途：辅助各类丝滑的变化
---@param cur number 当前值
---@param tar number 目标值
---@param speed number|nil 每帧变化量占当前差值的比例，默认为0.02
---@return number 目标值经过一帧之后的大小，注意接住
function misc_ex.approach(cur,tar,speed)
    speed=speed or 0.02
    if abs(cur-tar)<0.00001 then
        return tar
    else
        local delta=(tar-cur)*speed
        return cur+delta
    end
end

-- function misc_ex.PlayerMiss()
--     local p=player
--     if p.death == 0 and not p.dialog then
--         if p.protect == 0 then
--             PlaySound("pldead00", 0.5)
--             p.death = 100
--         end
--         if other.group == GROUP_ENEMY_BULLET then
--             Del(other)
--         end
--     end
-- end

---! 用于在player的视野外随机生成对象
---@param mode number 1,2,3,4--上下左右
function misc_ex.RandomCoor(mode)
    -- if not IsValid(player) then return nil,nil
    -- else
        local b=100
        local wo=lstg.worldoffset
        local cx,cy=wo.centerx,wo.centery
        local w,h=lstg.world.scrr-lstg.world.scrl,lstg.world.scrt-lstg.world.scrb
        if(mode==1) then
            return ran:Float(cx-w/2-b,cx+w/2+b),cy+h/2+b
        elseif(mode==2) then
            return ran:Float(cx-w/2-b,cx+w/2+b),cy+h/2+b
        elseif(mode==3) then
            return cx-w/2-b,ran:Float(cy-h/2-b,cy+h/2+b)
        elseif(mode==4) then
            return cx+w/2+b,ran:Float(cy-h/2-b,cy+h/2+b)
        end
        --return ran:Sign()*ranFloat(wo.centerx-w/2-b,wo.centerx+w/2)
    -- end
end

function misc_ex.InitializeSystem()
    lstg.var.LifeExtendPoint=100
    lstg.var.BombExtendPoint=100
    lstg.var.LifechipPoint=30
    lstg.var.BombchipPoint=30
    lstg.var.LifeMax=7
    lstg.var.LifeMax=7
    lstg.var.PowerMax=400
    lstg.var.PowerExtendPoint=100
    lstg.var.MinPower=0
    ResetWorld()
    lstg.var.block_shoot=false
    lstg.var.block_spell=false
    lstg.var.ShowLife=true
    lstg.var.ShowBomb=true
    lstg.var.ShowPower=true
    lstg.var.ShowBackground=true
    lstg.var.allow_continue=true
    PlayerSys.FrozenWhenDead = true
    cl.colorless_init()
end

function misc_ex.ClearScreen()
    for _,unit in ObjList(GROUP_FOOD) do
        _del(unit,true)
    end
    for _,unit in ObjList(GROUP_INDES) do
        _del(unit,true)
    end
    local origin_collectline=player.collect_line
    player.collect_line=-400
    task.New(player, function()
        task.Wait(2)
        player.collect_line=origin_collectline
        end)
end
