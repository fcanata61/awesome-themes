local module = {}

module.starts_with = function(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

module.split = function(str, delimiter)
    if str == nil then
        return {}
    end
    local ret = {''}
    count = 1
    for i = 1, string.len(str) do
        local c = str:sub(i,i)
        if c == delimiter then
            count = count + 1
            ret[count] = ''
        else
            ret[count] = ret[count] .. c
        end
    end
    return ret
end

module.pad = function(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end

return module
