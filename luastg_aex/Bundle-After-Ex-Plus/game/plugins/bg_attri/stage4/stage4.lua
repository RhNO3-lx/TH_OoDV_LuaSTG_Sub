stage4a_bg=Class(object)

Stage4Mode={}
Stage4Mode.Normal=1
Stage4Mode.BentHorizonal=2
Stage4Mode.BentVertical=3
Stage4Mode.Finish=4

Stage4Mode.length=0.3
Stage4Mode.radius=0.096

local dir="stage4/"

---默认背景向后移动，即与dir_at相反的方向
---约定用于渲染的图片是512*512的，否则请自行去最后的渲染循环中修改参数
---@param img string 图片名
---@param c table cx,cy,cz
---@param dir_at table at_x,at_y,at_z
---@param dir_top table up_x,up_y,up_z
---@param tim number 0~1
local function RenderChannel(img,c,dir_at,dir_top,tim,co,blend,r)
    --计算up与at的叉乘
    local up_cross_at={dir_top[2]*dir_at[3]-dir_top[3]*dir_at[2],dir_top[3]*dir_at[1]-dir_top[1]*dir_at[3],dir_top[1]*dir_at[2]-dir_top[2]*dir_at[1]}
    --print("up_cross_at")
    -- --for k,v in pairs(up_cross_at) do
    --     print(v)
    --     end
    -- print("up")
    -- for k,v in pairs(dir_top) do
    --     print(v)
    -- end
    -- print("at")
    -- for k,v in pairs(dir_at) do
    --     print(v)
    -- end
    --共有参数
    local r= r or Stage4Mode.radius
    local l=Stage4Mode.length
    co=co or Color(255,255,255,255)
    blend=blend or "mul+alpha"
    --计算通道起始的4四个顶点
    local v={{c[1]+r*(up_cross_at[1]+dir_top[1]),c[2]+r*(up_cross_at[2]+dir_top[2]),c[3]+r*(up_cross_at[3]+dir_top[3])},
            {c[1]+r*(up_cross_at[1]-dir_top[1]),c[2]+r*(up_cross_at[2]-dir_top[2]),c[3]+r*(up_cross_at[3]-dir_top[3])},
            {c[1]+r*(-up_cross_at[1]-dir_top[1]),c[2]+r*(-up_cross_at[2]-dir_top[2]),c[3]+r*(-up_cross_at[3]-dir_top[3])},
            {c[1]+r*(-up_cross_at[1]+dir_top[1]),c[2]+r*(-up_cross_at[2]+dir_top[2]),c[3]+r*(-up_cross_at[3]+dir_top[3])}}
    -- print("-----")
    -- for k,val in pairs(v) do
    --     print("v["..k.."]="..val[1]..","..val[2]..","..val[3])
    -- end
    --测试：先按照这组参数画个静态的通道
    local sr={0,1,tim,(tim+0.5)%1}--分割成三段的比例因子
    table.sort(sr)

    -- print("----")
    -- print("sr(after sort):"..""..sr[1]..","..sr[2]..","..sr[3]..","..sr[4])
    local ltex,wtex=GetImageSize(img)
    local lr={sr[1]*l,sr[2]*l,sr[3]*l,sr[4]*l}--三维坐标系下的长度
    local ur={{ltex*(1-(sr[2]-sr[1])*2),ltex},--前段保留图像的后半截
                {0,ltex},--中段的全保留
                {0,(sr[4]-sr[3])*2*ltex}}--后段保留图像的前半截，后端点理论上来说等于第一个table的前端点
    for i=1,4 do
        local next=i%4+1
        for j=1,3 do
            local v4={{v[i][1]+lr[j]*dir_at[1] , v[i][2]+lr[j]*dir_at[2] , v[i][3]+lr[j]*dir_at[3] , ur[j][1],wtex,co},
                    {v[next][1]+lr[j]*dir_at[1], v[next][2]+lr[j]*dir_at[2], v[next][3]+lr[j]*dir_at[3], ur[j][1],0,co},
                    {v[next][1]+lr[j+1]*dir_at[1], v[next][2]+lr[j+1]*dir_at[2], v[next][3]+lr[j+1]*dir_at[3], ur[j][2],0,co},
                    {v[i][1]+lr[j+1]*dir_at[1] , v[i][2]+lr[j+1]*dir_at[2] , v[i][3]+lr[j+1]*dir_at[3] , ur[j][2],wtex,co}}
            RenderTexture(img,blend,v4[1],v4[2],v4[3],v4[4])    
        end
        
    end

    -- --把通道的尽头包住

    -- local v4={{v[1][1]+l*dir_at[1] , v[1][2]+l*dir_at[2] , v[1][3]+l*dir_at[3] , 0,0,co},
    --         {v[2][1]+l*dir_at[1], v[2][2]+l*dir_at[2], v[2][3]+l*dir_at[3], ltex,0,co},
    --         {v[2][1]+l*dir_at[1], v[2][2]+l*dir_at[2], v[2][3]+l*dir_at[3], ltex,ltex,co},
    --         {v[1][1]+l*dir_at[1] , v[1][2]+l*dir_at[2] , v[1][3]+l*dir_at[3] , 0,ltex,co}}
    -- RenderTexture(img,blend,v4[1],v4[2],v4[3],v4[4])    
    
end

---把道路尽头的地方包住，方向朝左，top正对自己
---@param img string 图片名
---@param c table cx,cy,cz
---@param dir_at table at_x,at_y,at_z
---@param dir_top table up_x,up_y,up_z
---@param tim number 0~1
local function RenderChannelHalf(img,c,dir_at,dir_top,tim,co,blend,r,mode)
    --计算up与at的叉乘
    local up_cross_at={dir_top[2]*dir_at[3]-dir_top[3]*dir_at[2],dir_top[3]*dir_at[1]-dir_top[1]*dir_at[3],dir_top[1]*dir_at[2]-dir_top[2]*dir_at[1]}
    --print("up_cross_at")
    -- --for k,v in pairs(up_cross_at) do
    --     print(v)
    --     end
    -- print("up")
    -- for k,v in pairs(dir_top) do
    --     print(v)
    -- end
    -- print("at")
    -- for k,v in pairs(dir_at) do
    --     print(v)
    -- end
    --共有参数
    mode=mode or 1
    local r= r or Stage4Mode.radius
    local l=Stage4Mode.length
    co=co or Color(255,255,255,255)
    blend=blend or "mul+alpha"
    --计算通道起始的4四个顶点
    local v={{c[1]+r*(up_cross_at[1]+dir_top[1]),c[2]+r*(up_cross_at[2]+dir_top[2]),c[3]+r*(up_cross_at[3]+dir_top[3])},
            {c[1]+r*(up_cross_at[1]-dir_top[1]),c[2]+r*(up_cross_at[2]-dir_top[2]),c[3]+r*(up_cross_at[3]-dir_top[3])},
            {c[1]+r*(-up_cross_at[1]-dir_top[1]),c[2]+r*(-up_cross_at[2]-dir_top[2]),c[3]+r*(-up_cross_at[3]-dir_top[3])},
            {c[1]+r*(-up_cross_at[1]+dir_top[1]),c[2]+r*(-up_cross_at[2]+dir_top[2]),c[3]+r*(-up_cross_at[3]+dir_top[3])}}
    -- print("-----")
    -- for k,val in pairs(v) do
    --     print("v["..k.."]="..val[1]..","..val[2]..","..val[3])
    -- end
    --测试：先按照这组参数画个静态的通道
    local sr={0,1,tim,(tim+0.5)%1}--分割成三段的比例因子
    table.sort(sr)

    -- print("----")
    -- print("sr(after sort):"..""..sr[1]..","..sr[2]..","..sr[3]..","..sr[4])
    local ltex,wtex=GetImageSize(img)
    local lr={sr[1]*l,sr[2]*l,sr[3]*l,sr[4]*l}--三维坐标系下的长度
    local ur={{ltex*(1-(sr[2]-sr[1])*2),ltex},--前段保留图像的后半截
                {0,ltex},--中段的全保留
                {0,(sr[4]-sr[3])*2*ltex}}--后段保留图像的前半截，后端点理论上来说等于第一个table的前端点
    for i=1,3 do
        local next=i%4+1
        for j=1,3 do
            local v4={{v[i][1]+lr[j]*dir_at[1] , v[i][2]+lr[j]*dir_at[2] , v[i][3]+lr[j]*dir_at[3] , ur[j][1],wtex,co},
                    {v[next][1]+lr[j]*dir_at[1], v[next][2]+lr[j]*dir_at[2], v[next][3]+lr[j]*dir_at[3], ur[j][1],0,co},
                    {v[next][1]+lr[j+1]*dir_at[1], v[next][2]+lr[j+1]*dir_at[2], v[next][3]+lr[j+1]*dir_at[3], ur[j][2],0,co},
                    {v[i][1]+lr[j+1]*dir_at[1] , v[i][2]+lr[j+1]*dir_at[2] , v[i][3]+lr[j+1]*dir_at[3] , ur[j][2],wtex,co}}
            RenderTexture(img,blend,v4[1],v4[2],v4[3],v4[4])    
        end
        
    end
    
end

function stage4a_bg:InitView()
    local att=self.attri
    att.eye_to_theta=0 --x，z平面上，与z的夹角
    att.eye_to_phi=90 --与y的夹角

    --头顶与y轴夹角
    att.top_phi=0

    local r=Stage4Mode.radius
    local l=Stage4Mode.length
    att.c0={0,0,0}
    att.c1={-r,0,l+r}
    att.c2={ r,0,l+r}

    att.cv=0
    att.eye_to_theta=0 --x，z平面上，与z的夹角
end

function stage4a_bg:RenderBranch(Isvertical)
    local dir_at,dir_ht,dir_top,dir_at2,dir_at3,halfcoor
    local r=Stage4Mode.radius
    local att=self.attri
    if not Isvertical then
        dir_top={0,1,0}
        halfcoor={att.c0[1]+r,att.c0[2],att.c0[3]+Stage4Mode.length+r}
        dir_at={-1,0,0}
        dir_ht={0,0,-1}
        dir_at2={-1,0,0}
        dir_at3={1,0,0}
    else
        dir_top={0,0,-1}
        halfcoor={att.c0[1],att.c0[2]-r,att.c0[3]+Stage4Mode.length+r}
        dir_at={0,1,0}
        dir_ht={0,0,-1}
        dir_at2={0,1,0}
        dir_at3={0,-1,0}
    end

    -- print(halfcoor[3])
    RenderChannelHalf("stage4a_star_dark",halfcoor,dir_at,dir_ht,(-self.tim/600)%1,att.cols[1],"add+add",0.096)
    RenderChannelHalf("stage4a_star_light",halfcoor,dir_at,dir_ht,(-self.tim/900)%1,att.cols[2],"mul+add",0.096)
    RenderChannelHalf("stage4a_sora",halfcoor,dir_at,dir_ht,(-self.tim/1200)%1,att.cols[3],"mul+alpha",0.098)

    --渲染两条岔路
    RenderChannel("stage4a_star_dark",att.c1,dir_at2,dir_top,(-self.tim/600)%1,att.cols[1],"add+alpha")
    RenderChannel("stage4a_star_light",att.c1,dir_at2,dir_top,(-self.tim/900)%1,att.cols[2],"mul+add",0.096)
    RenderChannel("stage4a_sora",att.c1,dir_at2,dir_top,(-self.tim/1200)%1,att.cols[3],"mul+alpha",0.098)

    RenderChannel("stage4a_star_dark",att.c2,dir_at3,dir_top,(-self.tim/600)%1,att.cols[1],"add+alpha")
    RenderChannel("stage4a_star_light",att.c2,dir_at3,dir_top,(-self.tim/900)%1,att.cols[2],"mul+add",0.096)
    RenderChannel("stage4a_sora",att.c2,dir_at3,dir_top,(-self.tim/1200)%1,att.cols[3],"mul+alpha",0.098)
end

function stage4a_bg:ChangeColor(mode,duration)
    duration=duration or 240
    local att=self.attri
    local oc={}
    for i=1,3 do
        oc[i]=Color(att.cols[i].a,att.cols[i].r,att.cols[i].g,att.cols[i].b)
    end
    local cols={}
    if mode=="purple" then 
        cols={
            Color(255,20,0,40),
            Color(240,180,150,245),
            Color(70,220,150,220)
        }
    elseif mode=="red" then
        cols={
            Color(255,50,0,30),
            Color(240,245,150,210),
            Color(70,250,150,190)
        }
    elseif mode=="blue" then
        cols={
            Color(255,20,10,60),
            Color(240,140,170,250),
            Color(70,150,190,245)
        }
    end

    task.New(self,function()
        for i=1,duration do
            task.Wait(1)
            local lambda=0.5*(1-cos(i*180/duration))
            for j=1,3 do
                att.cols[j]=Color(oc[j].a*(1-lambda)+cols[j].a*lambda,
                                oc[j].r*(1-lambda)+cols[j].r*lambda,
                                oc[j].g*(1-lambda)+cols[j].g*lambda,
                                oc[j].b*(1-lambda)+cols[j].b*lambda)
            end
        end
    end)
end

function stage4a_bg:TurnTo(mode,target_top_phi)
    target_top_phi=target_top_phi or 0
    local att=self.attri
    local l=Stage4Mode.length
    local r=Stage4Mode.radius
    local origin_vel=self.vel
    task.New(self,function()
        if mode=="right" or mode=="left" then 
            self.mode=Stage4Mode.BentHorizonal
            att.c1={-r,0,l+r}
            att.c2={ r,0,l+r}
        else
            self.mode=Stage4Mode.BentVertical
            att.c1={0,r,l+r}
            att.c2={ 0,-r,l+r}
        end
        local dl=r
        local z0=att.c0[3]
        local z1=att.c1[3]
        local z2=att.c2[3]

        for i=1,300 do
            task.Wait(1)
            local lambda=0.5*(1-cos(i*180/300))
            att.c0[3]=z0*(1-lambda)-(Stage4Mode.length+r)*lambda
            att.c1[3]=z1*(1-lambda)
            att.c2[3]=z2*(1-lambda)

            local lambda2=0.5*(1-sin(i*180/300))
            self.vel=origin_vel*(lambda2)+(1-lambda2)*0.5
        end

        task.New(self,function()
            for i=1,240 do
                task.Wait(1)
                local lambda2=0.5*(1-sin(i*180/240))
                self.vel=origin_vel*(lambda2)+(1-lambda2)*0.5
            end
        end)
        z0=att.c0[3]
        z1=att.c1[3]
        z2=att.c2[3]
        local t=att.eye_to_theta

        local x0=att.c0[1]
        local x1=att.c1[1]
        local x2=att.c2[1]

        local y0=att.c0[2]
        local y1=att.c1[2]
        local y2=att.c2[2]

        if mode=="left" then
            for i=1,240 do
                task.Wait(1)
                local lambda=0.5*(1-cos(i*180/240))
                -- att.c0[3]=z0-1*r*lambda
                att.c0[1]=x0+r*lambda

                att.c1[1]=x1*(1-lambda)
                att.c2[1]=x2*(1-lambda)+lambda*r
                -- att.c1[3]=z1*(1-lambda)
                -- att.c2[3]=z2*(1-lambda)

                att.eye_to_theta=t*(1-lambda)+lambda*(-90)
                att.top_phi=0*(1-lambda)+lambda*(target_top_phi)
            end
        elseif mode=="right" then
            for i=1,240 do
                task.Wait(1)
                local lambda=0.5*(1-cos(i*180/240))
                -- att.c0[3]=z0-1*r*lambda
                att.c0[1]=x0-r*lambda

                att.c2[1]=x2*(1-lambda)
                att.c1[1]=x1*(1-lambda)-lambda*r
                -- att.c2[3]=z2*(1-lambda)
                -- att.c1[3]=z1*(1-lambda)

                att.eye_to_theta=t*(1-lambda)+lambda*(90)
                att.top_phi=0*(1-lambda)+lambda*(target_top_phi)
            end
        elseif mode=="up" then
            for i=1,240 do
                task.Wait(1)
                local lambda=0.5*(1-cos(i*180/240))
                -- att.c0[3]=z0-1*r*lambda
                att.c0[2]=y0-r*lambda

                att.c2[2]=y2*(1-lambda)-lambda*r
                att.c1[2]=y1*(1-lambda)+lambda*0  --目标是0
                -- att.c2[3]=z2*(1-lambda)
                -- att.c1[3]=z1*(1-lambda)

                att.eye_to_theta=t*(1-lambda)+lambda*(t+target_top_phi)
                --att.top_phi=0*(1-lambda)+lambda*(-90)
                att.eye_to_phi=90*(1-lambda)+lambda*0
            end
        elseif mode=="down" then
            for i=1,240 do
                task.Wait(1)
                local lambda=0.5*(1-cos(i*180/240))
                -- att.c0[3]=z0-1*r*lambda
                att.c0[2]=y0+r*lambda

                att.c1[2]=y1*(1-lambda)+lambda*r --撤出
                att.c2[2]=y2*(1-lambda)+lambda*0  --目标是0
                -- att.c2[3]=z2*(1-lambda)
                -- att.c1[3]=z1*(1-lambda)

                att.eye_to_theta=t*(1-lambda)+lambda*(t+target_top_phi)
                --att.top_phi=0*(1-lambda)+lambda*(-90)
                att.eye_to_phi=(90)*(1-lambda)+lambda*(180)
            end
        end
        self.mode=Stage4Mode.Normal
        stage4a_bg.InitView(self)
        -- stage4a_bg.ChangeColor(self,"red")
        self.mode=Stage4Mode.Normal
    end)
    -- task.New(self,function()
    --     if mode=="right" or mode=="left" then 
    --         self.mode=Stage4Mode.BentHorizontal
    --     else
    --         self.mode=Stage4Mode.BentVertical
    --     end

    --     target_top_phi=target_top_phi or 0
    --     local att=self.attri

    --     local r=Stage4Mode.radius
    --     local dl=r
    --     local z0=att.c0[3]
    --     local z1=att.c1[3]
    --     local z2=att.c2[3]

    --     for i=1,240 do
    --         task.Wait(1)
    --         local lambda=0.43*(1-cos(i*180/240))
    --         att.c0[3]=z0*(1-lambda)-(Stage4Mode.length+r)*lambda
    --         att.c1[3]=z1*(1-lambda)
    --         att.c2[3]=z2*(1-lambda)
    --     end

    --     z0=att.c0[3]
    --     z1=att.c1[3]
    --     z2=att.c2[3]
    --     if mode=="left" then
    --         local t=att.eye_to_theta

    --         local x0=att.c0[1]
    --         local x1=att.c1[1]
    --         local x2=att.c2[1]
    --         for i=1,240 do
    --             task.Wait(1)
    --             local lambda=0.5*(1-cos(i*180/240))
    --             -- att.c0[3]=z0-1*r*lambda
    --             att.c0[1]=x0+r*lambda

    --             att.c1[1]=x1*(1-lambda)
    --             att.c2[1]=x2*(1-lambda)+lambda*2*r
    --             att.c1[3]=z1*(1-lambda)
    --             att.c2[3]=z2*(1-lambda)

    --             att.eye_to_theta=t*(1-lambda)+lambda*(-90)
    --             att.top_phi=0*(1-lambda)+lambda*(target_top_phi)
    --         end
    --     elseif mode=="right" then
    --         local t=att.eye_to_theta

    --         local x0=att.c0[1]
    --         local x1=att.c1[1]
    --         local x2=att.c2[1]
    --         for i=1,240 do
    --             task.Wait(1)
    --             local lambda=0.5*(1-cos(i*180/240))
    --             -- att.c0[3]=z0-1*r*lambda
    --             att.c0[1]=x0+r*lambda

    --             att.c2[1]=x1*(1-lambda)
    --             att.c1[1]=x2*(1-lambda)+lambda*2*r
    --             att.c2[3]=z1*(1-lambda)
    --             att.c1[3]=z2*(1-lambda)

    --             att.eye_to_theta=t*(1-lambda)+lambda*(90)
    --             att.top_phi=0*(1-lambda)+lambda*(target_top_phi)
    --         end
    --     end


    --     self.mode=Stage4Mode.Normal
    --     stage4a_bg.InitView(self)
    --     stage4a_bg.ChangeColor(self,"red")
    --     self.mode=Stage4Mode.Normal
    -- end)
end

function stage4a_bg:Finish()
    task.New(self,function()
        self.mode=Stage4Mode.Finish
        for i=1,360 do
            task.Wait(1)
            local lambda=i/360
            -- local t=1-lambda
            -- local r=Stage4Mode.radius
            -- local l=Stage4Mode.length
            local att=self.attri
            att.bglight=lambda
            -- local li=att.bglight*255

            -- Set3D("fog",att.fogmin*t,att.fogmax,Color(255,li,li,li))
        end
        task.Wait(300)
        Del(self)
    end)
end
function stage4a_bg:init()
    --print("stage1_bg:init-1")
    background.init(self,false)

    LoadImageFromFile("stage4a_star_dark",dir.."void_background_space_outside.png")
    LoadImageFromFile("stage4a_star_light",dir.."void_background_space_inside.png")
    LoadImageFromFile("stage4a_sora",dir.."ocean_sora_1.png")
    LoadImageFromFile("stage4a_light",dir.."light.png")

    --采用这样的思路：在未遇到分叉的时候，墙壁按照与自机视线平行的方向移动
    --遇到分叉时，先使得拐弯中心移动至眼睛所在位置，然后视线方向调整

    self.attri={}
    local att=self.attri
    --这些理论上来说应该不变
    att.eye_x=0
    att.eye_y=0
    att.eye_z=0.00

    att.eye_to_theta=0 --x，z平面上，与z的夹角
    att.eye_to_phi=90 --与y的夹角

    --额外附加项
    att.eye_to_dphi=0
    att.eye_to_dtheta=0

    --头顶与y轴夹角
    att.top_phi=0

    att.cols={Color(255,20,0,40),
    Color(240,180,150,245),
    Color(70,220,150,220)}

    local r=Stage4Mode.radius
    local l=Stage4Mode.length
    --不要在别的地方修改该变量
    att.at={0,0,1}
    att.top={0,1,0}

    att.c0={0,0,0}
    att.c1={-r,0,l+r}
    att.c2={ r,0,l+r}

    att.cv=0

    att.bglight=0

    att.fogmax=0.30
    att.fogmin=0.15

    Set3D("eye",att.eye_x,att.eye_y,att.eye_z)
    Set3D("at",0,0,1)
    Set3D("up",0,1,0)
    -- Set3D("at",attri.eye_to_cx,0,attri.eye_to_cz)
    -- Set3D("up",0,0,1)
    Set3D("fovy",1.7)
    Set3D("z",0.00001,5)
    Set3D("x",-5,5)
    Set3D("y",-5,5)
    Set3D("fog",att.fogmin,att.fogmax,Color(255,0,0,0))

    self.vel=2.5 --背景移动速率的比例系数

    self.tim=0

    -- task.New(self,function()
    --     local r=Stage4Mode.radius
    --     self.mode=Stage4Mode.BentHorizonal
    --     local dl=r
    --     local z0=att.c0[3]
    --     local z1=att.c1[3]
    --     local z2=att.c2[3]

    --     for i=1,240 do
    --         task.Wait(1)
    --         local lambda=0.43*(1-cos(i*180/240))
    --         att.c0[3]=z0*(1-lambda)-(Stage4Mode.length+r)*lambda
    --         att.c1[3]=z1*(1-lambda)
    --         att.c2[3]=z2*(1-lambda)
    --     end

    --     z0=att.c0[3]
    --     z1=att.c1[3]
    --     z2=att.c2[3]
    --     local t=att.eye_to_theta

    --     local x0=att.c0[1]
    --     local x1=att.c1[1]
    --     local x2=att.c2[1]
    --     for i=1,240 do
    --         task.Wait(1)
    --         local lambda=0.5*(1-cos(i*180/240))
    --         -- att.c0[3]=z0-1*r*lambda
    --         att.c0[1]=x0+r*lambda

    --         att.c1[1]=x1*(1-lambda)
    --         att.c2[1]=x2*(1-lambda)+lambda*2*r
    --         att.c1[3]=z1*(1-lambda)
    --         att.c2[3]=z2*(1-lambda)

    --         att.eye_to_theta=t*(1-lambda)+lambda*(-90)
    --         att.top_phi=0*(1-lambda)+lambda*(-90)
    --     end
    --     self.mode=Stage4Mode.Normal
    --     stage4a_bg.InitView(self)
    --     stage4a_bg.ChangeColor(self,"red")
    --     self.mode=Stage4Mode.Normal
    -- end)

    self.mode=Stage4Mode.Normal
    
end

function stage4a_bg:frame()
    task.Do(self)
    --计算up和at的参数
    local att=self.attri
    assert(att.eye_x==0 and att.eye_y==0 ,"不要动eye的位置！")
    -- 计算视线方向
    local theta=att.eye_to_theta+att.eye_to_dtheta
    local phi=att.eye_to_phi+att.eye_to_dphi

    local cx=sin(theta)*sin(phi)
    local cy=cos(phi)
    local cz=cos(theta)*sin(phi)
    Set3D("at",cx,cy,cz)

    att.at={cx,cy,cz}
    -- print("cx,cy,cz:"..cx..","..cy..","..cz)
    -- 计算up方向
    -- 方便起见，这里默认把top按照初始分量（0,1,0）开始旋转
    -- 请不要让视线严格竖直向上或向下，否则会因为180°而崩掉
    local tp=att.top_phi
    --计算at在xz平面的投影，就是上一步算出来的cx和cz
    local top_to={cz*sin(tp),cos(tp),-cx*sin(tp)}
    --print("top_to:"..top_to[1]..","..top_to[2]..","..top_to[3])
    --正交归一化，扣除在at上的投影
    local top_to_ortho={top_to[1]-cx*top_to[1],top_to[2]-cy*top_to[2],top_to[3]-cz*top_to[3]}
    --print("toptoortho,before:"..top_to_ortho[1]..","..top_to_ortho[2]..","..top_to_ortho[3])
    local top_to_len=math.sqrt(top_to_ortho[1]*top_to_ortho[1]+top_to_ortho[2]*top_to_ortho[2]+top_to_ortho[3]*top_to_ortho[3])
    top_to_ortho[1]=top_to_ortho[1]/top_to_len
    top_to_ortho[2]=top_to_ortho[2]/top_to_len
    top_to_ortho[3]=top_to_ortho[3]/top_to_len
    -- print("toptoortho:"..top_to_ortho[1]..","..top_to_ortho[2]..","..top_to_ortho[3])
    Set3D("up",top_to_ortho[1],top_to_ortho[2],top_to_ortho[3])
    
    att.top={top_to_ortho[1],top_to_ortho[2],top_to_ortho[3]}
    -- print("att.top:"..att.top[1]..","..att.top[2]..","..att.top[3])

    

    --维护用于让背景流动的计时器
    self.tim=self.tim+1*self.vel
end

function stage4a_bg:render()

    SetViewMode("3d")
	background.WarpEffectCapture()

    local att=self.attri



    if(self.mode==Stage4Mode.BentHorizonal) then
        stage4a_bg.RenderBranch(self,false)
    elseif (self.mode==Stage4Mode.BentVertical) then
        stage4a_bg.RenderBranch(self,true)
    -- elseif (self.mode==Stage4Mode.Finish) then
    --     local r=Stage4Mode.radius
    --     local ratio=self.attri.bglight
    --     SetImageState("white","mul+alpha",Color(255,255,255,255))
    --     -- print("enter")
    --     local z=att.fogmax*(1-ratio)+0.01*ratio
    --     -- Render4V("white",-r,r,z,r,r,z,r,-r,z,-r,-r,z)
    end

    local dir_at={0,0,1}
    local dir_top={0,1,0}
    RenderChannel("stage4a_star_dark",att.c0,dir_at,dir_top,(-self.tim/600)%1,att.cols[1],"add+alpha")
    RenderChannel("stage4a_star_light",att.c0,dir_at,dir_top,(-self.tim/900)%1,att.cols[2],"mul+add",0.096)
    RenderChannel("stage4a_sora",att.c0,dir_at,dir_top,(-self.tim/1200)%1,att.cols[3],"mul+alpha",0.098)
    --Render4V("stage4a_star_dark",-1,-1,0,1,-1,0,1,-1,2,-1,-1,2)
    --local co=Color(255,255,255,255)
    --RenderTexture("stage4a_star_dark","mul+alpha",{-0.3,-0.3,0,0,0,co},{-0.3,0.3,0,0,512,co},{0.3,0.3,0.6,512,512,co},{0.3,-0.3,0.6,512,0,co})
    background.WarpEffectApply()

    if (self.mode==Stage4Mode.Finish) then
        local ratio=self.attri.bglight
        -- print("ratio:"..ratio)
        SetImageState("stage4a_light","mul+alpha",Color(255*ratio,255*ratio,255*ratio,255*ratio))
        local r=Stage4Mode.radius
        local z=att.fogmax*(1-ratio)*0.8+0.001*ratio
        -- print("enter")
        Render4V("stage4a_light",-r,r,z,r,r,z,r,-r,z,-r,-r,z)
    end
    SetViewMode("world")
    ---! todo:可以再加一些粒子？
end

--#region stage4b_bg
stage4b_bg=class(background)

---comment
---@param center table
---@param forward_dir table
---@param aside_dir table
---@param width number
---@param length number
---@param color lstg.Color
---@param tim number
---@param img string
---@param blend string
local function RenderLayer(img,blend,center,forward_dir,aside_dir,width,length,color,tim)
    --计算图像起始点
    local sp={{},{}}
    for i=1,3 do
        sp[1][i]=center[i]+aside_dir[i]*length/2
        sp[2][i]=center[i]-aside_dir[i]*length/2
    end


    --计算三段图像的起止长度
    local sr={0,1,tim,(tim+0.5)%1}--分割成三段的比例因子
    table.sort(sr)
    local l=length
    local ltex,wtex=GetImageSize(img)
    local lr={sr[1]*l,sr[2]*l,sr[3]*l,sr[4]*l}--三维坐标系下的长度
    local ur={{ltex*(1-(sr[2]-sr[1])*2),ltex},--前段保留图像的后半截
                {0,ltex},--中段的全保留
                {0,(sr[4]-sr[3])*2*ltex}}--后段保留图像的前半截，后端点理论上来说等于第一个table的前端点

    for i=1,3 do
        local r={lr[i],lr[i+1]}
        local u=ur[i]
        local v4={{sp[1][1]+forward_dir[1]*r[1],sp[1][2]+forward_dir[2]*r[1],sp[1][3]+forward_dir[3]*r[1],u[1],wtex,color},
                {sp[1][1]+forward_dir[1]*r[2],sp[1][2]+forward_dir[2]*r[2],sp[1][3]+forward_dir[3]*r[2],u[1],0,color},
                {sp[2][1]+forward_dir[1]*r[2],sp[2][2]+forward_dir[2]*r[2],sp[2][3]+forward_dir[3]*r[2],u[2],0,color},
                {sp[2][1]+forward_dir[1]*r[1],sp[2][2]+forward_dir[2]*r[1],sp[2][3]+forward_dir[3]*r[1],u[2],wtex,color},}
        RenderTexture(img,blend,v4[1],v4[2],v4[3],v4[4])
    end
end

function stage4b_bg:RenderFloor()
    local att=self.attri
    local dir_at={1,0,0}
    local dir_aside={0,0,1}
    local c0={-1,0,0.2}
    RenderLayer("stage4b_star_dark","add+alpha",c0,dir_at,dir_aside,att.width[1],att.depth[1],att.cols[1],self.tim)
    RenderLayer("stage4b_star_light","mul+add",c0,dir_at,dir_aside,att.width[2],att.depth[2],att.cols[2],self.tim)
    RenderLayer("stage4b_sora","mul+alpha",c0,dir_at,dir_aside,att.width[3],att.depth[3],att.cols[3],self.tim)

    -- RenderChannel("stage4a_star_dark",c0,dir_at,dir_top,(-self.tim/600)%1,att.cols[1],"add+alpha",att.depth[1])
    -- RenderChannel("stage4a_star_light",c0,dir_at,dir_top,(-self.tim/900)%1,att.cols[2],"mul+add",att.depth[2])
    -- RenderChannel("stage4a_sora",c0,dir_at,dir_top,(-self.tim/1200)%1,att.cols[3],"mul+alpha",att.depth[3])
end
---预留接口：变色、停转（停用着色器）
---需实现的组件：渲染相贯正四面体、着色器处理
function stage4b_bg:init()
    --print("stage1_bg:init-1")
    background.init(self,false)
    LoadImageFromFile("stage4b_star_dark",dir.."void_background_space_outside.png")
    LoadImageFromFile("stage4b_star_light",dir.."void_background_space_inside.png")
    LoadImageFromFile("stage4b_sora",dir.."ocean_sora_1.png")
    LoadImageFromFile("stage4b_light",dir.."light.png")

    self.attri={}
    local att=self.attri
    --这些理论上来说应该不变
    att.eye_x=0
    att.eye_y=0
    att.eye_z=0.00

    att.eye_to_theta=0 --x，z平面上，与z的夹角
    att.eye_to_phi=90 --与y的夹角

    att.cols={Color(255,20,0,40),
    Color(240,180,150,245),
    Color(70,220,150,220)}
    att.at={0,0,1}
    att.top={0,1,0}
    att.alpha=1

    att.fogmax=0.30
    att.fogmin=0.15

    att.depth={0.097,0.098,0.099,0.2}
    att.width={0.3,0.3,0.3,0.3}

    Set3D("eye",att.eye_x,att.eye_y,att.eye_z)
    Set3D("at",0,0,1)
    Set3D("up",0,1,0)
    -- Set3D("at",attri.eye_to_cx,0,attri.eye_to_cz)
    -- Set3D("up",0,0,1)
    Set3D("fovy",1.7)
    Set3D("z",0.00001,5)
    Set3D("x",-5,5)
    Set3D("y",-5,5)
    Set3D("fog",att.fogmin,att.fogmax,Color(255,0,0,0))

    self.tim=0
    self.dt=1
end

function stage4b_bg:frame()
    task.Do(self)
    self.tim=self.tim+self.dt
    local att=self.attri
end

function stage4b_bg:render()
    SetViewMode("3d")
    background.WarpEffectCapture()
    self:RenderFloor()
    background.WarpEffectApply()
    SetViewMode("world")
end