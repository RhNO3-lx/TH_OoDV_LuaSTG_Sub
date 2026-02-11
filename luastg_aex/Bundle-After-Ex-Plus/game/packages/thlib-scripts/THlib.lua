-- THlib
lstg.globalEventDispatcher:Clear()
lstg.plugin.LoadPlugins()

---! blank callback func yet
lstg.plugin.DispatchEvent("beforeTHlib")
Include("THlib/THlib.lua")
---! blank callback func yet
lstg.plugin.DispatchEvent("afterTHlib")
