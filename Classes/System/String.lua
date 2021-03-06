local String = {}

function String:filterLetters(self, options)
  if self == '' then 
    return nil
  end

  local retString = self
  if options and options.withSpaces then 
    retString = string.sub(retString, string.find(retString, '[^%c%d]+'))
  else
    retString = string.sub(retString, string.find(retString, '%a+'))
  end

  return retString
end

function String:filterNumbers(self, options)
  if self == '' then 
    return nil
  end

  local retNumber = self
  if options and options.withSpaces then 
    retNumber = string.sub(retNumber, string.find(retNumber, '[^%c%a]+'))
  else
    retNumber = tonumber(string.sub(retNumber, string.find(retNumber, '%d+')))
  end

  return retNumber
end

function String:filterAlphaNumeric(self, options)
  if self == '' then 
    return nil
  end

  local retString = self
  if options and options.withSpaces then 
    retString = string.sub(retString, string.find(retString, '[^%c]+'))
  else
    retString = string.sub(retString, string.find(retString, '%w+'))
  end

  return retString
end

function String:split(self, delimiter)
  if self == '' then 
    return nil
  end
  
  local result = {}
  local from  = 1
  local delim_from, delim_to = string.find(self, delimiter, from)
  while delim_from do
    table.insert(result, string.sub(self, from , delim_from - 1 ))
    from = delim_to + 1
    delim_from, delim_to = string.find(self, delimiter, from)
  end
  table.insert(result, string.sub(self, from))
  
  return result
end

function String:toTitleCase(self)
  return string.gsub(" " .. self, "%W%l", string.upper):sub(2)
end

return String