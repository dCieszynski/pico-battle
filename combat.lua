--combat--
function roll() return flr(rnd(6))+1 end

function unit_score(u,extra)
  local n=1
  if u.type.reroll then n+=1 end
  n+=extra or 0
  local best=0
  for i=1,n do
    local r=roll()
    if r>best then best=r end
  end
  if u.shaken then best-=3 elseif u.rattled then best-=2 end
  return best
end

function arty_melee_pen(u,foe)
  if not u.type.arty then return 0 end
  if foe.type.cav then return 3 end
  if is_foot(foe) then return 2 end
  return 0
end

function hill_bonus(u)
  if (is_foot(u) or u.type.cav) and tile_at(u.tx,u.ty)==2 then return 1 end
  return 0
end

function cav_terrain_pen(att,def)
  if not att.type.cav then return 0 end
  local t=tile_at(def.tx,def.ty)
  if t==1 or t==2 then return 1 end
  return 0
end

function close_combat(att,def)
  att.fought=true
  if def.type.cmd then
    local n=att.type.cav and 2 or 1
    push(def,att,n,false)
    banner_shove(att,def,n)
    cull_commanders() sweep_dead() check_win()
    return
  end
  burst((tcx(att.tx)+tcx(def.tx))/2,(tcy(att.ty)+tcy(def.ty))/2,7,10,7)
  jolt(1.5) sfx(2,0)
  local a_extra=(att.type.cav and is_foot(def) and not def.square) and 1 or 0
  local d_extra=(def.square and is_foot(def) and att.type.cav) and 1 or 0
  if tile_at(def.tx,def.ty)==3 then d_extra+=1 end
  local as=unit_score(att,a_extra)-arty_melee_pen(att,def)+hill_bonus(att)-cav_terrain_pen(att,def)
  local ds=unit_score(def,d_extra)-arty_melee_pen(def,att)+hill_bonus(def)
  local diff=as-ds
  banner_combat(att,def,as,ds,diff)
  if diff>0 then apply_result(def,att,diff)
  elseif diff<0 then apply_result(att,def,-diff) end
  cull_commanders() sweep_dead() check_win()
end

function apply_result(loser,winner,diff)
  if diff>=3 and not loser.type.cmd then
    eliminate(loser)
  else
    push(loser,winner)
  end
end

function eliminate(u)
  if u.type.cmd then return end
  u.alive=false
  burst(tcx(u.tx),tcy(u.ty),16,8,5)
  burst(tcx(u.tx),tcy(u.ty),3,6,5,-0.02,1)
  jolt(3) sfx(4,2)
end

function push(loser,winner,dist,shake)
  dist=dist or 1
  if shake==nil then shake=true end
  local dx,dy=0,(loser.team==1) and -1 or 1
  loser.facing={dx,dy}
  if shake then loser.shaken=true end
  burst(tcx(loser.tx),tcy(loser.ty),5,6,5)
  jolt(1) sfx(3,2)
  for i=1,dist do
    local nx,ny=loser.tx+dx,loser.ty+dy
    if nx<0 or nx>mw-1 or ny<0 or ny>mh-1 then
      rally(loser) return
    end
    local occ=unit_at(nx,ny)
    if occ then
      if occ.team==loser.team then
        push(occ,loser)
        if unit_at(nx,ny) then eliminate(loser) return end
        loser.tx,loser.ty=nx,ny
      else
        eliminate(loser) return
      end
    elseif can_enter(loser,nx,ny) then
      loser.tx,loser.ty=nx,ny
    else
      eliminate(loser) return
    end
  end
end

function rally(u)
  if u.type.cmd then u.offboard=true return end
  local need=(u.type.guard or u.type.arty) and 3 or 4
  if roll()<need then u.alive=false end
end

function arty_fire(att,ti)
  local def=ti.unit
  local d=ti.dist
  local tx0,ty0=def.tx,def.ty
  burst(tcx(att.tx),tcy(att.ty),5,6,5,-0.02,1)
  jolt(1) sfx(5,0)
  local need=(d>=6) and 6 or ((d==5) and 5 or 4)
  local hit=roll()
  local fx="miss"
  if hit>=need then
    burst(tcx(tx0),tcy(ty0),14,10,8)
    burst(tcx(tx0),tcy(ty0),4,6,5,-0.02,1)
    jolt(2.5) sfx(6,2)
    local e=roll()
    if e<=3 then fx="no effect"
    elseif def.type.cmd then
      if e==4 then
        def.shaken=true
        def.facing={sn(def.tx-att.tx),sn(def.ty-att.ty)}
        fx="disrupted"
      else
        push(def,att,(e==6) and 2 or 1,false)
        fx="pushed back"
      end
    elseif e==4 then
      def.shaken=true
      def.facing={sn(def.tx-att.tx),sn(def.ty-att.ty)}
      fx="disrupted"
    elseif e==5 then
      if def.type.guard then fx="guard holds"
      else eliminate(def) fx="destroyed" end
    else
      eliminate(def) fx="destroyed"
    end
  else
    burst(tcx(tx0)+rnd(7)-3,tcy(ty0)+rnd(7)-3,4,6,5)
  end
  att.fired=true
  banner_arty(att,need,hit,fx,def)
  cull_commanders() sweep_dead() check_win()
end

function sweep_dead()
  for u in all(units) do
    if not u.alive then del(units,u) end
  end
end

function brig_dead(team,b)
  for u in all(units) do
    if u.alive and u.team==team and u.brig==b and not u.type.cmd then
      return false
    end
  end
  return true
end

function cull_commanders()
  for u in all(units) do
    if u.alive and u.type.cmd and brig_dead(u.team,u.brig) then
      u.alive=false
    end
  end
end

function brigs_lost(team)
  local n=0
  for b=1,3 do if brig_dead(team,b) then n+=1 end end
  return n
end

function check_win()
  if brigs_lost(1)>=2 then win(2)
  elseif brigs_lost(2)>=2 then win(1) end
end

function win(team)
  winner=team
end
