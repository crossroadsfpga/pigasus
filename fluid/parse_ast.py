import enum

__counter = 0

def get_unique_name():
    global __counter
    out = "name" + str(__counter)
    __counter += 1
    return out


class Direction(enum.Enum):
    INPUT = 0,
    OUTPUT = 1,
    NONE = 2

    def to_string(self):
        if self == Direction.INPUT:
            return "input"
        elif self == Direction.OUTPUT:
            return "output"
        else:
            return ""

    @staticmethod
    def from_string(string):
        if string == "input" or string == "Input":
            return Direction.INPUT
        elif string == "output" or string == "Output":
            return Direction.OUTPUT
        else:
            return None


#Node base class
class ASTNode:
    def __init__(self, subnodes=[]):
        self.subnodes = []
        if isinstance(subnodes, list):
            self.subnodes += subnodes
        else:
            self.subnodes.append(subnodes)
        for subnode in self.subnodes:
            subnode.parent = self

    def add_subnode(self, subnode):
        self.subnodes.append(subnode)
        subnode.parent = self

    def to_debug_string(self, indent):
        indent_string = "\t" * indent
        out = type(self).__name__ + "\n"
        for var_name, var in vars(self).items():
            out += indent_string + str(var_name) + " = " + str(var) + "\n"
        for node in self.subnodes:
            out += node.to_debug_string(indent + 1)
        return out + "\n"

    def compile(self, indent=0):
        print("Unimplemented compile() function.")


#A collection of statements mainly for indenting. Does NOT correspond to basic blocks.
class Block(ASTNode):
    def __init__(self, statements):
        super().__init__(statements)
        self.statements = self.subnodes

    def add(self, statement):
        self.add_subnode(statement)

    def compile(self, indent):
        indent_str = "    " * indent
        return "\n".join(map(lambda x: indent_str + x.compile(indent), self.statements))


class ConstantType(enum.Enum):
    BINARY = 0,
    HEXADECIMAL = 1,
    DECIMAL = 2,
    NONE = 3

    def to_string(self):
        if self == ConstantType.BINARY:
            return "b"
        elif self == ConstantType.HEXADECIMAL:
            return "h"
        elif self == ConstantType.DECIMAL:
            return "d"
        else:
            return ""


#Constant
class Constant(ASTNode):
    def __init__(self, value, type=ConstantType.NONE, bit_width=None):
        super().__init__([])
        self.value = value
        self.type = type
        self.bit_width = bit_width

    def compile(self, indent=0):
        if self.type == ConstantType.NONE:
            return str(self.value)
        else:
            bw_string = "" if self.bit_width == None else str(self.bit_width)
            return bw_string + "'" + self.type.to_string() + str(self.value)


class DefinedConstant(ASTNode):
    def __init__(self, name):
        super().__init__([])
        self.name = name

    def compile(self, indent):
        return "`" + self.name


class Slice(ASTNode):
    def __init__(self, upper, lower):
        super().__init__([upper, lower])
        self.upper = upper
        self.lower = lower

    def compile(self, indent=0):
        return "[" + self.upper.compile(indent) + ":" + self.lower.compile(indent) + "]"


class Text(ASTNode):
    def __init__(self, text):
        super().__init__([])
        self.text = text

    def compile (self, indent=0):
        return self.text


class Index(ASTNode):
    def __init__(self, index):
        super().__init__(index)
        self.index = index

    def compile(self, indent=0):
        return "[" + self.index.compile(indent) + "]"


class Attribute(ASTNode):
    def __init__(self, base, attribute):
        super().__init__([base, attribute])
        self.base = base
        self.attribute = attribute

    def compile(self, indent=0):
        return self.base.compile(indent) + "." + self.attribute.compile(indent)


class Name(ASTNode):
    def __init__(self, name, modifier=None):
        if modifier == None:
            super().__init__([])
        else:
            super().__init__([modifier])
        self.name = name
        self.modifier = modifier

    def compile(self, indent=0):
        if self.modifier == None:
            return self.name
        else:
            return self.name + self.modifier.compile(indent)


class UnaryOpType(enum.Enum):
    COMPLEMENT = 0,
    NOT = 1,

    def __str__(self):
        if self == UnaryOpType.COMPLEMENT:
            return "complement"
        else:
            return "not"

    def to_string(self):
        if self == UnaryOpType.COMPLEMENT:
            return "~"
        else:
            return "!"

    @staticmethod
    def from_string(string):
        if string == "~":
            return UnaryOpType.COMPLEMENT
        else:
            return UnaryOpType.NOT


class Set(ASTNode):
    def __init__(self, items):
        super().__init__(items)
        self.items = items

    def compile(self, indent=0):
        compiled = "{" + ", ".join(map(lambda x: x.compile(indent), self.items)) + "}"
        return compiled


class BinOpType(enum.Enum):
    AND = 0,
    OR = 1,
    ADD = 2,
    SUB = 3,
    GT = 4,
    LT = 5,
    GT_EQ = 6,
    MUL = 7,
    EQ = 8,
    NOT_EQ = 9,
    DIV = 10,
    SL = 11

    def __str__(self):
        if self == BinOpType.AND:
            return "and"
        elif self == BinOpType.OR:
            return "add"
        elif self == BinOpType.SUB:
            return "sub"
        elif self == BinOpType.GT:
            return "gt"
        elif self == BinOpType.LT:
            return "lt"
        elif self == BinOpType.GT_EQ:
            return "gt_eq"
        elif self == BinOpType.MUL:
            return "mul"
        elif self == BinOpType.EQ:
            return "eq"
        elif self == BinOpType.NOT_EQ:
            return "not_eq"
        elif self == BinOpType.DIV:
            return "div"
        elif self == BinOpType.SL:
            return "sl"

    def to_string(self):
        if self == BinOpType.AND:
            return "&&"
        elif self == BinOpType.OR:
            return "||"
        elif self == BinOpType.ADD:
            return "+"
        elif self == BinOpType.SUB:
            return "-"
        elif self == BinOpType.GT:
            return ">"
        elif self == BinOpType.LT:
            return "<"
        elif self == BinOpType.GT_EQ:
            return ">="
        elif self == BinOpType.MUL:
            return "*"
        elif self == BinOpType.EQ:
            return "=="
        elif self == BinOpType.NOT_EQ:
            return "!="
        elif self == BinOpType.DIV:
            return "/"
        elif self == BinOpType.SL:
            return "<<"

    @staticmethod
    def from_string(string):
        if string == "&&":
            return BinOpType.AND
        elif string == "||":
            return BinOpType.OR
        elif string == "+":
            return BinOpType.ADD
        elif string == "-":
            return BinOpType.SUB
        elif string == ">":
            return BinOpType.GT
        elif string == "<":
            return BinOpType.LT
        elif string == ">=":
            return BinOpType.GT_EQ
        elif string == "*":
            return BinOpType.MUL
        elif string == "==":
            return BinOpType.EQ
        elif string == "!=":
            return BinOpType.NOT_EQ
        elif string == "/":
            return BinOpType.DIV
        elif string == "<<":
            return BinOpType.SL
        else:
            print(string, "unrecognized op type")
        
    def is_logical(self):
        if self == BinOpType.GT or self == BinOpType.LT or self == BinOpType.GT_EQ:
            return True
        else:
            return False


class UnaryOp(ASTNode):
    def __init__(self, op, operand):
        super().__init__(operand)
        self.op = op
        self.operand = operand

    def compile(self, indent=0):
        return "(" + self.op.to_string() + self.operand.compile(indent) + ")"


class BinaryOp(ASTNode):
    def __init__(self, op, lhs, rhs):
        super().__init__([lhs, rhs])
        self.op = op
        self.lhs = lhs
        self.rhs = rhs

    def compile(self, indent=0):
        return "(" + self.lhs.compile(indent) + " " + self.op.to_string() + " " + self.rhs.compile(indent) + ")"

class TrinaryOp(ASTNode):
    def __init__(self, condition, true_value, false_value):
        super().__init__([condition, true_value, false_value])
        self.condition = condition
        self.true_value = true_value
        self.false_value = false_value

    def compile(self, indent=0):
        return "((" + self.condition.compile(indent) + ") ? (" + self.true_value.compile(indent) + ") : (" + self.false_value.compile(indent) + "))"


class ConAssign(ASTNode):
    def __init__(self, lhs, rhs):
        super().__init__([lhs, rhs])
        self.lhs = lhs
        self.rhs = rhs

    def compile(self, indent=0):
        return "assign " + self.lhs.compile(indent) + " = " + self.rhs.compile(indent) + ";"


class CombAssign(ASTNode):
    def __init__(self, lhs, rhs):
        super().__init__([lhs, rhs])
        self.lhs = lhs
        self.rhs = rhs

    def compile(self, indent=0):
        return self.lhs.compile(indent) + " = " + self.rhs.compile(indent) + ";"


class FFAssign(ASTNode):
    def __init__(self, lhs, rhs):
        super().__init__([lhs, rhs])
        self.lhs = lhs
        self.rhs = rhs

    def compile(self, indent=0):
        return self.lhs.compile(indent) + " <= " + self.rhs.compile(indent) + ";"

class Localparam(ASTNode):
    def __init__(self, lhs, rhs):
        super().__init__([lhs, rhs])
        self.lhs = lhs
        self.rhs = rhs

    def compile(self, indent=0):
        buffer = "localparam " + self.lhs.compile(indent) + " = " + self.rhs.compile(indent)
        if type(self.parent) == ParameterList:
            return buffer
        else:
            return buffer + ";"

class Param(ASTNode):
    def __init__(self, lhs, rhs):
        super().__init__([lhs, rhs])
        self.lhs = lhs
        self.rhs = rhs

    def compile(self, indent=0):
        buffer = "parameter " + self.lhs.compile(indent) + " = " + self.rhs.compile(indent)
        if type(self.parent) == ParameterList:
            return buffer
        else:
            return buffer + ";"

class IfElse(ASTNode):
    def __init__(self, condition, if_block, else_block=None):
        super().__init__([condition, if_block])
        if else_block != None:
            self.add_subnode(else_block)
        self.condition = condition
        self.if_block = if_block
        self.else_block = else_block

    def compile(self, indent):
        indent_str = "    " * (indent - 1)
        buffer = "if (" + self.condition.compile(indent) + ") begin\n" + self.if_block.compile(indent + 1) + "\n    " + indent_str + "end"
        if self.else_block != None:
            buffer += "\n    " + indent_str + "else begin\n" + self.else_block.compile(indent + 1) + "\n    " + indent_str + "end"
        return buffer


class AlwaysComb(ASTNode):
    def __init__(self, block):
        super().__init__(block)
        self.block = block

    def compile(self, indent):
        indent_str = "    " * (indent - 1)
        return indent_str + "always_comb begin\n" + self.block.compile(indent + 1) + "\n    " + indent_str + "end"

class For(ASTNode):
    def __init__(self, var, start, end, block):
        super().__init__([var, start, end, block])
        self.block = block
        self.var = var
        self.start = start
        self.end = end

    def compile(self, indent):
        indent_str = "    " * (indent - 1)
        var_str = self.var.compile(0)
        start_str = self.start.compile(0)
        end_str = self.end.compile(0)
        return "for (int " + var_str + " = " + start_str + "; " + var_str + " < " + end_str + "; " + var_str + " = " + var_str + " + 1) begin\n" + self.block.compile(indent + 1) + "\n    " + indent_str + "end"

class TriggerType(enum.Enum):
    POSEDGE = 0,
    NEGEDGE = 1

    def to_string(self):
        if self == TriggerType.POSEDGE:
            return "posedge"
        else:
            return "negedge"

    @staticmethod
    def from_string(string):
        if string == "negedge":
            return TriggerType.NEGEDGE
        else:
            return TriggerType.POSEDGE


class AlwaysFF(ASTNode):
    def __init__(self, type, trigger_signal, block):
        super().__init__([trigger_signal, block])
        self.block = block
        self.type = type
        self.trigger_signal = trigger_signal
        
    def compile(self, indent):
        indent_str = "    " * (indent - 1)
        return indent_str + "always_ff @(" + self.type.to_string() + " " + self.trigger_signal.compile(indent) + ") begin\n" + self.block.compile(indent + 1) + "\n    " + indent_str + "end"

class CommaBlock(Block):
    def compile(self, indent):
        indent_str = "    " * indent
        return ",\n".join(map(lambda x: indent_str + x.compile(indent), self.statements))

class Type(ASTNode):
    def __init__(self, name, slice=None):
        super().__init__(name)
        self.name = name
        if slice != None:
            self.add_subnode(slice)
            self.slice = slice

    def compile(self, indent):
        if len(self.subnodes) == 1:
            return self.name.compile(indent)
        else:
            return self.name.compile(indent) + " " + self.slice.compile(0)

class Define(ASTNode):
    def __init__(self, name, type, is_interface=False, parameter_list=None):
        super().__init__([name, type])
        self.name = name
        self.type = type
        self.is_interface = is_interface
        self.parameter_list = parameter_list

    def compile(self, indent):
        buffer = self.type.compile(indent) 
        if self.parameter_list != None:
            buffer += self.parameter_list.compile(indent)
        buffer += " " + self.name.compile(indent)
        if self.is_interface:
            buffer += "()"
        return buffer + ";"

class Construct(ASTNode):
    def __init__(self, type, value):
        super().__init__([type, value])
        self.type = type
        self.value = value

    def compile(self, indent=0):
        return self.type.compile(indent) + "'(" + self.value.compile(indent) + ")"


class Port(ASTNode):
    def __init__(self, name, type, direction=None):
        super().__init__([name, type])
        self.name = name
        self.type = type
        self.direction = direction

    def compile(self, indent):
        if self.direction == None:
            return self.type.compile(indent) + " " + self.name.compile(indent)
        else:
            return self.direction.to_string() + " " + self.type.compile(indent) + " " + self.name.compile(indent)


class Parameter(ASTNode):
    def __init__(self, name, value):
        super().__init__([name, value])
        self.name = name
        self.value = value

    def compile(self, indent):
        return ""


class ParameterList(ASTNode):
    def __init__(self, parameters):
        super().__init__(parameters)
        self.parameters = parameters

    @staticmethod
    def compile_parameter(param):
        if type(param) == Localparam:
            return param.compile(0)
        else:
            return param.name.compile(0) + "=" + param.value.compile(0)
    
    def compile(self, indent):
        return "#(" + ", ".join(map(lambda x: self.compile_parameter(x), self.parameters)) + ")"


class InstantiateParameterList(ParameterList):
    def compile(self, indent):
        return "#(" + ", ".join(map(lambda x: "." + x.name.compile(indent) + "(" + x.value.compile(indent) + ")", self.parameters)) + ")"


class Connect(ASTNode):
    def __init__(self, socket, signal):
        super().__init__([socket, signal])
        self.socket = socket
        self.signal = signal
    
    def compile(self, indent):
        return "." + self.socket.compile(indent) + "(" + self.signal.compile(indent) + ")"

class Instantiate(ASTNode):
    def __init__(self, module_name, name, connections_block, parameter_list=None):
        if parameter_list == None:
            super().__init__([module_name, name, connections_block])
        else:
            super().__init__([module_name, name, connections_block, parameter_list])
        self.name = name
        self.connections_block = connections_block
        self.module_name = module_name
        self.parameter_list = parameter_list
    
    def compile(self, indent):
        indent_str = "    " * indent
        if self.parameter_list == None:
            return self.module_name.compile(indent) + " " + self.name.compile(indent) + " (\n" + self.connections_block.compile(indent + 1) + "\n" + indent_str + ");"
        else:
            return self.module_name.compile(indent) + self.parameter_list.compile(indent) + " " + self.name.compile(indent) + " (\n" + self.connections_block.compile(indent + 1) + "\n" + indent_str + ");"


class ASTModule(ASTNode):
    def __init__(self, name, ports_block, body_block, parameter_list=None):
        if parameter_list == None:
            super().__init__([ports_block, body_block])
        else:
            super().__init__([ports_block, body_block, parameter_list])
        self.name = name
        self.ports_block = ports_block
        self.body_block = body_block
        self.parameter_list = parameter_list

    def compile(self, indent):
        indent_str = "    " * indent
        if self.parameter_list == None:
            return indent_str + "module " + self.name + " (\n" + self.ports_block.compile(indent + 1) + "\n);\n" + self.body_block.compile(indent + 1) + "\n" + indent_str + "endmodule: " + self.name
        else:
            return indent_str + "module " + self.name + self.parameter_list.compile(indent) + " (\n" + self.ports_block.compile(indent + 1) + "\n);\n" + self.body_block.compile(indent + 1) + "\n" + indent_str + "endmodule: " + self.name

class File(ASTNode):
    def __init__(self, name, modules, includes=None, imports=None):
        super().__init__(modules)
        self.name = name
        self.modules = modules
        self.includes = includes
        self.imports = [] if imports == None else imports

    def compile(self, indent=0):
        return "\n".join(map(lambda x: '`include "' + x + '"', self.includes)) + "\n\n" + "\n".join(map(lambda x: "import " + x + "::*;", self.imports)) + "\n\n" + "\n\n".join(map(lambda x: x.compile(0), self.modules))

class Call(ASTNode):
    def __init__(self, name, args):
        super().__init__(args)
        self.name = name
        self.args = args

    def compile(self, indent):
        semi = ""
        if isinstance(self.parent, Block):
            semi = ";"
        return self.name.compile(indent) + "(" + ", ".join(map(lambda x: x.compile(indent), self.args)) + ")" + semi

class String(ASTNode):
    def __init__(self, string):
        super().__init__([])
        self.string = string

    def compile(self, indent=0):
        return '"' + self.string + '"'

class BlockBuilder:
    def __init__(self, block=None):
        if block == None:
            self.block = Block([])
        else:
            self.block = block
        self.stack = []

    def define(self, name, type, is_interface=False, parameter_list=None):
        self.block.add(Define(name, type, is_interface, parameter_list))
    
    def port(self, name, type, direction=None):
        self.block.add(mk_port(name, type, direction))

    def port_full(self, name, type, direction=None):
        self.block.add(Port(name, type, direction))

    def con_assign(self, lhs, rhs):
        self.block.add(ConAssign(lhs, rhs))

    def comb_assign(self, lhs, rhs):
        self.block.add(CombAssign(lhs, rhs))

    def ff_assign(self, lhs, rhs):
        self.block.add(FFAssign(lhs, rhs))

    def localparam(self, lhs, rhs):
        self.block.add(Localparam(lhs, rhs))

    def param(self, lhs, rhs):
        self.block.add(Param(lhs, rhs))

    def always_comb(self, block):
        self.block.add(AlwaysComb(block))

    def always_ff(self, trigger_type, trigger_signal, block):
        self.block.add(AlwaysFF(trigger_type, trigger_signal, block))

    def if_else(self, condition, if_block, else_block=None):
        self.block.add(IfElse(condition, if_block, else_block))

    def connect(self, socket, signal):
        self.block.add(Connect(Name(socket), signal))

    def instantiate(self, module_name, name, connections_block, parameter_list=None):
        self.block.add(Instantiate(module_name, name, connections_block, parameter_list))
    
    def for_loop(self, var, start, end, block):
        self.block.add(For(var, start, end, block))

    def text(self, string):
        self.block.add(Text(string))
    

def mk_type(name, upper=None, lower=None):
    if upper == None:
        return Type(Name(name))
    else:
        return Type(Name(name), slice=Slice(Constant(upper), Constant(lower)))

def mk_port(name, type, direction=None):
    return Port(Name(name), type, direction)

def mk_attrib(string):
    strings = string.split(".")
    base = Name(strings[0])
    for s in strings[1:]:
        base = Attribute(base, Name(s))
    return base

def mk_unary(op, operand):
    return UnaryOp(UnaryOpType.from_string(op), operand)

def mk_connect(socket, signal):
    return Connect(Name(socket), signal)

def mk_binary(op, lhs, rhs):
    return BinaryOp(BinOpType.from_string(op), lhs, rhs)

def mk_minus_one(thing):
    return mk_binary("-", thing, Constant(1))

def mk_minus_to_zero(thing):
    return Slice(mk_minus_one(thing), Constant(0))

def mk_zero_to_minus(thing):
    return Slice(Constant(0), mk_minus_one(thing))