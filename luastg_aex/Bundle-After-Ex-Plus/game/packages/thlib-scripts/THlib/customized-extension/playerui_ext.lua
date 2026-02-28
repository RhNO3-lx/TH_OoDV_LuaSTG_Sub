---! 在这里添加player ui杂项的渲染支持
---! 调用时机由编辑器内的关卡进程中决定，手动渲染player中的物体


function PutPlayerLifeBar(pl)
    local alpha1 = 0.4
    ---! 血条边框
    SetImageState("base_hp", "", Color(alpha1 * 255, 255, 0, 0))
    ---! 指示实际生命值的血条
    SetImageState("hpbar1", "", Color(alpha1 * 255, 255, 255, 255))
    ---! 衬底用的血条
    SetImageState("hpbar2", "", Color(0, 255, 255, 255))
    SetImageState("life_node", "", Color(alpha1 * 255, 255, 255, 255))
end