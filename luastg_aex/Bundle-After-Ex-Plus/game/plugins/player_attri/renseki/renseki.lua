---todo: based on the homing bullet template, design our player
---! 穹海 涟析 | Kyuukai Renseki
renseki_player=Class(player_class)
local pl=Include 'THlib/player/player.lua'
local dir= "renseki/"

lstg.var.EatColliderSize={10,18,26,34,44}
---TODO: 允许自机power低于100
--#region
EatCollider=Class(object)
function EatCollider:init(player)
	LoadImageFromFile('EatCollider',dir..'eat_collider.png')

	---! 可以访问这个字段来调整碰撞体不透明度
	self.alpha=0.3
	SetImageState('EatCollider','mul+add',Color(255*self.alpha,150,120,150))
	self.img="EatCollider"
	self.rect=false
	self.p=player
	self.group=GROUP_PLAYER_EAT

	
	if IsValid(self.p) then
		self.x,self.y=self.p.x,self.p.y
	else
		self.x,self.y=0,0
	end
	self.a=lstg.var.EatColliderSize[math.floor(lstg.var.power/lstg.var.PowerExtendPoint)+1]
	self.b=self.a
	self.imgr=self.a
end

function EatCollider:frame()
	self.a=lstg.var.EatColliderSize[math.floor(lstg.var.power/lstg.var.PowerExtendPoint)+1]
	---print(self.a)
	self.b=self.a
	self.imgr=misc_ex.approach(self.imgr,self.a,0.14)
	if IsValid(self.p) then
		self.x,self.y=self.p.x,self.p.y
	end
	--self.p.LightRange=misc_ex.approach(self.p.LightRange,self.TargetLightRange,0.1)
end

function EatCollider:render()
	if(self.p.protect==0) then 
		SetImageState('EatCollider','mul+add',Color(255*self.alpha,200,120,230))
	else
		SetImageState('EatCollider','mul+add',Color(255*self.alpha,90,140,70))
	end
	Render(self.img,self.x,self.y,0,self.imgr/50,self.imgr/50)
end

function EatCollider:colli(other)
--print("playereat colli")
	if other.group == GROUP_FOOD then
		if other.a >= self.a and lstg.player.protect == 0 then
			---触发被咬死的miss效果
			--print("enter")
			item.LifeShrinkCheck(other.EatLifePenality,true,true,50);
			lstg.New(renseki_hit_effect,self.x,self.y,self)
		elseif other.a < self.a then
			---触发咬了别人的效果
			if other.kill_flag~=true then 
				GetPower(other.EatPowerBonus)
				self.p.TargetLightRange=self.p.TargetLightRange+other.EatLightBonus
				PlaySound("lgodsget",0.4)
				other.eaten=true
				other.kill_flag=true
			end
			---todo: 对于food，同样注册他的colli函数，以便我们额外定义被咬死之后的效果
			---至于food的判定大小显示，考虑：
			---1.加入鱼的属性字段，随后通过在外面创建一个task，组遍历，挨个按属性绘制碰撞范围
			---或者
			---2.他的一切行为直接在编辑器里慢慢写代码搞定
		end
	end
end
--#endregion
---!todo: add class member var to enable shooting direction locked/released
--#region
function renseki_player:init(slot)
	LoadTexture('renseki_player',dir..'renseki_full.png')
	LoadTexture('reimu_kekkai',dir..'reimu_kekkai.png')
	-----------------------------------------
	LoadImageGroup('renseki_player','renseki_player',0,0,256,256,12,3,0.5,0.5)
	LoadImageFromFile('reimu_bomb_ef',dir..'reimu_bomb_ef.png')
	LoadImage('reimu_kekkai','reimu_kekkai',0,0,256,256,0,0)
	SetImageState('reimu_kekkai','mul+add',Color(0x804040FF))
	LoadPS('reimu_sp_ef',dir..'reimu_sp_ef.psi','parimg1',16,16)
	-----------------------------------------
	LoadTexture("renseki_bullet1",dir.."b1.png")
	LoadAnimation("renseki_bullet1_ani","renseki_bullet1",0,0,128,64,4,3,3)
	SetAnimationState("renseki_bullet1_ani","mul+add",Color(160,255,140,230))
	SetAnimationScale("renseki_bullet1_ani",0.60)

	LoadAnimation("renseki_bullet2_ani","renseki_bullet1",0,0,128,64,4,3,3)
	SetAnimationState("renseki_bullet2_ani","mul+add",Color(160,210,210,210))
	SetAnimationScale("renseki_bullet2_ani",0.55)

	LoadTexture("renseki_bullet3",dir.."b2.png")
	LoadAnimation("renseki_bullet3_ani","renseki_bullet3",0,0,128,128,4,3,3)
	SetAnimationState("renseki_bullet3_ani","mul+add",Color(150,210,210,210))
	SetAnimationScale("renseki_bullet3_ani",0.45)

	LoadTexture("renseki_support",dir.."player_sub.png")
	LoadImage("renseki_support_img","renseki_support",0,0,128,128)
	SetImageState("renseki_support_img","mul+add",Color(180,200,220,230))
	SetImageScale("renseki_support_img",0.18)

	LoadTexture("renseki_bullet_ef",dir.."bullet_eff.png")
	LoadAnimation("renseki_bullet_ef_ani","renseki_bullet_ef",0,0,128,128,3,3,1)
	SetAnimationState("renseki_bullet_ef_ani","mul+add",Color(150,140,50,140))
	SetAnimationScale("renseki_bullet_ef_ani",0.65)

	LoadPS("renseki_bullet_particle",dir.."renseki_bulletef2.psi","parimg11")
	LoadPS("renseki_weaken_particle",dir.."particle_weaken.psi","parimg12")
	LoadPS("renseki_heal_particle",dir.."particle_heal.psi","parimg11")
	LoadPS("renseki_hit_particle",dir.."particle_hit.psi","parimg11")
	LoadPS("renseki_powerup_particle",dir.."particle_powerup.psi","parimg10")
	LoadPS("renseki_powerup_bullet_effect",dir.."bullet_powerup_particle.psi","parimg11")
	LoadPS("renseki_bomb1_particle",dir.."renseki_bomb_particle.psi","parimg11")

	LoadFX("renseki_bomb1",dir.."renseki_bomb1.hlsl")
	
	---self.testvar=1
	player_class.init(self)

	---todo: regist extra frame event here
	--self._playersys:addFrameBeforeEvent("test",1,function()
		---self.testvar=1+self.testvar;
		---Print("exetute player addframe logic")
	--end)

	self.name='Renseki'
	self.hspeed=4.5
	self.imgs={}
	self.A=0.5 self.B=0.5
	self.EatCollider=New(EatCollider,self)
	for i=1,36 do self.imgs[i]='renseki_player'..i end
	self.collect_line=600

	self.LightRange=120
	self.TargetLightRange=120
	self.MinLightRange=120
	self.MaxLightRange=250

	self.nf=12 self.nc=8
	self.hscale=0.25 self.vscale=0.20
	self.FixViewportAtPlayer=false

	--self.PoisonEffectTime=0
	self.HealEffectTime=0
	self.WeakEffectTime=0
	self.PowerupEffectTime=0

	self.MaxBuffTime=1200

	self.healeff=lstg.New(renseki_heal_effect,self.x,self.y,self)
	self.weakeneff=lstg.New(renseki_weaken_effect,self.x,self.y,self)
	self.powerupeff=lstg.New(renseki_powerup_effect,self.x,self.y,self)
	--子机位置
	self.slist=
	{
		{nil,nil,nil,nil},
		{{0,48,0,36}     ,           nil,         nil,           nil},
		{{-45,0,-18,36}    ,{45,0,18,36}    ,         nil,           nil},
		{{-45,-12,-24,30}   ,{0,-45,0,42}  ,{45,-12,24,30} ,           nil},
		{{-48,-16,-24,30},{-21,-43,-9,42},{21,-43,9,42},{48,-16,24,30}},
		{{-36,-12,-16,20},{-16,-32,-6,28},{16,-32,6,28},{36,-12,16,20}},
	}
	self.anglelist=
	{
		{90,90,90,90},
		{98,82,90,90},
		{105,75,90,90},
		{110,90,70,90},
		{120,105,75,60},
	}
	self.anglelistSlow={
		{90,90,90,90},
		{90,90,90,90},
		{85,95,90,90},
		{80,90,100,70},
		{83,92,88,97},
	}
end

function renseki_player:ChangeColor(a,r,g,b,blend)
	blend=blend or 'mul+alpha'
	--todo:让它变得更加丝滑
	self._a=a
	self._r=r
	self._g=g
	self._b=b
end

function renseki_player:frame()
	task.Do(self)
	player_class.frame(self)
	self.LightRange=misc_ex.approach(self.LightRange,self.TargetLightRange,0.1)
	self.TargetLightRange=max(self.TargetLightRange-0.3,self.MinLightRange)
	self.TargetLightRange=min(self.TargetLightRange,self.MaxLightRange)

	-- if self.PoisonEffectTime>0 and self.PoisonEffectTime%3==0 then
	-- 	item.LifeShrinkCheck(1,true,true,50);
	-- end

	if self.HealEffectTime>0 and self.HealEffectTime%7==0 then
		lstg.var.chip=lstg.var.chip+1
		LifeExtendCheck()
	end

	if self.WeakEffectTime>0 and self.WeakEffectTime%5==0 then
		GetPower(-1)
	end

	--self.PoisonEffectTime=max(self.PoisonEffectTime-1,0)
	self.HealEffectTime=max(self.HealEffectTime-1,0)
	self.WeakEffectTime=max(self.WeakEffectTime-1,0)
	self.PowerupEffectTime=max(self.PowerupEffectTime-1,0)

	self.HealEffectTime=min(self.HealEffectTime,self.MaxBuffTime)
	self.WeakEffectTime=min(self.WeakEffectTime,self.MaxBuffTime)
	self.PowerupEffectTime=min(self.PowerupEffectTime,self.MaxBuffTime)

	if(self.FixViewportAtPlayer) then
		local mapw,maph=lstg.world.r-lstg.world.l,lstg.world.t-lstg.world.b
		local sw,sh=lstg.world.scrr-lstg.world.scrl,lstg.world.scrt-lstg.world.scrb
		
		local cxlb=-(mapw)/2+sw/2
		local cylb=-(maph)/2+sh/2

		local cx=player.x
		local cy=player.y

		if cx<cxlb then cx=cxlb
		else if cx>-cxlb then cx=-cxlb
			end
		end

		if cy<cylb then cy=cylb
		else if cy>-cylb then cy=-cylb
			end
		end

		SetWorldOffset(cx,cy,1,1)
	end
	
end
-------------------------------------------------------
---
---!todo: let player be able to shoot towards different dir, not just front
---!todo: may use key c to switch locked/released state
---!todo: may fine move func to change dir
function renseki_player:shoot()
	PlaySound('plst00',0.3,self.x/1024)
	local Powerup=self.PowerupEffectTime>0

	---! 定义攻击间隔
	self.nextshoot=5
	New(renseki_bullet_main,'renseki_bullet1_ani',self.x+5,self.y,15,90,2.1,Powerup)
	New(renseki_bullet_main,'renseki_bullet1_ani',self.x-5,self.y,15,90,2.1,Powerup)
	if self.support>0 then
		if self.slow==1 then
			local num=int(lstg.var.power/100)+1
			local dtheta_max=4.3
			for i=1,4 do
				if self.sp[i] and self.sp[i][3]>0.5 then
					local dtheta=dtheta_max*abs(i-num/2.0)/num
					New(renseki_bullet_slow,'renseki_bullet2_ani',self.supportx+self.sp[i][1]-3,self.supporty+self.sp[i][2],15,self.anglelistSlow[num][i]+dtheta,1.3,Powerup)
					New(renseki_bullet_slow,'renseki_bullet2_ani',self.supportx+self.sp[i][1]+3,self.supporty+self.sp[i][2],15,self.anglelistSlow[num][i]-dtheta,1.3,Powerup)
				end
			end
		else
--			local num=60/(self.support+1)
		--if self.timer%8<4 then
			local num=int(lstg.var.power/100)+1
			for i=1,4 do
				if self.sp[i] and self.sp[i][3]>0.5 then
					New(renseki_bullet_fast,'renseki_bullet3_ani',self.supportx+self.sp[i][1],self.supporty+self.sp[i][2],7.3,self.anglelist[num][i]+ran:Float(-5,5),self.target,900,1.8,Powerup)
				end
			end
		end --end
	end
end


-------------------------------------------------------
function renseki_player:spell()
	local infi=2000
	self.collect_line=self.collect_line-infi
	New(tasker,function()
		task.Wait(90)
		self.collect_line=self.collect_line+infi
	end)
	-- if self.slow==1 then
		PlaySound('power1',0.8)
		PlaySound('cat00',0.8)
		misc.ShakeScreen(210,3)
--		New(bullet_killer,self.x,self.y)
		--New(player_spell_mask,64,64,255,30,210,30)
		--New(reimu_kekkai,self.x,self.y,1.25,12,20,12)
		New(renseki_bomb1,self.x,self.y,1.1)
		self.nextspell=240
		self.protect=360
	-- else
	-- 	PlaySound('nep00',0.8)
	-- 	PlaySound('slash',0.8)
	-- 	New(player_spell_mask,200,0,0,30,180,30)
	-- 	local rot=ran:Int(0,360)
	-- 	for i=1,8 do
	-- 		New(reimu_sp_ef1,'reimu_sp_ef',self.x,self.y,8,rot+i*45,tar1,1200,1,40-10*i,self)
	-- 	end
	-- 	self.nextspell=300
	-- 	self.protect=360
	-- end
end
-------------------------------------------------------
function renseki_player:render()
	for i=1,4 do
		if self.sp[i] and self.sp[i][3]>0.5 then
			Render('renseki_support_img',self.supportx+self.sp[i][1],self.supporty+self.sp[i][2],self.timer*5)
		end
	end
	---render special effect
	player_class.render(self)
end
--#endregion
-------------------------------------------------------
---! tmd,迟早给你换掉
--#region
reimu_sp_ef1=Class(object)
function reimu_sp_ef1:init(img,x,y,v,angle,target,trail,dmg,t,player)
	self.killflag=true
	self.group=GROUP_PLAYER_BULLET
	self.layer=LAYER_PLAYER_BULLET
	self.img=img
	self.vscale=1.2
	self.hscale=1.2
	self.a=self.a*1.2
	self.b=self.b*1.2
	self.x=x
	self.y=y
	self.rot=angle
	self.angle=angle
	self.v=v
	self.target=target
	self.trail=trail
	self.dmg=dmg
	self.DMG=dmg
	self.bound=false
	self.tflag=t
	self.player=player
end
function reimu_sp_ef1:frame()
	if BoxCheck(self,-192,192,-224,224) then self.inscreen=true end
	if self.timer<150+self.tflag then
	self.rot=self.angle-4*self.timer-90
	self.x=self.timer*1*cos(self.rot+90)+self.player.x
	self.y=self.timer*1*sin(self.rot+90)+self.player.y
	end
	player_class.findtarget(self)
	if self.timer>150+self.tflag then
		self.killflag=false
		self.dmg=35
		if IsValid(self.target) and self.target.colli then
		local a=math.mod(Angle(self,self.target)-self.rot+720,360)
		if a>180 then a=a-360 end
		local da=self.trail/(Dist(self,self.target)+1)
		if da>=abs(a) then self.rot=Angle(self,self.target)
		else self.rot=self.rot+sign(a)*da end
		end
		self.vx=8*cos(self.rot)
		self.vy=8*sin(self.rot)
		if self.inscreen then
			if self.x>192 then self.x=192 self.vx=0 self.vy=0 end
			if self.x<-192 then self.x=-192 self.vx=0 self.vy=0 end
			if self.y>224 then self.y=224 self.vx=0 self.vy=0 end
			if self.y<-224 then self.y=-224 self.vx=0 self.vy=0 end
		end
	end
	if self.timer>230 then
		self.killflag=true
		self.dmg=0.4*self.DMG
		self.a=2*self.a
		self.b=2*self.b
		self.vscale=(self.timer-230)*0.5+1
		self.hscale=(self.timer-230)*0.5+1
	end
	if self.timer>240 then
		Kill(self)
	end
	New(bomb_bullet_killer,self.x,self.y,self.a*1.5,self.b*1.5,false)
end

function reimu_sp_ef1:kill()
	misc.ShakeScreen(5,5)
	PlaySound('explode',0.3)
	New(bubble,'parimg12',self.x,self.y,30,4,6,Color(0xFFFFFFFF),Color(0x00FFFFFF),LAYER_ENEMY_BULLET_EF,'')
	local a=ran:Float(0,360)
	for i=1,12 do
		New(reimu_sp_ef2,self.x,self.y,ran:Float(4,6),a+i*30,2,ran:Int(1,3))
	end
	self.vscale=2
	self.hscale=2
--	misc.KeepParticle(self)
end

function reimu_sp_ef1:del()
	PlaySound('explode',0.3)
	New(bubble,'parimg12',self.x,self.y,30,4,6,Color(0xFFFFFFFF),Color(0x00FFFFFF),LAYER_ENEMY_BULLET_EF,'')
--	for i=1,4 do
--		New(reimu_sp_ef2,16,16,self.x,self.y,3,360/16*i,0.25,4,30)
--	end
	misc.KeepParticle(self)
	self.vscale=6
	self.hscale=6
end
-------------------------------------------------------
reimu_sp_ef2=Class(object)

function reimu_sp_ef2:init(x,y,v,angle,scale,index)
	self.img='reimu_bomb_ef'
	self.group=GROUP_GHOST
	self.layer=LAYER_PLAYER_BULLET
	self.colli=false
	self.x=x
	self.y=y
	self.rot=angle
	self.vx=v*cos(angle)
	self.vy=v*sin(angle)
	self.dmg=dmg
	self.hide=false
	self.scale=scale
	self.hscale=scale self.vscale=scale
	self.rbg={{255,0,0},{0,255,0},{0,0,255}}
	self.index=index
--	ParticleSetEmission(self,10)
end

function reimu_sp_ef2:frame()
	self.vscale=self.scale*(1-self.timer/60)
	self.hscale=self.scale*(1-self.timer/60)
	if self.timer>=30 then Del(self) end
end

function reimu_sp_ef2:render()
	SetImageState(self.img,'mul+add',Color(255-255*self.timer/30,self.rbg[self.index][1],self.rbg[self.index][2],self.rbg[self.index][3]))
	Render(self.img,self.x,self.y)
	SetImageState(self.img,'mul+add',Color(255,255,255,255))
end

--#endregion


-------------------------------------------------------
renseki_bullet_main=Class(player_bullet_straight)
function renseki_bullet_main:init(img,x,y,v,angle,dmg,Powerup)
	player_bullet_straight.init(self,img,x,y,v,angle,dmg)

	Powerup=Powerup or false
	if Powerup then
		lstg.New(renseki_powerup_bullet_effect,self.x,self.y,self)
		_object.set_color(self,"mul+add",255,255,40,160)
		self.dmg=self.dmg*1.5
	else
		_object.set_color(self,"mul+add",255,255,160,220)
	end
	--assert(self._a~=nil,"?")
	
end
function renseki_bullet_main:render()
	SetImgState(self,'mul+add',self._a,self._r,self._g,self._b)
	object.render(self)
end
function renseki_bullet_main:kill()
	New(renseki_bullet_ef,self.x,self.y,self.rot+180)
	Del(self)
end
-------------------------------------------------------
renseki_bullet_ef=Class(object)

function renseki_bullet_ef:init(x,y)
	self.x=x self.y=y self.rot=ran:Int(0,360) self.img='renseki_bullet_ef_ani' self.layer=LAYER_PLAYER_BULLET+50 self.group=GROUP_GHOST
	self.vy=0
	self.t=0
end
function renseki_bullet_ef:frame()
	self.t=self.t+1
	if self.t>=9 then self.y=600 Del(self) end
	_object.set_color(self,"mul+add",(9-self.t)/9*255*0.6,140,50,140)
end

---x,y,v,angle,dmg
renseki_bullet_slow=Class(player_bullet_straight)
function renseki_bullet_slow:init(img,x,y,v,angle,dmg,Powerup)
	player_bullet_straight.init(self,img,x,y,v,angle,dmg)
	self.a,self.b=12,12

	Powerup=Powerup or false
	if Powerup then
		lstg.New(renseki_powerup_bullet_effect,self.x,self.y,self)
		_object.set_color(self,"mul+add",255,255,140,215)
		self.dmg=self.dmg*1.5
	else
		_object.set_color(self,"mul+add",255,255,255,255)
	end
end
function renseki_bullet_slow:render()
	SetImgState(self,'mul+add',self._a,self._r,self._g,self._b)
	object.render(self)
end
function renseki_bullet_slow:kill()
	---todo:add particle eff
	--New(reimu_bullet_orange_ef,self.x,self.y,self.rot+180+ran:Float(-15,15))
	--New(reimu_bullet_orange_ef2,self.x,self.y)
	--local vx,vy=self.vx,self.vy
	New(renseki_bullet_ef,self.x+self.vx/2,self.y+self.vx/2)
	Del(self)
end

renseki_bullet_explode=Class(object)

function renseki_bullet_explode:init(x,y)
	--player_bullet_straight("renseki_bullet_particle",x,y,0,0,0.12)
	self.x=x
	self.y=y
	self.vx=0
	self.vy=0
	self.img="renseki_bullet_particle"
	--SetImgState(self,"mul+add",160,200,200,200)
	self.layer=LAYER_PLAYER_BULLET+50 
	self.group=GROUP_GHOST
end

function renseki_bullet_explode:render()
	SetViewMode("world")
	object.render(self)
	SetViewMode("world")
end

function renseki_bullet_explode:frame()
	if self.timer==5 then ParticleStop(self) end
	if self.timer==40 then Del(self) end
end

---
-------------------------------------------------------
renseki_bullet_fast=Class(player_bullet_trail)
function renseki_bullet_fast:init(img,x,y,v,angle,target,trail,dmg,Powerup)
	self.group=GROUP_PLAYER_BULLET
	self.layer=LAYER_PLAYER_BULLET
	self.img=img
	self.x=x
	self.y=y
	self.vscale=0.7
	self.rot=angle
	self.v=v
	self.target=target
	self.trail=trail
	self.dmg=dmg

	Powerup=Powerup or false
	if Powerup then
		lstg.New(renseki_powerup_bullet_effect,self.x,self.y,self)
		_object.set_color(self,"mul+add",255,255,140,215)
		self.dmg=self.dmg*1.5
	else
		_object.set_color(self,"mul+add",255,255,255,255)
	end
end

function renseki_bullet_fast:frame()
	player_class.findtarget(self)
	if IsValid(self.target) and self.target.colli then
		local a=math.mod(Angle(self,self.target)-self.rot+720,360)
		if a>180 then a=a-360 end
		local da=self.trail/(Dist(self,self.target)+1)
		if da>=abs(a) then self.rot=Angle(self,self.target)
		else self.rot=self.rot+sign(a)*da end
	end
	self.vx=self.v*cos(self.rot)
	self.vy=self.v*sin(self.rot)
end

function renseki_bullet_fast:render()
	SetImgState(self,'mul+add',self._a,self._r,self._g,self._b)
	object.render(self)
end
function renseki_bullet_fast:kill()
	--todo:add particle effect
	---New(reimu_bullet_blue_ef,self.x,self.y,self.rot)
	New(renseki_bullet_explode,self.x+self.vx/2,self.y+self.vy/2)
	Del(self)
end
-------------------------------------------------------
---

--#region
renseki_hit_effect=Class(object)

function renseki_hit_effect:init(x,y,p)
	self.x=x self.y=y self.rot=ran:Int(0,360) self.img='renseki_hit_particle' self.layer=LAYER_PLAYER_BULLET+50 self.group=GROUP_GHOST
	self.hscale=1.0
	self.vscale=1.0
	self.vy=0
	self.pl=p
end

function renseki_hit_effect:frame()

	if self.timer==10 then ParticleStop(self) end
	if self.timer==50 or not IsValid(self.pl) then Del(self) end
	--SetImgState(self,"mul+add",(9-self.timer)/9*255*0.6,140,50,50)
	self.x=self.pl.x
	self.y=self.pl.y
end

function renseki_hit_effect:render()
	SetViewMode("world")
	object.render(self)
	SetViewMode("world")
end
--#endregion

renseki_heal_effect=Class(object)

function renseki_heal_effect:init(x,y,p)
	self.x=x
	self.y=y
	self.img='renseki_heal_particle'
	self.layer=LAYER_PLAYER_BULLET+50
	self.group=GROUP_GHOST
	self.hscale=1.0
	self.vscale=1.0
	self.vy=0
	self.vx=0
	self.pl=p
end

function renseki_heal_effect:frame()
	task.Do(self)
	if not IsValid(self.pl) then ParticleStop(self) return end
	if self.pl.HealEffectTime<=0 then ParticleStop(self) 
	else ParticleFire(self)
	end
	self.x=self.pl.x
	self.y=self.pl.y
end

function renseki_heal_effect:render()
	--if self.pl.HealEffectTime<=0 then return end
	SetViewMode("world")
	object.render(self)
	SetViewMode("world")
end
---
renseki_weaken_effect=Class(object)
function renseki_weaken_effect:init(x,y,p)
	self.x=x
	self.y=y
	self.img='renseki_weaken_particle'
	self.layer=LAYER_PLAYER_BULLET+50
	self.group=GROUP_GHOST
	self.hscale=0.6
	self.vscale=0.6
	self.vy=0
	self.pl=p
end

function renseki_weaken_effect:frame()
	if not IsValid(self.pl) then Del(self) end
	if self.pl.WeakEffectTime<=0 then ParticleStop(self) 
	else ParticleFire(self)end
	self.x=self.pl.x
	self.y=self.pl.y
end

function renseki_weaken_effect:render()
	--if self.pl.WeakEffectTime<=0 then return end
	SetViewMode("world")
	object.render(self)
	SetViewMode("world")
end

renseki_powerup_bullet_effect=Class(object)
function renseki_powerup_bullet_effect:init(x,y,target)
	self.x=x
	self.y=y
	self.img='renseki_powerup_bullet_effect'
	self.layer=LAYER_PLAYER_BULLET+50
	self.group=GROUP_GHOST
	self.hscale=1.0
	self.vscale=1.0
	self.vy=0
	self.vx=0
	self.tar=target
	self.DeathTimer=0
end

function renseki_powerup_bullet_effect:frame()
	task.Do(self)
	if IsValid(self.tar) then
		self.x=self.tar.x
		self.y=self.tar.y
	else
		ParticleStop(self)
		task.New(self,function()
			task.Wait(50)
			Del(self)
		end)
	end
end
--#region
renseki_powerup_effect=Class(object)
function renseki_powerup_effect:init(x,y,p)
	self.x=x
	self.y=y
	self.img='renseki_powerup_particle'
	self.layer=LAYER_PLAYER_BULLET+50
	self.group=GROUP_GHOST
	self.hscale=1.0
	self.vscale=1.0
	self.vy=0
	self.vx=0
	self.pl=p
end

function renseki_powerup_effect:frame()
	if not IsValid(self.pl) then Del(self) end
	if self.pl.PowerupEffectTime<=0 then ParticleStop(self) 
	else ParticleFire(self)
	end
	self.x=self.pl.x
	self.y=self.pl.y
end

function renseki_powerup_effect:render()
	--if self.pl.HealEffectTime<=0 then return end
	SetViewMode("world")
	object.render(self)
	SetViewMode("world")
end
--#endregion

-- reimu_bullet_blue_ef=Class(object)

-- function reimu_bullet_blue_ef:init(x,y,rot)
-- 	self.x=x self.y=y self.rot=rot self.img='reimu_bullet_blue_ef' self.layer=LAYER_PLAYER_BULLET+50 self.group=GROUP_GHOST
-- 	self.vx=1*cos(rot) self.vy=1*sin(rot)
-- end

-- function reimu_bullet_blue_ef:frame()
-- 	if self.timer>14 then Del(self) end
-- end
-------------------------------------------------------
-- reimu_sp_ef=Class(player_bullet_trail)

-- function reimu_sp_ef:kill()
-- 	PlaySound('explode',0.3)
-- 	New(bubble,'parimg12',self.x,self.y,30,4,6,Color(0xFFFFFFFF),Color(0x00FFFFFF),LAYER_ENEMY_BULLET_EF,'')
-- 	for i=1,16 do
-- 		New(reimu_sp_ef2,16,16,self.x,self.y,3,360/16*i,0.25,4,30)
-- 	end
-- 	misc.KeepParticle(self)
-- end

-- function reimu_sp_ef:del()
-- 	misc.KeepParticle(self)
-- end
-- -------------------------------------------------------
-- reimu_bullet_ef=Class(object)

-- function reimu_bullet_ef:init(x,y,rot)
-- 	self.x=x self.y=y self.rot=rot self.img='reimu_bullet_ef_ani' self.layer=LAYER_PLAYER_BULLET+50 self.group=GROUP_GHOST
-- end

-- function reimu_bullet_ef:frame()
-- 	if self.timer==4 then ParticleStop(self) end
-- 	if self.timer==30 then Del(self) end
-- end
-- -------------------------------------------------------
-- reimu_bullet_orange_ef=Class(object)

-- function reimu_bullet_orange_ef:init(x,y,rot)
-- 	self.x=x self.y=y+32 self.rot=rot self.img='reimu_bullet_orange_ef' self.layer=LAYER_PLAYER_BULLET+50 self.group=GROUP_GHOST self.vy=2
-- 	self.hscale=ran:Float(1.4,1.6)
-- end

-- function reimu_bullet_orange_ef:frame()
-- 	if self.timer>15 then self.x=600 Del(self) end
-- end

-- function reimu_bullet_orange_ef:render()
-- 	SetImageState(self.img,'mul+add',Color(255-255*self.timer/16,255,255,255))
-- 	object.render(self)
-- end
-- --修改击中效果
-- -------------------------------------------------------
-- reimu_bullet_orange_ef2=Class(object)

-- function reimu_bullet_orange_ef2:init(x,y)
-- 	self.x=x self.y=y+32 self.rot=-90+ran:Float(-10,10) self.img='reimu_bullet_orange_ef2' self.layer=LAYER_PLAYER_BULLET+50 self.group=GROUP_GHOST
-- 	self.hscale=ran:Float(1.5,1.8) self.vscale=1.5 
-- end

-- function reimu_bullet_orange_ef2:frame()
-- 	if self.timer>=9 then self.x=600 Del(self) end
-- end
-- -------------------------------------------------------

--#region
renseki_bomb1=Class(object)

function renseki_bomb1:init(x,y,dmg)
	self.x=x
	self.y=y
	self.dmg=dmg
	self.group=GROUP_PLAYER_BULLET
	self.layer=LAYER_PLAYER_BULLET
	self.list={}
	self.killflag=true---自行管理生命周期
	self.img="img_void"
	self.hscale=20.0
	self.vscale=20.0
	self.vy=0
	self.vx=0
	self.timer=0

	self.r=0
	self.al=0

	self.rmax=300
	self.absorb=130
	self.a=280
	self.b=280

	self.maxlife=240
	task.New(self,function()
		for i=1,60 do
			task.Wait(1)
			local lambda=(i/60)*(i/60)
			self.r=self.rmax*lambda
			self.al=255*lambda
		end
		task.Wait(self.maxlife)
		for i=30,1,-1 do
			task.Wait(1)
			local lambda=(i/30)*(i/30)
			self.r=self.rmax*lambda
			self.al=255*lambda
		end
		New(bomb_bullet_killer,self.x,self.y,500,500,false)
		PlaySound('slash',0.8)
		Del(self)
	end)
	--New(ParticleEx,self.x,self.y,0,0)
	CreateRenderTarget("bomb_black")
	--New(renseki_bomb1_particle,self)
end
--#endregion

function renseki_bomb1:frame()
	task.Do(self)
	--免疫不良状态
	player.WeakEffectTime=0
	--New(bomb_bullet_killer,self.x,self.y,self.r*1.6,self.r*1.6,false)
	--self.timer=self.timer+1
	if self.timer>30 then
		for _,unit in ObjList(GROUP_ENEMY_BULLET) do
			if(IsValid(unit)) then
				local d=Dist(unit,self)
				local frac=(d/170)*(d/170)
				local a=max(0.5/frac,0.1)
				_set_a(unit,a,Angle(unit,self),false)
				unit.navi=true
				if(d<self.absorb+60+ran:Float(-10,10)) then
					unit._angle=Angle(unit,self)
				end
				if(d<self.absorb+ran:Float(-40,40)) then
					if(ran:Float(0,1)<0.3) then
						New(renseki_bullet_fast,'renseki_bullet3_ani',self.x,self.y,7.3,Angle(self,unit)+ran:Float(-4,4),self.target,900,2,false)
						PlaySound("enep00",0.5)
					end
					Del(unit)
				end
			end
		end

		for _,unit in ObjList(GROUP_FOOD) do
			if(IsValid(unit)) then
				_set_a(unit,0.3,Angle(unit,self),false)
				unit.navi=true
				if(Dist(unit,self)<self.absorb+60+ran:Float(-10,10)) then
					unit._angle=Angle(unit,self)
				end
			end
		end
		---闪烁粒子
		local pp=ParticlePresets
		if self.timer<self.maxlife+20 then
			--print("enter timer stamp")
			local r=ran:Float(self.r*0.45,self.r*0.65)
			local s=ran:Float(0.65,1.35)
			local weight=(self.r-r)/self.r
			pp.DynamicScatter(self,Color((110+ran:Int(-70,50))*weight,10+ran:Int(10,50),180,180+ran:Int(10,50)),r,0,"parimg6",45,s*weight,0,true,0.3,-0.1)
		end
	end
	self.x,self.y=player.x,player.y
end

function renseki_bomb1:render()
	SetViewMode("world")
	PushRenderTarget("bomb_black")
	RenderClear(Color(0,0,0,0))
	SetImgState(self,"mul+add",self.al,0,0,0)
	object.render(self)
	PopRenderTarget()
	-- PostEffect("bomb_black","renseki_bomb1","mul+add",{
	-- 	center_pos={self.x,self.y,0,0},
	-- 	effect_param={self.r,self.timer,0,0}
	-- })
	local x, y = GetScr(self)
    local x1 = x * screen.scale
    local y1 = (screen.height - y) * screen.scale
	local scrh=lstg.world.scrt-lstg.world.scrb
	lstg.PostEffect('renseki_bomb1','bomb_black',6,"mul+add",{
		{x1,y1,0,0},
		{self.r*screen.scale,self.timer/60,0,0}
	},{
		-- {self.x,self.y,0,0},
		-- {self.r,self.timer,0,0}
	})
	--SetImgState(self,"mul+add",self.al,255,255,255)
	SetViewMode("world")
end

renseki_bomb1_particle=Class(object)

function renseki_bomb1_particle:init(target)
	self.tar=target
	self.img="renseki_bomb1_particle"
	self.hscale=1
	self.vscale=1
	self.vy=0
	self.vx=0
	self.x=target.x
	self.y=target.y
	self.layer=LAYER_PLAYER_BULLET+50 
	self.group=GROUP_GHOST
end

function renseki_bomb1_particle:frame()
	local t=self.tar
	if(not IsValid(t)) then Del(self) 
	else if(t.timer<t.maxlife+20 and t.timer>30) then
			self.x=t.x
			self.y=t.y
			ParticleFire(self)
		else
			ParticleStop(self)
		end
	end
end

function renseki_bomb1_particle:render()
	SetViewMode("world")
	object.render(self)
	SetViewMode("world")
end

---
---! 这个倒是挺有保留的价值
--#region
-- reimu_kekkai=Class(object)

-- function reimu_kekkai:init(x,y,dmg,dr,n,t)
-- 	self.x=x
-- 	self.y=y
-- 	self.dmg=dmg
-- 	SetImageState('reimu_kekkai','mul+add',Color(0x804040FF))
-- 	self.killflag=true
-- 	self.group=GROUP_PLAYER_BULLET
-- 	self.layer=LAYER_PLAYER_BULLET
-- 	self.r=0
-- 	self.a=0
-- 	self.b=0
-- 	self.dr=dr
-- 	self.ds=dr/256
-- 	self.n=0
-- 	self.mute=true
-- 	self.list={}
-- 	task.New(self,function()
-- 		for i=1,n do
-- 			self.list[i]={scale=0,rot=0}
-- 			self.n=self.n+1
-- 			task.Wait(t)
-- 		end
-- 		self.dmg=0
-- 		PlaySound('slash',1.0)
-- --		New(bullet_killer,self.x,self.y)
-- 		for i=128,0,-4 do
-- 			SetImageState('reimu_kekkai','mul+add',Color(0x004040FF)+i*Color(0x01000000))
-- 			task.Wait(1)
-- 		end
-- 		Del(self)
-- 	end)
-- end

-- function reimu_kekkai:frame()
-- 	task.Do(self)
-- 	if self.timer%6==0 then self.mute=false else self.mute=true end
-- 	self.r=self.r+self.dr
-- 	self.a=self.r
-- 	self.b=self.r
-- 	for i=1,self.n do
-- 		self.list[i].scale=self.list[i].scale+self.ds
-- 		self.list[i].rot=self.list[i].rot+(-1)^i
-- 	end
-- 	New(bomb_bullet_killer,self.x,self.y,self.a/1.25,self.b/1.25,false)
-- end

-- function reimu_kekkai:render()
-- 	for i=1,self.n do
-- 		Render('reimu_kekkai',self.x,self.y,self.list[i].rot,self.list[i].scale)
-- 	end
-- end
--#endregion
AddPlayerToPlayerList('Kyuukai Renseki','renseki_player','Renseki')
