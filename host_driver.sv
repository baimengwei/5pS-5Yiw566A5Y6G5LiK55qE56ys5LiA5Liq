`ifndef _HOST_DRIVER_SV_
`define _HOST_DRIVER_SV_
class host_driver extends uvm_driver#(host_data);
    // data or class properties
    `uvm_component_utils(host_driver)
    virtual host_io sigs;

    // initialization
    function new(string name="host_driver", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual host_io)::get(this, "", "host_io", sigs);
    endfunction: build_phase

    virtual task reset_phase(uvm_phase phase);
        sigs.wr_n = '1;
        sigs.address = '1;
        sigs.data = '1;
    endtask: reset_phase

    virtual task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            `uvm_info("HOST_GET_BEFORE", req.sprint, UVM_MEDIUM)
            data_rw(req);
            seq_item_port.item_done();
            `uvm_info("HOST_GET_AFTER", req.sprint, UVM_MEDIUM)
        end
    endtask: run_phase

    virtual task data_rw(host_data req);
        // pay attention to the equation
        case (req.kind)
            host_data::READ: begin
                sigs.wr_n = 1;
                sigs.address <= req.address;
                @(sigs.cb);
                req.data = sigs.data;
            end
            host_data::WRITE: begin
                sigs.wr_n = 0;
                sigs.data = req.data;
                sigs.address <= req.address;
                @(sigs.cb);
                sigs.wr_n = 1;
                sigs.data = 'z;
            end
            default: begin
                `uvm_fatal("DATA_ERROR", $sformatf("value req.kind error %s", req.kind))
            end
        endcase
    endtask: data_rw
endclass : host_driver
`endif
