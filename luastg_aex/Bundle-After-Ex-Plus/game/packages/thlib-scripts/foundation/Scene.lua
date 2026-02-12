---@class foundation.Scene
local Scene = {}

--- 该方法由 `foundation.SceneManager` 自动管理  
--- 每次创建场景实例时，都会被强制定义为返回   
--- `foundation.SceneManager.add` 时设置的 `scene_name`
---! scene callback func declared here
---! when need a new scene, these functions will br rewrote
---! in onupdate, we define the update procedure( when to call frame callbacks, collide check, etc.)
---! we can see enample of game scene in ext.lua
function Scene:getName()
    return "__default__"
end

--- 进入当前场景时会被 `foundation.SceneManager` 调用  
function Scene:onCreate()
end

--- 离开当前场景时会被 `foundation.SceneManager` 调用  
function Scene:onDestroy()
end

--- 需要更新场景时会被 `foundation.SceneManager` 调用  
function Scene:onUpdate()
end

--- 需要渲染场景时会被 `foundation.SceneManager` 调用  
function Scene:onRender()
end

--- 场景处于活跃状态时会被 `foundation.SceneManager` 调用  
--- 相当于窗口获得焦点，比如用户切换回此程序继续使用  
function Scene:onActivated()
end

--- 场景不处于活跃状态时会被 `foundation.SceneManager` 调用  
--- 相当于窗口失去焦点，比如用户切换到别的窗口  
function Scene:onDeactivated()
end

return Scene
