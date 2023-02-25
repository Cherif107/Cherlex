local StringUtil = require 'cherlex.util.StringUtil'
function string.split(self, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = self:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
          table.insert(t, cap)
       end
       last_end = e+1
       s, e, cap = self:find(fpat, last_end)
    end
    if last_end <= #self then
       cap = self:sub(last_end)
       table.insert(t, cap)
    end
    return t
 end

function isArray(table)
    local count = 0
    for _,_ in pairs(table) do count = count + 1 end
    return count == #table
end
  

---@class HScript An hscript Class
local HScript = {}

HScript.variables = setmetatable({}, {
    __index = function(t, k)
        HScript.addLibrary('FunkinLua')
        return HScript.getValue('FunkinLua.hscript.variables.get('..HScript.parseValue(k)..')')
    end,
    __newindex = function(t, k, v)
        HScript.shouldInit = true
        HScript.addLibrary('FunkinLua')
        HScript.execute('FunkinLua.hscript.variables.set('..HScript.parseValue(k)..', '..HScript.parseValue(v)..');\n')
        HScript.initedVars[k] = nil
    end
})
HScript.functions = {}
HScript.shouldInit = true
HScript.executeUnsafe = function(code)
    return runHaxeCode(code)
end
HScript.addLibrary = function(library)
    local res = StringUtil.split(library, '.')
    local lib = res[#res]
    addHaxeLibrary(lib, library:sub(1, -(#lib+2)))
    return lib, true
end
HScript.checkConvertedMap = function(v)
    if type(v) == 'table' then
        if v[1] == 'DEFAULT_HSCRIPT_MAP_CONVERTED_TO_LUA_FROM_ARRAY' then
            local q = {}
            for i = 2, #v do
                q[v[i][1]] = v[i][2]
            end
            return q
        end
    end
    return v
end
HScript.getValue = function(value)
    HScript.addLibrary('Std')
    HScript.addLibrary('Reflect')
    HScript.addLibrary('haxe.ds.StringMap')
    HScript.addLibrary('haxe.ds.IntMap')
    for _, q in pairs({"String", "Int", "Float", "Bool", "Array"}) do
        HScript.addLibrary(q)
    end
    return HScript.checkConvertedMap(HScript.executeUnsafe(
        'var v = '..value..';\n'..
        [[
            function isMap(v){
                if (Std.isOfType(v, StringMap) || Std.isOfType(v, IntMap))
                    return true;
            }
            function parseValue(v){
                if (Std.isOfType(v, Float) || Std.isOfType(v, Int) || Std.isOfType(v, String) || Std.isOfType(v, Bool))
                    return v;
                if (Std.isOfType(v, Array)){
                    var q = [];
                    for (i in 0...v.length)
                        q[i] = parseValue(v[i]);
                    return q;
                }
                if (isMap(v)){
                    var q = ["DEFAULT_HSCRIPT_MAP_CONVERTED_TO_LUA_FROM_ARRAY"];
                    for (k in v.keys())
                        q.push([k, v.get(k)]);
                    return q;
                }
                if (v == null)
                    return "Variable Not Found";
                return "Type Not Allowed";
            }
            return parseValue(v);
        ]]
    ))
end
HScript.initedVars = {}
HScript.init = function()
    if HScript.shouldInit then
        local str = [[
            function debugPrint(?txt1, ?txt2, ?txt3, ?txt4, ?txt5, ?color){
                if (txt1 != null) txt1 += ', '; else txt1 = '';
                if (txt2 != null) txt2 += ', '; else txt2 = '';
                if (txt3 != null) txt3 += ', '; else txt3 = '';
                if (txt4 != null) txt4 += ', '; else txt4 = '';
                if (txt5 != null) txt5 += ', '; else txt5 = '';
                if (color == null) color = 0xFFffffff;
                game.addTextToDebug((txt1+txt2+txt3+txt4+txt5).substr(0, -2), color);
            }
            function getCallback(funcName, arguments){
                var argStuff = [funcName];
                for (v in arguments)
                    argStuff.push(v);

                game.callOnLuas("CALL_HSCRIPT_FROM_TABLE", argStuff);
                var v = TEMPORARY_HSCRIPT_VARIABLE;
                TEMPORARY_HSCRIPT_VARIABLE = null;
                return v;
            }
        ]]
        for fName, functionStuff in next, HScript.functions, nil do
            if not HScript.functions[fName].inited then
                str = str..'function '..fName..'('..functionStuff.args..'){ return getCallback("'..fName..'", ['..functionStuff.arguments..']); }\n'
                HScript.functions[fName].inited = true
            end
        end
        for var, value in next, HScript.variables, nil do
            if HScript.initedVars[var] == nil then
                str = str..var..' = '..HScript.parseValue(value)..';'
                HScript.variables[var] = nil
                HScript.initedVars[var] = value
            end
        end
        HScript.executeUnsafe(str)
        HScript.shouldInit = false
    end
end
HScript.parseImports = function(imports)
    local imps = imports:gsub('\n', ' '):split('import ')
    local toRemove = imports:sub(1, -#(imps[#imps]:sub(#imps[#imps]:split(';')[1]+2)))
    for i = 1, #imps do
        local import = StringUtil.split(imps[i], ';')[1]
        import = import:gsub('\n', ''):gsub(' ', ''):gsub(';', '')
        if import ~= '' then
            HScript.addLibrary(import)
        end
    end
    return toRemove
end
HScript.execute = function(code)
    code:gsub('public var ', '') -- public vars are basically variable = shit
    local R = ''
    if code:find('import ') then R = HScript.parseImports(code) end
    HScript.init()
    return HScript.executeUnsafe(code:sub(#R))
end

local function tableThing(v)
    local t = '[\n'
    for k, f in pairs(v) do
        if isArray(v) then
            t = t..HScript.parseValue(f)..', '
        else
            t = t..HScript.parseValue(k)..' => '..HScript.parseValue(f)..',\n'
        end
    end
    return t..']\n'
end

HScript.parseValue = function(v)
    if type(v) == 'string' then
        return '"'..v..'"'
    elseif v == nil then
        return 'null'
    elseif type(v) == 'table' then
        return tableThing(v)
    else
        return tostring(v)
    end
end
HScript.unpack = function(t, i)
    i = i or 1
    if t[i] ~= nil then
        return (HScript.parseValue(t[i])..(i ~= #t and ", ".. HScript.unpack(t, i + 1) or ""))
    end
    return ''
end

local function contains(ta, v) for a, b in next, ta, nil do
    if b == v then return true end
end end
local function keyOf(tbl, v)
    for a, b in next, tbl, nil do
        if v == b then return a end
    end
end

function HScript.getFunctionArguments(func) -- not so hscript thing lol
    local argumentss = {}
    for i = 1, debug.getinfo(func).nparams do
        table.insert(argumentss, debug.getlocal(func, i));
    end
    return argumentss;
end
HScript.setFunction = function(functionName, func, optionalArguments)
    HScript.shouldInit = true
    optionalArguments = optionalArguments or {}
    local arguments = HScript.getFunctionArguments(func)
    local args = {}

    if optionalArguments == 'all' then optionalArguments = arguments end
    for i = 1, #arguments do
        if contains(optionalArguments, arguments[i]) then
            args[i] = '?'..arguments[i]
        else
            args[i] = arguments[i]
        end
    end
    
    HScript.functions[functionName] = {
        arguments = table.concat(arguments, ', '),
        args = table.concat(args, ', '),
        func = func
    }
    HScript.init()
end

HScript.setVariable = function(variable, value) -- for global variables ONLY 
    HScript.variables[variable] = value
    HScript.init()
end
HScript.getVariable = function(variable) -- for global variables ONLY 
    return HScript.variables[variable]
end
HScript.call = function(func, ...)
    return HScript.executeUnsafe(
        'if ('..func..' != null)\n return '..func..'('..HScript.unpack({...})..');'
    )
end

function CALL_HSCRIPT_FROM_TABLE(func, ...)
    local v = HScript.functions[func].func(...)
    HScript.setVariable('TEMPORARY_HSCRIPT_VARIABLE', v or 'null')
end
function CANCEL_HSCRIPT_TEMPO_SET()
    HScript.setVariable('TEMPORARY_HSCRIPT_VARIABLE', nil)
end

return HScript