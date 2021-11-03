#instead of generating a SOMA services application, this just generates a verilog file that can be plonked into anything

from .parse_ast import *
from .header import SourceType, Pass, Service
from os import system, environ
from .vtl import vtl_compile

def server_to_name(server):
    return "_".join([server.parent.module_name, server.name, "direct"])

def next_pow2(num):
    if num == 0:
        return 0
    p = 2
    while num > p:
        p = p * 2
    return p

class GenericRegisters:
    def __init__(self, source_name, source_type, source_file=None):
        self.source_name = source_name
        self.source_type = source_type
        self.source_file = source_file
        self.source_vtl = None
        if source_type == SourceType.VTL:
            self.source_vtl = next(filter(lambda x: x.name.split(".")[0] == source_name, vtl_compile(open(source_file, "r").read())))

class GenericPlatform:
    def __init__(self, clock, reset, registers):
        self.clock = clock
        self.reset = reset
        self.registers = registers

class GenericAnalysisPass(Pass):
    def run(self, app, data):
        control_signal_map = {}
        for service in app.services:
            for control in service.controls.values():
                control_signal_map[control.name + "_" + service.module_name] = control
        data["control-signal-map"] = control_signal_map
        data["files"] = {}
        if app.platform.registers.source_type == SourceType.VTL:
            data["files"][app.platform.registers.source_vtl.name] = app.platform.registers.source_vtl

        data["num-network-ports"] = next_pow2(len(app.noc_clients) + len(app.noc_servers))


class GenericTopPass(Pass):
    @staticmethod
    def get_dependencies():
        return "GenericAnalysisPass"

    def run(self, app, data):
        ports = BlockBuilder(CommaBlock([]))
        body = BlockBuilder()

        #generate externs
        for extern in app.externs.values():
            ports.port(extern.name, mk_type("logic", extern.size-1, 0), extern.direction)
    
        for extifc in app.extern_interfaces.values():
            ports.port(extifc.name, Type(mk_attrib(extifc.type)))

        #no need to handle memory interfaces
        #construct controls
        #controls
        control_signal_map = data["control-signal-map"]
        for control_name, control in control_signal_map.items():
            if control.size == 1:
                control_type = mk_type("logic")
            else:
                control_type = mk_type("logic", control.size-1, 0)
            if not app.hide_controls:
                body.define(Name(control_name), control_type)

        #CSR wiring
        # if len(data["control-signal-map"]) > 0:
        #     builder = BlockBuilder(CommaBlock([]))
        #     builder.connect("clk", Name(app.platform.clock))
        #     builder.connect("SoftReset", Name(app.platform.reset))
        #     builder.connect("csrs", Name("csrs"))
        #     for control_name in data["control-signal-map"]:
        #         builder.connect(control_name, Name(control_name))
        #     body.instantiate(Name("controls"), Name("csr"), builder.block)

        for paste_file in app.paste_files:
            body.text(open(app.path_prefix + paste_file, "r").read())

        #NOC wiring
        num_clients = len(app.noc_clients)
        num_servers = len(app.noc_servers)
        if len(app.noc_servers) != 0:    
            arg_size = 64#app.noc_servers[0].arg_size
            data_size = 512#app.noc_servers[0].data_size
            p_arg_size0 = Parameter(Name("SDARG_BITS"), Constant(arg_size))
            p_data_size0 = Parameter(Name("DATA_BITS"), Constant(data_size))
            p_arg_size1 = Parameter(Name("SDARG_BITS"), Constant(arg_size))
            p_data_size1 = Parameter(Name("DATA_BITS"), Constant(data_size))
            body.define(Name("noc_svr", Index(Constant(num_clients))), mk_type("server"), is_interface=True, parameter_list=InstantiateParameterList([p_arg_size0, p_data_size0]))
            body.define(Name("noc_clt", Index(Constant(num_servers))), mk_type("server"), is_interface=True, parameter_list=InstantiateParameterList([p_arg_size1, p_data_size1]))

            plist = InstantiateParameterList([
                Parameter(Name("NUM_CLT"), Constant(num_clients)),
                Parameter(Name("NUM_SVR"), Constant(num_servers)),
                Parameter(Name("SDARG_BITS"), Constant(64))
            ])
            builder = BlockBuilder(CommaBlock([]))
            builder.connect("clk", Name(app.platform.clock))
            builder.connect("SoftReset", Name(app.platform.reset))
            builder.connect("noc_svr", Name("noc_svr"))
            builder.connect("noc_clt", Name("noc_clt"))
            body.instantiate(Name("network_wrapper_map"), Name("noc"), builder.block, parameter_list=plist)

        unused_count = 0

        #generate unused servers
        for service in app.services:
            for server in service.servers.values():
                if not ((server in app.direct_servers) or (server in app.noc_servers)):
                    arg_size = server.arg_size
                    data_size = server.data_size
                    plist = InstantiateParameterList([
                        Parameter(Name("SDARG_BITS"), Constant(arg_size)),
                        Parameter(Name("DATA_BITS"), Constant(data_size))
                    ])
                    body.define(Name(server_to_name(server)), mk_type("server"), is_interface=True, parameter_list=plist)
            for client in service.clients.values():
                if client.provider == None:
                    arg_size = 32
                    data_size = 512
                    plist = InstantiateParameterList([
                        Parameter(Name("SDARG_BITS"), Constant(arg_size)),
                        Parameter(Name("DATA_BITS"), Constant(data_size))
                    ])
                    client.provider = unused_count
                    unused_count += 1
                    body.define(Name("unused_{}".format(client.provider)), mk_type("server"), is_interface=True, parameter_list=plist)

        #generate direct servers
        for service in app.services:
            for server in service.servers.values():
                if server in app.direct_servers:
                    arg_size = server.arg_size
                    data_size = server.data_size
                    plist = InstantiateParameterList([
                        Parameter(Name("SDARG_BITS"), Constant(arg_size)),
                        Parameter(Name("DATA_BITS"), Constant(data_size))
                    ])
                    body.define(Name(server_to_name(server)), mk_type("server"), is_interface=True, parameter_list=plist)

        #generate module wirings
        sdarg_fix_server = []
        sdarg_fix_client = []
        sdarg_fix_server_count = 0
        sdarg_fix_client_count = 0
        for service in app.services:
            builder = BlockBuilder(CommaBlock([]))
            for p, ec in service.extern_connections.items():
                builder.connect(p, Name(ec.extern_name))
            for control_name in service.controls:
                builder.connect(control_name, Name(control_name + "_" + service.module_name))
            for server_name, server in service.servers.items():
                if server in app.noc_servers:
                    if server.arg_size != 64 or server.data_size != 512:
                        sdarg_name = "sdarg_fix_clt_{}_{}".format(server.name, server.parent.module_name)
                        plist = InstantiateParameterList([
                            Parameter(Name("SDARG_BITS"), Constant(server.arg_size)),
                            Parameter(Name("DATA_BITS"), Constant(server.data_size))
                        ])
                        body.define(Name(sdarg_name), mk_type("server"), is_interface=True, parameter_list=plist)
                        plist = InstantiateParameterList([Parameter(Name("SDARG_BITS_C"), Constant(64)), 
                                                        Parameter(Name("DATA_BITS_C"), Constant(512)), 
                                                        Parameter(Name("SDARG_BITS_S"), Constant(server.arg_size)),
                                                        Parameter(Name("DATA_BITS_S"), Constant(server.data_size))])
                        sdarg_builder = BlockBuilder(CommaBlock([]))
                        sdarg_builder.connect("to_c", Name("noc_clt", Index(Constant(app.server_to_idx[server]))))
                        sdarg_builder.connect("to_s", Name(sdarg_name))
                        body.instantiate(Name("sdarg_fix"), Name("fix" + sdarg_name), sdarg_builder.block, parameter_list=plist)
                        builder.connect(server_name, Name(sdarg_name))
                    else:
                        builder.connect(server_name, Name("noc_clt", Index(Constant(app.server_to_idx[server]))))
                else:
                    builder.connect(server_name, Name(server_to_name(server)))
            for client_name, client in service.clients.items():
                if client in app.direct_clients:
                    builder.connect(client_name, Name(server_to_name(app.direct_map[client])))
                elif client in app.noc_clients:
                    if client.provider.arg_size != 64 or client.provider.data_size != 512:
                        sdarg_name = "sdarg_fix_svr_{}_{}".format(client.name, client.parent.module_name)
                        plist = InstantiateParameterList([
                            Parameter(Name("SDARG_BITS"), Constant(client.provider.arg_size)),
                            Parameter(Name("DATA_BITS"), Constant(client.provider.data_size))
                        ])
                        body.define(Name(sdarg_name), mk_type("server"), is_interface=True, parameter_list=plist)
                        plist = InstantiateParameterList([Parameter(Name("SDARG_BITS_S"), Constant(64)), 
                                                        Parameter(Name("DATA_BITS_S"), Constant(512)), 
                                                        Parameter(Name("SDARG_BITS_C"), Constant(client.provider.arg_size)),
                                                        Parameter(Name("DATA_BITS_C"), Constant(client.provider.data_size))])
                        sdarg_builder = BlockBuilder(CommaBlock([]))
                        sdarg_builder.connect("to_s", Name("noc_svr", Index(Constant(app.client_to_idx[client]))))
                        sdarg_builder.connect("to_c", Name(sdarg_name))
                        body.instantiate(Name("sdarg_fix"), Name("fix" + sdarg_name), sdarg_builder.block, parameter_list=plist)
                        builder.connect(client_name, Name(sdarg_name))
                    else:
                        builder.connect(client_name, Name("noc_svr", Index(Constant(app.client_to_idx[client]))))
                else:
                    builder.connect(client_name, Name("unused_{}".format(client.provider)))
            if service.properties.get("memory-interfaces") != None:
                    memories = service.properties.get("memory-interfaces")
                    for memory in memories.value:
                        memory.generate_passthrough(builder)
            plist = None
            has_params = False
            if service.properties.get("parameters") != None:
                params = service.properties["parameters"].value
                lt = []
                for name, value in params.items():
                    lt.append(Parameter(Name(name), Text(value)))
                plist = InstantiateParameterList(lt)
                has_params = True
            if has_params:
                body.instantiate(Name(service.source_name), Name("my_" + service.module_name), builder.block, parameter_list=plist)
            else:
                if service.source_type == SourceType.SYSTEM_VERILOG:
                    body.instantiate(Name(service.source_name), Name("my_" + service.module_name), builder.block)
                elif service.source_type == SourceType.BLUESPEC_SYSTEM_VERILOG:
                    body.instantiate(Name(service.source_name + "_wrapper"), Name("my_" + service.module_name), builder.block)

        # generate file
        module = ASTModule(app.top_name, ports.block, body.block)
        f = File(app.top_name+".sv", [module], app.top_includes, [])
        data["files"][f.name] = f


