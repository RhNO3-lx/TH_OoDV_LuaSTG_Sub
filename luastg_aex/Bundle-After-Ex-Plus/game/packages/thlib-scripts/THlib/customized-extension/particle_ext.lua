local M={}
require("THlib.misc.misc")


M.ParticleEmitter=Class(object)

local pe=M.ParticleEmitter

---生成一个粒子发射器
---@param x number init x
---@param y number init y
---@param ps_eff string particle effect name loaded by LoadPS
---@param target lstg.object if fixed at some object, set it here
---@param blend string | nil blend mode, default is "mul+add"
---@param layer number | nil layer, default is LAYER_ENEMY_BULLET_EF+3
---@return ParticleEmitter
function pe.CreateParticleEmitter(x,y,ps_eff,target,blend,layer)
    return New(pe,x,y,ps_eff,target,blend,layer)
end


function pe:init(x,y,ps_eff,target,blend,layer)
    self.x=x
    self.y=y
    self.img=ps_eff   
    self.target=target
    self.BindedWithTarget=target and true or false

    self.blend=blend or "mul+add"
    self.layer=layer or LAYER_ENEMY_BULLET_EF+3
    self.group=GROUP_GHOST

    self.DeathTimer=0
    ParticleFire(self)
end

function pe:frame()
    task.Do(self)
    if self.BindedWithTarget then
        if IsValid(self.target) then
            self.x=self.target.x
            self.y=self.target.y
        else
            ParticleStop(self)
            -- self.BindedWithTarget=false
            self.DeathTimer=self.DeathTimer+1
        end
    end

    if self.DeathTimer>60 then Del(self) end
end

M.ParticlePresets={}
---todo:向粒子基类中加入加速度
---todo:定义常用的粒子效果：向内收缩蓄力，向外喷溅等
M.ParticleEx = Class(object)
local ParticleEx = M.ParticleEx
local ParticlePresets = M.ParticlePresets
function ParticleEx:init( x, y,v,angle,omega,acc,acc_angle,life_time, img,  size, color1,  blend,layer)
    self.img = img or "parimg11"
    self.x = x
    self.y = y
    _set_a(self,acc,acc_angle,false)
    SetV(self,v,angle)
    self.omiga=omega
    
    self.group = GROUP_GHOST
    self.life_time = life_time or 120
    self.size = size or 0.4
    self.color1 = color1 or Color(0,255,255,255)
    self.layer = layer or LAYER_ENEMY_BULLET_EF-3
    self.blend = blend or 'mul+add'
    self.AppearMode="fade_out"
    self.actual_size=self.size
end
function ParticleEx:render()
    -- local t = (self.life_time - self.timer) / self.life_time
    -- -- print("in particleex,timer is:"..self.timer)
    -- local size = self.size * (1-cos(t*360)/2)
    -- local c = self.color1 * (1-cos(t*360)/2)
    -- SetImageState(self.img, self.blend, c)
    Render(self.img, self.x, self.y, self.rot, self.actual_size)
end
function ParticleEx:frame()
    local t = (self.life_time - self.timer) / self.life_time
    -- print("in particleex,timer is:"..self.timer)
    if self.AppearMode=="fade_in_out" then
        self.actual_size = self.size * (1-cos(t*360)/2)
        local c = self.color1 * (1-cos(t*360)/2)
        SetImageState(self.img, self.blend, c)
    else
        self.actual_size = self.size*t
        local c = self.color1*t
        SetImageState(self.img, self.blend, c)
    end
    task.Do(self)
    if self.timer == self.life_time - 1 then
        Del(self)
    end
    --self.rot=self.rot+self.omiga
end

---功能尚不完全，不建议使用
function ParticlePresets.StaticScatter(obj,co,r,dr,tex,lifetime,size,dsize,FixedAtObj)
    assert(IsValid(obj), "obj is not valid when parsed to ParticlePresets.StaticScatter")
    task.New(obj, function()
        local x, y = obj.x, obj.y

        local nr=r+ran:Float(-dr,dr)
        local a=ran:Float(0,360)

        x,y=x+nr*cos(a),y+nr*sin(a)

        local p=New(ParticleEx,x,y,0,ran:Float(0,360),ran:Float(2,4),0,0,lifetime,tex,ran:Float(size-dsize,size+dsize),co)
        if FixedAtObj then
            task.New(p, function()
                for i=1,lifetime do
                    task.Wait(1)
                    if IsValid(obj)==false then 
                        Del(p)
                    else
                        p.x,p.y=obj.x+nr*cos(a),obj.y+nr*sin(a)
                    end
                end
            end)
        end
    end)

end

---发射单个动态的粒子
---@param x number 粒子初始位置的分布中心x
---@param y number 
---@param co lstg.Color
---@param r number 粒子初始位置距分布中心的半径
---@param dr number 粒子初始位置距分布中心的半径的随机范围，r+-dr
---@param tex string 粒子的纹理图片
---@param lifetime any
---@param size any 粒子的scale分布中心
---@param dsize any 粒子scale的波动
---@param FixedAtObj boolean 暂时不要用，有bug
---@param obj lstg。object | nil 粒子绑定到某个对象上，则该对象消失后粒子也消失，否则一直存在
---@param acc number 粒子的加速度大小
---@param v0 number 粒子初速度大小
---@param v_angle number |nil 粒子速度方向，默认纯随机
---@param acc_angle number |nil 粒子加速度方向，默认与v_angle相同
function ParticlePresets.DynamicScatter(x,y,co,r,dr,tex,lifetime,size,dsize,FixedAtObj,obj,acc,v0,v_angle,acc_angle)
    v_angle=v_angle or ran:Float(0,360)
    acc_angle=acc_angle or v_angle
    if FixedAtObj then
        assert(IsValid(obj), "obj is not valid when parsed in ParticlePresets.StaticScatter")
    end
    local x, y = x,y

    local nr=r+ran:Float(-dr,dr)
    local a=ran:Float(0,360)

    x,y=x+nr*cos(a),y+nr*sin(a)

    local p=New(ParticleEx,x,y,v0,v_angle,ran:Float(4,8),acc,acc_angle,lifetime,tex,ran:Float(size-dsize,size+dsize),co)
    if FixedAtObj then
        task.New(p, function()
            local deltaa=ran:Float(-10,10)
            local deltava=ran:Float(-30,30)
            for i=1,lifetime do
                task.Wait(1)
                if IsValid(obj)==false then 
                    Del(p)
                else
                    p._angle=Angle(p,obj)+deltava
                    _set_a(p,acc,Angle(p,obj)+deltaa,false)
                    if(Dist(p,obj)<10) then
                        Del(p)
                    end
                end
            end
        end)
    end

end

return M