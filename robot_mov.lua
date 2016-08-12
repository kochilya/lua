r = require ('robot')
os = require ('os')
local ret = {}

function ret.FW(dist)
  dist = dist or 1
  for i=1,dist do
    while not r.forward() do
      os.sleep(1)
    end
  end
end

function ret.BW(dist)
  dist = dist or 1
  for i=1,dist do
    while not r.back() do
      os.sleep(1)
    end
  end
end

function ret.UP(dist)
  dist = dist or 1
  for i=1,dist do
    while not r.up() do
      os.sleep(1)
    end
  end
end

function ret.DN(dist)
  dist = dist or 1
  for i=1,dist do
    while not r.down() do
      os.sleep(1)
    end
  end
end

function ret.TL(cnt)
  cnt = cnt or 1
  for i=1,cnt do
    r.turnLeft()
  end
end

function ret.TR(cnt)
  cnt = cnt or 1
  for i=1,cnt do
    r.turnRight()
  end
end

function ret.TA()
  r.turnAround()
end

return ret;