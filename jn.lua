local jn = { _version = "0.0.2" }
local json = require("json")

function jn.to_json(tabl)
  local result = {}

  for key, value in pairs(tabl) do
    if type(value) == "screen" then
    elseif type(value) == "table" then
      table.insert(result, string.format("\"%s\": %s", key, jn.to_json(value)))
    else
      -- prepare json key-value pairs and save them in separate table
      table.insert(result, string.format("\"%s\": %s", key, json.stringify(value)))
    end
  end

  result = "{" .. table.concat(result, ",") .. "}"

  return result
end

return jn
