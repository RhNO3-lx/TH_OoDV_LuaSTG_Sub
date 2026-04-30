local post_effect=require("lib.posteffect")
local colorless_bottom=Class(object)
function colorless_bottom:init()
    self.x,self.y=0,0
    self.bound=false
    self.layer=LAYER_BG-10
    self.group=GROUP_GHOST
    self.nopause=true
    CreateRenderTarget("whole_scene")
end

function colorless_bottom:render()
    if(IsValid(player)) then
        if player.death>=90 then
            PushRenderTarget("whole_scene")
        end
    end
end
function colorless_bottom:frame()
    if(IsValid(player)) then
        if player.death>=90 then
            AddSuperPause(1)
        end
    end
end

local colorless_top=Class(object)
function colorless_top:init()
    self.x,self.y=0,0
    self.bound=false
    self.layer=LAYER_TOP+100
    self.group=GROUP_GHOST
    self.nopause=true
end

function colorless_top:render()
    if(IsValid(player)) then
        if player.death>=90 then
            PopRenderTarget()
            print("draw hsl")
            post_effect.drawHSLShiftEffect("whole_scene", 0, -0.5, -0.2)
        end
    end
end

local M={}
function M.colorless_init()
    New(colorless_bottom)
    New(colorless_top)
end

return M
