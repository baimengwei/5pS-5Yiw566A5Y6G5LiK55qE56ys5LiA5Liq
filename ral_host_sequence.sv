`ifndef _RAL_HOST_SEQUENCE_SV_
`define _RAL_HOST_SEQUENCE_SV_
`include "ral_host_regmodel.sv"

class ral_host_sequence extends uvm_reg_sequence#(uvm_sequence #(host_data));
    // data or class properties
    ral_block_host_regmodel regmodel;    
    `uvm_object_utils(ral_host_sequence)
    // initialization

    function new(string name="ral_host_sequence");
        super.new(name);
    endfunction : new

    virtual task body();
        uvm_status_e status;
        uvm_reg_data_t data;
        if (starting_phase!=null) begin
            starting_phase.raise_objection(this);
        end
        regmodel.PORT_LOCK.read(.status(status), .value(data), .path(UVM_FRONTDOOR), .parent(this));
        `uvm_info("RAL_READ", $sformatf("read_port_lock %0h", data), UVM_MEDIUM)
        regmodel.PORT_LOCK.write(.status(status), .value('1), .path(UVM_FRONTDOOR), .parent(this));
        `uvm_info("RAL_WRITE", $sformatf("read_port_lock %0h", data), UVM_MEDIUM)
        regmodel.PORT_LOCK.read(.status(status), .value(data), .path(UVM_FRONTDOOR), .parent(this));
        `uvm_info("RAL_READ", $sformatf("read_port_lock %0h", data), UVM_MEDIUM)
        if (starting_phase!=null) begin
            starting_phase.drop_objection(this);
        end
    endtask: body

endclass : ral_host_sequence
`endif
