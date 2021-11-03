import enum
import copy
from .vtl import vtl_compile

global_counter = 0

def not_none(thing1, thing2):
    if thing1 == None:
        return thing2
    else:
        return thing1

class SourceType(enum.Enum):
    VERILOG = 1
    SYSTEM_VERILOG = 2
    BLUESPEC_SYSTEM_VERILOG = 3
    BLUESPEC_CLASSIC = 4
    SOFTWARE = 5
    VTL = 6
    UNKNOWN = 7

    @staticmethod
    def from_string(string):
        if string == "SV":
            return SourceType.SYSTEM_VERILOG
        elif string == "BSV":
            return SourceType.BLUESPEC_SYSTEM_VERILOG
        else:
            return SourceType.UNKNOWN

    @staticmethod
    def to_path_key(source_type):
        if source_type == SourceType.SYSTEM_VERILOG:
            return "sv-mod"
        elif source_type == SourceType.BLUESPEC_SYSTEM_VERILOG:
            return "bsv-mod"
        else:
            return "unknown"


class Platform:
    pass


class Server:
    def __init__(self, name, arg_size, data_size):
        self.name = name
        self.arg_size = arg_size
        self.data_size = data_size
        self.clients = []
        self.parent = None

    def add_client(self, client):
        client.provider = self
        self.clients.append(client)

    def __str__(self):
        return "[Service " + self.name + "]"


class Client:
    def __init__(self, name):
        self.name = name
        self.parent = None
        self.provider = None


class Property:
    def __init__(self, name, value=None):
        self.name = name
        self.value = value
        self.parent = None

class Control:
    def __init__(self, name, size, direction):
        self.name = name
        self.size = size
        self.direction = direction
        self.parent = None


class Extern:
    def __init__(self, name, size, direction):
        self.name = name
        self.size = size
        self.direction = direction
        self.parent = None


class ExternInterface:
    def __init__(self, name, type_):
        self.name = name
        self.type = type_


class ExternConnection:
    def __init__(self, port_name, extern_name):
        self.name = port_name
        self.port_name = port_name
        self.extern_name = extern_name



class Noc:
    def __init__(self, name):
        self.name = name
        self.connections = {}
        self.servers = []
        self.clients = []

    def connect(self, client, server):
        if client not in self.clients:
            self.clients.append(client)
        if server not in self.servers:
            self.servers.append(server)
        self.connections[client] = server

    def get_num_nodes_pow2(self):
        return next_pow2(len(self.clients) + len(self.servers))

    def gen_mappings(self):
        self.server_to_idx = {}
        for i, server in enumerate(self.servers):
            self.server_to_idx[server] = i
        self.client_to_idx = {}
        for i, client in enumerate(self.clients):
            self.client_to_idx[client] = i

class Direct:
    def __init__(self, name):
        self.name = name
        self.connections = {}
        self.servers = []
        self.clients = []

    def connect(self, client, server):
        if client not in self.clients:
            self.clients.append(client)
        if server not in self.servers:
            self.servers.append(server)
        self.connections[client] = server


class Service:
    def init_members(self):
        self.controls = {}
        self.clients = {}
        self.servers = {}
        self.properties = {}
        self.extern_connections = {}
        self.requires = None
        self.provides = None
        self.bypasses = []

    def __init__(self, source_name, source_type, module_name=None):
        global global_counter
        self.source_type = source_type
        self.source_name = source_name
        if module_name == None:
            self.module_name = source_name + "_" + str(global_counter)
            global_counter += 1
        else:
            self.module_name = module_name
        self.init_members()

    def add(self, thing):
        thing.parent = self
        if isinstance(thing, Control):
            self.controls[thing.name] = thing
        elif isinstance(thing, Client):
            self.clients[thing.name] = thing
        elif isinstance(thing, Server):
            self.servers[thing.name] = thing
        elif isinstance(thing, Property):
            self.properties[thing.name] = thing
        elif isinstance(thing, ExternConnection):
            self.extern_connections[thing.name] = thing
        self.requires = self.clients
        self.provides = self.servers

    def add_property(self, name, value):
        pro = Property(name, value)
        self.add(pro)

    def add_provides(self, name, arg_size, data_size, channel_type=None):
        ser = Server(name, arg_size, data_size)
        self.add(ser)

    def add_requires(self, name, channel_type=None):
        cli = Client(name)
        self.add(cli)

    def add_control(self, name, size, direction):
        con = Control(name, size, direction)
        self.add(con)

    def add_extern_connection(self, port_name, extern_name):
        ext = ExternConnection(port_name, extern_name)
        self.add(ext)

    def add_bypass(self, client, service):
        self.bypasses.append((client, service))
        

class Application:
    def __init__(self, platform, path_prefix="", noc_topology="double_ring", noc_width=224, top_name="soma_app_top", top_includes=[], paste_files=[], hide_controls=False):
        self.platform = platform
        self.path_prefix = path_prefix
        self.noc_clients = []
        self.noc_servers = []
        self.direct_clients = []
        self.direct_servers = []
        self.direct_map = {}
        self.noc_map = {}
        self.externs = {}
        self.extern_interfaces = {}
        self.services = []
        self.noc_topology = noc_topology
        self.noc_width = noc_width
        self.top_name = top_name
        self.top_includes = top_includes
        self.paste_files = paste_files
        self.hide_controls = hide_controls

    def direct(self, client, server):
        self.direct_map[client] = server
        server.add_client(client)
        if client.parent not in self.services:
            self.services.append(client.parent)
        if server.parent not in self.services:
            self.services.append(server.parent)
        if client not in self.direct_clients:
            self.direct_clients.append(client)
        if server not in self.direct_servers:
            self.direct_servers.append(server)

    def noc(self, client, server):
        self.noc_map[client] = server
        server.add_client(client)
        if client.parent not in self.services:
            self.services.append(client.parent)
        if server.parent not in self.services:
            self.services.append(server.parent)
        if client not in self.noc_clients:
            self.noc_clients.append(client)
        if server not in self.noc_servers:
            self.noc_servers.append(server)
        
        self.server_to_idx = {}
        for i, server in enumerate(self.noc_servers):
            self.server_to_idx[server] = i
        self.client_to_idx = {}
        for i, client in enumerate(self.noc_clients):
            self.client_to_idx[client] = i

    def add_extern(self, name, size, direction):
        ext = Extern(name, size, direction)
        self.externs[ext.name] = ext

    def add_extern_interface(self, name, type_):
        extifc = ExternInterface(name ,type_)
        self.extern_interfaces[extifc.name] = extifc


class Pass:
    def __init__(self, data):
        pass

    def print_named(self, string):
        print("[" + type(self).__name__ + "] " + string)

    def run(self, app, data):
        self.print_named("this is a base Pass")

    @staticmethod
    def get_dependencies():
        return []

class PassManager:
    def __init__(self, app):
        self.passes = {}
        self.dependencies = {}
        self.app = app
        self.data = {}

    def add_pass(self, pass_type):
        self.passes[pass_type.__name__] = pass_type
        deps = pass_type.get_dependencies()
        if not isinstance(deps, list):
            deps = [deps]
        self.dependencies[pass_type.__name__] = deps

    def run_pass(self, pass_name, data):
        pass_type = self.passes[pass_name]
        pass_obj = pass_type(data)
        pass_obj.run(self.app, data)

    def load_data(self, key, object):
        self.data[key] = object

    def schedule_and_run_passes(self):
        finished_list = []
        data = self.data
        while len(self.passes) > 0:
            delete_list = []
            for name in self.passes:
                can_run = True
                for dependency in self.dependencies[name]:
                    if dependency not in finished_list:
                        can_run = False
                if can_run:
                    self.run_pass(name, data)
                    finished_list.append(name)
                    delete_list.append(name)
            for name in delete_list:
                del self.passes[name]

    def add_before_pass(self, target_pass_name, new_pass_type):
        target_pass_copy = copy.deepcopy(self.passes[target_pass_name])
        del self.passes[target_pass_name]
        target_pass_deps = self.dependencies[target_pass_copy.__name__]
        target_pass_deps.append(new_pass_type.__name__)
        target_pass_copy.get_dependencies = lambda : target_pass_deps
        self.add_pass(new_pass_type)
        self.add_pass(target_pass_copy)

