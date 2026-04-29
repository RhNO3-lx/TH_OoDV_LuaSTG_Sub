---! here to define extra particle effects
---! by:RhNO3-lx

require("THlib.misc.misc")
ParticlePresets={}
---todo:向粒子基类中加入加速度
---todo:定义常用的粒子效果：向内收缩蓄力，向外喷溅等
ParticleEx = Class(object)
function ParticleEx:init( x, y,v,angle,omega,acc,acc_angle,life_time, img,  size, color1,  blend,layer)
    self.img = img or "parimg11"
    self.x = x
    self.y = y
    _set_a(self,acc,acc_angle,false)
    self._speed=v
    self.rot=angle
    self.omiga=omega
    
    self.group = GROUP_GHOST
    self.life_time = life_time or 120
    self.size = size or 0.4
    self.color1 = color1 or Color(0,255,255,255)
    self.layer = layer or LAYER_ENEMY_BULLET_EF+3
    self.blend = blend or 'mul+add'
end
function ParticleEx:render()
    local t = (self.life_time - self.timer) / self.life_time
    -- print("in particleex,timer is:"..self.timer)
    local size = self.size * (1-cos(t*360)/2)
    local c = self.color1 * (1-cos(t*360)/2)
    SetImageState(self.img, self.blend, c)
    Render(self.img, self.x, self.y, self.rot, size)
end
function ParticleEx:frame()
    task.Do(self)
    if self.timer == self.life_time - 1 then
        Del(self)
    end
    --self.rot=self.rot+self.omiga
end

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

function ParticlePresets.DynamicScatter(x,y,co,r,dr,tex,lifetime,size,dsize,FixedAtObj,obj,acc,v0)
    assert(IsValid(obj), "obj is not valid when parsed to ParticlePresets.StaticScatter")
    task.New(obj, function()
        local x, y = x,y

        local nr=r+ran:Float(-dr,dr)
        local a=ran:Float(0,360)

        x,y=x+nr*cos(a),y+nr*sin(a)

        local p=New(ParticleEx,x,y,v0,ran:Float(0,360),ran:Float(4,8),0,0,lifetime,tex,ran:Float(size-dsize,size+dsize),co)
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
    end)

end

