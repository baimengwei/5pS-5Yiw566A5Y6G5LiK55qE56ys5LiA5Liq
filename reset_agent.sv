`ifndef _RESET_AGENT_SV_
`define _RESET_AGENT_SV_

`include "reset_transaction.sv"
`include "reset_sequence.sv"
`include "reset_driver.sv"

typedef uvm_sequencer#(reset_transaction) reset_sequencer;

class reset_agent extends uvm_agent;
    // data or class properties
    reset_sequencer seqr;
    reset_sequence seq;
    reset_driver drv;
    virtual router_io sigs;

    `uvm_component_utils(reset_agent)

    // initialization
    function new(string name="reset_agent", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);
        uvm_config_db#(virtual router_io)::get(this, "", "router_io", sigs);

        `uvm_info("DEBUG_RESET", $sformatf("is_active is %s", is_active), UVM_NONE)
        if(is_active==UVM_ACTIVE) begin
            drv = reset_driver::type_id::create("drv", this);
            seqr = reset_sequencer::type_id::create("seqr", this);

            uvm_config_db#(virtual router_io)::set(this, "drv", "router_io", sigs);
        end
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(is_active==UVM_ACTIVE) begin
            uvm_config_db#(uvm_object_wrapper)::set(this, "seqr.reset_phase", "default_sequence", seq.get_type());
            drv.seq_item_port.connect(seqr.seq_item_export);
        end
    endfunction: connect_phase

endclass : reset_agent
`endif
