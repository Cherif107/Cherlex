local Class = require 'cherlex.Class'

local function indexOf(tbl, val)
  for i = 1, #tbl do
    if tbl[i] == val then
      return i
    end
  end
  return nil
end
local function splice(tbl, startIndex, deleteCount, ...)
  local len = #tbl
  startIndex = math.min(math.max(startIndex, 1), len)

  deleteCount = deleteCount or (len - startIndex + 1)
  deleteCount = math.max(deleteCount, 0)

  local deleted = {}
  for i = 1, deleteCount do
    table.insert(deleted, tbl[startIndex])
    table.remove(tbl, startIndex)
  end

  local insertCount = select("#", ...)
  for i = 1, insertCount do
    table.insert(tbl, startIndex + i - 1, select(i, ...))
  end

  return unpack(deleted)
end

local function clearArray(array, recursive)
    if array == nil then
      return array
    end
  
    recursive = recursive or false
    
    if recursive then
      while #array > 0 do
        local thing = table.remove(array)
        if type(thing) == "table" then
          clearArray(thing, true)
        end
      end
    else
      while #array > 0 do
        table.remove(array)
      end
    end
  
    return array
end

local function setLength(array, newLength)
  if newLength < 0 then
    return array
  end

  local oldLength = #array
  local diff = newLength - oldLength

  if diff >= 0 then
    return array
  end

  diff = -diff

  for i=1,diff do
    table.remove(array)
  end

  return array
end

  


---@class TypedGroup:Class
local TypedGroup = Class()

TypedGroup.field('members', {})
TypedGroup.field('maxSize', 0, nil, function (v, t)
    v = math.floor(math.abs(v))
    if (t._marker >= v) then
        t._marker = 0
    end
    if (v == 0 or t.members == nil or t.v >= t.length) then
		return v
    end

    local i = v
    local l = t.length
    local basic

    while i > l do
        i = i + 1
        basic = t.members[i]

        if basic ~= nil then
            if (t.memberRemoved ~= nil) then
                t.memberRemoved(basic)
            end 
            basic.destroy()
        end
    end
    setLength(t.members, v)
    t.length = #t.members

    return v
end)
TypedGroup.field('length', 0)
TypedGroup.field('_marker', 0)
TypedGroup.field('memberAdded', nil)
TypedGroup.field('memberRemoved', nil)

TypedGroup.new = function (maxSize)
    local this = TypedGroup.create()
    this.members = {}
    this.maxSize = math.floor(math.abs(maxSize or 0))

    this.getFirstNil = function ()
        local i = 0
        while (i < this.length) do
            i = i + 1
            if this.members[i] == nil then return i end
        end
        return -1
    end
    this.destroy = function()
        if this.members then
            local i = 0
            local basic

            while (i < this.length) do
                i = i + 1
                basic = this.members[i]
                if basic then
                    basic.destroy()
                end
            end
        end
        this.members = nil
    end
    this.add = function (object, top)
        if object == nil or indexOf(this.members, object) ~= nil then
            return object
        end

        local idx = this.getFirstNil()
        if idx ~= -1 then
            this.members[idx] = object
            if idx > this.length then
                this.length = idx + 1
            end
            object.add(top)
            if this.memberAdded ~= nil then
                this.memberAdded(object)
            end
            return object
        end

        if this.maxSize > 0 and this.length >= this.maxSize then
            return object
        end

        table.insert(this.members, object)
        this.length = this.length + 1
        object.add(top)
        if this.memberAdded ~= nil then
            this.memberAdded(object)
        end
        return object
    end
    this.insert = function (position, object)
        if object == nil or indexOf(this.members, object) ~= nil then
            return object
        end

        if position <= this.length and this.members[position] == nil then
            this.members[position] = object
            if this.memberAdded ~= nil then
                this.memberAdded(object)
            end
            return object
        end

        if maxSize > 0 and this.length >= maxSize then
            return object
        end

        table.insert(this.members, position, object)
        this.length = this.length + 1
        if this.memberAdded ~= nil then
            this.memberAdded(object)
        end
        return object
    end
    this.remove = function (object, Splice)
        if this.members == nil then return nil end
        local idx = indexOf(this.members, object)

        if idx == nil then return nil end

        if Splice then
            splice(this.members, idx, 1)
            this.length = this.length - 1
        else
            this.members[idx] = nil
        end

        if this.memberRemoved ~= nil then
            this.memberRemoved(object)
        end
        return object
    end
    this.replace = function (object, newObject)
        local idx = indexOf(this.members, object)
        if idx == nil then return nil end

        this.members[idx] = newObject

        if this.memberRemoved ~= nil then
            this.memberRemoved(object)
        end
        if this.memberAdded ~= nil then
            this.memberAdded(newObject)
        end

        return newObject
    end
    this.sort = function(comp)
        table.sort(this.members, comp)
    end
    this.getFirstExisting = function()
        local i = 0
        local basic

        while (i < this.length) do
            i = i + 1
            basic = this.members[i]

            if basic ~= nil and basic.exists then
                return basic
            end
        end
    end
    this.getFirstAlive = function()
        local i = 0
        local basic

        while (i < this.length) do
            i = i + 1
            basic = this.members[i]

            if basic ~= nil and basic.exists and basic.alive then
                return basic
            end
        end
    end
    this.getFirstDead = function()
        local i = 0
        local basic

        while (i < this.length) do
            i = i + 1
            basic = this.members[i]

            if basic ~= nil and not basic.alive then
                return basic
            end
        end
    end
    this.countLiving = function()
        local i = 0
        local count = -1
        local basic

        while (i < this.length) do
            i = i + 1
            basic = this.members[i]

            if count < 0 then
                count = 0
            end
            if basic.exists and basic.alive then
                count = count + 1
            end
        end
        return count
    end
    this.countDead = function()
        local i = 0
        local count = -1
        local basic

        while (i < this.length) do
            i = i + 1
            basic = this.members[i]

            if count < 0 then
                count = 0
            end
            if not basic.alive then
                count = count + 1
            end
        end
        return count
    end
    this.getRandom = function (startIndex, length)
        if startIndex < 0 then startIndex = 1 end
        if length <= 0 then length = this.length end
        return this.members[math.random(startIndex, length)]
    end
    this.clear = function ()
        this.length = 0
        if this.memberRemoved ~= nil then
            for i = 1, #this.members do
                if this.members[i] ~= nil then
                    this.memberRemoved(this.members[i])
                end
            end
        end
        clearArray(this.members)
    end
    this.kill = function ()
        local i = 0
        local basic
        while i < this.length do
            i = i + 1
            basic = this.members[i]
            if basic ~= nil and basic.exists then
                basic.kill()
            end
        end
    end
    this.revive = function ()
        local i = 0
        local basic
        while i < this.length do
            i = i + 1
            basic = this.members[i]
            if basic ~= nil and not basic.exists then
                basic.revive()
            end
        end
    end
    this.forEach = function (Function)
        local i = 0
        local basic
        while i < this.length do
            i = i + 1
            basic = this.members[i]
            if basic ~= nil then
                Function(basic)
            end
        end
    end
    this.forEachAlive = function (Function)
        local i = 0
        local basic
        while i < this.length do
            i = i + 1
            basic = this.members[i]
            if basic ~= nil and basic.exists and basic.alive then
                Function(basic)
            end
        end
    end
    this.forEachDead = function (Function)
        local i = 0
        local basic
        while i < this.length do
            i = i + 1
            basic = this.members[i]
            if basic ~= nil and not basic.alive then
                Function(basic)
            end
        end
    end
    this.forEachExists = function (Function)
        local i = 0
        local basic
        while i < this.length do
            i = i + 1
            basic = this.members[i]
            if basic ~= nil and basic.exists then
                Function(basic)
            end
        end
    end
    return this
end

return TypedGroup