---=====================================
---THlib
---Touhou style library
---=====================================
---!caution:the inner thlib.lua is loaded before outer thlib.lua
----------------------------------------
---加载脚本

Include 'THlib/ex.lua' --ESC的ex库
Include 'THlib/WalkImageSystem.lua'
Include 'THlib/DNHWalkImageSystem.lua'
Include 'THlib/DNHRenderObject.lua'
Include 'THlib/resourcesRedirect.lua'
Include 'THlib/misc/misc.lua'
Include 'THlib/se/se.lua'
Include 'THlib/item/item.lua'
Include 'THlib/player/player.lua'
Include 'THlib/enemy/enemy.lua'
Include 'THlib/bullet/bullet.lua'
Include 'THlib/bullet/bullet_style_loader.lua'
Include 'THlib/bullet/bullet_others.lua'
Include 'THlib/bullet/legacy_bullet_styles.lua'
Include 'THlib/laser/laser.lua'
Include 'THlib/background/background.lua'
Include 'THlib/ext/ext.lua'
Include 'THlib/UI/menu.lua'
Include 'THlib/editor.lua'
Include 'THlib/UI/UI.lua'
Include 'sp/sp.lua'--OLC神的sp加强库

---! 在这里加入自行拓展的各类接口
Include("THlib/customized-extension/Lscreen_ext.lua")
