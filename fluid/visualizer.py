from graphviz import Graph, Digraph
from .header import Pass, not_none
import copy
import enum

class VisualizerPass(Pass):
    
    
    def run(self, app, data):
        g = Digraph("Services", filename="lmao.gv", engine=self.engine, format="png")
        g.attr("node", shape="plaintext")
        g.graph_attr["rankdir"] = "RL"
        # g.attr("node", color="#F9F4F1")
        # g.attr("node", style="filled")
        client_table = {}
        server_table = {}
        to_delete = []
        invisible_clients = {}
        for service in app.services:
            if service.properties.get("hide-visualization") != None:
                viz_type = service.properties["hide-visualization"].value
                #print("Invisible node: {}".format(service.module_name))
                #edit the service and client tables 
                #currently, direct only
                to_delete.append(service)
                to_delete_clients = []
                to_connect = []
                for b_client, b_server in service.bypasses:
                    target_server = app.direct_map[b_client]
                    to_delete_clients.append(b_client)
                    target_client = None
                    for m_client, m_server in app.direct_map.items():
                        if b_server == m_server:
                            target_client = m_client
                            to_delete_clients.append(target_client)
                    app.direct_clients.remove(b_client)
                    app.direct_servers.remove(b_server)
                    to_connect.append((target_client, target_server))
                for client in to_delete_clients:
                    del app.direct_map[client]
                for tc, ts in to_connect:
                    #print("{}, {}".format(tc.name, ts.name))
                    app.direct(tc, ts)
                    invisible_clients[tc] = viz_type

        for service in to_delete:
            app.services.remove(service)

        for service in app.services:
            # """"<<TABLE BORDER="1" CELLBORDER="1" CELLSPACING="0">
            #         <TR><TD PORT="f0"><B>title</B></TD></TR>
            #         <TR><TD PORT="f1">index</TD></TR>
            #         <TR><TD PORT="f2">field1</TD></TR>
            #         <TR><TD PORT="f3">field2</TD></TR>
            #     </TABLE>>"""
            client_ifcs = [client.name for client in service.clients.values()]
            server_ifcs = [server.name for server in service.servers.values()]
            num_clients = len(client_ifcs)
            # f_list = ["<TR><TD PORT=\"f{}\" bgcolor=\"#2c92ff\">{}</TD></TR>".format(i, name) for i, name in enumerate(client_ifcs)]
            # f_list += ["<TR><TD PORT=\"f{}\" bgcolor=\"#ffe387\">{}</TD></TR>".format(i + num_clients, name) for i, name in enumerate(server_ifcs)]
            f_list = ["<TR><TD PORT=\"f{}\" bgcolor=\"#2c92ff\">{}</TD></TR>".format(i, name) for i, name in enumerate(client_ifcs)]
            f_list += ["<TR><TD PORT=\"f{}\" bgcolor=\"#ffe387\">{}</TD></TR>".format(i + num_clients, name) for i, name in enumerate(server_ifcs)]
            line = '<<TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0">' + '<TR><TD><B>{}</B></TD></TR>'.format(service.module_name) + " ".join(f_list) + "</TABLE>>"
            client_table[service.module_name] = client_ifcs
            server_table[service.module_name] = server_ifcs
            g.node(service.module_name, line)

        for client, server in app.direct_map.items():
            server_port_idx = len(client_table[server.parent.module_name]) + server_table[server.parent.module_name].index(server.name)
            client_port_idx = client_table[client.parent.module_name].index(client.name)
            #g.edge("{}:f{}".format(server.module.name, server_port_idx), "{}:f{}".format(client.module.name, client_port_idx), color="#43aa8b", label="{}:{}".format(server.arg_size, server.data_size), fontsize=self.label_size, fontcolor="#43aa8b")
            if client in invisible_clients:
                g.edge("{}:f{}".format(server.parent.module_name, server_port_idx), "{}:f{}".format(client.parent.module_name, client_port_idx), fontsize=self.label_size, style=invisible_clients[client], dir="back")
            else:
                g.edge("{}:f{}".format(server.parent.module_name, server_port_idx), "{}:f{}".format(client.parent.module_name, client_port_idx), fontsize=self.label_size, dir="back")
            #g.edge("{}:f{}".format(server.parent.module_name, server_port_idx), "{}:f{}".format(client.parent.module_name, client_port_idx), label="{}:{}".format(server.arg_size, server.data_size), fontsize=self.label_size)

        for client, server in app.noc_map.items():
            server_port_idx = len(client_table[server.parent.module_name]) + server_table[server.parent.module_name].index(server.name)
            client_port_idx = client_table[client.parent.module_name].index(client.name)
            #g.edge("{}:f{}".format(server.module.name, server_port_idx), "{}:f{}".format(client.module.name, client_port_idx), color="#f94144", label="{}:{}".format(server.arg_size, server.data_size), fontsize=self.label_size, fontcolor="#f94144")
            #g.edge("{}:f{}".format(server.parent.module_name, server_port_idx), "{}:f{}".format(client.parent.module_name, client_port_idx), label="{}:{}".format(server.arg_size, server.data_size), fontsize=self.label_size, style="dashed")
            g.edge("{}:f{}".format(server.parent.module_name, server_port_idx), "{}:f{}".format(client.parent.module_name, client_port_idx), style="dashed", dir="back")
        g.render("services.gv", view=False)

class VisualizerType(enum.Enum):
    DEFAULT = 0
    CIRCULAR = 1
    ENERGY = 2

    @staticmethod
    def to_string(t):
        if t == VisualizerType.DEFAULT:
            return "dot"
        elif t == VisualizerType.CIRCULAR:
            return "circo"
        else:
            return "neato"


def generate_visualizer_pass(type=VisualizerType.DEFAULT, label_size=10):
    p = VisualizerPass
    p.engine = VisualizerType.to_string(type)
    p.label_size = str(label_size)
    return p
