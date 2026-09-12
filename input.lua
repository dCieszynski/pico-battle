--input-- player controls, one routine per phase
function move_cursor()
  if btnp(0) then cx=max(0,cx-1) end
  if btnp(1) then cx=min(mw-1,cx+1) end
  if btnp(2) then cy=max(0,cy-1) end
  if btnp(3) then cy=min(mh,cy+1) end
end

function help_input()
  if btnp(5) then game_state="title"
  elseif btnp(4) or btnp(1) then
    help_page+=1
    if help_page>help_pages then game_state="title" end
  elseif btnp(0) then
    help_page=max(1,help_page-1)
  end
end

function setup_input()
  if cpu[setup_team] then ai_setup() return end
  if setup_phase=="compose" then compose_input()
  else place_input() end
end

function compose_input()
  if draft_hidden then
    if btnp(0) then view_col=max(0,view_col-1) end
    if btnp(1) then view_col=min(mw-1,view_col+1) end
    if btnp(4) or btnp(5) then draft_hidden=false end
    return
  end
  if btnp(2) then cur_sel=max(1,cur_sel-1) end
  if btnp(3) then cur_sel=min(5,cur_sel+1) end
  if btnp(1) then
    if comp_total()<4 and avail(setup_team,cur_sel)>0 then
      cur_counts[cur_sel]+=1
    end
  end
  if btnp(0) then
    if cur_counts[cur_sel]>0 then cur_counts[cur_sel]-=1 end
  end
  if btnp(5) then draft_hidden=true view_col=9 return end
  if btnp(4) and comp_total()==4 then
    comp[setup_team][pcount[setup_team]+1]=materialize()
    reset_counts()
    setup_phase="place"
    sr=first_free_base(setup_team)
  end
end

function place_input()
  if btnp(0) then sr=max(0,sr-1) end
  if btnp(1) then sr=min(mw-3,sr+1) end
  if btnp(4) and try_place(setup_team,sr) then
    if pcount[1]>=3 and pcount[2]>=3 then
      finish_setup()
    else
      setup_team=(setup_team==1) and 2 or 1
      setup_phase="compose"
      reset_counts() cur_sel=1
    end
  elseif btnp(5) then
    setup_phase="compose"
    reset_counts() cur_sel=1
  end
end

function player_turn()
  if not sel and cy==mh then
    if btnp(4) then next_phase() end
    move_cursor() return
  end
  if phase=="move" then move_phase()
  elseif phase=="arty" then arty_phase()
  elseif phase=="combat" then combat_phase() end
end

function turn_input(u)
  if btnp(0) then u.facing={-1,0} end
  if btnp(1) then u.facing={1,0} end
  if btnp(2) then u.facing={0,-1} end
  if btnp(3) then u.facing={0,1} end
end

function savemv(u)
  lastmv={u=u,x=u.tx,y=u.ty,f=u.facing,sq=u.square}
end

function move_phase()
  if not sel then
    move_cursor()
    if btnp(4) then
      local u=unit_at(cx,cy)
      if lastmv and u==lastmv.u then
        local m=lastmv
        m.u.tx,m.u.ty=m.x,m.y
        m.u.facing=m.f m.u.square=m.sq m.u.moved=false
        lastmv=nil
      elseif u and u.team==active and not u.moved
      and (u.canmove or u.square or u.rattled) then
        sel=u reach=reachable(u)
      end
    end
  elseif sel.rattled then
    turn_input(sel)
    if btnp(4) then sel.moved=true sel=nil
    elseif btnp(5) then sel=nil end
  else
    move_cursor()
    if btnp(4) then
      if cx==sel.tx and cy==sel.ty then
        if is_foot(sel) then savemv(sel) sel.square=not sel.square sel.moved=true end
        sel=nil
      elseif reach[cx..","..cy] then
        savemv(sel)
        sel.facing={sn(cx-sel.tx),sn(cy-sel.ty)}
        sel.tx,sel.ty=cx,cy
        sel.moved=true sel=nil
      end
    elseif btnp(5) then sel=nil end
  end
end

function arty_phase()
  if not sel then
    move_cursor()
    if btnp(4) then
      local u=unit_at(cx,cy)
      if u and u.team==active and u.type.arty
      and not u.moved and not u.fired and not u.rattled then
        local ts=fire_targets(u)
        if #ts>0 then
          sel=u atargets=ts
          cx,cy=ts[1].unit.tx,ts[1].unit.ty
        end
      end
    end
  else
    move_cursor()
    if btnp(4) then
      for ti in all(atargets) do
        if ti.unit.tx==cx and ti.unit.ty==cy then
          arty_fire(sel,ti) sel=nil return
        end
      end
    elseif btnp(5) then sel=nil end
  end
end

function combat_phase()
  if not sel then
    move_cursor()
    if btnp(4) then
      local u=unit_at(cx,cy)
      if u and u.team==active and not u.type.cmd
      and not u.fought and not u.rattled then
        local ts=melee_targets(u)
        if #ts>0 then sel=u ctargets=ts cx,cy=ts[1].tx,ts[1].ty end
      end
    end
  else
    move_cursor()
    if btnp(4) then
      for d in all(ctargets) do
        if d.tx==cx and d.ty==cy then
          close_combat(sel,d) sel=nil return
        end
      end
    elseif btnp(5) then sel=nil end
  end
end
