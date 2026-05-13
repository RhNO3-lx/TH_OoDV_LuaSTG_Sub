---todo: based on the homing bullet template, design our player
---! 穹海 涟析 | Kyuukai Renseki
renseki_player=Class(player_class)
local pe=require "THlib.customized-extension.particle_ext"
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
			-- if other.kill_flag~=true then 
				GetPower(other.EatPowerBonus)
				self.p.TargetLightRange=self.p.TargetLightRange+other.EatLightBonus
				PlaySound("lgodsget",0.4)
				other.eaten=true
				Kill(other)
			-- 	other.kill_flag=true
			-- end
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
	SetAnimationState("renseki_bullet1_ani","mul+add",Color(140,215,70,190))
	SetAnimationScale("renseki_bullet1_ani",0.60)

	LoadAnimation("renseki_bullet2_ani","renseki_bullet1",0,0,128,64,4,3,3)
	SetAnimationState("renseki_bullet2_ani","mul+add",Color(120,150,150,150))
	SetAnimationScale("renseki_bullet2_ani",0.55)

	LoadTexture("renseki_bullet3",dir.."b2.png")
	LoadAnimation("renseki_bullet3_ani","renseki_bullet3",0,0,128,128,4,3,3)
	SetAnimationState("renseki_bullet3_ani","mul+add",Color(120,150,150,150))
	SetAnimationScale("renseki_bullet3_ani",0.45)

	LoadTexture("renseki_support",dir.."player_sub.png")
	LoadImage("renseki_support_img","renseki_support",0,0,128,128)
	SetImageState("renseki_support_img","mul+add",Color(180,200,220,230))
	SetImageScale("renseki_support_img",0.18)

	LoadTexture("renseki_bullet_ef",dir.."bullet_eff.png")
	LoadAnimation("renseki_bullet_ef_ani","renseki_bullet_ef",0,0,128,128,3,3,1)
	SetAnimationState("renseki_bullet_ef_ani","mul+add",Color(150,140,50,140))
	SetAnimationScale("renseki_bullet_ef_ani",0.65)

	LoadPS("renseki_bullet_particle",dir.."renseki_bullet_hit_1.psi","parimg1")
	LoadPS("renseki_bullet_particle_powerup",dir.."renseki_bullet_hit_2.psi","parimg1")
	LoadPS("renseki_weaken_particle",dir.."particle_weaken.psi","parimg12")
	LoadPS("renseki_heal_particle",dir.."particle_heal.psi","parimg11")
	LoadPS("renseki_hit_particle",dir.."particle_hit.psi","parimg11")
	LoadPS("renseki_powerup_state",dir.."particle_powerup.psi","parimg10")
	LoadPS("renseki_powerup_bullet_track",dir.."bullet_powerup_track_particle.psi","parimg11")
	LoadPS("renseki_bullet_track",dir.."bullet_track_particle.psi","parimg11")
	LoadPS("renseki_bomb1_particle",dir.."renseki_bomb_particle.psi","parimg11")

	LoadFX("renseki_bomb1",dir.."renseki_bomb1.hlsl")
	
	---self.testvar=1
	player_class.init(self)
	misc_ex.InitializeSystem()

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
		{92,88,90,90},
		{95,90,85,70},
		{97,93,87,83},
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
	--让sp_actual缓动追随sp

	self.sp_dx=sin(self.timer/0.6)*4.2
	self.sp_dy=cos(self.timer/0.6)*5.7

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
	local num=int(lstg.var.power/100)+1
	local da=sin(self.timer/0.8)*(num+1)/6

	---! 定义攻击间隔
	self.nextshoot=6
	New(renseki_bullet_main,'renseki_bullet1_ani',self.x+5,self.y,15,90,2.3,Powerup)
	New(renseki_bullet_main,'renseki_bullet1_ani',self.x-5,self.y,15,90,2.3,Powerup)

	if self.support>0 then
		if self.slow==1 then
			local dtheta_max=7
			for i=1,4 do
					local sgn=0
					if i>num/2 then sgn=-1 
						elseif i<num/2 then sgn=1 
					end
					local sy=-1
					if i<=num/4 or i>=num/4*3 then sy=1 end
				if self.sp[i] and self.sp[i][3]>0.5 then
					local dtheta=dtheta_max*(abs(i-num/2)/num+0.2*sin(self.timer/4))*num/3.5
					New(renseki_bullet_slow,'renseki_bullet2_ani',self.supportx+self.sp_dx*sgn+self.sp[i][1]-3,self.supporty+self.sp_dy*sy+self.sp[i][2],15,self.anglelistSlow[num][i]+dtheta+da,1.7,Powerup)
					New(renseki_bullet_slow,'renseki_bullet2_ani',self.supportx+self.sp_dx*sgn+self.sp[i][1]+3,self.supporty+self.sp_dy*sy+self.sp[i][2],15,self.anglelistSlow[num][i]-dtheta-da,1.7,Powerup)
				end
			end
		else
--			local num=60/(self.support+1)
		--if self.timer%8<4 then
			for i=1,4 do
				local sgn=0
				if i>num/2 then sgn=-1 
					elseif i<num/2 then sgn=1 
				end
				local sy=-1
				if i<=num/4 or i>=num/4*3 then sy=1 end

				if self.sp[i] and self.sp[i][3]>0.5 then
					New(renseki_bullet_fast,'renseki_bullet3_ani',self.supportx+self.sp_dx*sgn+self.sp[i][1],self.supporty+self.sp_dy*sy+self.sp[i][2],7.3,self.anglelist[num][i]+ran:Float(-5,5),self.target,900,2.2,Powerup)
				end
			end
		end --end
	end
end


-------------------------------------------------------
local function straight_particle(self,co_list)
	--local prob=(8+self.timer%8)/15*ran:Float(0,1)
	if ran:Float(0,1)<0.10 then
		local r=ran:Float(0,3)
		local a=self.rot+180+ran:Float(-60,60)
		local dx,dy=r*cos(a),r*sin(a)
		local t=ran:Int(25,35)
		local v0=ran:Float(0.1,0.9)
		local acc=-v0/t-0.005
		local co_list={Color(105,255,40,160),Color(85,120,190,255)}
		local co= self.powerup and co_list[1] or co_list[2]
		pe.ParticlePresets.DynamicScatter(self.x,self.y,co,r,r,"parimg11",t,0.7,0.15,false,self,acc,v0)
	end 
end

local function trail_particle(self,co_list)
	--local index=ran:Int(2,7)
	if ran:Float(0,1)<0.10 then
		local r=0
		local a=self.rot+180+ran:Float(-10,10)
		local dx,dy=r*cos(a),r*sin(a)
		local t=ran:Int(15,25)
		local v0=ran:Float(0.4,0.9)
		v0=0
		local acc=-v0/t
		local co_list={Color(105,255,40,160),Color(85,120,190,255)}
		local co= self.powerup and co_list[1] or co_list[2]
		pe.ParticlePresets.DynamicScatter(self.x,self.y,co,r,r,"parimg11",t,0.7,0.15,false,self,acc,v0)
	end
end

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
		self.death=0
		-- SetSuperPause(0)
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
	local num=int(lstg.var.power/100)+1
	for i=1,4 do
		if self.sp[i] and self.sp[i][3]>0.5 then
			local sgn=0
			local sy=-1
			if i<=num/4 or i>=num/4*3 then sy=1 end
			if i>num/2 then sgn=-1 
			elseif i<num/2 then sgn=1 
			end
			Render('renseki_support_img',self.supportx+self.sp_dx*sgn+self.sp[i][1],self.supporty+self.sp_dy*sy+self.sp[i][2],self.timer*5)
		end
	end
	---render special effect
	player_class.render(self)
end
--#endregion



-------------------------------------------------------
renseki_bullet_main=Class(player_bullet_straight)
function renseki_bullet_main:init(img,x,y,v,angle,dmg,Powerup)
	player_bullet_straight.init(self,img,x,y,v,angle,dmg)

	self.powerup=Powerup or false
	if Powerup then
		-- lstg.New(renseki_powerup_bullet_track,self.x,self.y,self)
		_object.set_color(self,"mul+add",190,255,40,160)
		self.dmg=self.dmg*1.5
	else
		_object.set_color(self,"mul+add",190,170,180,220)
		-- lstg.New(renseki_powerup_bullet_track,self.x,self.y,self,"renseki_bullet_track")
	end
	--assert(self._a~=nil,"?")
	
end
function renseki_bullet_main:frame()
	straight_particle(self,{Color(190,255,40,160),Color(190,170,180,220)})
end
function renseki_bullet_main:render()
	SetImgState(self,'mul+add',self._a,self._r,self._g,self._b)
	object.render(self)
end
function renseki_bullet_main:kill()
		local pimg="renseki_bullet_particle"
	if self.powerup then pimg="renseki_bullet_particle_powerup" end
	New(renseki_bullet_ef,self.x+self.vx/2,self.y+self.vy/2,pimg)
	Del(self)
end
-------------------------------------------------------
-- renseki_bullet_ef=Class(object)

-- function renseki_bullet_ef:init(x,y)
-- 	self.x=x self.y=y self.rot=ran:Int(0,360) self.img='renseki_bullet_ef_ani' self.layer=LAYER_PLAYER_BULLET+50 self.group=GROUP_GHOST
-- 	self.vy=0
-- 	self.t=0
-- end
-- function renseki_bullet_ef:frame()
-- 	self.t=self.t+1
-- 	if self.t>=9 then self.y=600 Del(self) end
-- 	_object.set_color(self,"mul+add",(9-self.t)/9*255*0.6,140,50,140)
-- end

---x,y,v,angle,dmg
renseki_bullet_slow=Class(player_bullet_straight)
function renseki_bullet_slow:init(img,x,y,v,angle,dmg,Powerup)
	player_bullet_straight.init(self,img,x,y,v,angle,dmg)
	self.a,self.b=14,14
	self.vscale=0.85

	self.powerup=Powerup or false
	if Powerup then
		-- lstg.New(renseki_powerup_bullet_track,self.x,self.y,self)
		_object.set_color(self,"mul+add",190,255,140,215)
		self.dmg=self.dmg*1.5
	else
		_object.set_color(self,"mul+add",190,170,180,220)
		-- lstg.New(renseki_powerup_bullet_track,self.x,self.y,self,"renseki_bullet_track")
	end
end
function renseki_bullet_slow:frame()
	straight_particle(self,{Color(190,255,140,215),Color(190,170,180,220)})
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
	local pimg="renseki_bullet_particle"
	if self.powerup then pimg="renseki_bullet_particle_powerup" end
	New(renseki_bullet_ef,self.x+self.vx/2,self.y+self.vy/2,pimg)
	Del(self)
end

renseki_bullet_ef=Class(object)

function renseki_bullet_ef:init(x,y,img)
	--player_bullet_straight("renseki_bullet_particle",x,y,0,0,0.12)
	self.x=x
	self.y=y
	self.vx=0
	self.vy=0
	img=img or "renseki_bullet_particle"
	self.img=img
	--SetImgState(self,"mul+add",160,200,200,200)
	self.layer=LAYER_PLAYER_BULLET+5 
	self.group=GROUP_GHOST
end

function renseki_bullet_ef:render()
	SetViewMode("world")
	object.render(self)
	SetViewMode("world")
end

function renseki_bullet_ef:frame()
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
	self.vscale=0.55
	self.rot=angle
	self.v=v
	self.target=target
	self.trail=trail
	self.dmg=dmg

	self.powerup=Powerup or false
	if Powerup then
		-- lstg.New(renseki_powerup_bullet_track,self.x,self.y,self)
		_object.set_color(self,"mul+add",190,255,140,215)
		self.dmg=self.dmg*1.5
	else
		_object.set_color(self,"mul+add",190,170,180,220)
		-- lstg.New(renseki_powerup_bullet_track,self.x,self.y,self,"renseki_bullet_track")
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

	trail_particle(self)
end

function renseki_bullet_fast:render()
	SetImgState(self,'mul+add',self._a,self._r,self._g,self._b)
	object.render(self)
end
function renseki_bullet_fast:kill()
	--todo:add particle effect
	---New(reimu_bullet_blue_ef,self.x,self.y,self.rot)
	local pimg="renseki_bullet_particle"
	if self.powerup then pimg="renseki_bullet_particle_powerup" end
	New(renseki_bullet_ef,self.x+self.vx/2,self.y+self.vy/2,pimg)
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

renseki_powerup_bullet_track=Class(object)
function renseki_powerup_bullet_track:init(x,y,target,img)
	self.x=x
	self.y=y
	self.img=img or 'renseki_powerup_bullet_track'
	self.layer=LAYER_PLAYER_BULLET+50
	self.group=GROUP_GHOST
	self.hscale=1.0
	self.vscale=1.0
	self.vy=0
	self.vx=0
	self.tar=target
	self.DeathTimer=0
	SetImgState(self,"mul+add",0,0,0,0)
end

function renseki_powerup_bullet_track:frame()
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
	self.img='renseki_powerup_state'
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
	self.absorb=70
	self.a=280
	self.b=280

	self.maxlife=240
	self.count=0

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
		for _,unit in ObjList(GROUP_FOOD) do
			if(IsValid(unit)) then
				if unit.RemoveFlag==true then
					Del(unit)
				end
			end
		end

		PlaySound('slash',0.8)
		Del(self)
	end)
	CreateRenderTarget("bomb_black")
end
--#endregion

function renseki_bomb1:frame()
	task.Do(self)
	--免疫不良状态
	player.WeakEffectTime=0

	local SetAttraction=function(unit)
		local d=Dist(unit,self)
		local frac=(d/200)*(d/200)
		local a=max(0.7/frac+0.1,0.15)
		local maxv=10
		SetA(unit,a,Angle(unit,self),maxv,0,maxv,true)
	end
	if self.timer>30 then
		for _,unit in ObjList(GROUP_ENEMY_BULLET) do
			if(IsValid(unit)) then
				task.Clear(unit)
				SetAttraction(unit)
				local d=Dist(unit,self)
				unit.navi=true
				if(d<self.absorb+ran:Float(-40,40)) then
					self.count=self.count+1
					if self.count%5==0 then
						PlaySound("enep00",0.5)
						New(renseki_bullet_fast,'renseki_bullet3_ani',self.x,self.y,7.3,Angle(self,unit)+ran:Float(-4,4),self.target,900,2,true)
					end
					Del(unit)
				end
			end
		end

		for _,unit in ObjList(GROUP_FOOD) do
			if(IsValid(unit)) then
				task.Clear(unit)
				SetAttraction(unit)
				unit.RemoveFlag=true
			end
		end
		---闪烁粒子
		local pp=pe.ParticlePresets
		if self.timer<self.maxlife+20 then
			--print("enter timer stamp")
			local r=ran:Float(self.r*0.55,self.r*0.70)
			local s=ran:Float(0.65,1.35)
			local weight=(self.r-r)/self.r
			pp.DynamicScatter(self.x,self.y,Color((110+ran:Int(-70,50))*weight,10+ran:Int(10,50),180,180+ran:Int(10,50)),r,0,"parimg6",45,s*weight,0,true,self,0.3,-0.1)
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
	local x, y = GetScr(self)
    local x1 = x * screen.scale
    local y1 = (screen.height - y) * screen.scale
	local scrh=lstg.world.scrt-lstg.world.scrb
	lstg.PostEffect('renseki_bomb1','bomb_black',6,"mul+add",{
		{x1,y1,0,0},
		{self.r*screen.scale,self.timer/60,0,0}
	},{
	})
	SetViewMode("world")
end

AddPlayerToPlayerList('Kyuukai Renseki','renseki_player','Renseki')
