stage3_bg=Class(object)

local dur_sta1 = 100
local t_sta2 = 0 + dur_sta1
local dur_sta2 = 500
local t_sta3 = t_sta2 + dur_sta2
local dur_sta3 = 1000
local t_sta4 = t_sta3 + dur_sta3

function stage3_bg:init()

    --resource
    do
        LoadImageFromFile("rock","stage3/rock.png")
        LoadImageFromFile("rock_door","stage3/rock_.png")
        LoadImageFromFile("ground1","stage3/ground1.png")
        LoadImageFromFile("tree1","stage3/tree1.png")
        --SetImageState("tree1",'',Color(255,0,0,0))
        LoadImageFromFile("tree2","stage3/tree2.png")
        LoadImageFromFile("wood","stage3/wood.png")
        LoadImageFromFile("pyramid","stage3/pyramid.png")
    end
    --
    background.init(self,false)
    
    self.timer=0

    self.z=0
    self.y=0
    
    self.gr_z=0

    self.speed=0.01

    self.statu = 0

    self.etdx = 0
    self.etdy = 2
    self.etdz = 1

    self.edx=0
    self.edy=-1
    self.edz=2

    self.dzr = 0
    self.tree1itv = 0.6
    self.tree1num = 14
    self.tree1dx = {}
    for i=1,self.tree1num do
        self.tree1dx[i] = (math.random() - 0.5)*1.5
        while math.abs(self.tree1dx[i]) < 0.2 do
            self.tree1dx[i] = (math.random() - 0.5)*1.5
        end
    end

    Set3D('eye',0,0,0)
    Set3D('at',0,self.edy,self.edz) 
    Set3D('up',0,self.etdy,self.etdz)
    Set3D('z',0.1,24) 
    Set3D('fovy',0.7)
    Set3D("fog",0,6,Color(200,0,0,0))

end
function stage3_bg:frame()
    task.Do(self)
    self.timer=self.timer+1

    if self.timer >= 0 and self.timer < t_sta2 then
        self.statu = 1
    elseif self.timer >= t_sta2 and self.timer < t_sta3 then
        self.statu = 2
        self.speed = 0.03
        -- if self.edy < 0 then
        --     self.edy = self.edy + 0.01
        --     self.etdy = -2 / self.edy
        --     if self.edy > 0 then
        --         self.edy = 0
        --         self.etdy = 1
        --         self.etdz = 0
        --     end
        --     Set3D('at',0,self.edy,self.edz) 
        --     Set3D('up',0,self.etdy,self.etdz)
        -- end
        if self.y > -0.25 then
            self.y = self.y - 0.01
        end
        if self.timer >= t_sta2 + 300 then
            Set3D("fog",0,(t_sta3 - self.timer)/33,Color(200,0,0,0))
        end
        
    elseif self.timer >= t_sta3 and self.timer <= t_sta4 then
        Set3D("fog",min((self.timer-t_sta3)/100,5),min((self.timer-t_sta3)/40,6),Color(200,0,0,0))
        -- Set3D('at',0,-1,1)
        -- Set3D('up',0,1,1)
        self.statu = 3
        self.speed = 0
    end
	self.z=self.z+self.speed
end

local function draw_tree1(x,y,z,num,itv)
    for j=num,1,-1 do
        local dx = x[j]
        local dz = j*itv-z
        Render4V('wood', 0.02+dx,-0.5+y,dz,
                            -0.02+dx,-0.5+y,dz,
                            -0.02+dx,-1+y,dz,
                            0.02+dx,-1+y,dz)
        Render4V('tree1', 0.25+dx,-0.25+y,dz,
                            -0.25+dx,-0.25+y,dz,
                            -0.25+dx,-0.75+y,dz,
                            0.25+dx,-0.75+y,dz)
        Render4V('tree1', 0.175+dx,0+y,dz,
                            -0.175+dx,0+y,dz,
                            -0.175+dx,-0.5+y,dz,
                            0.175+dx,-0.5+y,dz)
    end
end

function stage3_bg:render() 
    SetViewMode("3d")
    lstg.RenderClear(Color(0,0,0,0))
    local statu = self.statu
    
	background.WarpEffectCapture()
    if statu == 1 then
        --ground
        for j=0,4 do
		local dz=j*2-math.mod(self.z,2)
		Render4V('ground1', -3,-1,dz,
                            -1,-1,dz,
                            -1,-1,-2+dz,
                            -3,-1,-2+dz)
		Render4V('ground1', -1,-1,dz,
                            1,-1,dz,
                            1,-1,-2+dz,
                            -1,-1,-2+dz)
		Render4V('ground1', 1,-1,dz,
                            3,-1,dz,
                            3,-1,-2+dz,
                            1,-1,-2+dz)
	    end
        --tree2
        for j=6,0,-1 do
		local dz=j*1.8-math.mod(self.z,1.8)
		Render4V('tree2', -0.3,0.1,dz,
                            -1.3,0.1,dz,
                            -1.3,-0.9,dz,
                            -0.3,-0.9,dz)
		Render4V('tree2', 0.3,0.1,dz,
                            1.3,0.1,dz,
                            1.3,-0.9,dz,
                            0.3,-0.9,dz)
	    end
        --tree1
        local dz=math.mod(self.z,self.tree1itv)

        while self.tree1dx[self.tree1num] == nil do
            local dx = (math.random() - 0.5)*1.5
            while math.abs(dx) < 0.2 do
                dx = (math.random() - 0.5)*1.5
            end
            table.insert(self.tree1dx,(math.random() - 0.5)*1.5)
        end
        if self.z/self.tree1itv > self.dzr then
            local dx = (math.random() - 0.5)*1.5
            while math.abs(dx) < 0.2 do
                print(dx)
                dx = (math.random() - 0.5)*1.5
            end
            print(dx)
            print("end")
            table.insert(self.tree1dx,dx)
            table.remove(self.tree1dx,1)
            self.dzr = self.dzr + 1
        end

        draw_tree1(self.tree1dx,0,dz,self.tree1num-1,self.tree1itv)
    end
    if statu == 2 then
        local dy = -self.y
        for j=0,4 do
		local dz=j*2-math.mod(self.z,2)
		Render4V('ground1', -3,-1+dy,dz,
                            -1,-1+dy,dz,
                            -1,-1+dy,-2+dz,
                            -3,-1+dy,-2+dz)
		Render4V('ground1', -1,-1+dy,dz,
                            1,-1+dy,dz,
                            1,-1+dy,-2+dz,
                            -1,-1+dy,-2+dz)
		Render4V('ground1', 1,-1+dy,dz,
                            3,-1+dy,dz,
                            3,-1+dy,-2+dz,
                            1,-1+dy,-2+dz)
	    end
        --tree2
        for j=6,0,-1 do
		local dz=j*1.8-math.mod(self.z,1.8)
		Render4V('tree2', -0.3,0.1+dy,dz,
                            -1.3,0.1+dy,dz,
                            -1.3,-0.9+dy,dz,
                            -0.3,-0.9+dy,dz)
		Render4V('tree2', 0.3,0.1+dy,dz,
                            1.3,0.1+dy,dz,
                            1.3,-0.9+dy,dz,
                            0.3,-0.9+dy,dz)
	    end

        --tree1
        local dz=math.mod(self.z,self.tree1itv)

        while self.tree1dx[self.tree1num] == nil do
            local dx = (math.random() - 0.5)*1.5
            while math.abs(dx) < 0.2 do
                dx = (math.random() - 0.5)*1.5
            end
            table.insert(self.tree1dx,(math.random() - 0.5)*1.5)
        end
        if self.z/self.tree1itv > self.dzr then
            local dx = (math.random() - 0.5)*1.5
            while math.abs(dx) < 0.2 do
                print(dx)
                dx = (math.random() - 0.5)*1.5
            end
            print(dx)
            print("end")
            table.insert(self.tree1dx,dx)
            table.remove(self.tree1dx,1)
            self.dzr = self.dzr + 1
        end

        draw_tree1(self.tree1dx,dy,dz,self.tree1num-1,self.tree1itv)
    end
    if statu == 3 then
        local x_off = -5
        for i = 0,10  do
            local y_off = -3
            for j = 0,6 do
                Render4V("rock", x_off-0.5, y_off+0.5, 3,
                                x_off+0.5, y_off+0.5, 3,
                                x_off+0.5, y_off-0.5, 3,
                                x_off-0.5, y_off-0.5, 3)
                y_off = y_off + 1
            end
            x_off = x_off + 1
        end
    end
    if statu == 4 then
        local x_off = -5
        for i = 0,10  do
            local y_off = -3
            for j = 0,6 do
                Render4V("rock", x_off-0.5, y_off+0.5, 6,
                                x_off+0.5, y_off+0.5, 6,
                                x_off+0.5, y_off-0.5, 6,
                                x_off-0.5, y_off-0.5, 6)
                y_off = y_off + 1
            end
            x_off = x_off + 1
        end
    end
	background.WarpEffectApply()
    SetViewMode("world")

end