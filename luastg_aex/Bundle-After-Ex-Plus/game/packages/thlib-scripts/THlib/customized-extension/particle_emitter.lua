local M={}

M.ParticleEmitter=Class(object)

local pe=M.ParticleEmitter

---@param x number init x
---@param y number init y
---@param ps_eff string particle effect name loaded by LoadPS
---@param target object if fixed at some object, set it here
---@param blend string | nil blend mode, default is "mul+add"
---@param layer number | nil layer, default is LAYER_ENEMY_BULLET_EF+3
function pe:init(x,y,ps_eff,target,blend,layer)
    self.x=x
    self.y=y
    self.ps_eff=ps_eff   
    self.target=target
    self.BindedWithTarget=target and true or false

    self.blend=blend or "mul+add"
    self.layer=layer or LAYER_ENEMY_BULLET_EF+3

    self.DeathTimer=0
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

return M