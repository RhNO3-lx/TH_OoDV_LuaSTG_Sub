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
    lstg.worldoffset.cy3d=cy
    lstg.worldoffset.cx3d=cx
end

---! sl,sb,sw,sh ->screen param
---! w,h ->world size param
---! l3d,r3d,b3d,t3d ->3d render world rect, =scr by default
function SetWorldV2(sl, sb,sw,sh, w, h,l3d,r3d,b3d,t3d,bound, m)
    bound = bound or 32
    m = m or 15
    local l=-w / 2
    local r=w/2
    local b=-h/2
    local t=h/2
    l3d=l3d or sl
    r3d=r3d or sl+sw
    b3d=b3d or sb
    t3d=t3d or sb+sh
    OriginalSetWorld(
            l,r,b,t,
            l - bound, r + bound, b - bound, t + bound,
            sl,sl+sw,sb,sb+sh,
            l,r,b,t,
            m,
            l3d,r3d,b3d,t3d
    )
    SetBound(lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt)

    print("in setworldv2:")
    local tmp=""
    for k,v in pairs(lstg.world) do
        tmp=tmp..k..":"..v..","
    end
    print(tmp)
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