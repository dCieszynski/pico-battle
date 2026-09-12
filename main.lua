--main-- picobattle - napoleonic wargame
function _init()
  game_state="title"
  banner_t=0
  bpop=0
  parts={}
  shk=0
  vs_cpu=false
  cpu={false,false}
end

function _update()
  update_fx()
  if btnp(4) then sfx(0,3) elseif btnp(5) then sfx(1,3) end
  if game_state~=pstate then pstate=game_state
    if game_state=="title" then music(0) end
  end
  if game_state=="title" then
    if btnp(4) then start_game()
    elseif btnp(5) then game_state="help" help_page=1
    elseif btnp(2) or btnp(3) then vs_cpu=not vs_cpu end
  elseif game_state=="help" then
    help_input()
  elseif game_state=="setup" then
    setup_input()
  elseif game_state=="play" then
    update_play()
  elseif game_state=="game_over" then
    if btnp(4) then game_state="title" end
  end
end

function _draw()
  if game_state=="title" then
    draw_title()
  elseif game_state=="help" then
    draw_help()
  elseif game_state=="setup" then
    draw_setup()
  elseif game_state=="play" then
    draw_play()
  elseif game_state=="game_over" then
    draw_over()
  end
end
