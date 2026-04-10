stage3_bg=Class(object)
--start:400
--measure:200
local dur_sta1 = 7280
local t_sta2 = 0 + dur_sta1
local dur_sta2 = 800
local t_sta3 = t_sta2 + dur_sta2
local dur_sta3 = 3840+2000
local t_sta4 = t_sta3 + dur_sta3
local dur_sta4 = 20000
local t_sta5 = t_sta4 + dur_sta4
--statu1:forest
--statu2:rush out forest
--statu3:rock and dark
--statu4:pyramid

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

    self.x=0
    self.y=0
    self.z=0
    
    self.gr_z=0

    self.speedx=0
    self.speedy=0
    self.speedz=0.01

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

    self.holex = -1.72
    self.holey = -1.72
    self.resetpos = false

    self.rot = 0
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
        local t = self.timer - t_sta2
        self.statu = 2
        self.speedz = 0.03
        if self.edy < -0.6 then
            self.edy = self.edy + 0.01
            self.etdy = -2 / self.edy
            if self.edy > 0 then
                self.edy = 0
                self.etdy = 1
                self.etdz = 0
            end
            Set3D('at',0,self.edy,self.edz) 
            Set3D('up',0,self.etdy,self.etdz)
        end
        if t < 100 then
            self.speedy = -(50-math.abs(t-50) + 1)*0.0002
            
        end
        if self.timer >= t_sta2 + 300 then
            Set3D("fog",0,(t_sta3 - self.timer)/33,Color(200,0,0,0))
        end
        
    elseif self.timer >= t_sta3 and self.timer <= t_sta4 then
        if not self.resetpos then
            self.x = 0
            self.y = 0
            self.z = 0
            self.resetpos = true
        end
        local t = self.timer - t_sta3
        Set3D("fog",min(t/100,1.8),min(t/30,6),Color(200,math.min(max(t-80,0),100),math.min(max(t-80,0),100),math.min(max(t-80,0),100)))
        Set3D('at',0,-0.5,1)
        Set3D('up',0,2,1)
        self.statu = 3
        self.speedz = 0
        self.speedy = -0.001
        self.speedx = -0.001
        if t > 3440 then
            self.speedx = min(0,-((800-t)/100)*0.001)
            self.speedy = min(0,-((800-t)/100)*0.001)
            self.speedz = 0.01
            Set3D('at',0,-0.5+(t-3440)/1600,1)
            Set3D('up',0,-1600/(t-4240),1)
        end
        if t > 4240 then
            Set3D('at',0,0,1)
            Set3D('up',0,1,0)
            self.speedz = 0.008
        end
        if t > 5000 then
            Set3D("fog",0,0,Color(255,0,0,0))
        end
        self.holex = self.holex-self.speedx
        self.holey = self.holey-self.speedy
        --print(self.x..' '..self.y)
        --print("holex:"..self.holex.."holey"..self.holey)
    elseif self.timer >= t_sta4 and self.timer <= t_sta5 then
        Set3D('eye',0,0,-1)
        local t = self.timer - t_sta4
        Set3D('at',0,0,1) 
        Set3D('up',0,1,0)
        Set3D("fog",0,t/500,Color(200,0,0,0))
        self.statu = 4
        local t = self.timer - t_sta3
        self.speedz = 0
        self.speedy = 0
        self.speedx = 0
        self.rot = math.mod(self.rot + 0.01,math.pi/2)
    end
    
    self.x=self.x+self.speedx
    self.y=self.y+self.speedy
	self.z=self.z+self.speedz
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
local function draw_pyramid(vertex,h,w,rot)
    local radiu = math.sqrt(2)*(w/2)
    local p1 = {(vertex[1]+radiu*math.cos(rot)),(vertex[2]-(h/2)),(vertex[3]+radiu*math.sin(rot))}
    local P1 = {(vertex[1]+2*radiu*math.cos(rot)),(vertex[2]-h),(vertex[3]+2*radiu*math.sin(rot))}
    local p2 = {(vertex[1]-radiu*math.sin(rot)),(vertex[2]-(h/2)),(vertex[3]+radiu*math.cos(rot))}
    local P2 = {(vertex[1]-2*radiu*math.sin(rot)),(vertex[2]-h),(vertex[3]+2*radiu*math.cos(rot))}
    local p3 = {(vertex[1]-radiu*math.cos(rot)),(vertex[2]-(h/2)),(vertex[3]-radiu*math.sin(rot))}
    local P3 = {(vertex[1]-2*radiu*math.cos(rot)),(vertex[2]-h),(vertex[3]-2*radiu*math.sin(rot))}
    local p4 = {(vertex[1]+radiu*math.sin(rot)),(vertex[2]-(h/2)),(vertex[3]-radiu*math.cos(rot))}
    local P4 = {(vertex[1]+2*radiu*math.sin(rot)),(vertex[2]-h),(vertex[3]-2*radiu*math.cos(rot))}
    local p = {p1,p2,p3,p4}
    local P = {P1,P2,P3,P4}
    local v_ = {}
    local v = {}
    local itable = {1,2,4,3}
    for _,i in ipairs(itable) do
        
        local other_p_i = i%4+1
        -- print(i)
        -- print(other_p_i)
        RenderTexture("pyramid",'',{vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
                                {vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
                                {p[i][1],p[i][2],p[i][3],0,512,Color(255,255,255,255)},--p[1]
                                {p[other_p_i][1],p[other_p_i][2],p[other_p_i][3],512,512,Color(255,255,255,255)})--p2
        --右减左
        v_ = {p[other_p_i][1]-p[i][1],p[other_p_i][3]-p[i][3]}
        v = {v_[2]/(v_[2]^2+v_[1]^2),-v_[1]/(v_[2]^2+v_[1]^2)}
                                
        RenderTexture("pyramid",'',{p[i][1],p[i][2],p[i][3],0,0,Color(255,255,255,255)},
                                {p[other_p_i][1],p[other_p_i][2],p[other_p_i][3],512,0,Color(255,255,255,255)},
                                {p[other_p_i][1]+v[1]*w/2,(vertex[2]-h),p[other_p_i][3]+v[2]*w/2,512,512,Color(255,255,255,255)},
                                {p[i][1]+v[1]*w/2,(vertex[2]-h),p[i][3]+v[2]*w/2,0,512,Color(255,255,255,255)})
        RenderTexture("pyramid",'',{p[i][1],p[i][2],p[i][3],512,0,Color(255,255,255,255)},
                                {p[i][1],p[i][2],p[i][3],512,0,Color(255,255,255,255)},
                                {p[i][1]+v[1]*w/2,(vertex[2]-h),p[i][3]+v[2]*w/2,512,512,Color(255,255,255,255)},
                                {P[i][1],(vertex[2]-h),P[i][3],256,512,Color(255,255,255,255)})
        RenderTexture("pyramid",'',{p[other_p_i][1],p[other_p_i][2],p[other_p_i][3],0,0,Color(255,255,255,255)},
                                {p[other_p_i][1],p[other_p_i][2],p[other_p_i][3],0,0,Color(255,255,255,255)},
                                {p[other_p_i][1]+v[1]*w/2,(vertex[2]-h),p[other_p_i][3]+v[2]*w/2,0,512,Color(255,255,255,255)},
                                {P[other_p_i][1],(vertex[2]-h),P[other_p_i][3],256,512,Color(255,255,255,255)})
    end
    --print("_______________________________________")



    -- RenderTexture("pyramid",'',{vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
    --                            {vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
    --                            {p3[1],p3[2],p3[3],512,512,Color(255,255,255,255)},--p3
    --                            {p2[1],p2[2],p2[3],0,512,Color(255,255,255,255)})--p2


    -- RenderTexture("pyramid",'',{vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
    --                            {vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
    --                            {(vertex[1]+radiu*math.sin(rot)),(vertex[2]-(h/2)),(vertex[3]-radiu*math.cos(rot)),0,512,Color(255,255,255,255)},--p4
    --                            {(vertex[1]+radiu*math.cos(rot)),(vertex[2]-(h/2)),(vertex[3]+radiu*math.sin(rot)),512,512,Color(255,255,255,255)})--p1


    -- RenderTexture("pyramid",'',{vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
    --                            {vertex[1],vertex[2],vertex[3],256,0,Color(255,255,255,255)},
    --                            {(vertex[1]-radiu*math.cos(rot)),(vertex[2]-(h/2)),(vertex[3]-radiu*math.sin(rot)),0,512,Color(255,255,255,255)},--p3
    --                            {(vertex[1]+radiu*math.sin(rot)),(vertex[2]-(h/2)),(vertex[3]-radiu*math.cos(rot)),512,512,Color(255,255,255,255)})--p4
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
                -- print(dx)
                dx = (math.random() - 0.5)*1.5
            end
            -- print(dx)
            -- print("end")
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
                -- print(dx)
                dx = (math.random() - 0.5)*1.5
            end
            -- print(dx)
            -- print("end")
            table.insert(self.tree1dx,dx)
            table.remove(self.tree1dx,1)
            self.dzr = self.dzr + 1
        end

        draw_tree1(self.tree1dx,dy,dz,self.tree1num-1,self.tree1itv)
    end
    if statu == 3 then
        local dx=-math.mod(self.x,1)+0.28
        local dy=-math.mod(self.y,1)+0.28
        local dz=-self.z
        local x_off = -5
        for i = 0,10  do
            local y_off = -3
            for j = 0,6 do
                Render4V("rock", x_off-0.5+dx, y_off+0.5+dy, 2+dz,
                                x_off+0.5+dx, y_off+0.5+dy, 2+dz,
                                x_off+0.5+dx, y_off-0.5+dy, 2+dz,
                                x_off-0.5+dx, y_off-0.5+dy, 2+dz)
                y_off = y_off + 1
            end
            x_off = x_off + 1
        end
        Render4V("rock_door", -0.5+self.holex,0.5+self.holey, 2+dz,
                        0.5+self.holex, 0.5+self.holey, 2+dz,
                        0.5+self.holex, -0.5+self.holey, 2+dz,
                        -0.5+self.holex, -0.5+self.holey, 2+dz)
        -- print(dx)
        -- print("door_x:"..self.holex.."door_y"..self.holey)
    end
    if statu == 4 then
        draw_pyramid({0,0.5,1.5},1.2,1,self.rot)
    end

	background.WarpEffectApply()
    SetViewMode("world")

end