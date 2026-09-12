--fx-- particles + screen shake
parts={}
shk=0

function tcx(x) return x*8+3 end
function tcy(y) return y*8+11 end
function jolt(s) shk=max(shk,s) end

function update_fx()
  if shk>0 then shk-=1 end
  if bpop>0 then bpop-=1 end
  for p in all(parts) do
    p[1]+=p[3] p[2]+=p[4]
    p[4]+=p[5]
    p[3]*=0.9 p[4]*=0.9
    p[6]-=1
    if p[6]<=0 then del(parts,p) end
  end
end

function draw_fx()
  for p in all(parts) do
    local c=(p[6]<5) and p[8] or p[7]
    if p[9]>0 then circfill(p[1],p[2],p[9],c) else pset(p[1],p[2],c) end
  end
end

function burst(x,y,n,c0,c1,g,rad)
  for i=1,n do
    local a,s=rnd(1),0.4+rnd(1.4)
    add(parts,{x,y,cos(a)*s,sin(a)*s,g or 0.06,10+rnd(8),c0,c1,rad or 0})
  end
end
