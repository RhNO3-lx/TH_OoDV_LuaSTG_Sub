stage4a_bg=Class(object)


local dir="stage4a/"

---默认背景向后移动，即与dir_at相反的方向
---约定用于渲染的图片是512*512的，否则请自行去最后的渲染循环中修改参数
---@param img string 图片名
---@param c table cx,cy,cz
---@param dir_at table at_x,at_y,at_z
---@param dir_top table up_x,up_y,up_z
---@param tim number 0~1
function RenderChannel(img,c,dir_at,dir_top,tim,co,blend,r)
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
    local r=0.1 or r
    local l=0.2 
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

    print("----")
    print("sr(after sort):"..""..sr[1]..","..sr[2]..","..sr[3]..","..sr[4])
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
    
    
end

function stage4a_bg:init()
    --print("stage1_bg:init-1")
    background.init(self,false)

    LoadImageFromFile("stage4a_star_dark",dir.."void_background_space_outside.png")
    LoadImageFromFile("stage4a_star_light",dir.."void_background_space_inside.png")
    LoadImageFromFile("stage4a_sora",dir.."ocean_sora_1.png")

    --采用这样的思路：在未遇到分叉的时候，墙壁按照与自机视线平行的方向移动
    --遇到分叉时，先使得拐弯中心移动至眼睛所在位置，然后视线方向调整

    self.attri={}
    local att=self.attri
    --这些理论上来说应该不变
    att.eye_x=0
    att.eye_y=0
    att.eye_z=0

    att.eye_to_theta=0 --x，z平面上，与z的夹角
    att.eye_to_phi=0 --与y的夹角

    --额外附加项
    att.eye_to_dphi=90
    att.eye_to_dtheta=0

    --头顶与y轴夹角
    att.top_phi=0

    --不要在别的地方修改该变量
    att.at={0,0,1}
    att.top={0,1,0}

    Set3D("eye",att.eye_x,att.eye_y,att.eye_z)
    Set3D("at",0,0,1)
    Set3D("up",0,1,0)
    -- Set3D("at",attri.eye_to_cx,0,attri.eye_to_cz)
    -- Set3D("up",0,0,1)
    Set3D("fovy",2)
    Set3D("z",0.01,3)
    Set3D("x",-3,3)
    Set3D("y",-3,3)
    Set3D("fog",0.05,0.25,Color(255,0,0,0))

    self.tim=0
end

function stage4a_bg:frame()
    --计算up和at的参数
    local att=self.attri
    assert(att.eye_x==0 and att.eye_y==0 and att.eye_z==0,"不要动eye的位置！")
    -- 计算视线方向
    local theta=att.eye_to_theta+att.eye_to_dtheta
    local phi=att.eye_to_phi+att.eye_to_dphi

    local cx=sin(theta)*sin(phi)
    local cy=cos(phi)
    local cz=cos(theta)*sin(phi)
    Set3D("at",cx,cy,cz)

    att.at={cx,cy,cz}
    print("cx,cy,cz:"..cx..","..cy..","..cz)
    -- 计算up方向
    -- 方便起见，这里默认把top按照初始分量（0,1,0）开始旋转
    -- 请不要让视线严格竖直向上或向下，否则会因为180°而崩掉
    local tp=att.top_phi
    --计算at在xz平面的投影，就是上一步算出来的cx和cz
    local top_to={cz*sin(tp),cos(tp),-cx*sin(tp)}
    print("top_to:"..top_to[1]..","..top_to[2]..","..top_to[3])
    --正交归一化，扣除在at上的投影
    local top_to_ortho={top_to[1]-cx*top_to[1],top_to[2]-cy*top_to[2],top_to[3]-cz*top_to[3]}
    print("toptoortho,before:"..top_to_ortho[1]..","..top_to_ortho[2]..","..top_to_ortho[3])
    local top_to_len=math.sqrt(top_to_ortho[1]*top_to_ortho[1]+top_to_ortho[2]*top_to_ortho[2]+top_to_ortho[3]*top_to_ortho[3])
    top_to_ortho[1]=top_to_ortho[1]/top_to_len
    top_to_ortho[2]=top_to_ortho[2]/top_to_len
    top_to_ortho[3]=top_to_ortho[3]/top_to_len
    print("toptoortho:"..top_to_ortho[1]..","..top_to_ortho[2]..","..top_to_ortho[3])
    Set3D("up",top_to_ortho[1],top_to_ortho[2],top_to_ortho[3])
    
    att.top={top_to_ortho[1],top_to_ortho[2],top_to_ortho[3]}
    print("att.top:"..att.top[1]..","..att.top[2]..","..att.top[3])

    task.Do(self)

    --维护用于让背景流动的计时器
    self.tim=self.tim+1
end

function stage4a_bg:render()
    SetViewMode("3d")
	background.WarpEffectCapture()
    RenderChannel("stage4a_star_dark",{0,0,0},self.attri.at,self.attri.top,(-self.tim/600)%1,Color(255,20,0,40),"add+add")
    RenderChannel("stage4a_star_light",{0,0,0},self.attri.at,self.attri.top,(-self.tim/900)%1,Color(240,180,150,245),"mul+add",0.096)
    RenderChannel("stage4a_sora",{0,0,0},self.attri.at,self.attri.top,(-self.tim/1200)%1,Color(70,220,150,220),"mul+alpha",0.098)
    --Render4V("stage4a_star_dark",-1,-1,0,1,-1,0,1,-1,2,-1,-1,2)
    local co=Color(255,255,255,255)
    --RenderTexture("stage4a_star_dark","mul+alpha",{-0.3,-0.3,0,0,0,co},{-0.3,0.3,0,0,512,co},{0.3,0.3,0.6,512,512,co},{0.3,-0.3,0.6,512,0,co})
	background.WarpEffectApply()
    SetViewMode("world")
    ---! todo:可以再加一些粒子？
end

