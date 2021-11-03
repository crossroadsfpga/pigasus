#Verilog Templating Language
import ast
import copy
import sys
import os
import enum
import inspect
from pprint import *
from .parse_ast import *

def vtl(func):
    pass

def vtl_nomodule(func):
    pass

def vtl_include(filename):
    def empty(func):
        pass
    return empty

class CompilerState(enum.Enum):
    MODULE = 0,
    INSTANTIATION = 3,
    PORT = 4,
    PARAM = 5

class AssignmentType(enum.Enum):
    CON = 0,
    COMB = 1,
    FF = 2

def get_caller_global(string):
    ans = None
    stack_frame = inspect.currentframe()
    while stack_frame:
        if stack_frame.f_code.co_name == '<module>':
            if stack_frame.f_code.co_filename != '<stdin>':
                caller_module = inspect.getmodule(stack_frame)
            else:
                caller_module = sys.modules['__main__']
            if not caller_module is None:
                try:
                    ans = vars(caller_module)[string]
                except:
                    ans = None
                break
        stack_frame = stack_frame.f_back
    
    return ans

class VTLCompiler(ast.NodeVisitor):
    def __init__(self, state):
        self.state = state
        self.ports_builder = BlockBuilder(CommaBlock([]))
        self.body_builder = BlockBuilder()
        self.inst_builder = BlockBuilder(CommaBlock([]))
        self.inst_params_list = None
        self.module_params_list = None
        self.inside_for = False
        self.for_var = ""
        self.for_value = ""
        self.builder = self.body_builder
        self.params_list = None
        self.assign_type = AssignmentType.CON

    def compile_type(self, thing):
        if len(thing.args) > 1:
            return Type(self.compile_name(thing.args[0]), slice=Slice(self.compile_expr(thing.args[1]), self.compile_expr(thing.args[2])))
        else:
            return Type(self.compile_name(thing.args[0]))

    def get_last_name(self, attribute):
        if isinstance(attribute, Name):
            return attribute
        elif isinstance(attribute, Attribute):
            return self.get_last_name(attribute.attribute)

    def compile_name(self, name):
        string = name
        is_slice = False
        slice = None
        if isinstance(name, ast.Name):
            ans = get_caller_global(name.id)
            if ans != None:
                string = str(ans)
            else:
                string = name.id
        elif isinstance(name, ast.Str):
            return String(name.s)
        elif isinstance(name, ast.Subscript):
            is_slice = True
            if isinstance(name.slice, ast.Index):
                slice = Index(self.compile_expr(name.slice.value))
            else:
                slice = Slice(self.compile_expr(name.slice.lower), self.compile_expr(name.slice.upper))
            if isinstance(name.value, ast.Name):
                string = name.value.id
            else:
                a = self.compile_name(name.value)
                a.attribute.modifier = slice
                return a
        elif isinstance(name, ast.Attribute):
            return Attribute(self.compile_name(name.value), self.compile_name(name.attr))
        elif isinstance(name, ast.Tuple):
            lt = []
            for item in name.elts:
                lt.append(self.compile_expr(item))
            return Set(lt)
        if self.inside_for:
            query = "_" + self.for_var + "_"
            string = string.replace(query, self.for_value)
        if is_slice:
            return Name(string, slice)
        else:
            return Name(string)

    def compile_expr(self, expr):
        if isinstance(expr, ast.Num):
            return Constant(expr.n)
        elif isinstance(expr, ast.Compare):
            op_str = "=="
            if isinstance(expr.ops[0], ast.Eq):
                op_str = "=="
            elif isinstance(expr.ops[0], ast.Gt):
                op_str = ">"
            elif isinstance(expr.ops[0], ast.Lt):
                op_str = "<"
            elif isinstance(expr.ops[0], ast.NotEq):
                op_str = "!="
            return mk_binary(op_str, self.compile_expr(expr.left), self.compile_expr(expr.comparators[0]))
        elif isinstance(expr, ast.BoolOp):
            op_str = "&&"
            if isinstance(expr.op, ast.And):
                op_str = "&&"
            elif isinstance(expr.op, ast.Or):
                op_str = "||"
            values_reversed = copy.deepcopy(expr.values)
            values_reversed.reverse()
            node = mk_binary(op_str, self.compile_expr(values_reversed[1]), self.compile_expr(values_reversed[0]))
            for n in values_reversed[2:]:
                node = mk_binary(op_str, self.compile_expr(n), node)
            return node
        elif isinstance(expr, ast.BinOp):
            op_str = "+"
            if isinstance(expr.op, ast.Add):
                op_str = "+"
            elif isinstance(expr.op, ast.Mult):
                op_str = "*"
            elif isinstance(expr.op, ast.Sub):
                op_str = "-"
            elif isinstance(expr.op, ast.Div):
                op_str = "/"
            elif isinstance(expr.op, ast.LShift):
                op_str = "<<"
            return mk_binary(op_str, self.compile_expr(expr.left), self.compile_expr(expr.right))
        elif isinstance(expr, ast.UnaryOp):
            op_str = "~"
            if isinstance(expr.op, ast.Invert):
                op_str = "~"
            elif isinstance(expr.op, ast.Not):
                op_str = "!"
            return mk_unary(op_str, self.compile_expr(expr.operand))
        elif isinstance(expr, ast.Call):
            if expr.func.id == "d":
                return Constant(expr.args[1].n, ConstantType.DECIMAL, expr.args[0].n)
            elif expr.func.id == "b":
                return Constant(expr.args[1].n, ConstantType.BINARY, expr.args[0].n)
            elif expr.func.id == "h":
                return Constant(expr.args[1].n, ConstantType.HEXADECIMAL, expr.args[0].n)
            elif expr.func.id == "Defined":
                return DefinedConstant(expr.args[0].id)
            else:
                name = Name("$" + expr.func.id)
                args = []
                for arg in expr.args:
                    args.append(self.compile_expr(arg))
                return Call(name, args)
        else:
            return self.compile_name(expr)
        
    def visit_With(self, node):
        if isinstance(node.items[0].context_expr, ast.Name):
            if self.state == CompilerState.MODULE:
                if node.items[0].context_expr.id == "AlwaysComb":
                    old_builder = self.builder
                    self.builder = BlockBuilder()
                    old_assign = self.assign_type
                    self.assign_type = AssignmentType.COMB
                    for item in node.body:
                        self.visit(item)
                    old_builder.always_comb(self.builder.block)
                    self.builder = old_builder
                    self.assign_type = old_assign
                elif node.items[0].context_expr.id == "Params":
                    old_list = self.params_list
                    self.params_list = ParameterList([])
                    self.state = CompilerState.PARAM
                    for item in node.body:
                        self.visit(item)
                    self.module_params_list = self.params_list
                    self.params_list = old_list
                    self.state = CompilerState.MODULE
                elif node.items[0].context_expr.id == "Ports":
                    old_builder = self.builder
                    self.builder = self.ports_builder
                    self.state = CompilerState.PORT
                    for item in node.body:
                        self.visit(item)
                    self.ports_builder = self.builder
                    self.builder = old_builder
                    self.state = CompilerState.MODULE
                else:
                    self.state = CompilerState.INSTANTIATION
                    old_builder = self.builder
                    self.builder = BlockBuilder(CommaBlock([]))
                    old_list = self.params_list
                    self.params_list = InstantiateParameterList([])
                    module_name = self.compile_name(node.items[0].context_expr)
                    name = self.compile_name(node.items[0].optional_vars)
                    for item in node.body:
                        self.visit(item)
                    old_builder.instantiate(module_name, name, self.builder.block, self.params_list)
                    self.builder = old_builder
                    self.params_list = old_list
                    self.state = CompilerState.MODULE                
            elif self.state == CompilerState.INSTANTIATION:
                if node.items[0].context_expr.id == "Params":
                    self.state = CompilerState.PARAM
                    for item in node.body:
                        self.visit(item)
                    self.state = CompilerState.INSTANTIATION
        elif isinstance(node.items[0].context_expr, ast.Call):
            if node.items[0].context_expr.func.id == "AlwaysFF":
                trigger_type = TriggerType.from_string(node.items[0].context_expr.args[0].id)
                trigger_signal = self.compile_name(node.items[0].context_expr.args[1])
                old_builder = self.builder
                self.builder = BlockBuilder()
                old_assign = self.assign_type
                self.assign_type = AssignmentType.FF
                for item in node.body:
                    self.visit(item)
                old_builder.always_ff(trigger_type, trigger_signal, self.builder.block)
                self.builder = old_builder
                self.assign_type = old_assign
            if node.items[0].context_expr.func.id == "For":
                var = self.compile_expr(node.items[0].context_expr.args[0])
                start = self.compile_expr(node.items[0].context_expr.args[1])
                end = self.compile_expr(node.items[0].context_expr.args[2])
                old_builder = self.builder
                self.builder = BlockBuilder()
                old_assign = self.assign_type
                self.assign_type = old_assign#AssignmentType.FF
                for item in node.body:
                    self.visit(item)
                old_builder.for_loop(var, start, end, self.builder.block)
                self.builder = old_builder
                self.assign_type = old_assign
                
    
    def visit_Assign(self, node):
        if self.state == CompilerState.PARAM:
            if isinstance(node.value, ast.Call):
                if node.value.func.id == "Localparam":
                    p = Localparam(self.compile_name(node.targets[0]), self.compile_expr(node.value.args[0]))
                    self.params_list.parameters.append(p)
                    self.params_list.add_subnode(p)
                elif node.value.func.id == "Param":
                    p = Param(self.compile_name(node.targets[0]), self.compile_expr(node.value.args[0]))
                    self.params_list.parameters.append(p)
                    self.params_list.add_subnode(p)
            else:
                p = Parameter(Name(self.compile_name(node.targets[0])).name, self.compile_expr(node.value))
                self.params_list.parameters.append(p)
                self.params_list.add_subnode(p)
        elif self.state == CompilerState.PORT:
            n = self.compile_name(node.targets[0])
            t = self.compile_type(node.value)
            d = Direction.from_string(node.value.func.id)
            self.builder.port_full(n, t, d)
        elif self.state == CompilerState.MODULE:
            if isinstance(node.value, ast.Call) and node.value.func.id not in ["b", "d", "h", "Defined"]:
                if node.value.func.id == "Localparam":
                    self.builder.localparam(self.compile_name(node.targets[0]), self.compile_expr(node.value.args[0]))
                elif node.value.func.id == "Param":
                    self.builder.param(self.compile_name(node.targets[0]), self.compile_expr(node.value.args[0]))
                elif node.value.func.id == "Def":
                    self.builder.define(self.compile_name(node.targets[0]), self.compile_type(node.value))
            else:
                if self.assign_type == AssignmentType.CON:
                    self.builder.con_assign(self.compile_name(node.targets[0]), self.compile_expr(node.value))
                elif self.assign_type == AssignmentType.COMB:
                    self.builder.comb_assign(self.compile_name(node.targets[0]), self.compile_expr(node.value))
                elif self.assign_type == AssignmentType.FF:
                    self.builder.ff_assign(self.compile_name(node.targets[0]), self.compile_expr(node.value))
        elif self.state == CompilerState.INSTANTIATION:
            self.builder.connect(self.compile_name(node.targets[0]).name, self.compile_expr(node.value))

    def visit_If(self, node):
        else_b = None
        condition = self.compile_expr(node.test)
        old_builder = self.builder
        self.builder = BlockBuilder()
        for item in node.body:
            self.visit(item)
        if_b = self.builder
        if len(node.orelse) != 0:
            else_b = BlockBuilder()
            self.builder = else_b
            for item in node.orelse:
                self.visit(item)
        self.builder = old_builder
        if else_b != None:
            self.builder.if_else(condition, if_b.block, else_b.block)
        else:
            self.builder.if_else(condition, if_b.block)
        
    def get_global_value(self, thing):
        if isinstance(thing, ast.Num):
            return thing.n
        elif isinstance(thing, ast.Name):
            return get_caller_global(thing.id)
        else:
            print("Could not find value for generate-for range argument")

    def visit_For(self, node):
        self.for_var = node.target.id
        self.inside_for = True
        if len(node.iter.args) > 1:
            lower = self.get_global_value(node.iter.args[0])
            upper = self.get_global_value(node.iter.args[1])
            step = self.get_global_value(node.iter.args[2])
            for i in range(lower, upper, step):
                self.for_value = str(i)
                for item in node.body:
                    self.visit(item)
        else:
            num_iters = self.get_global_value(node.iter.args[0])
            for i in range(num_iters):
                self.for_value = str(i)
                for item in node.body:
                    self.visit(item)
        self.inside_for = False

    def visit_Call(self, node):
        if node.func.id == "vtl_include":
            return
        elif node.func.id == "T":
            self.builder.block.add(Text(node.args[0].s))
        else:
            name = Name("$" + node.func.id)
            args = []
            for arg in node.args:
                args.append(self.compile_expr(arg))
            self.builder.block.add(Call(name, args))

def vtl_compile(string):
    f = ast.parse(string)
    files = []
    for node in f.body:
        if type(node) == ast.FunctionDef:
            if len(node.decorator_list) > 0 and node.decorator_list[0].id == "vtl":
                includes = []
                if len(node.decorator_list) > 1:
                    for decorator in node.decorator_list[1:]:
                        includes.append(decorator.args[0].s)
                compiler = VTLCompiler(CompilerState.MODULE)
                compiler.visit(node)
                module = ASTModule(node.name, compiler.ports_builder.block, compiler.body_builder.block, compiler.module_params_list)
                f = File(module.name + ".sv", [module], includes=includes)
                files.append(f)
            elif len(node.decorator_list) > 0 and node.decorator_list[0].id == "vtl_nomodule":
                includes = []
                if len(node.decorator_list) > 1:
                    for decorator in node.decorator_list[1:]:
                        includes.append(decorator.args[0].s)
                compiler = VTLCompiler(CompilerState.MODULE)
                compiler.visit(node)
                module = ASTModule(node.name, compiler.ports_builder.block, compiler.body_builder.block, compiler.module_params_list)
                f = File(module.name + ".sv", [compiler.body_builder.block], includes=includes)
                files.append(f)
    return files
                
#vtl_compile(open(__file__, "r").read())