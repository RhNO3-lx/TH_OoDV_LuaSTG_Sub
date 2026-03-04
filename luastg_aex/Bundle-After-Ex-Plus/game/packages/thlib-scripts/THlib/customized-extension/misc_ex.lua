---! 定义各种有用的小工具
misc_ex = {}

---! 用途：辅助各类丝滑的变化
---@param cur number 当前值
---@param tar number 目标值
---@param speed number|nil 每帧变化量占当前差值的比例，默认为0.02
---@return number 目标值经过一帧之后的大小，注意接住
function misc_ex.approach(cur,tar,speed)
    speed=speed or 0.02
    if abs(cur-tar)<0.00001 then
        return tar
    else
        local delta=(tar-cur)*speed
        return cur+delta
    end
end