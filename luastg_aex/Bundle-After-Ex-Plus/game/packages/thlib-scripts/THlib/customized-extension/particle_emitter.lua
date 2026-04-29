local M={}

M.ParticleEmitter=Class(object)

local pe=M.ParticleEmitter

function pe:init(x,y,tex,eff,blend,layer)
    self.x=x
    self.y=y
    self.tex=tex or "parimg11"
    
    self.blend=blend or "mul+add"
    self.layer=layer or LAYER_ENEMY_BULLET_EF+3
end
