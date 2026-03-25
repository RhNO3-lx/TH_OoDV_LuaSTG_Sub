-- 代码来自复刻统领liu_10_mc，侵删
-- 修改版扭曲效果系统，支持颜色和扭曲力度渐变

local tex_name = "Trestone_Distortion_texture"
CreateRenderTarget(tex_name)

local cut = 16
local min_radius = 16
local const_expand = 20
local const_expand_r = 16
local phasex = 180
local phasey = 90
local phasex_i = 90
local phasey_i = 45
local blow_rangeX = 10
local blow_rangeY = -10
local phase_speedX = 10
local phase_speedY = 5

local canvas_w, canvas_h = 640, 480

local _w = lstg.world.r - lstg.world.l
local _h = lstg.world.t - lstg.world.b
local _w1, _h1 = _w * screen.scale, _h * screen.scale

-- 渲染目标管理类
local _ObjPushTS = Class(object)
local _ObjPopTS = Class(object)

function _ObjPushTS:init(layer_A)
    self.layer = layer_A
    self.group = GROUP_GHOST
end

function _ObjPushTS:render()
    PushRenderTarget(tex_name)
    RenderClear(Color(0, 0, 0, 0))
end

local function _DrawTextureTS()
    local _iro = Color(255, 255, 255, 255)
    local bx, by = lstg.world.scrl * screen.scale + screen.dx, 
                   (canvas_h - lstg.world.scrt) * screen.scale + screen.dy
    RenderTexture(tex_name, "one",
        {lstg.world.l, lstg.world.t, 0.5, bx + 0, by + 0, _iro},
        {lstg.world.l + _w, lstg.world.t, 0.5, bx + _w1, by + 0, _iro},
        {lstg.world.l + _w, lstg.world.t - _h, 0.5, bx + _w1, by + _h1, _iro},
        {lstg.world.l, lstg.world.t - _h, 0.5, bx + 0, by + _h1, _iro}
    )
end

function _ObjPopTS:init(layer_A, layer_B)
    self.layer = layer_B
    self.group = GROUP_GHOST
    self.servant = New(_ObjPushTS, layer_A)
end

function _ObjPopTS:render()
    PopRenderTarget()
    _DrawTextureTS()
end

function Trestone_Distortion_CaptureAndDraw(a, b)
    New(_ObjPopTS, a, b)
end

-- 预计算网格数据
local distortion_mesh = {}
local function init_distortion_mesh_TS()
    for j = 1, cut do
        for i = 1, cut do
            local index = (j-1)*cut + i
            local x1 = -min_radius + ((min_radius*2)/cut)*(i-1)
            local y1 = min_radius - ((min_radius*2)/cut)*(j-1)
            local x2 = -min_radius + ((min_radius*2)/cut)*(i)
            local y2 = min_radius - ((min_radius*2)/cut)*(j-1)
            local x3 = -min_radius + ((min_radius*2)/cut)*(i)
            local y3 = min_radius - ((min_radius*2)/cut)*(j)
            local x4 = -min_radius + ((min_radius*2)/cut)*(i-1)
            local y4 = min_radius - ((min_radius*2)/cut)*(j)
            
            local unit = {
                x1 = x1, y1 = y1, z1 = 0.5,
                x2 = x2, y2 = y2, z2 = 0.5,
                x3 = x3, y3 = y3, z3 = 0.5,
                x4 = x4, y4 = y4, z4 = 0.5,
            }
            
            -- 预计算距离和角度
            unit.distance1 = Dist(0, 0, x1, y1)
            unit.distance2 = Dist(0, 0, x2, y2)
            unit.distance3 = Dist(0, 0, x3, y3)
            unit.distance4 = Dist(0, 0, x4, y4)
            
            unit.angle1 = Angle(0, 0, x1, y1)
            unit.angle2 = Angle(0, 0, x2, y2)
            unit.angle3 = Angle(0, 0, x3, y3)
            unit.angle4 = Angle(0, 0, x4, y4)
            
            unit.disx1, unit.disy1 = unit.distance1 * cos(unit.angle1), unit.distance1 * sin(unit.angle1)
            unit.disx2, unit.disy2 = unit.distance2 * cos(unit.angle2), unit.distance2 * sin(unit.angle2)
            unit.disx3, unit.disy3 = unit.distance3 * cos(unit.angle3), unit.distance3 * sin(unit.angle3)
            unit.disx4, unit.disy4 = unit.distance4 * cos(unit.angle4), unit.distance4 * sin(unit.angle4)
            
            -- 预计算比率
            unit.ratio1 = 1 - min(1, max(unit.distance1 / min_radius, 0))
            unit.ratio2 = 1 - min(1, max(unit.distance2 / min_radius, 0))
            unit.ratio3 = 1 - min(1, max(unit.distance3 / min_radius, 0))
            unit.ratio4 = 1 - min(1, max(unit.distance4 / min_radius, 0))
            
            -- 预计算扩展比率
            unit.e_ratio1 = unit.distance1 > 0 and 1 - min(1, max(unit.distance1 / const_expand_r, 0))^2 or 0
            unit.e_ratio2 = unit.distance2 > 0 and 1 - min(1, max(unit.distance2 / const_expand_r, 0))^2 or 0
            unit.e_ratio3 = unit.distance3 > 0 and 1 - min(1, max(unit.distance3 / const_expand_r, 0))^2 or 0
            unit.e_ratio4 = unit.distance4 > 0 and 1 - min(1, max(unit.distance4 / const_expand_r, 0))^2 or 0
            
            -- 预计算相位
            unit.phasex1 = phasex + phasex_i*((j-1)*16 + i - 1)
            unit.phasex2 = phasex + phasex_i*(j*16 + i)
            unit.phasey1 = phasey + phasey_i*((j-1)*16 + i - 1)
            unit.phasey2 = phasey + phasey_i*(j*16 + i)
            
            -- 预计算UV坐标
            unit.u1, unit.v1 = x1 * screen.scale, -y1 * screen.scale
            unit.u2, unit.v2 = x2 * screen.scale, -y2 * screen.scale
            unit.u3, unit.v3 = x3 * screen.scale, -y3 * screen.scale
            unit.u4, unit.v4 = x4 * screen.scale, -y4 * screen.scale
            
            -- 预计算透明度比率
            unit.aratio1 = unit.distance1 >= min_radius and 0 or 1
            unit.aratio2 = unit.distance2 >= min_radius and 0 or 1
            unit.aratio3 = unit.distance3 >= min_radius and 0 or 1
            unit.aratio4 = unit.distance4 >= min_radius and 0 or 1
            
            -- 预计算颜色比率
            local dist_ratio1 = min(1, max(unit.distance1 / min_radius, 0))
            local dist_ratio2 = min(1, max(unit.distance2 / min_radius, 0))
            local dist_ratio3 = min(1, max(unit.distance3 / min_radius, 0))
            local dist_ratio4 = min(1, max(unit.distance4 / min_radius, 0))
            
            unit.cratio1 = 1 - dist_ratio1^2
            unit.cratio2 = 1 - dist_ratio2^2
            unit.cratio3 = 1 - dist_ratio3^2
            unit.cratio4 = 1 - dist_ratio4^2
            
            distortion_mesh[index] = unit
        end
    end
end

-- 初始化网格数据
init_distortion_mesh_TS()

-- 世界坐标到UV转换函数
local function TSWorldToUv(x, y)
    local bx, by = lstg.world.scrl * screen.scale + screen.dx, 
                   (canvas_h - lstg.world.scrt) * screen.scale + screen.dy
    return x * screen.scale + (bx + _w1 * 0.5), -y * screen.scale + (by + _h1 * 0.5)
end

-- 扭曲效果对象类
SA_ObjDistortion = Class(object)

function SA_ObjDistortion:init(target, _radius, layer, A, R, G, B, duration)
    self.layer = layer or LAYER_BG + 1
    self.target_color = {A or 255, R or 255, G or 0, B or 0}  -- 目标颜色
    self.start_color = {255, 255, 255, 255}  -- 起始颜色（纯白）
    self.current_color = {255, 255, 255, 255}  -- 当前颜色
    self.group = GROUP_GHOST
    self.target = target
    self.radius = _radius
    self.count = 0
    self.bound = false
    self.size_factor = 0  -- 从0开始
    self.x = target.x or 0
    self.y = target.y or 0
    self.uvx, self.uvy = TSWorldToUv(0, 0)
    self.mesh = distortion_mesh
    self.mesh_unit = self.mesh[1]
    self.distclose_frames = 0
    
    -- 渐变控制参数
    self.duration = duration or 240  -- 颜色和扭曲渐变持续时间（帧）
    self.progress = 0  -- 渐变进度（0-1）
    
    -- 扭曲强度控制
    self.base_blow_rangeX = blow_rangeX
    self.base_blow_rangeY = blow_rangeY
    self.current_blow_rangeX = 0  -- 从0开始
    self.current_blow_rangeY = 0  -- 从0开始
end

function SA_ObjDistortion:frame()
    self.count = self.count + 1

    if not IsValid(self.target) then
        Del(self)
        return
    end

    -- 更新位置
    self.x, self.y = self.target.x, self.target.y
    self.uvx, self.uvy = TSWorldToUv(self.x, self.y)

    -- 检测是否需要启动淡出
    if self.target.distclose and self.distclose_frames == 0 then
        self.distclose_frames = 60  -- 启动60帧淡出
    end

    if self.distclose_frames > 0 then
        self.distclose_frames = self.distclose_frames - 1
        local close_progress = 1 - (self.distclose_frames / 60)  -- 0 → 1

        local base_alpha = self.target_color[1] * sin(self.progress)  -- 正常渐变结束时的 Alpha
        self.current_color[1] = base_alpha * (1 - close_progress)  -- 淡出 Alpha

        -- 扭曲强度归零
        self.current_blow_rangeX = self.base_blow_rangeX * sin(self.progress) * (1 - close_progress)
        self.current_blow_rangeY = self.base_blow_rangeY * sin(self.progress) * (1 - close_progress)

        -- 半径从当前大小缩到 0
        self.size_factor = (self.radius / min_radius) * sin(self.progress) * (1 - close_progress)

        if self.distclose_frames <= 0 then
            Del(self)
            return
        end
    else
        self.progress = min(90, self.progress + 90 / self.duration)

        -- 颜色渐变
        self.current_color[1] = self.start_color[1] + (self.target_color[1] - self.start_color[1]) * sin(self.progress)  -- A
        self.current_color[2] = self.start_color[2] + (self.target_color[2] - self.start_color[2]) * sin(self.progress)  -- R
        self.current_color[3] = self.start_color[3] + (self.target_color[3] - self.start_color[3]) * sin(self.progress)  -- G
        self.current_color[4] = self.start_color[4] + (self.target_color[4] - self.start_color[4]) * sin(self.progress)  -- B

        -- 扭曲强度渐变
        self.current_blow_rangeX = self.base_blow_rangeX * sin(self.progress)
        self.current_blow_rangeY = self.base_blow_rangeY * sin(self.progress)

        -- 半径渐变
        self.size_factor = (self.radius / min_radius) * sin(self.progress)
    end
end

local k = 0.5

function SA_ObjDistortion:render()
    local size_factor = self.size_factor
    local x, y = self.x, self.y
    local count = self.count
    local uvx, uvy = self.uvx, self.uvy
    local color = self.current_color  -- 使用渐变后的颜色
    local blow_rangeX_current = self.current_blow_rangeX  -- 使用渐变后的扭曲强度
    local blow_rangeY_current = self.current_blow_rangeY
    
    for j = 1, cut do
        for i = 1, cut do
            local index = (j-1)*cut + i
            local muni = self.mesh[index]
            
            -- 计算扭曲偏移（使用渐变后的强度）
            local m1 = blow_rangeX_current * cos(muni.phasex1 + phase_speedX * count)
            local m2 = blow_rangeX_current * cos(muni.phasex2 + phase_speedX * count)
            local m3 = blow_rangeY_current * sin(muni.phasey1 + phase_speedY * count)
            local m4 = blow_rangeY_current * sin(muni.phasey2 + phase_speedY * count)
            
            -- 计算顶点位置
            local px1 = muni.x1 * size_factor + x + m1 * muni.ratio1 + muni.disx1 * size_factor * muni.ratio1 * muni.ratio1 * k + const_expand * muni.e_ratio1 * cos(muni.angle1)
            local py1 = muni.y1 * size_factor + y + m3 * muni.ratio1 + muni.disy1 * size_factor * muni.ratio1 * muni.ratio1 * k + const_expand * muni.e_ratio1 * sin(muni.angle1)
            
            local px2 = muni.x2 * size_factor + x + m2 * muni.ratio2 + muni.disx2 * size_factor * muni.ratio2 * muni.ratio2 * k + const_expand * muni.e_ratio2 * cos(muni.angle2)
            local py2 = muni.y2 * size_factor + y + m4 * muni.ratio2 + muni.disy2 * size_factor * muni.ratio2 * muni.ratio2 * k + const_expand * muni.e_ratio2 * sin(muni.angle2)
            
            local px3 = muni.x3 * size_factor + x + m2 * muni.ratio3 + muni.disx3 * size_factor * muni.ratio3 * muni.ratio3 * k + const_expand * muni.e_ratio3 * cos(muni.angle3)
            local py3 = muni.y3 * size_factor + y + m4 * muni.ratio3 + muni.disy3 * size_factor * muni.ratio3 * muni.ratio3 * k + const_expand * muni.e_ratio3 * sin(muni.angle3)
            
            local px4 = muni.x4 * size_factor + x + m1 * muni.ratio4 + muni.disx4 * size_factor * muni.ratio4 * muni.ratio4 * k + const_expand * muni.e_ratio4 * cos(muni.angle4)
            local py4 = muni.y4 * size_factor + y + m3 * muni.ratio4 + muni.disy4 * size_factor * muni.ratio4 * muni.ratio4 * k + const_expand * muni.e_ratio4 * sin(muni.angle4)
            
            -- 计算颜色（使用渐变后的颜色）
            local c1 = Color(color[1] * muni.aratio1, 
                            255 + (color[2] - 255) * muni.cratio1, 
                            255 + (color[3] - 255) * muni.cratio1, 
                            255 + (color[4] - 255) * muni.cratio1)
            local c2 = Color(color[1] * muni.aratio2, 
                            255 + (color[2] - 255) * muni.cratio2, 
                            255 + (color[3] - 255) * muni.cratio2, 
                            255 + (color[4] - 255) * muni.cratio2)
            local c3 = Color(color[1] * muni.aratio3, 
                            255 + (color[2] - 255) * muni.cratio3, 
                            255 + (color[3] - 255) * muni.cratio3, 
                            255 + (color[4] - 255) * muni.cratio3)
            local c4 = Color(color[1] * muni.aratio4, 
                            255 + (color[2] - 255) * muni.cratio4, 
                            255 + (color[3] - 255) * muni.cratio4, 
                            255 + (color[4] - 255) * muni.cratio4)
            
            -- 渲染纹理
            RenderTexture(tex_name, "mul+alpha",
                {px1, py1, muni.z1, muni.u1 * size_factor + uvx, muni.v1 * size_factor + uvy, c1},
                {px2, py2, muni.z2, muni.u2 * size_factor + uvx, muni.v2 * size_factor + uvy, c2},
                {px3, py3, muni.z3, muni.u3 * size_factor + uvx, muni.v3 * size_factor + uvy, c3},
                {px4, py4, muni.z4, muni.u4 * size_factor + uvx, muni.v4 * size_factor + uvy, c4}
            )
        end
    end
end

-- 应用扭曲效果的函数（支持渐变持续时间参数）
function Trestone_Distortion_Apply(target, _radius, layer, A, R, G, B, duration)
    target.distortion = New(SA_ObjDistortion, target, _radius, layer, A, R, G, B, duration)
end

-- 获取渐变进度信息
function Trestone_Distortion_GetProgress(distortion_obj)
    if IsValid(distortion_obj) then
        return distortion_obj.progress
    end
    return 0
end

-- 性能统计
function Trestone_Distortion_GetStats()
    return {
        mesh_size = #distortion_mesh,
        cut = cut,
        min_radius = min_radius
    }
end