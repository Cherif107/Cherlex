-----* [[ REQUIRES ]] *-----
local Class = require 'cherlex.Class'
local arrowString = require 'cherlex.interp.ArrowString'
-----* [[ MAIN ]] *-----

local String = function(str)
    local this = str or ''
    debug.setmetatable(this, {__index = function(t, k)
        if type(k) == 'number' then
            return t:sub(k, k)
        end
        return string[k]
    end})
    return this
end

local CHX_INT = 'INT'
local CHX_FLOAT = 'FLOAT'
local CHX_PLUS = 'PLUS'
local CHX_MINUS = 'MINUS'
local CHX_MUL = 'MUL'
local CHX_DIV = 'DIV'
local CHX_POW = 'POW'
local CHX_MODULO = 'MODULO'
local CHX_LSHIFT = 'LSHIFT'
local CHX_RSHIFT = 'RSHIFT'
local CHX_BAND = 'BAND'
local CHX_BOR = 'BOR'
local CHX_XOR = 'XOR'
local CHX_LPAREN = 'LPAREN'
local CHX_RPAREN = 'RPAREN'
local CHX_IDENTIFIER = 'IDENTIFIER'
local CHX_KEYWORD = 'KEYWORD'
local CHX_EQ = 'EQ'
local CHX_EOF = 'EOF'

local DIGITS = '0123456789'
local KEYWORDS = {
    'var'
}

local LETTERS = ''
for i = 97,  122 do LETTERS = LETTERS..string.char(i) end
LETTERS = LETTERS..LETTERS:upper()
local LETTERS_DIGITS = LETTERS..DIGITS

--- [[ ERROR ]] ---
local Error = Class('Error')
    Error.new = function(pos_start, pos_end, error_name, details)
        local this = Error.create()

        this.pos_start = pos_start
        this.pos_end = pos_end
        this.error_name = error_name
        this.details = details
        return this
    end
    Error.instance.__tostring = function(t)
        return '('..t.error_name..' : '..t.details..') | File '..t.pos_start.fn..' - Line '..(t.pos_start.ln+1)..
        '\n\n'..arrowString(t.pos_start.ftxt, t.pos_start, t.pos_end)
    end

--- [[ ILLEGAL CHAR ERROR ]] ---
local IllegalCharError = Error.copy('IllegalCharError')
    IllegalCharError.new = function(pos_start, pos_end, details)
        return Error.new(pos_start, pos_end, 'Illegal Character', details)
    end

--- [[ ILLEGAL CHAR ERROR ]] ---
local InvalidSyntaxError = Error.copy('InvalidSyntaxError')
    InvalidSyntaxError.new = function(pos_start, pos_end, details)
        return Error.new(pos_start, pos_end, 'Invalid Syntax', details)
    end

--- [[ ILLEGAL CHAR ERROR ]] ---
local RTError = Error.copy('RTError')
    RTError.new = function(pos_start, pos_end, details, context)
        local this = Error.new(pos_start, pos_end, 'Run Time Error', details)
        this.context = context
        this.generate_traceback = function()
            local result = ''
            local pos = this.pos_start
            local ctx = this.context

            while ctx do
                result = 'File '..this.pos_start.fn..' - Line '..(this.pos_start.ln+1)..' - in '..ctx.display_name..'\n'..result
                pos = ctx.parent_entry_pos
                ctx = ctx.parent 
            end
            return '(most recent call):\n'..result
        end
        return this
    end
    RTError.instance.__tostring = function(t)
        return t.generate_traceback()..'('..t.error_name..' : '..t.details..')'..
        '\n\n'..arrowString(t.pos_start.ftxt, t.pos_start, t.pos_end)
    end

--- [[ POSITION ]] --
local Position = Class('Position')
    Position.new = function(idx, ln, col, fn, ftxt)
        local this = Position.create()

        this.idx = idx
        this.ln = ln
        this.col = col
        this.fn = fn
        this.ftxt = ftxt

        this.advance = function(current_char)
            this.idx = this.idx + 1
            this.col = this.col + 1

            if current_char == '\n' then
                this.ln = this.ln + 1
                this.col = 1
            end
        end
        this.copy = function()
            return Position(this.idx, this.ln, this.col, this.fn, this.ftxt)
        end
        return this
    end

--- [[ TOKEN ]] ---
local Token = Class('Token')
    Token.new = function(type, value, pos_start, pos_end)
        local this = Token.create()

        this.type = type
        this.value = value
        this.matches = function(t, v) return (this.type == t and this.value == v) end

        if pos_start ~= nil then
            this.pos_start = pos_start.copy()
            this.pos_end = pos_start.copy()
            this.pos_end.advance()
        end
        if pos_end ~= nil then this.pos_end = pos_end end
        return this
    end
    Token.instance.__tostring = function(t)
        return t.type..(t.value ~= nil and (':'..t.value) or '')
    end

--- [[ NODES ]] ---

--/ NUMBER NODE \--
local NumberNode = Class('NumberNode')
    NumberNode.new = function(tok)
        local this = NumberNode.create()

        this.tok = tok
        this.pos_start = this.tok.pos_start
        this.pos_end = this.tok.pos_end
        return this
    end
    NumberNode.instance.__tostring = function(t)
        return tostring(t.tok)
    end

--/ BINARY OP NODE \--
local BinOpNode = Class('BinOpNode')
    BinOpNode.new = function(left_node, op_tok, right_node)
        local this = BinOpNode.create()

        this.left_node = left_node
        this.op_tok = op_tok
        this.right_node = right_node

        this.pos_start = this.left_node.pos_start
        this.pos_end = this.right_node.pos_end
        return this
    end
    BinOpNode.instance.__tostring = function(t)
        return '('..tostring(t.left_node)..', '..tostring(t.op_tok)..', '..tostring(t.right_node)..')'
    end

--/ UNARY OP NODE \--
local UnaryOpNode = Class('UnaryOpNode')
    UnaryOpNode.new = function(op_tok, node)
        local this = UnaryOpNode.create()

        this.op_tok = op_tok
        this.node = node
        this.pos_start = this.op_tok.pos_start
        this.pos_end = this.op_tok.pos_end
        return this
    end
    UnaryOpNode.instance.__tostring = function(t)
        return '('..tostring(t.op_tok)..', '..tostring(t.node)..')'
    end

--/ Var Access Node \--
local VarAccessNode = Class('VarAccessNode')
    VarAccessNode.new = function(var_name_tok)
        local this = VarAccessNode.create()

        this.var_name_tok = var_name_tok

        this.pos_start = this.var_name_tok.pos_start
        this.pos_end = this.var_name_tok.pos_end
        return this
    end

--/ Var Assign Node \--
local VarAssignNode = Class('VarAssignNode')
    VarAssignNode.new = function(var_name_tok, value_node)
        local this = VarAssignNode.create()

        this.var_name_tok = var_name_tok
        this.value_node = value_node

        this.pos_start = this.var_name_tok.pos_start
        this.pos_end = this.var_name_tok.pos_end
        return this
    end


--- [[ PARSE RESULT ]] ---
local ParseResult = Class('ParseResult')
    ParseResult.new = function()
        local this = ParseResult.create()

        this.register = function(res)
            if ParseResult.isInstance(res) then
                if res.error ~= nil then this.error = res.error end
                return res.node
            end
            return res
        end
        this.success = function(node)
            this.node = node
            return this
        end
        this.failure = function(error)
            this.error = error
            return this
        end
        return this
    end
        
--- [[ PARSER ]] ---
local Parser = Class('Parser')
    Parser.new = function(tokens)
        local this = Parser.create()

        this.advance = function()
            this.tok_idx = this.tok_idx + 1
            if this.tok_idx < #this.tokens+1 then
                this.current_tok = this.tokens[this.tok_idx]
            end
            return this.current_tok
        end
        this.tokens = tokens
        this.tok_idx = 0
        this.advance()

        this.atom = function()
            local res = ParseResult()
            local tok = this.current_tok
            if tok.type == CHX_FLOAT or tok.type == CHX_INT then
                res.register(this.advance())
                return res.success(NumberNode(tok))
            elseif tok.type == CHX_IDENTIFIER then
                res.register(this.advance())
                return res.success(VarAccessNode(tok))
            elseif tok.type == CHX_LPAREN then
                res.register(this.advance())
                local expr = res.register(this.expr())
                if res.error ~= nil then return res end
                if this.current_tok.type == CHX_RPAREN then
                    res.register(this.advance())
                    return res.success(expr)
                else
                    return res.failure(InvalidSyntaxError(this.current_tok.pos_start, this.current_tok.pos_end, 'Expected ")"'))
                end
            end
            return res.failure(InvalidSyntaxError(tok.pos_start, tok.pos_end, 'Expected Int or Float'))
        end
        this.power = function()
            return this.bin_op(this.atom, {CHX_POW, CHX_MODULO, CHX_LSHIFT, CHX_RSHIFT}, this.factor)
        end
        this.factor = function()
            local res = ParseResult()
            local tok = this.current_tok
            
            if tok.type == CHX_PLUS or tok.type == CHX_MINUS then
                res.register(this.advance())
                local factor = res.register(this.factor())
                if res.error then return res end
                return res.success(UnaryOpNode(tok, factor))
            end
            return this.power()
        end
        this.term = function()
            return this.bin_op(this.factor, {CHX_MUL, CHX_DIV})
        end
        this.expr = function()
            local res = ParseResult()

            if this.current_tok.matches(CHX_KEYWORD, 'var') then
                res.register(this.advance())
                if this.current_tok.type ~= CHX_IDENTIFIER then
                    return res.failure(InvalidSyntaxError(this.current_tok.pos_start, this.current_tok.pos_end, 'Expected Variable Name'))
                end
                local var_name = this.current_tok
                res.register(this.advance())

                if this.current_tok.type ~= CHX_EQ then
                    return res.failure(InvalidSyntaxError(this.current_tok.pos_start, this.current_tok.pos_end, 'Expected Expression, Suggestion: "="'))
                end

                res.register(this.advance())
                local expr = res.register(this.expr())
                if res.error ~= nil then return res end
                return res.success(VarAssignNode(var_name, expr))
            end
            return this.bin_op(this.term, {CHX_PLUS, CHX_MINUS, CHX_BOR, CHX_BAND})
        end

        local function set(stuff)
            local ret = {}
            for _,k in ipairs(stuff) do ret[k] = true end
            return ret
        end
        this.bin_op = function(func, ops, func2)
            if func2 == nil then func2 = func end 
            local res = ParseResult()
            local left = res.register(func())
            if res.error ~= nil then return res end
            
            while set(ops)[this.current_tok.type] do
                local op_tok = this.current_tok
                res.register(this.advance())

                local right = res.register(func2())
                if res.error ~= nil then return res end
                left = BinOpNode(left, op_tok, right)
            end
            return res.success(left)
        end

        this.parse = function()
            local res = this.expr()
            if not res.error and this.current_tok.type ~= CHX_EOF then
                return res.failure(InvalidSyntaxError(this.current_tok.pos_start, this.current_tok.pos_end, 'Expected Expression'))
            end
            return res
        end
        return this
    end

local function contains(t, v)
    for i, o in pairs(t) do if v == o then return true end end
end
--- [[ LEXER ]] ---
local Lexer = Class('Lexer')
    Lexer.new = function(fn, text)
        local this = Lexer.create()

        this.advance = function()
            this.pos.advance(this.current_char)
            this.current_char = (this.pos.idx < #this.text+1 and this.text[this.pos.idx] or nil)
        end

        this.fn = fn
        this.text = String(text)
        this.pos = Position(0, 0, 0, fn, text)
        this.current_char = nil
        this.advance()

        this.make_number = function()
            local nstr = String('')
            local dcount = 0
            local pos_start = this.pos.copy()

            while this.current_char ~= nil and (DIGITS:find(this.current_char, 1, true) or this.current_char == '.') do
                if this.current_char == '.' then
                    if dcount == 1 then break end
                    dcount = dcount + 1
                    nstr = nstr..'.'
                else
                    nstr = nstr..this.current_char
                end
                this.advance()
            end
            if dcount == 0 then
                return Token(CHX_INT, tonumber(nstr), pos_start, this.pos)
            else
                return Token(CHX_FLOAT, tonumber(nstr), pos_start, this.pos)
            end
        end
        this.make_identifier = function()
            local id_str = ''
            local pos_start = this.pos.copy()
            while this.current_char ~= nil and (LETTERS_DIGITS..'_'):find(this.current_char, 1, true) do
                id_str = id_str..this.current_char
                this.advance()
            end
            local tok_type = (contains(KEYWORDS, id_str) and CHX_KEYWORD or CHX_IDENTIFIER)
            return Token(tok_type, id_str, pos_start, this.pos)
        end
        this.shift_check = function(shift)
            local lcount = 0
            local pos_start = this.pos.copy()
            local s

            while this.current_char ~= nil and (this.current_char == shift) do
                lcount = lcount+1
                if lcount == 2 then s = (shift == '<' and CHX_LSHIFT or (shift == '>' and CHX_LSHIFT)) end
                this.advance()
            end
            return Token(s, nil, pos_start, this.pos)
        end
        this.make_tokens = function()
            local tokens = {}

            while this.current_char ~= nil do
                if (' \t'):find(this.current_char, 1, true) then
                    this.advance()
                elseif DIGITS:find(this.current_char, 1, true) then
                    table.insert(tokens, this.make_number())
                elseif LETTERS:find(this.current_char, 1, true) then
                    table.insert(tokens, this.make_identifier())
                elseif this.current_char == '+' then
                    table.insert(tokens, Token(CHX_PLUS, nil, this.pos))
                    this.advance()
                elseif this.current_char == '-' then
                    table.insert(tokens, Token(CHX_MINUS, nil, this.pos))
                    this.advance()
                elseif this.current_char == '*' then
                    table.insert(tokens, Token(CHX_MUL, nil, this.pos))
                    this.advance()
                elseif this.current_char == '/' then
                    table.insert(tokens, Token(CHX_DIV, nil, this.pos))
                    this.advance()
                elseif this.current_char == '^' then
                    table.insert(tokens, Token(CHX_POW, nil, this.pos))
                    this.advance()
                elseif this.current_char == '%' then
                    table.insert(tokens, Token(CHX_MODULO, nil, this.pos))
                    this.advance()
                elseif this.current_char == '>' or this.current_char == '<' then
                    table.insert(tokens, this.shift_check(this.current_char))
                elseif this.current_char == '&' then
                    table.insert(tokens, Token(CHX_BAND, nil, this.pos))
                    this.advance()
                elseif this.current_char == '|' then
                    table.insert(tokens, Token(CHX_BOR, nil, this.pos))
                    this.advance()
                elseif this.current_char == '(' then
                    table.insert(tokens, Token(CHX_LPAREN, nil, this.pos))
                    this.advance()
                elseif this.current_char == ')' then
                    table.insert(tokens, Token(CHX_RPAREN, nil, this.pos))
                    this.advance()
                elseif this.current_char == '=' then
                    table.insert(tokens, Token(CHX_EQ, nil, this.pos))
                    this.advance()
                else
                    local pos_start = this.pos.copy()
                    local char = String(this.current_char)
                    this.advance()
                    return {}, IllegalCharError(pos_start, this.pos, "'"..char.."'")
                end
            end

            table.insert(tokens, Token(CHX_EOF, nil, this.pos))
            return tokens, nil
        end
        return this
    end

--- [[ Run Time Result ]] ---
local RTResult = Class('RTResult')
    RTResult.new = function()
        local this = RTResult.create()

        this.register = function(res)
            if res.error ~= nil then this.error = res.error end
            return res.value
        end
        this.success = function(value)
            this.value = value
            return this
        end
        this.failure = function(error)
            this.error = error
            return this
        end
        return this
    end

--- [[ Context ]] ---
local Context = Class('Context')
    Context.new = function(display_name, parent, parent_entry_pos)
        local this = Context.create()

        this.display_name = display_name
        this.parent = parent
        this.parent_entry_pos = parent_entry_pos
        return this
    end

function lshift(a,disp)
    if disp < 0 then return rshift(a,-disp) end 
    return (a * 2^disp) % 2^32
end
function rshift(a, disp)
    if disp < 0 then return lshift(a,-disp) end
    return math.floor(a % 2^32 / 2^disp)
end

--- [[ Values ]] ---
--/ Number \ --
local Number = Class('Number')
    Number.new = function(value)
        local this = Number.create()

        this.value = value
        this.set_pos = function(pos_start, pos_end)
            this.pos_start = pos_start
            this.pos_end = pos_end
            return this
        end
        this.set_context = function (context)
            this.context = context
            return this
        end
        this.added_to = function(other)
            if Number.isInstance(other) then
                return Number(this.value+other.value).set_context(this.context)
            end
        end
        this.subbed_by = function(other)
            if Number.isInstance(other) then
                return Number(this.value-other.value).set_context(this.context)
            end
        end
        this.multed_by = function(other)
            if Number.isInstance(other) then
                return Number(this.value*other.value).set_context(this.context)
            end
        end
        this.divided_by = function(other)
            if Number.isInstance(other) then
                return Number(this.value/other.value).set_context(this.context)
            end
        end
        this.powed_by = function(other)
            if Number.isInstance(other) then
                return Number(this.value^other.value).set_context(this.context)
            end
        end
        this.modded_by = function(other)
            if Number.isInstance(other) then
                return Number(this.value%other.value).set_context(this.context)
            end
        end
        this.lshifted_by = function(other)
            if Number.isInstance(other) then
                return Number(bit.lshift(this.value, other.value)).set_context(this.context)
            end
        end
        this.rshifted_by = function(other)
            if Number.isInstance(other) then
                return Number(bit.rshift(this.value, other.value)).set_context(this.context)
            end
        end
        this.banded_by = function(other)
            if Number.isInstance(other) then
                return Number(bit.band(this.value, other.value)).set_context(this.context)
            end
        end
        this.bored_by = function(other)
            if Number.isInstance(other) then
                return Number(bit.bor(this.value, other.value)).set_context(this.context)
            end
        end
        this.set_pos()
        return this
    end
    Number.instance.__tostring = function(t) return tostring(t.value) end

--- [[ Symbol Table ]] ---
local SymbolTable = Class('SymbolTable')
    SymbolTable.new = function()
        local this = SymbolTable.create()

        this.symbols = {}
        this.get = function(name)
            local value = this.symbols.get(name, nil)
            if value == nil and this.parent ~= nil then
                return this.parent.get(name)
            end
            return value
        end
        this.set = function(name, value)
            this.symbols[name] = value
        end
        this.remove = function(name)
            this.symbols[name] = nil
        end
        return this
    end

--- [[ Interpreter ]] ---
local function getattr(inst, k, default)
    return inst[k] or default
end
local Interpreter = Class('Interpreter')
    Interpreter.new = function()
        local this = Interpreter.create()

        this.no_visit_method = function(node, context)
            error('No Visit visit_'..node.originClass.__type..' method defined')
        end
        this.visit = function(node, context)
            local method_name = 'visit_'..node.originClass.__type
            local method = getattr(this, method_name, this.no_visit_method)
            return method(node, context)
        end
        this.visit_NumberNode = function(node, context)
            return RTResult().success(Number(node.tok.value).set_context(context).set_pos(node.pos_start, node.pos_end))
        end
        this.visit_VarAccessNode = function(node, context)
            local res = RTResult()
            local var_name = node.var_name_tok.value
            local value = context.symbol_table.get(var_name)

            if value == nil then
                return res.failure(RTError(node.pos_start, node.pos_end, 'variable "'..var_name..'" is not defined', context))
            end
            return res.success(value)
        end
        this.visit_VarAssignNode = function(node, context)
            local res = RTResult()
            local var_name = node.var_name_tok
            local value = res.register(this.visit(node.value_node, context))
            
            if res.error ~= nil then return res end
            context.symbol_table.set(var_name, value)
            return res.success(value)
        end
        this.visit_BinOpNode = function(node, context)
            local res = RTResult()

            local left = res.register(this.visit(node.left_node, context))
            if res.error ~= nil then return res end
            local right = res.register(this.visit(node.right_node, context))
            if res.error ~= nil then return res end

            local result, error

            if node.op_tok.type == CHX_PLUS then
                result, error = left.added_to(right), nil
            elseif node.op_tok.type == CHX_MINUS then
                result, error = left.subbed_by(right), nil
            elseif node.op_tok.type == CHX_MUL then
                result, error = left.multed_by(right), nil
            elseif node.op_tok.type == CHX_DIV then
                result, error = left.divided_by(right), nil
            elseif node.op_tok.type == CHX_POW then
                result, error = left.powed_by(right), nil
            elseif node.op_tok.type == CHX_MODULO then
                result, error = left.modded_by(right), nil
            elseif node.op_tok.type == CHX_LSHIFT then
                result, error = left.lshifted_by(right), nil
            elseif node.op_tok.type == CHX_RSHIFT then
                result, error = left.rshifted_by(right), nil
            elseif node.op_tok.type == CHX_BAND then
                result, error = left.banded_by(right), nil
            elseif node.op_tok.type == CHX_BOR then
                result, error = left.bored_by(right), nil
            end
            if error ~= nil then return res.failure(error) end
            return res.success(result.set_pos(node.pos_start, node.pos_end))
        end
        this.visit_UnaryOpNode = function(node, context)
            local res = RTResult()
            local error
            local number = res.register(this.visit(node.node, context))
            if res.error ~= nil then return res end

            if node.op_tok.type == CHX_MINUS then
                number, error = number.multed_by(Number(-1))
            end

            if error ~= nil then return res.failure(error) end
            return res.success(number.set_pos(node.pos_start, node.pos_end))
        end
        return this
    end


local variables = SymbolTable()
variables.set('null', nil)

----- * [[ RUN ]] * -----
local function run(fn, text)
    local lex = Lexer(fn, text)
    local tokens, error = lex.make_tokens()
    if error ~= nil then return nil, error end

    local parser = Parser(tokens)
    local ast = parser.parse()
    if ast.error ~= nil then return nil, ast.error end

    local interpreter = Interpreter()
    local context = Context('<pee>')
    context.symbol_table = variables
    local result = interpreter.visit(ast.node, context)

    return result.value, result.error
end

return run