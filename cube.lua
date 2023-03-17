local tilesetSize = 512
local tileSize = 16
local step = tileSize / tilesetSize

local format = {
  { "VertexPosition", "float", 3 },
  { "VertexTexCoord", "float", 2 },
}

local vertices = {
  { -1, -1,  1 },
  {  1, -1,  1 },
  { -1,  1,  1 },
  {  1,  1,  1 },
  { -1,  1, -1 },
  {  1,  1, -1 },
  { -1, -1, -1 },
  {  1, -1, -1 },
}

local uvs = {
  { 0, 1 },
  { 1, 1 },
  { 0, 0 },
  { 1, 0 },
}

-- vertex index / uv index
local faces = {
  { 1, 1, 2, 2, 3, 3 },  -- front
  { 3, 3, 2, 2, 4, 4 },  -- front
  { 3, 1, 4, 2, 5, 3 },  -- top
  { 5, 3, 4, 2, 6, 4 },  -- top
  { 5, 4, 6, 3, 7, 2 },  -- back
  { 7, 2, 6, 3, 8, 1 },  -- back
  { 7, 1, 8, 2, 1, 3 },  -- bottom
  { 1, 3, 8, 2, 2, 4 },  -- botoom
  { 2, 1, 8, 2, 4, 3 },  -- right
  { 4, 3, 8, 2, 6, 4 },  -- right
  { 7, 1, 1, 2, 5, 3 },  -- left
  { 5, 3, 1, 2, 3, 4 },  -- left
}

return function(textures)
  local cube = {}

  for i, face in ipairs(faces) do
    local tile = textures[math.ceil(i / 2)]

    for j = 1, 6, 2 do
      local u = (tile[1] - 1) * step
      local v = (tile[2] - 1) * step

      local vertex = face[j]
      local uv = face[j+1]

      cube[#cube + 1] = {
        vertices[vertex][1] * 0.5,
        vertices[vertex][2] * 0.5,
        vertices[vertex][3] * 0.5,
        u + uvs[uv][1] * step,
        v + uvs[uv][2] * step,
      }
    end
  end

  -- local mesh = love.graphics.newMesh(format, cube, "triangles")
  -- mesh:setTexture(tileset)

  return cube
end
