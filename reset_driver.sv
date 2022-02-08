`ifndef _RESET_DRIVER_SV
`define _RESET_DRIVER_SV

class reset_driver extends uvm_driver#(reset_transaction);
    // data or class properties
    virtual router_io sigs;

    `uvm_component_utils(reset_driver)

    // initialization
    function new(string name="reset_driver", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual router_io)::get(this, "", "router_io", sigs);
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("RESET_GET", {"\n", req.sprint}, UVM_HIGH)
            drive(req);
            seq_item_port.item_done;
        end
    endtask: run_phase

    virtual task drive(reset_transaction tr);
        if (tr.kind==reset_transaction::ASSERT) begin
            sigs.drvClk.reset_n <= 0;
        end else begin
            sigs.drvClk.reset_n <= 1;
            /* sigs.reset_n <= 1; */
        end
        repeat (tr.cycle_cnt) begin
            @(sigs.drvClk);
        end
    endtask: drive

endclass : reset_driver
`endif
