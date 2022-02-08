`ifndef _INOUT_AGENT_SV_
`define _INOUT_AGENT_SV_
`include "packet.sv"
`include "packet_da_pl.sv"

`include "driver.sv"
`include "packet_sequence.sv"
`include "input_monitor.sv"
`include "output_monitor.sv"

typedef uvm_sequencer#(packet) packet_sequencer;

class inout_agent extends uvm_agent;
// data or class properties
`uvm_component_utils(inout_agent)

driver drv;
packet_sequencer seqr;
packet_sequence seq;
input_monitor i_mon;
output_monitor o_mon;
virtual router_io sigs;
uvm_analysis_port#(packet) analysis_port;

int port_id = -1;

// initialization
function new(string name="inout_agent", uvm_component parent);
    super.new(name, parent);
endfunction : new

virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    uvm_config_db#(uvm_active_passive_enum)::get(this, "", "is_active", is_active);
    uvm_config_db#(virtual router_io)::get(this, "", "router_io", sigs);
    uvm_config_db#(int)::get(this, "", "port_id", port_id);
    if(port_id==-1) begin
        `uvm_fatal("BUILD_ERROR", $sformatf("%m port_id is not set!"))
    end

    if (is_active == UVM_ACTIVE) begin
        drv = driver::type_id::create("drv", this);
        seqr = packet_sequencer::type_id::create("seqr", this);
        i_mon = input_monitor::type_id::create("i_mon", this);

        uvm_config_db#(virtual router_io)::set(this, "drv", "router_io", sigs);
        uvm_config_db#(virtual router_io)::set(this, "seqr", "router_io", sigs);
        uvm_config_db#(virtual router_io)::set(this, "i_mon", "router_io", sigs);
        uvm_config_db#(uvm_object_wrapper)::set(this, "seqr.main_phase", "default_sequence", seq.get_type());
        uvm_config_db#(int)::set(this, "i_mon", "port_id", port_id);
        uvm_config_db#(int)::set(this, "seqr", "port_id", port_id);
        uvm_config_db#(int)::set(this, "drv", "port_id", port_id);
    end else begin
        o_mon = output_monitor::type_id::create("o_mon", this);
        uvm_config_db#(virtual router_io)::set(this, "o_mon", "router_io", sigs);
        uvm_config_db#(int)::set(this, "o_mon", "port_id", port_id);
    end

    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        if (is_active == UVM_ACTIVE) begin
            drv.seq_item_port.connect(seqr.seq_item_export);
            this.analysis_port = i_mon.analysis_port;
        end else begin
            this.analysis_port = o_mon.analysis_port;
        end
    endfunction: connect_phase

endclass : inout_agent
`endif
