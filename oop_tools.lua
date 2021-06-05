-- Object Oriented Programming Tools
-- Author: Sean Meyers
-- References:
--    lua-users wiki: Simple Lua Classes
--        URL:  http://lua-users.org/wiki/SimpleLuaClasses

local oop = {}

-------------------------------------------------
-- Create a class definition
--
-- Parameters:
--    base <table>: The parent class to use if
--                  creating a subclass, leave it
--                  out if not creating a --                  subclass.
-- 
-- Interface Example:
--    Cat = class()
--      function Cat:__init(gender)
--        self.gender = gender
--      end 
--    fluffy = Cat('male')
--
function oop.class(base)
  local class = {}
  class.__index = class

  -- If we are defining a subclass
  if type(base) == 'table' then

    -- Copy the values of the parent class into
    --   the subclass
    for key, value in pairs(base) do
      class[key] = value
    end
    class._base = base
  end

  -- Constructor that may be called
  --   by <classname>(<args>)
  local meta_table = {}
  function meta_table.__call(...)

    -- Initialize the class instance
    local self = {}
    setmetatable(self, class)

    if type(class.__init) == 'function' then
      class.__init(self, unpack(arg))

    elseif class._base.__init then
      -- If there is no initialization function
      --   defined for the subclass, use the
      --   parent class'
      class._base.__init(self, unpack(arg))
    end

    return self
  end

  --------------------------
  -- Compare a class instance with a class
  --
  -- If 'me' is an instance or subclass of 'it',
  --   then return true, otherwise false. 
  function class.is_a(me, it)
    me = getmetatable(me)
    while me do
      if me == it then
        return true
      end
      me = me._base
    end
    return false  -- if me is not it
  end

  setmetatable(class, meta_table)
  return class
end






return oop