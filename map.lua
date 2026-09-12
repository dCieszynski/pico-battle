--map-- random terrain + movement / los / target queries
mw=20
mh=10

function gen_map()
  local g={}
  local towns={}
  for ty=0,mh-1 do
    g[ty]={}
    for tx=0,mw-1 do
      local ch="."
      if ty>=2 and ty<=mh-3 then
        local r=rnd(1)
        if r<0.16 then ch="f"
        elseif r<0.24 then ch="h"
        elseif r<0.30 then ch="t" end
      end
      g[ty][tx]=ch
      if ch=="t" then add(towns,{tx,ty}) end
    end
  end
  connect_towns(g,towns)
  board_map={}
  for ty=0,mh-1 do
    board_map[ty]={}
    for tx=0,mw-1 do
      local c=g[ty][tx]
      board_map[ty][tx]=c=="f" and 1 or c=="h" and 2
        or c=="t" and 3 or c=="r" and 4 or 0
    end
  end
end

function carve_road(g,a,b)
  local x,y=a[1],a[2]
  while x~=b[1] do x+=sn(b[1]-x) if g[y][x]~="t" then g[y][x]="r" end end
  while y~=b[2] do y+=sn(b[2]-y) if g[y][x]~="t" then g[y][x]="r" end end
end

function connect_towns(g,towns)
  if #towns<2 then return end
  local linked={[1]=true}
  local cur=1
  for n=2,#towns do
    local best,bd=nil,32767
    for j=1,#towns do
      if not linked[j] then
        local d=abs(towns[j][1]-towns[cur][1])+abs(towns[j][2]-towns[cur][2])
        if d<bd then bd=d best=j end
      end
    end
    carve_road(g,towns[cur],towns[best])
    linked[best]=true
    cur=best
  end
end

function tile_at(tx,ty)
  if tx<0 or tx>mw-1 or ty<0 or ty>mh-1 then return 1 end
  return board_map[ty][tx]
end

function unit_at(tx,ty)
  for u in all(units) do
    if u.alive and not u.offboard and u.tx==tx and u.ty==ty then return u end
  end
end

function sn(a)
  if a>0 then return 1 elseif a<0 then return -1 end
  return 0
end

_dirs8={{0,-1},{1,-1},{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1}}

function can_enter(u,tx,ty)
  if tx<0 or tx>mw-1 or ty<0 or ty>mh-1 then return false end
  if tile_at(tx,ty)==1 and not u.type.foot then return false end
  return true
end

function reachable(u,force)
  local res={}
  if not force and not u.canmove then return res end
  local base=u.type.move
  local onroad=tile_at(u.tx,u.ty)==4
  local maxs=base+(onroad and 1 or 0)
  local seen={}
  local q={{u.tx,u.ty,0}}
  seen[u.tx..","..u.ty]=true
  while #q>0 do
    local c=deli(q,1)
    local cx,cy,cs=c[1],c[2],c[3]
    if cs<maxs then
      for d in all(_dirs8) do
        local nx,ny=cx+d[1],cy+d[2]
        local ns=cs+1
        local key=nx..","..ny
        local okstep=ns<=base or (onroad and tile_at(nx,ny)==4)
        if okstep and not seen[key]
        and can_enter(u,nx,ny) and not unit_at(nx,ny) then
          seen[key]=true
          res[key]=true
          add(q,{nx,ny,ns})
        end
      end
    end
  end
  return res
end

function brigadier_of(team,brig)
  for u in all(units) do
    if u.alive and not u.offboard and u.team==team and u.brig==brig and u.type.cmd then
      return u
    end
  end
end

function in_cohesion(u)
  if u.type.cmd then return true end
  local b=brigadier_of(u.team,u.brig)
  if not b then return false end
  local mem={}
  for o in all(units) do
    if o.alive and o.team==u.team and o.brig==u.brig then
      mem[o.tx..","..o.ty]=o
    end
  end
  local seen={[b.tx..","..b.ty]=true}
  local q={b}
  while #q>0 do
    local c=deli(q,1)
    for d in all(_dirs8) do
      local k=(c.tx+d[1])..","..(c.ty+d[2])
      if mem[k] and not seen[k] then
        seen[k]=true
        add(q,mem[k])
      end
    end
  end
  return seen[u.tx..","..u.ty]==true
end

function enemy_adjacent(u)
  return #melee_targets(u)>0
end

function melee_targets(u)
  local res={}
  for d in all(_dirs8) do
    local o=unit_at(u.tx+d[1],u.ty+d[2])
    if o and o.team~=u.team then add(res,o) end
  end
  return res
end

function fire_targets(u)
  local res={}
  if enemy_adjacent(u) then return res end
  local hi=tile_at(u.tx,u.ty)==2
  for d in all(_dirs8) do
    for step=1,6 do
      local nx,ny=u.tx+d[1]*step,u.ty+d[2]*step
      if nx<0 or nx>mw-1 or ny<0 or ny>mh-1 then break end
      local o=unit_at(nx,ny)
      if o then
        if o.team~=u.team then add(res,{unit=o,dist=step}) end
        if not hi then break end
      else
        local t=tile_at(nx,ny)
        if (t==1 or t==2 or t==3) and not hi then break end
      end
    end
  end
  return res
end

function fire_range(u)
  local res={}
  if enemy_adjacent(u) then return res end
  local hi=tile_at(u.tx,u.ty)==2
  for d in all(_dirs8) do
    for step=1,6 do
      local nx,ny=u.tx+d[1]*step,u.ty+d[2]*step
      if nx<0 or nx>mw-1 or ny<0 or ny>mh-1 then break end
      local t=tile_at(nx,ny)
      if (t==1 or t==2 or t==3) and not hi then break end
      res[nx..","..ny]=true
      if unit_at(nx,ny) and not hi then break end
    end
  end
  return res
end
