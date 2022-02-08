`ifndef _HOST_AGENT_SV_
`define _HOST_AGENT_SV_

`include "host_data.sv"

`include "host_driver.sv"
`include "host_monitor.sv"
`include "host_sequence.sv"

typedef uvm_sequencer#(host_data) host_sequencer;

class host_agent extends uvm_agent;
    // data or class properties
    host_driver drv;

    host_sequence seq;
    host_sequencer seqr;
    virtual host_io sigs;

    `uvm_component_utils(host_agent)

    // initialization
    function new(string name="host_agent", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual host_io)::get(this, "", "host_io", sigs);
        //
        drv = host_driver::type_id::create("drv", this);
        seqr = host_sequencer::type_id::create("seqr", this);
        //
        uvm_config_db#(uvm_object_wrapper)::set(this, "seqr.configure_phase", "default_sequence", seq.get_type());
        uvm_config_db#(virtual host_io)::set(this, "drv", "host_io", sigs);

    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(seqr.seq_item_export);
    endfunction: connect_phase

endclass : host_agent
`endif
