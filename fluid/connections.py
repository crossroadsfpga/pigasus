#### Pigasus 2.0 Fluid Connection Types ####
from .header import *
from .parse_ast import *

# Ugly hack: global var for incrementally naming connections in Verilog
count = 0

# Constructs a custom class on-the-fly that implements a standard Pigasus 3-FIFO ChannelFIFO
# this custom class instantiates a triple-FIFO Verilog module and wires it up on both sides
# it also hides the triple-FIFO module in the visuals for reduced clutter
def make_channel_fifo(clk_i, rst_n_i, counter, dual_clock=False, clk_o=None, rst_n_o=None):
    class CF(Service):
        def __init__(self, name):
            # Specify the Verilog source file, here channel_fifo_service.sv (note lack of extension)
            # Other option is Bluespec source file with SourceType.BLUESPEC_SYSTEM_VERILOG
            super().__init__("channel_fifo_service", SourceType.SYSTEM_VERILOG, name)
            if dual_clock == False:
                self.add_extern_connection("Clk_i", clk_i)
                self.add_extern_connection("Rst_n_i", rst_n_i)
                self.add_property("parameters", {"DUAL_CLOCK":"0"})
            else:
                self.add_extern_connection("Clk_i", clk_i)
                self.add_extern_connection("Rst_n_i", rst_n_i)
                self.add_extern_connection("Clk_o", clk_o)
                self.add_extern_connection("Rst_n_o", rst_n_o)
                self.add_property("parameters", {"DUAL_CLOCK":"1"})

            self.add_control("in_pkt_fill_level", 32, Direction.OUTPUT)

            # the provides-requires relationship may be a bit confusing here
            # basically this service "provides" a triple-FIFO to send messages to i.e. this is input side
            self.add_provides("in_pkt", 32, 512, channel_type="Packet")
            self.add_provides("in_meta", 32, 512, channel_type="Meta")
            self.add_provides("in_usr", 32, 512, channel_type="Usr")

            # this service "requires" a module to drain the FIFOs i.e. the output side
            self.add_requires("out_pkt", channel_type="Packet")
            self.add_requires("out_meta", channel_type="Meta")
            self.add_requires("out_usr", channel_type="Usr")

            # some stats connections. Can be ignored for now.
            self.add_control("stats_in_pkt", 32, Direction.OUTPUT);
            self.add_control("stats_in_pkt_sop", 32, Direction.OUTPUT);
            self.add_control("stats_in_meta", 32, Direction.OUTPUT);
            self.add_control("stats_in_rule", 32, Direction.OUTPUT);
            
            # for visualization ONLY - if you could remove this module from the diagram,
            # which connections would you show connected from the in side and out side?
            # this has no functional use otherwise, no effect on generated Verilog.
            self.add_bypass(self.requires["out_pkt"], self.provides["in_pkt"])
            self.add_bypass(self.requires["out_meta"], self.provides["in_meta"])
            self.add_bypass(self.requires["out_usr"], self.provides["in_usr"])
            
            # do not render this module in the visualization, instead use a bold line to connect bypasses
            # can be "dashed" too for  a e s t h e t i c s
            self.add_property("hide-visualization", "bold")
    global count

    # do some metaclass magic to rename our class at runtime (otherwise they will all be called "CF")
    CF.__name__ = "CF_" + str(count)
    CF.__qualname__ = "CF_" + str(count)
    count += 1
    return CF # this function returns a runtime-built Python *class*, not an object


# Given a ChannelFIFO class constructed as above and a source module and a sink module, connect them up
# This is a dumb version that does not do auto clock crossing
def connect_channel_fifo(app, fifo_class, name, source, sink):
    fifo = fifo_class(name)
    app.direct(source.requires["out_pkt"], fifo.provides["in_pkt"])
    app.direct(source.requires["out_meta"], fifo.provides["in_meta"])
    app.direct(source.requires["out_usr"], fifo.provides["in_usr"])

    app.direct(fifo.requires["out_pkt"], sink.provides["in_pkt"])
    app.direct(fifo.requires["out_meta"], sink.provides["in_meta"])
    app.direct(fifo.requires["out_usr"], sink.provides["in_usr"])

# Given a ChannelFIFO class constructed as above and a source module and a sink module, connect them up
# This is the smart variant that looks up clocks automatically
def connect_channel_fifo_auto(app, fifo_class, name, source, sink):
    fifo = fifo_class(name)
    #look up clocks automatically
    src_clk = None
    dst_clk = None
    src_rst = None
    dst_rst = None
    
    if source.extern_connections.get("Clk_back") != None:
        src_clk = source.extern_connections["Clk_back"].extern_name
    elif source.extern_connections.get("Clk_o") != None:
        src_clk = source.extern_connections["Clk_o"].extern_name
    elif source.extern_connections.get("Clk") != None:
        src_clk = source.extern_connections["Clk"].extern_name
    if src_clk != None:
        fifo.extern_connections["Clk_i"].extern_name = src_clk

    if source.extern_connections.get("Rst_back_n") != None:
        src_rst = source.extern_connections["Rst_back_n"].extern_name
    elif source.extern_connections.get("Rst_n_o") != None:
        src_rst = source.extern_connections["Rst_n_o"].extern_name
    elif source.extern_connections.get("Rst_n") != None:
        src_rst = source.extern_connections["Rst_n"].extern_name
    if src_rst != None:
        fifo.extern_connections["Rst_n_i"].extern_name = src_rst

    if sink.extern_connections.get("Clk") != None:
        dst_clk = sink.extern_connections["Clk"].extern_name
    elif sink.extern_connections.get("Clk_i") != None:
        dst_clk = sink.extern_connections["Clk_i"].extern_name
    if fifo.extern_connections.get("Clk_o") != None and dst_clk != None:
        fifo.extern_connections["Clk_o"].extern_name = dst_clk

    if sink.extern_connections.get("Rst_n") != None:
        dst_rst = sink.extern_connections["Rst_n"].extern_name
    elif sink.extern_connections.get("Rst_n_i") != None:
        dst_rst = sink.extern_connections["Rst_n_i"].extern_name
    if fifo.extern_connections.get("Rst_n_o") != None and dst_rst != None:
        fifo.extern_connections["Rst_n_o"].extern_name = dst_rst
    
    app.direct(source.requires["out_pkt"], fifo.provides["in_pkt"])
    app.direct(source.requires["out_meta"], fifo.provides["in_meta"])
    app.direct(source.requires["out_usr"], fifo.provides["in_usr"])

    app.direct(fifo.requires["out_pkt"], sink.provides["in_pkt"])
    app.direct(fifo.requires["out_meta"], sink.provides["in_meta"])
    app.direct(fifo.requires["out_usr"], sink.provides["in_usr"])
    

# Just like ChannelFIFO, this constructs a runtime class for a single FIFO connection used in Pigasus for talking to Ethernet
def make_unified_fifo(clk_i, rst_n_i, uf_name, fill_level, dual_clock=False, clk_o=None, rst_n_o=None):
    class UF(Service):
        def __init__(self, name):
            super().__init__("unified_pkt_fifo_service", SourceType.SYSTEM_VERILOG, name)
            if dual_clock == False:
                self.add_extern_connection("Clk_i", clk_i)
                self.add_extern_connection("Rst_n_i", rst_n_i)
                # Fill in the Verilog module's paramaters
                self.add_property("parameters", {"FIFO_NAME":'"' + uf_name + '"', 
                                                 "MEM_TYPE":'"M20K"',
                                                 "DUAL_CLOCK":"0",
                                                 "USE_ALMOST_FULL":"1",
                                                 "FULL_LEVEL":"450",
                                                 "SYMBOLS_PER_BEAT":"64",
                                                 "BITS_PER_SYMBOL":"8",
                                                 "FIFO_DEPTH":"512"})
            else:
                self.add_extern_connection("Clk_i", clk_i)
                self.add_extern_connection("Rst_n_i", rst_n_i)
                self.add_extern_connection("Clk_o", clk_o)
                self.add_extern_connection("Rst_n_o", rst_n_o)
                self.add_property("parameters", {"FIFO_NAME":'"' + uf_name + '"', 
                                                 "MEM_TYPE":'"M20K"', 
                                                 "DUAL_CLOCK":"1",
                                                 "USE_ALMOST_FULL":"1",
                                                 "FULL_LEVEL":"450",
                                                 "SYMBOLS_PER_BEAT":"64",
                                                 "BITS_PER_SYMBOL":"8",
                                                 "FIFO_DEPTH":"512"})

            self.add_provides("in", 32, 512)
            self.add_requires("out")
            self.add_extern_connection("fill_level", fill_level)
            self.add_bypass(self.requires["out"], self.provides["in"])
            self.add_property("hide-visualization", "bold")
    global count
    UF.__name__ = "UF_" + str(count)
    UF.__qualname__ = "UF_" + str(count)
    return UF


# make a cross-fpga connection
def connect_cross_fpga(app, app1, fifo_class, name, cross_mux, cross_demux, source, dest):
    connect_channel_fifo_auto(app, fifo_class, name, source, cross_mux)
    connect_channel_fifo_auto(app1, fifo_class, name, cross_demux, dest)