stage1_bg=Class(object)
S1BG_Attri={}
local attri=S1BG_Attri
attri.eye_to_cx=0
attri.eye_to_cz=0.5
attri.eye_x=0
attri.eye_z=0.5

---! todo:可以在stage结束的时候使劲增加这个值来实现腾空而起的视觉效果
attri.eye_y=0.53

attri.eye_to_dx=0
attri.eye_to_dz=0

attri.eye_dx=0
attri.eye_dz=0

local dir="stage1/"
---@param tex string
---@param cx number
---@param cy number
---@param cz number
---@param back number 1|-1
---@param left number 1|-1
local function cycling(tex,cx,cy,cz,back,left)
    ---! 默认背景向眼睛后移动
    local dx=1
    local dz=1
    Render4V(tex,cx-0.5,cy,cz+0.5,
                cx+0.5,cy,cz+0.5,
                cx+0.5,cy,cz-0.5,
                cx-0.5,cy,cz-0.5)
    Render4V(tex,cx-0.5+dx,cy,cz+0.5,
                cx+0.5+dx,cy,cz+0.5,
                cx+0.5+dx,cy,cz-0.5,
                cx-0.5+dx,cy,cz-0.5)
    Render4V(tex,cx-0.5,cy,cz+0.5+dz,
                cx+0.5,cy,cz+0.5+dz,
                cx+0.5,cy,cz-0.5+dz,
                cx-0.5,cy,cz-0.5+dz)
    Render4V(tex,cx-0.5-dx,cy,cz+0.5,
                cx+0.5-dx,cy,cz+0.5,
                cx+0.5-dx,cy,cz-0.5,
                cx-0.5-dx,cy,cz-0.5)
    Render4V(tex,cx-0.5+dx,cy,cz+0.5+dz,
                cx+0.5+dx,cy,cz+0.5+dz,
                cx+0.5+dx,cy,cz-0.5+dz,
                cx-0.5+dx,cy,cz-0.5+dz)
    Render4V(tex,cx-0.5-dx,cy,cz+0.5+dz,
                cx+0.5-dx,cy,cz+0.5+dz,
                cx+0.5-dx,cy,cz-0.5+dz,
                cx-0.5-dx,cy,cz-0.5+dz)
    -- Render4V(tex,cx-0.5+dx,cy,cz+0.5+dz,
    --             cx+0.5+dx,cy,cz+0.5+dz,
    --             cx+0.5+dx,cy,cz-0.5+dz,
    --             cx-0.5+dx,cy,cz-0.5+dz)
    
end

local function approach(cur,tar)
    if abs(cur-tar)<0.00001 then
        return tar
    else
        local delta=(tar-cur)*0.02
        return cur+delta
    end
end
function stage1_bg:init()
    --print("stage1_bg:init-1")
    background.init(self,false)
    --print("stage1_bg:init")
    LoadImageFromFile("s1_ocean",dir.."gzz6bg2.png")
    SetImageState("s1_ocean","mul+add",Color(190,160,160,160))
    LoadImageFromFile("s1_ripple",dir.."gzz6bg3.png")
    SetImageState("s1_ripple","mul+add",Color(80,20,160,210))
    LoadImageFromFile("s1_sora1",dir.."ocean_sora_1.png")
    SetImageState("s1_sora1","mul+add",Color(90,140,70,170))
    --LoadImageFromFile("s1_sora2",dir.."ocean_sora_2.png")
    LoadImageFromFile("s1_sora3",dir.."ocean_sora_3.png")
    SetImageState("s1_sora3","add+mul",Color(255,255,255,255))
    --LoadImageFromFile("s1_star",dir.."timg.jpg")

    self.timer=0
    
    self.l1dx=0
    self.l1dz=0

    self.l2dx=0
    self.l2dz=0

    self.l3dx=0
    self.l3dz=0

    ---! 目光朝向的实际值，attri中的是目标值
    self.etdx=0
    self.etdz=0

    self.edx=0
    self.edz=0

    Set3D("eye",attri.eye_x,attri.eye_y,attri.eye_z)
    Set3D("at",attri.eye_to_cx,0,attri.eye_to_cz)
    Set3D("up",0,0,1)
    Set3D("fovy",1)
    Set3D("z",0.1,7.0)
    Set3D("x",-7,7)
    Set3D("y",-3,3)
    Set3D("fog",1.0,1.5,Color(100,0,0,0))
end

function stage1_bg:frame()
    task.Do(self)
    self.timer=self.timer+1

    if IsValid(player) then
        attri.eye_to_dx=player.x/3000
        attri.eye_to_dz=player.y/3000
        attri.eye_dx=player.x/8000
        attri.eye_dz=player.y/8000
    end

    self.etdx=approach(self.etdx,attri.eye_to_dx)
    self.etdz=approach(self.etdz,attri.eye_to_dz)
    self.edx=approach(self.edx,attri.eye_dx)
    self.edz=approach(self.edz,attri.eye_dz)

    local cx=0.03*sin(self.timer*0.093)+attri.eye_x+self.etdx
    local cz=0.03*sin(self.timer*0.13)+attri.eye_z+self.etdz

    local cy=0.035*sin(self.timer*0.072)+attri.eye_y
    Set3D("eye",cx,cy,cz)

    local tx=0.06*sin(self.timer*0.081)+attri.eye_to_cx+self.edx
    local tz=0.06*sin(self.timer*0.121)+attri.eye_to_cz+self.edz

    Set3D("at",tx,0,tz)

    ---! 每张纹理都按长宽为1来处理
    self.l1dx=(0.0003*sin(self.timer*0.071)-0.0001*self.timer)%1-0.5
    self.l1dz=(0.0005*sin(self.timer*0.111)-0.0004*self.timer)%1-0.5

    self.l2dx=(0.0001*sin(self.timer*0.082)+0.00005*self.timer)%1-0.5
    self.l2dz=(0.0002*sin(self.timer*0.122)-0.0001*self.timer)%1-0.5

    self.l3dx=(0.0001*sin(self.timer*0.093)-0.0001*self.timer)%1-0.5
    self.l3dz=(0.0004*sin(self.timer*0.133)+0.0001*self.timer)%1-0.5

    self.l4dx=(0.0002*sin(self.timer*0.074)-0.0001*self.timer)%1-0.5
    self.l4dz=(0.0003*sin(self.timer*0.114)-0.0002*self.timer)%1-0.5
end

function stage1_bg:render()
    SetViewMode("3d")
	background.WarpEffectCapture()


    cycling("s1_ocean",self.l1dx,0,self.l1dz,1,1)
    cycling("s1_ripple",self.l2dx,0.13,self.l2dz,1,1)
    cycling("s1_sora1",self.l3dx,0.30,self.l3dz,1,1)
    cycling("s1_sora3",self.l4dx,0.21,self.l4dz,1,1)
	background.WarpEffectApply()
    SetViewMode("world")
    ---! todo:可以再加一些粒子？
end

