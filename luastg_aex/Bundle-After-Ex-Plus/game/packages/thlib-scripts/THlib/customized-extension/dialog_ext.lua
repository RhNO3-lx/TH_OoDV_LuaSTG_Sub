DialogDisplayer=Class(object)
ContinueHinter=Class(object)
---用户在创建一组对话的时候，向displayer中一次性加入若干个DialogSentence对象
---然后在DialogDisplayer中，依次激活这若干个sentence
DialogSentence=Class(object)
CharacterDisplayer=Class(object)

LoadImageFromFile("dialog_box_ext","THlib/UI/dialog.png")
SetImageScale("dialog_box_ext",0.65)

local w=lstg.world
DialogAttri={
    cy=w.scrb+60,
    cx=(w.scrl+w.scrr)/2,
    w=360,---!规定：这是文字部分的边界
    h=65
}

--#region
-- function DialogDisplayer:CreateSentence(text,color,size,font)
--     local sentence=New(DialogSentence,text,color,size,font)
--     self.CurrentSentence=sentence
-- end
---@param sentences table{{text,color,size,font,func},...}
---func 函数里可以定义与角色立绘有关的事件
function DialogDisplayer:init(sentences)
    self.img="dialog_box_ext"
    self.ShowBackground=true
    self.CharacterList={}---约定：表内字段格式："charactername","character_image"
    self.y=DialogAttri.cy ---预期纹理素材：dialog_box_ext.png,400*80
    self.x=DialogAttri.cx
    self.timer=0

    self.SentenceList=sentences
    --根据输入参数批量创建句子
    -- for i=1,#sentences do
    --     local s=sentences
    --     self.SentenceList[i]=New(DialogSentence,s[i].text,s[i].color,s[i].size,s[i].align,s[i].font)
    -- end

    assert(#sentences > 0,"至少要有一句话")
    assert(self.CharacterList~=nil,"wtf2")
    self.SentenceList[1].IsActive=true

    --print("DialogDisplayer initialized with "..#self.SentenceList.." sentences.")
    self.CurrentSentenceIndex=1

    local s=self.SentenceList[1]
    self.CurrentSentence=New(DialogSentence,s.text,s.color,s.CanSkip,s.size,s.font,s.align,s.alignv,s.lifetime)
    local f=s.func or function(self) end
    f(self)

    self.group=GROUP_GHOST
    self.layer=LAYER_TOP+18

    self.alpha=255

    ---淡入
    task.New(self,function()
        for i=1,30 do
            task.Wait(1)
            self.alpha=self.alpha+255/30
            SetImageState(self.img,"mul+alpha",Color(self.alpha,255,255,255))
        end
        self.alpha=255
        SetImageState(self.img,"mul+alpha",Color(self.alpha,255,255,255))
    end)
end

function DialogDisplayer:frame()
    task.Do(self)

    if self.CurrentSentenceIndex<#self.SentenceList then
        if not IsValid(self.CurrentSentence) then
            self.CurrentSentenceIndex=self.CurrentSentenceIndex+1
            local s=self.SentenceList[self.CurrentSentenceIndex]
            self.CurrentSentence=New(DialogSentence,s.text,s.color,s.CanSkip,s.size,s.font,s.align,s.alignv,s.lifetime)
            local f=s.func or function(self) end
            f(self)
        end
    else
        ---! 约定：当对话结束时，Displayer会自动删除自己
        if not IsValid(self.CurrentSentence) then
            task.New(self,function()
                for k,v in pairs(self.CharacterList) do
                    if IsValid(v) then
                        CharacterDisplayer.FadeOut(v)
                    end
                end
                for i=1,30 do
                    task.Wait(1)
                    self.alpha=self.alpha-255/30
                    SetImageState(self.img,"mul+alpha",Color(self.alpha,255,255,255))
                end
                self.alpha=0
                SetImageState(self.img,"mul+alpha",Color(self.alpha,255,255,255))
                Del(self)
            end)
        end
    end
end

function DialogDisplayer:render()
    SetViewMode'ui'
    Render(self.img,self.x,self.y)
    SetViewMode'world'
end

function DialogDisplayer:AddChara(self,name,img,pos,scale)
    assert(self.CharacterList~=nil,"wtf?")
    if self.CharacterList[name] then
        ---! 如果表里已经有这个角色了，那么就覆盖掉原来的立绘
        Del(self.CharacterList[name])
    end

    self.CharacterList[name]=New(CharacterDisplayer,img,pos.x,pos.y,scale)
end

function DialogDisplayer:SetCharaState(self,name,state)
    if self.CharacterList[name] then
        ---! state=true表示这个角色正在说话，state=false表示这个角色在旁观
        if state=="active" then
            self.CharacterList[name].IsActive=true
        else
            self.CharacterList[name].IsActive=false
        end
    end 
end

function DialogDisplayer:RemoveChara(self,name)
    if self.CharacterList[name] then
        Del(self.CharacterList[name])
        self.CharacterList[name]=nil
    end
end

function DialogDisplayer:del()
    for k,v in pairs(self.CharacterList) do
        if IsValid(v) then
            CharacterDisplayer.FadeOut(v)
        end
    end
    object.del(self)
end

--#endregion

--#region


---DialogSentence
---自行控制自己的生命周期
function DialogSentence:init(text,color,CanSkip,size,font,align,alignv,lifetime)
    self.TextAttri={
        text=text or "Test text.",
        color=color or Color(255,195, 255, 245),
        size=size or 20,
        align=align or "left",
        alignv=alignv or "top",
        font=font or "dialog",---ttfname
        CanSkip=CanSkip or true
    }
    self.lifetime=lifetime or 300
    self.IsActive=true
    self.group=GROUP_GHOST
    self.layer=LAYER_TOP+20
    self.TargetAlpha=self.TextAttri.color.a
    self.TextAttri.color.a=0
    ---淡入
    task.New(self,function()
        local attri=self.TextAttri
        for i=1,15 do
            task.Wait(1)
            attri.color.a=attri.color.a+self.TargetAlpha/30
        end
        attri.color.a=self.TargetAlpha
    end)
end

function DialogSentence:frame()
    if self.IsActive then
        task.Do(self)
        self.lifetime=self.lifetime-1
        if self.lifetime<=0 then
            DialogSentence.FadeOut(self)
        end
    end

    ---检测玩家是否按z继续
    if KeyIsPressed 'shoot' and self.TextAttri.CanSkip then
        DialogSentence.FadeOut(self)
    end
end

function DialogSentence:render()
    SetViewMode'ui'
    local attri=self.TextAttri
    local dl=DialogAttri
    local l=dl.cx-dl.w/2
    local r=dl.cx+dl.w/2
    local t=dl.cy+dl.h/2
    local b=dl.cy-dl.h/2

    ---shade below
    local delta=0.3
    local alp=attri.color.a
    local ShadeColor=Color(160*alp/255.0,0,0,0)
    local scale=attri.size/24
    RenderTTF2(attri.font,attri.text,l+delta,r+delta,b+delta,t+delta,scale,ShadeColor,attri.align,attri.alignv)
    RenderTTF2(attri.font,attri.text,l-delta,r-delta,b+delta,t+delta,scale,ShadeColor,attri.align,attri.alignv)
    RenderTTF2(attri.font,attri.text,l-delta,r-delta,b-delta,t-delta,scale,ShadeColor,attri.align,attri.alignv)
    RenderTTF2(attri.font,attri.text,l+delta,r+delta,b-delta,t-delta,scale,ShadeColor,attri.align,attri.alignv)

    ---main body
    RenderTTF2(attri.font,attri.text,l,r,b,t,scale,attri.color,attri.align,attri.alignv)
    SetViewMode'world'
end

function DialogSentence:FadeOut()
    ---淡出+死亡
    task.New(self,function()
        local attri=self.TextAttri
        for i=1,15 do
            task.Wait(1)
            attri.color.a=attri.color.a-self.TargetAlpha/30
        end
        Del(self)
    end)
end

--#endregion

--#region

---CharaDisplayer
CharacterDisplayer=Class(object)

function CharacterDisplayer:init(img,x,y,scale)
    self.img=img
    self.x=x
    self.y=y
    self.scale=scale
    self.group=GROUP_GHOST
    self.layer=LAYER_TOP+7
    self.TargetAlpha=255
    self.alp=0
    self.IsActive=true---这个变量暂时只用来指示仿官作的效果：角色在说话的时候，则所在图层增高，亮度正常，否则下降
    ---淡入
    task.New(self,function()
        for i=1,30 do
            task.Wait(1)
            self.alp=self.alp+self.TargetAlpha/30
            --SetImgState(self,"mul+alpha",self.alpha,255,255,255)
        end
        self.alp=self.TargetAlpha
        --SetImgState(self,"mul+alpha",self.alpha,255,255,255)
    end)
end

function CharacterDisplayer:frame()
    task.Do(self)
    if self.IsActive==true then
        SetImgState(self,"mul+alpha",self.alp,255,255,255)
        self.layer=LAYER_TOP+7
    else
        SetImgState(self,"mul+alpha",self.alp,128,128,128)
        self.layer=LAYER_TOP+4
    end
end
function CharacterDisplayer:render()
    SetViewMode'ui'
    Render(self.img,self.x,self.y,0,self.scale)
    SetViewMode'world'
end
function CharacterDisplayer.FadeOut(obj)
    task.New(obj,function()
        for i=1,30 do
            local Current=obj.alp
            assert(IsValid(obj),"wtf?")
            task.Wait(1)
            obj.alp=obj.alp-Current/30
            ---会在frame中自动设置图片状态
        end
        Del(obj)
    end)
end
--#endregion