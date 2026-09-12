--board-- draft pool, placement, turn/phase flow, play dispatch
ptypes={infantry,guard,artillery,lightcav,heavycav}
pmax  ={4,      2,    2,        2,       2}
plabel={"light inf","elite inf","artillery","light cav","heavy cav"}

brig_cmd={1,0}
brig_cells={{0,0},{2,0},{0,1},{2,1}}

function place(t,team,b,along,depth,base)
  local tx=base+along
  local ty=(team==1) and depth or (mh-1-depth)
  spawn(t,team,b,tx,ty)
end

function brig_layout(fighters,base)
  local r={{brigadier,brig_cmd[1],brig_cmd[2]}}
  for i=1,4 do
    local c=brig_cells[i]
    add(r,{fighters[i],c[1],c[2]})
  end
  return r
end

function place_brigade(team,b,base)
  for c in all(brig_layout(comp[team][b],base)) do
    place(c[1],team,b,c[2],c[3],base)
  end
end

function reset_counts() cur_counts={0,0,0,0,0} end

function comp_total()
  local s=0
  for i=1,5 do s+=cur_counts[i] end
  return s
end

function committed(team,ti)
  local n=0
  for b=1,pcount[team] do
    for f in all(comp[team][b]) do
      if f==ptypes[ti] then n+=1 end
    end
  end
  return n
end

function avail(team,ti)
  return pmax[ti]-committed(team,ti)-cur_counts[ti]
end

function materialize()
  local r={}
  for ti=1,5 do
    for j=1,cur_counts[ti] do add(r,ptypes[ti]) end
  end
  return r
end

function band_free(team,base)
  if base<0 or base>mw-3 then return false end
  for pb in all(pbases[team]) do
    if base<=pb+2 and pb<=base+2 then return false end
  end
  return true
end

function first_free_base(team)
  for base=0,mw-3 do if band_free(team,base) then return base end end
  return -1
end

function try_place(team,base)
  if not band_free(team,base) then return false end
  add(pbases[team],base)
  if pcount[team]<2 and first_free_base(team)<0 then
    del(pbases[team],base) return false
  end
  place_brigade(team,pcount[team]+1,base)
  pcount[team]+=1
  return true
end

function finish_setup()
  local r1,r2
  repeat r1=roll() r2=roll() until r1~=r2
  local first=(r1>r2) and 1 or 2
  set_banner({
    {"initiative  p1:"..r1.."  p2:"..r2,7},
    {"player "..first.." goes first",tc(first)},
  },90)
  music(2)
  sfx(9,0)
  game_state="play"
  begin_turn(first)
end

function start_game()
  units={}
  gen_map()
  winner=nil
  banner_t=0
  cpu={false,vs_cpu}
  ai_t=0
  pbases={{},{}}
  pcount={0,0}
  comp={{},{}}
  setup_team=1
  setup_phase="compose"
  reset_counts()
  cur_sel=1
  sr=0
  draft_hidden=false
  view_col=9
  game_state="setup"
end

function begin_turn(team)
  active=team
  for u in all(units) do
    if u.team==team then
      u.moved=false u.fired=false u.fought=false
      u.rattled=u.shaken
      u.shaken=false
      if u.rattled then u.facing={-u.facing[1],-u.facing[2]} end
      u.canmove=in_cohesion(u) and not u.square and not u.rattled and not u.offboard
    end
  end
  phase="move"
  sel=nil
  lastmv=nil
  first_cursor()
end

function first_cursor()
  for u in all(units) do
    if u.team==active and u.alive and not u.offboard then cx,cy=u.tx,u.ty return end
  end
  cx,cy=1,5
end

function next_phase()
  sel=nil
  if phase=="move" then
    phase="arty"
  elseif phase=="arty" then
    phase="combat"
  else
    end_turn()
  end
end

function end_turn()
  sweep_dead() check_win()
  if winner then game_state="game_over" music(-1) sfx(7,0) return end
  active=(active==1) and 2 or 1
  if cpu[active] then begin_turn(active) else phase="pass" end
end

function update_play()
  if banner_t~=0 then
    if banner_t>0 then banner_t-=1 end
    if btnp(4) or btnp(5) then banner_t=0 end
    if cpu[active] and banner_t<0 then banner_t=50 end
    return
  end
  if winner then game_state="game_over" music(-1) sfx(7,0) return end
  if phase=="pass" then
    if btnp(4) then begin_turn(active) end
    return
  end
  if cpu[active] then ai_update() return end
  player_turn()
end
