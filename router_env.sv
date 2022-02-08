`ifndef _ROUTER_ENV_SV_
`define _ROUTER_ENV_SV_
`include "inout_agent.sv"
`include "reset_agent.sv"
`include "host_agent.sv"
`include "inout_lib_agent.sv"
`include "ral_host_agent.sv"
`include "scoreboard.sv"
class router_env extends uvm_env;
    // data or class properties
    `uvm_component_utils(router_env);
    `define _ROUTER_ENV_PORT_CNT 16
    inout_agent i_agt[`_ROUTER_ENV_PORT_CNT];
    inout_agent o_agt[`_ROUTER_ENV_PORT_CNT];
    reset_agent r_agt;
    host_agent h_agt;
    scoreboard sb;

    // initialization
    function new(string name="router_env", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TRACE", "%m", UVM_HIGH);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        r_agt = reset_agent::type_id::create("r_agt", this);
        sb = scoreboard::type_id::create("sb", this);
        h_agt = host_agent::type_id::create("h_agt", this);

        for (int i = 0; i < `_ROUTER_ENV_PORT_CNT; i++) begin
            i_agt[i] = inout_agent::type_id::create($sformatf("i_agt[%0d]", i), this);
            uvm_config_db#(uvm_active_passive_enum)::set(this,
                $sformatf("i_agt[%0d]", i), "is_active", UVM_ACTIVE);
            uvm_config_db#(int)::set(this,
                $sformatf("i_agt[%0d]", i), "port_id", i);

            o_agt[i] = inout_agent::type_id::create($sformatf("o_agt[%0d]", i), this);
            uvm_config_db#(uvm_active_passive_enum)::set(this,
                $sformatf("o_agt[%0d]", i), "is_active", UVM_PASSIVE);
            uvm_config_db#(int)::set(this,
                $sformatf("o_agt[%0d]", i), "port_id", i);
        end
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        for (int i = 0; i < `_ROUTER_ENV_PORT_CNT; i++) begin
            i_agt[i].analysis_port.connect(sb.export_before);
            o_agt[i].analysis_port.connect(sb.export_after);
        end
    endfunction: connect_phase
endclass : router_env
`endif
