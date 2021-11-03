`timescale 1 ps / 1 ps
module generic_component_0 (
    input  coreclkin_hip,      
    input  app_nreset_status,  
    output wire  coreclkout_hip,    
    output wire  app_nreset_status_1
    );

    assign coreclkout_hip = coreclkin_hip;
    assign app_nreset_status_1 = app_nreset_status;
endmodule
