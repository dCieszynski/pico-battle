--draw-- screens, terrain, units, overlays, hud, banners
function set_cam(fx)
  local ox,oy=0,0
  if shk>0 then ox=flr(rnd(shk*2+1))-shk oy=flr(rnd(shk*2+1))-shk end
  camera(mid(0,fx*8-60,mw*8-128)+ox,oy)
end

function cprint(s,y,c)
  local w=0
  for i=1,#s do w+=(ord(s,i)>=128) and 8 or 4 end
  print(s,(128-w)/2,y,c)
end

function blink(n) return flr(t()*n)%2==0 end

function draw_title()
  camera()
  palt(0,false)
  spr(0,0,0,16,16)
  palt()
  cprint("napoleonic wargame",40,7)
  cprint(vs_cpu and "1 player  vs cpu" or "2 players  hot-seat",
    56,vs_cpu and 9 or 12)
  cprint("updn  change mode",68,6)
  cprint("press \151 to start",82,blink(2) and 7 or 10)
  cprint("press \142 how to play",92,6)
end

help_data={
  {"the game",{
    "a napoleonic hot-seat",
    "wargame for two players.",
    "",
    "each army: 3 brigades of 5",
    "(1 brigadier +4 fighters).",
    "",
    "win by destroying 2 of",
    "the enemy's 3 brigades.",
    "arrows move, \151 pick,",
    "\151 a moved unit = undo,",
    "\142 cancel selection."}},
  {"your turn",{
    "3 phases each turn:",
    "move  - move units",
    "fire  - artillery shoots",
    "fight - close combat",
    "",
    "to advance: go down to the",
    "next-phase button & \151 it.",
    "fire & fight are optional.",
    "hover a foe to see its",
    "reach; a gun for its range."}},
  {"units",{
    "cmd brigadier: cant fight",
    "inf infantry: forms square",
    "grd guard: rerolls, tough",
    "lcv light cav: fast vs foot",
    "hcv heavy cav: charge bonus",
    "art artillery: fires, weak",
    "",
    "shape=type col=team pip=brig"}},
  {"terrain",{
    "plains: open ground",
    "forest: foot only, hides",
    "hill: +1 fight, blocks los",
    "town: defenders +1 die",
    "road: +1 move along it"}},
}
help_pages=#help_data

function draw_help()
  cls()
  camera()
  local p=help_data[help_page]
  rectfill(0,0,127,7,0)
  print("how to play",2,1,12)
  print(help_page.."/"..help_pages,108,1,6)
  print(p[1],2,12,10)
  for i=1,#p[2] do print(p[2][i],2,12+i*9,7) end
  rectfill(0,121,127,127,0)
  print("\151 next   \142 back to title",2,122,6)
end

function draw_over()
  cls()
  camera()
  cprint("player "..winner.." wins!",50,tc(winner))
  cprint("two brigades broken",62,6)
  cprint("press \151 to restart",82,7)
end

function draw_setup()
  cls()
  if setup_phase=="place" then
    set_cam(sr+1)
    draw_terrain() draw_units() draw_place_preview()
  elseif draft_hidden then
    set_cam(view_col)
    draw_terrain() draw_units()
  else
    set_cam(9)
    draw_terrain() draw_units()
  end
  camera()
  if setup_phase=="compose" and not draft_hidden then draw_compose() end
  draw_setup_hud()
end

function draw_compose()
  rectfill(16,22,111,98,0)
  rect(16,22,111,98,7)
  print("draft brigade "..(pcount[setup_team]+1),22,26,
    brig_col(pcount[setup_team]+1))
  print("add  left",70,36,5)
  for ti=1,5 do
    local y=36+ti*9
    local c=(ti==cur_sel) and 7 or 6
    if ti==cur_sel then print(">",18,y,7) end
    print(plabel[ti],24,y,c)
    print(cur_counts[ti],80,y,c)
    print(avail(setup_team,ti),98,y,c)
  end
  local tot=comp_total()
  print("total "..tot.."/4",22,90,(tot==4) and 11 or 8)
end

function draw_place_preview()
  local rows=(setup_team==1) and {0,1} or {mh-2,mh-1}
  for r in all(rows) do for tx=0,mw-1 do
    rect(tx*8,r*8+8,tx*8+7,r*8+15,setup_team==1 and 1 or 2)
  end end
  local b=pcount[setup_team]+1
  local ok=band_free(setup_team,sr)
  local col=ok and tc(setup_team) or 5
  for cell in all(brig_layout(comp[setup_team][b],sr)) do
    local tx=sr+cell[2]
    local ty=(setup_team==1) and cell[3] or (mh-1-cell[3])
    local px,py=tx*8,ty*8+8
    draw_shape({type=cell[1]},px,py,col)
    pset(px,py,brig_col(b)) pset(px+1,py,brig_col(b))
    rect(px,py,px+7,py+7,ok and 7 or 2)
  end
end

function draw_setup_hud()
  rectfill(0,0,127,7,0)
  print("setup "..pn(setup_team),1,1,tc(setup_team))
  print("brigade "..(pcount[setup_team]+1),52,1,
    brig_col(pcount[setup_team]+1))
  rectfill(0,121,127,127,0)
  if cpu[setup_team] then
    print("cpu drafting...",2,122,6)
  elseif setup_phase=="compose" then
    if draft_hidden then
      print("lr scroll   \151\142 draft",2,122,6)
    else
      print("updn pick lr+- \151ok \142map",2,122,6)
    end
  else
    print("lr move   \151 place   x back",2,122,6)
  end
end

function draw_play()
  cls()
  set_cam(cx)
  draw_terrain()
  draw_overlays()
  draw_units()
  draw_fx()
  local act=phase~="pass" and banner_t==0 and not cpu[active]
  if act and cy<mh then draw_cursor() end
  camera()
  draw_hud()
  if act and not sel then draw_next_btn() end
  if phase=="pass" then draw_pass()
  elseif banner_t~=0 then draw_banner() end
end

function draw_next_btn()
  rectfill(72,93,126,102,(cy==mh or blink(2)) and 10 or 9)
  if cy==mh then rect(71,92,127,103,7) end
  print("next phase",75,95,0)
end

function road_link(tx,ty)
  local t=tile_at(tx,ty)
  return t==4 or t==3
end

function draw_terrain()
  for ty=0,mh-1 do for tx=0,mw-1 do
    local px,py=tx*8,ty*8+8
    local t=tile_at(tx,ty)
    if t==1 then
      rectfill(px,py,px+7,py+7,0)
      pset(px+2,py+3,3) pset(px+5,py+2,3) pset(px+3,py+5,3)
    else
      rectfill(px,py,px+7,py+7,1)
      if t==2 then
        line(px+1,py+6,px+6,py+6,4)
        line(px+1,py+6,px+3,py+2,4)
        line(px+6,py+6,px+3,py+2,4)
      elseif t==3 then
        if road_link(tx-1,ty) then line(px,py+3,px+3,py+3,4) end
        if road_link(tx+1,ty) then line(px+3,py+3,px+7,py+3,4) end
        if road_link(tx,ty-1) then line(px+3,py,px+3,py+3,4) end
        if road_link(tx,ty+1) then line(px+3,py+3,px+3,py+7,4) end
        rect(px+2,py+3,px+5,py+6,6)
        line(px+2,py+3,px+3,py+1,6)
        line(px+5,py+3,px+3,py+1,6)
      elseif t==4 then
        local mx,my=px+3,py+3
        local n=false
        if road_link(tx-1,ty) then line(px,my,mx,my,4) n=true end
        if road_link(tx+1,ty) then line(mx,my,px+7,my,4) n=true end
        if road_link(tx,ty-1) then line(mx,py,mx,my,4) n=true end
        if road_link(tx,ty+1) then line(mx,my,mx,py+7,4) n=true end
        if not n then line(px,my,px+7,my,4) end
      end
    end
  end end
  for i=0,mw do line(i*8,8,i*8,8+mh*8,0) end
  for j=0,mh do line(0,8+j*8,mw*8,8+j*8,0) end
end

function draw_overlays()
  draw_arty_range()
  draw_enemy_move()
  if not sel then return end
  if phase=="move" then
    for ty=0,mh-1 do for tx=0,mw-1 do
      if reach[tx..","..ty] then
        rect(tx*8,ty*8+8,tx*8+7,ty*8+15,12)
      end
    end end
  else
    local list=(phase=="arty") and atargets or ctargets
    local pc=blink(3) and 8 or 9
    for d in all(list) do
      local u=d.unit or d
      rect(u.tx*8,u.ty*8+8,u.tx*8+7,u.ty*8+15,pc)
    end
  end
end

function draw_arty_range()
  if phase~="move" and phase~="arty" then return end
  local g=(sel and sel.type.arty) and sel or unit_at(cx,cy)
  if not g or not g.type.arty then return end
  local rng=fire_range(g)
  for ty=0,mh-1 do for tx=0,mw-1 do
    if rng[tx..","..ty] then
      local px,py=tx*8+3,ty*8+11
      rectfill(px,py,px+1,py+1,9)
    end
  end end
end

function draw_enemy_move()
  if phase=="pass" or sel then return end
  local u=unit_at(cx,cy)
  if not u or u.team==active or u.square or u.offboard then return end
  local r=reachable(u,true)
  for ty=0,mh-1 do for tx=0,mw-1 do
    if r[tx..","..ty] then
      rect(tx*8,ty*8+8,tx*8+7,ty*8+15,8)
    end
  end end
end

function brig_col(b)
  return (b==1) and 7 or ((b==2) and 10 or 9)
end

function diamond(px,py,col,fill)
  line(px+3,py,px+6,py+3,col) line(px+6,py+3,px+3,py+6,col)
  line(px+3,py+6,px,py+3,col)  line(px,py+3,px+3,py,col)
  if fill then
    line(px+1,py+3,px+5,py+3,col)
    line(px+3,py+1,px+3,py+5,col)
  end
end

function draw_shape(u,px,py,col)
  local s=u.type.shape
  local mx,my=px+3,py+3
  if s=="inf" then circfill(mx,my,2,col)
  elseif s=="grd" then circfill(mx,my,2,col) circ(mx,my,3,col)
  elseif s=="lcv" then diamond(px,py,col,false)
  elseif s=="hcv" then diamond(px,py,col,true)
  elseif s=="art" then rect(px+1,py+1,px+6,py+6,col) pset(mx,my,col)
  elseif s=="cmd" then
    circ(mx,my,3,col)
    line(mx,py,mx,py+6,col) line(px,my,px+6,my,col)
  end
end

function acted(u)
  return (phase=="move" and u.moved)
    or (phase=="arty" and u.fired)
    or (phase=="combat" and u.fought)
end

function draw_units()
  for u in all(units) do
    if u.alive and not u.offboard then
      local px,py=u.tx*8,u.ty*8+8
      local mx,my=px+3,py+3
      local col=tc(u.team)
      if u.team==active and acted(u) then col=5 end
      draw_shape(u,px,py,col)
      local bc=brig_col(u.brig)
      pset(px,py,bc) pset(px+1,py,bc)
      local f=u.facing
      line(mx,my,mx+f[1]*3,my+f[2]*3,7)
      if u.square then rect(px,py,px+7,py+7,7) end
      if u.shaken or u.rattled then line(px+6,py,px+7,py,8) end
      if u==sel then rect(px-1,py-1,px+8,py+8,blink(4) and 10 or 7) end
    end
  end
end

function draw_cursor()
  local x0,y0=cx*8,cy*8+8
  rect(x0,y0,x0+7,y0+7,7)
  if blink(4) then
    rect(x0-1,y0-1,x0+8,y0+8,10)
  end
end

function phase_name()
  if phase=="move" then return "move"
  elseif phase=="arty" then return "fire"
  elseif phase=="combat" then return "fight" end
  return ""
end

function draw_hud()
  rectfill(0,0,127,7,0)
  print(pn(active),1,1,tc(active))
  print(phase_name(),18,1,7)
  if sel then
    print(sel.type.name..(sel.rattled and " turn!" or ""),46,1,10)
  end
  print(cpu[active] and "cpu thinking" or
    (sel and "\151ok \142back" or "\151pick"),80,1,6)
  rectfill(0,121,127,127,0)
  print("brigades lost  p1:"..brigs_lost(1).." p2:"..brigs_lost(2),1,122,6)
end

function set_banner(lines,dur)
  banner_lines=lines
  banner_t=dur or -1
  bpop=6
end

function tc(t) return t==1 and 12 or 8 end
function pn(t) return t==1 and "p1" or "p2" end
function pl(u) return pn(u.team).." "..u.type.name end
function tcol(u) return tc(u.team) end

function draw_banner()
  local n=#banner_lines
  local w=0
  for l in all(banner_lines) do
    local lw=#l[1]*4
    if lw>w then w=lw end
  end
  w+=14
  local h=n*9+7
  local s=(bpop>0) and (1-bpop*0.13) or 1
  local hw=flr(w/2*s) local hh=flr(h/2*s)
  rectfill(64-hw,64-hh,64+hw,64+hh,0)
  rect(64-hw,64-hh,64+hw,64+hh,7)
  if bpop>0 then return end
  local y0=64-flr(h/2)
  for i=1,n do
    local l=banner_lines[i]
    print(l[1],64-#l[1]*2,y0+5+(i-1)*9,l[2])
  end
end

function draw_pass()
  rectfill(8,42,119,80,0)
  rect(8,42,119,80,7)
  local w="player "..active.." turn"
  print(w,64-#w*2,52,tc(active))
  cprint("press \151 when ready",66,7)
end

function banner_combat(att,def,as,ds,diff)
  local r=(diff==0) and "stalemate"
    or ((abs(diff)>=3) and "eliminated!" or "pushed back")
  set_banner({
    {"close combat",6},
    {pl(att).."  rolls "..as,tcol(att)},
    {pl(def).."  rolls "..ds,tcol(def)},
    {r,10},
  })
end

function banner_arty(att,need,hit,fx,def)
  set_banner({
    {"artillery fire",6},
    {pl(att).."  need "..need.."+ rolled "..hit,tcol(att)},
    {pl(def)..":  "..fx,tcol(def)},
  })
end

function banner_shove(att,def,n)
  set_banner({
    {"brigadier shoved!",6},
    {pl(att).." shoves",tcol(att)},
    {pl(def).." back "..n.." tile"..(n>1 and "s" or ""),tcol(def)},
  })
end
