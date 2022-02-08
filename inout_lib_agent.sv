`ifndef _INOUT_LIB_AGENT_SV_
`define _INOUT_LIB_AGENT_SV_
`include "inout_agent.sv"
import packet_seq_lib_pkg::*;

class inout_lib_agent extends inout_agent;
    // data or class properties
    `uvm_component_utils(inout_lib_agent)

    // initialization
    function new(string name="inout_lib_agent", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (is_active == UVM_ACTIVE) begin
            uvm_config_db#(uvm_object_wrapper)::set(
                this, "seqr.main_phase", "default_sequence", packet_seq_lib::get_type());
        end
    endfunction: build_phase

endclass : inout_lib_agent
`endif
