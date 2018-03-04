local quadHelp = {}

function quadHelp.newQuadData(image, rows, columns, sizeX, sizeY)
  local quadData = {
    img = image,
    quads = {}
    }
  for row = 0, rows-1 do
    for column = 0, columns-1 do
      table.insert(quadData.quads, love.graphics.newQuad(sizeX*column, sizeY*row, sizeX, sizeY, quadData.img:getDimensions()))
    end
  end
  return quadData
end

return quadHelp