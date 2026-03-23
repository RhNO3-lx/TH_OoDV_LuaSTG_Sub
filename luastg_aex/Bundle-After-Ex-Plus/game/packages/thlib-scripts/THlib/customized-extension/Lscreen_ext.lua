---! customized Lscreen.lua
---! by:RhNO3-lx
require("lib.Lscreen")

---todo(done):扩大实际活动范围配套的3d背景可选操作
---! 预先向Lscreen.lua->worldoffset中注入了两个额外字段
---! 并在setViewMode->3d->setviewport引入
---! warning: 千万不要在出现变形类着色器的时候使之超出屏幕
---@param cx number
---@param cy number
---@deprecated
function Set3DOffset(cx,cy)
    --lstg.worldoffset.cy3d=cy
    --lstg.worldoffset.cx3d=cx
end

---! sl,sb,sw,sh ->screen param
---! w,h ->world size param
---! l3d,r3d,b3d,t3d ->3d render world rect, =scr by default
function SetWorldV2(sl, sb,sw,sh, w, h,bound, m)
    bound = bound or 100
    m = m or 15
    local l=-w / 2
    local r=w/2
    local b=-h/2
    local t=h/2

    OriginalSetWorld(
            l,r,b,t,
            l - bound, r + bound, b - bound, t + bound,
            sl,sl+sw,sb,sb+sh,
            l,r,b,t,
            m
    )
    SetBound(lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt)

    --print("in setworldv2:")
    -- local tmp=""
    -- for k,v in pairs(lstg.world) do
    --     tmp=tmp..k..":"..v..","
    -- end
    -- print(tmp)
end

---! warning: 3dworld中绘制出的图形会被拉伸
---! warning: 千万不要在出现变形类着色器的时候使之超出屏幕
---! 虽然在实际操作过程中，背景渲染得差不多就行
---@deprecated
function Set3DWorld(l3d,r3d,b3d,t3d)
    local w=lstg.world
    w.l3d=l3d
    w.r3d=r3d
    w.b3d=b3d
    w.t3d=t3d
end

---! 指定ui模式下渲染的偏移量，计算版面中心坐标
---! 警告：并未使ui能随版面大小改变而更改偏移，不过我认为咱们并不需要
function GetUIOffset()
    local w=lstg.world
    local cx, cy = (w.scrr+w.scrl)/2, (w.scrt+w.scrb)/2
    return cx, cy
end

---@return number,number@player的屏幕坐标
function GetPlayerScr()
    local cx,cy=GetUIOffset()
    local wo=lstg.worldoffset
    local player_scrx=player.x-wo.centerx+cx
    local player_scry=player.y-wo.centery+cy
    return player_scrx,player_scry
end

function GetScr(obj)
    local cx,cy=GetUIOffset()
    local wo=lstg.worldoffset
    local obj_scrx=obj.x-wo.centerx+cx
    local obj_scry=obj.y-wo.centery+cy
    return obj_scrx,obj_scry
end

function ChangeWorldTo(w,h,duration,PlaySE,SEName)
    PlaySE=PlaySE or true
    SEName=SEName or "boon01"
    duration=duration or 180
    PlaySound(SEName, 0.5)
    local wo=lstg.world
    local cw=wo.r-wo.l
    local ch=wo.t-wo.b
    local sl,sr,sb,st=wo.scrl,wo.scrr,wo.scrb,wo.scrt
    local sw=sr-sl
    local sh=st-sb
    for i=1,duration do
        task.Wait(1)
        local la=sin(i/duration*90)
        local setw=cw*(1-la)+w*la
        local seth=ch*(1-la)+h*la
        SetWorldV2(sl,sb,sw,sh,setw,seth)
    end
end
---! invoke example:
--[[

--set map and 3d map
local vpcx=320
local vpcy=240
local mapw=1000
local maph=800

local sl=0
local sb=0
local sw=640
local sh=480

SetWorldV2(sl,sb,sw,sh,mapw,maph,-300,300,-300,300)

--set player tracked

--in repitition:
task.wait(1)
local cxlb=-(mapw)/2+sw/2
local cylb=-(maph)/2+sh/2

local cx=player.x
local cy=player.y

if cx<cxlb then cx=cxlb
else if cx>-cxlb then cx=-cxlb
	end
end

if cy<cylb then cy=cylb
else if cy>-cylb then cy=-cylb
	end
end
SetWorldOffset(cx,cy,1,1)

---! use 3d offset to track player
Set3DOffset(cx,cy)

--]]