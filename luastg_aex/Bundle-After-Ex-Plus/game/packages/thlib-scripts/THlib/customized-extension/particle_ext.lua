---! here to define extra particle effects
---! by:RhNO3-lx

require("THlib.misc.misc")

---todo:向粒子基类中加入加速度
---todo:定义常用的粒子效果：向内收缩蓄力，向外喷溅等
ParticleEx = Class(object)
function ParticleEx:init(img, x, y, vx, vy, life_time, size1, size2, color1, color2, layer, blend)
    self.img = img
    self.x = x
    self.y = y
    self.vx = vx
    self.vy = vy
    self.group = GROUP_GHOST
    self.life_time = life_time
    self.size1 = size1
    self.size2 = size2
    self.color1 = color1
    self.color2 = color2
    self.layer = layer
    self.blend = blend or ''
end
function ParticleEx:render()
    local t = (self.life_time - self.timer) / self.life_time
    local size = self.size1 * t + self.size2 * (1 - t)
    local c = self.color1 * t + self.color2 * (1 - t)
    SetImageState(self.img, self.blend, c)
    Render(self.img, self.x, self.y, 0, size)
end
function ParticleEx:frame()
    if self.timer == self.life_time - 1 then
        Del(self)
    end
end