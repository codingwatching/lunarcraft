local Vector = require "vector"
local Camera = require "camera"
local Collider = require "collider"

local Player = Object:extend()

local GRAVITY = 32

function Player:new(world)
  self.world = world

  self.position = Vector(0, 30, 0)
  self.velocity = Vector(0, 0, 0)
  self.accel = Vector(0, -GRAVITY, 0)

  self.speed = 1000

  self.width = 0.6
  self.height = 1.8

  self.yaw = math.pi/2
  self.pitch = 0

  self.collider = Collider(Vector(), Vector())
  self.ground = false

  self.camera = Camera(world)
end


function Player:update(dt)
  self:handleInput(dt)
  self:updateCollider()
  self:checkCollisions(dt)

  -- FIXME: position should not come first, but collisions won't work otherwise
  self.position = self.position + self.velocity * dt

  self.velocity.x = self.velocity.x * math.pow(0.95, dt * 100)
  self.velocity.z = self.velocity.z * math.pow(0.95, dt * 100)

  self.velocity = self.velocity + self.accel * dt

  self.camera.position = self.position + Vector(0, self.height, 0)
  self.camera:update(dt)
end

function Player:draw()
  self.camera:draw()
end

function Player:handleInput(dt)
  local dz, dx
  if love.keyboard.isDown "w" then dx = -1 end
  if love.keyboard.isDown "s" then dx = 1 end
  if love.keyboard.isDown "a" then dz = -1 end
  if love.keyboard.isDown "d" then dz = 1 end

  if love.keyboard.isDown "space" and self.ground then
    self.velocity.y = math.sqrt(2 * GRAVITY * 1.25)
    self.ground = false
  end

  local d = Vector(dx, 0, dz):rotated(self.yaw)
  self.accel.x = d.x * self.speed * dt
  self.accel.z = d.z * self.speed * dt
end

function Player:updateDirection(dx, dy)
  -- TODO: only update once (on camera or on player)
  self.yaw = self.yaw + dx * 0.001

  self.camera:updateDirection(dx, dy)
end

function Player:updateCollider()
  self.collider.pos1 = self.position - Vector(self.width/2, 0, self.width/2)
  self.collider.pos2 = self.position + Vector(self.width/2, self.height, self.width/2)
end

local function sign(x) return x < 0 and -1 or 1 end

function Player:checkCollisions(dt)
  for i = 1, 3 do
    local dv = self.velocity * dt
    local sx, sy, sz = sign(dv.x), sign(dv.y), sign(dv.z)

    local stepsXZ = math.floor(self.width/2)
    local stepsY = math.floor(self.height)

    local x, y, z = self.position:floored():unpack()
    local cx, cy, cz = (self.position + dv):floored():unpack()

    local potential = {}
    for i = x - sx * (stepsXZ+1), cx + sx * (stepsXZ+2), sx do
      for j = y - sy * (stepsY+2), cy + sy * (stepsY+3), sy do
        for k = z - sz * (stepsXZ+1), cz + sz * (stepsXZ+2), sz do
          local pos = Vector(i, j, k)
          local half = Vector(0.5, 0.5, 0.5)
          local block = self.world:getBlock(i, j, k)

          if block > 0 then
            local collider = Collider(pos - half, pos + half)

            local entry, normal = self.collider:collide(collider, dv)

            if entry then
              table.insert(potential, { entry = entry, normal = normal, pos = pos })
            end
          end

          -- TODO: allow different hitboxes for blocks
        end
      end
    end

    if #potential > 0 then
      -- get collision with smallest entry
      table.sort(potential, function(a, b) return a.entry < b.entry end)

      local entry, normal = potential[1].entry, potential[1].normal
      entry = entry - 0.0001

      if normal.x ~= 0 then
        self.velocity.x = 0
        self.position.x = self.position.x + entry * dv.x
      end

      if normal.y ~= 0 then
        self.velocity.y = 0
        self.position.y = self.position.y + entry * dv.y
      end

      if normal.z ~= 0 then
        self.velocity.z = 0
        self.position.z = self.position.z + entry * dv.z
      end

      if normal.y == 1 then
        self.ground = true
      end
    end
  end
end

return Player