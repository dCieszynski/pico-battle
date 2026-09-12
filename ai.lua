--ai-- optional cpu (vs_cpu): calls the same action fns the human input does
function cheby(ax,ay,bx,by) return max(abs(ax-bx),abs(ay-by)) end

function ai_target_brig(team)
  local bb,bn
  for b=1,3 do
    local n=0
    for u in all(units) do
      if u.alive and u.team~=team and u.brig==b and not u.type.cmd then n+=1 end
    end
    if n>0 and (not bn or n<bn) then bb=b bn=n end
  end
  return bb
end

function nearest_enemy(tx,ty,team)
  local tb=ai_target_brig(team)
  local best,bd=nil,32767
  for u in all(units) do
    if u.alive and not u.offboard and u.team~=team and u.brig==tb then
      local d=cheby(tx,ty,u.tx,u.ty)
      if d<bd then bd=d best=u end
    end
  end
  return best
end

function nearest_member(team,brig,tx,ty,ex)
  local best,bd=nil,32767
  for u in all(units) do
    if u.alive and not u.offboard and u~=ex
    and u.team==team and u.brig==brig and not u.type.cmd then
      local d=cheby(tx,ty,u.tx,u.ty)
      if d<bd then bd=d best=u end
    end
  end
  return best
end

function ai_setup()
  if ai_t>0 then ai_t-=1 return end
  if setup_phase=="compose" then
    reset_counts()
    while comp_total()<4 do
      local ti=flr(rnd(5))+1
      if avail(setup_team,ti)>0 then cur_counts[ti]+=1 end
    end
    comp[setup_team][pcount[setup_team]+1]=materialize()
    reset_counts()
    setup_phase="place"
    sr=ai_pick_base(setup_team)
  elseif try_place(setup_team,sr) or ai_place(setup_team) then
    if pcount[1]>=3 and pcount[2]>=3 then
      finish_setup()
    else
      setup_team=(setup_team==1) and 2 or 1
      setup_phase="compose"
      reset_counts() cur_sel=1
    end
  end
  ai_t=18
end

function free_bases(team)
  local r={}
  for b=0,mw-3 do if band_free(team,b) then add(r,b) end end
  return r
end

function ai_pick_base(team)
  local bases=free_bases(team)
  if #bases==0 then return -1 end
  return bases[flr(rnd(#bases))+1]
end

function ai_place(team)
  local bases=free_bases(team)
  for i=#bases,2,-1 do
    local j=flr(rnd(i))+1
    bases[i],bases[j]=bases[j],bases[i]
  end
  for b in all(bases) do
    if try_place(team,b) then return true end
  end
  return false
end

function ai_update()
  if ai_t>0 then ai_t-=1 return end
  if phase=="move" then ai_move()
  elseif phase=="arty" then ai_arty()
  elseif phase=="combat" then ai_combat() end
end

function ai_tile_score(u,tx,ty)
  local e=nearest_enemy(tx,ty,u.team)
  local s=e and cheby(tx,ty,e.tx,e.ty) or 0
  local anchor
  if u.type.cmd then anchor=nearest_member(u.team,u.brig,tx,ty,u)
  else anchor=brigadier_of(u.team,u.brig) end
  if anchor then
    local d=cheby(tx,ty,anchor.tx,anchor.ty)
    if d>1 then s+=(d-1)*3 end
  end
  return s
end

function ai_pick_move(u)
  local best,bs=nil,ai_tile_score(u,u.tx,u.ty)
  for k in pairs(reachable(u)) do
    local p=split(k,",")
    local s=ai_tile_score(u,p[1],p[2])
    if s<bs then bs=s best={p[1],p[2]} end
  end
  return best
end

function ai_move()
  for u in all(units) do
    if u.team==active and u.alive and not u.moved then
      if not (u.type.arty and #fire_targets(u)>0) then
        if u.canmove then
          local d=ai_pick_move(u)
          if d then
            u.facing={sn(d[1]-u.tx),sn(d[2]-u.ty)}
            u.tx,u.ty=d[1],d[2]
          end
          u.moved=true ai_t=12 return
        else
          u.moved=true
        end
      end
    end
  end
  next_phase()
end

function ai_arty()
  for u in all(units) do
    if u.team==active and u.alive and u.type.arty
    and not u.moved and not u.fired and not u.rattled then
      local ts=fire_targets(u)
      if #ts>0 then
        local best=ts[1]
        for t in all(ts) do if t.dist<best.dist then best=t end end
        arty_fire(u,best) ai_t=18 return
      end
    end
  end
  next_phase()
end

function ai_dice(u,extra)
  local n=1
  if u.type.reroll then n+=1 end
  if extra then n+=1 end
  return n
end

function ai_edge(att,def)
  local a_extra=att.type.cav and is_foot(def) and not def.square
  local d_extra=def.square and is_foot(def) and att.type.cav
  local av=ai_dice(att,a_extra)-arty_melee_pen(att,def)+hill_bonus(att)-cav_terrain_pen(att,def)
  local dv=ai_dice(def,d_extra)-arty_melee_pen(def,att)+hill_bonus(def)
  if tile_at(def.tx,def.ty)==3 then dv+=1 end
  if att.shaken then av-=3 elseif att.rattled then av-=2 end
  if def.shaken then dv-=3 elseif def.rattled then dv-=2 end
  return av-dv
end

function ai_favorable(u,foe)
  if foe.type.cmd then return true end
  return ai_edge(u,foe)>=0
end

function ai_combat()
  for u in all(units) do
    if u.team==active and u.alive and not u.type.cmd
    and not u.fought and not u.rattled then
      local pick,pe
      for foe in all(melee_targets(u)) do
        if ai_favorable(u,foe) then
          local e=foe.type.cmd and 99 or ai_edge(u,foe)
          if not pick or e>pe then pick,pe=foe,e end
        end
      end
      if pick then close_combat(u,pick) ai_t=18 return end
    end
  end
  next_phase()
end
