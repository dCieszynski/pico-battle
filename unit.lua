--unit-- base prototype + 6 troop types
unit={}
unit.__index=unit
function unit:new(o)
  o=o or {}
  setmetatable(o,self)
  return o
end

brigadier=unit:new({name="cmd",move=2,shape="cmd",cmd=true})
infantry =unit:new({name="inf",move=1,shape="inf",foot=true})
guard    =unit:new({name="grd",move=1,shape="grd",foot=true,guard=true,reroll=true})
lightcav =unit:new({name="lcv",move=2,shape="lcv",cav=true})
heavycav =unit:new({name="hcv",move=2,shape="hcv",cav=true,reroll=true})
artillery=unit:new({name="art",move=1,shape="art",arty=true})

function spawn(t,team,brig,tx,ty)
  add(units,{
    type=t,team=team,brig=brig,tx=tx,ty=ty,
    facing={0,(team==1) and 1 or -1},
    square=false,shaken=false,rattled=false,
    moved=false,fired=false,fought=false,
    canmove=true,alive=true})
end

function is_foot(u) return u.type.foot end
