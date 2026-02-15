---! customized Lscreen.lua

--require("lib.Lscreen")

---todo:扩大实际活动范围尚未实现
function SetWorldV2(w, h, sl,sr,sb,st,bound, m)
    bound = bound or 32
    m = m or 15
    OriginalSetWorld(
    --l,r,b,t,
            (-w / 2), (w / 2), (-h / 2), (h / 2),
    --bl,br,bb,bt,
            (-w / 2) - bound, (w / 2) + bound, (-h / 2) - bound, (h / 2) + bound,
    --sl,sr,sb,st,
            sl,w,sb,h,
    --pl,pr,pb,pt
            (-w / 2), (w / 2), (-h / 2), (h / 2),
    --world mask
            m
    )
    SetBound(lstg.world.boundl, lstg.world.boundr, lstg.world.boundb, lstg.world.boundt)
end