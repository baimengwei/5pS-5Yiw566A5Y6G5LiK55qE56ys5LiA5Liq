`ifndef _HOST_MONITOR_SV_
`define _HOST_MONITOR_SV_
// should be delete.
class host_monitor extends uvm_monitor;
    // data or class properties
    virtual host_io sigs;
    event go;
    uvm_analysis_port#(host_data) analysis_port;

    `uvm_component_utils(host_monitor)

    // initialization
    function new(string name="host_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual host_io)::get(this, "", "host_io", sigs);
        analysis_port = new("analysis_port", this);
    endfunction: build_phase

    virtual task post_reset_phase(uvm_phase phase);
        -> go;
    endtask: post_reset_phase

    virtual task run_phase(uvm_phase phase);
        wait(go.triggered);
        forever begin
            host_data tr = new("host_data");
            data_rw(tr);
            //TODO  where to go ?
            analysis_port.write(tr);
            `uvm_info("HOST_MONITOR", "send a tr", UVM_MEDIUM);
        end
    endtask: run_phase

    virtual task data_rw(host_data tr);
        if (!sigs.mon.wr_n) begin
            tr.address = sigs.address;
            tr.data = sigs.data;
            tr.kind = host_data::WRITE;
            @(sigs.mon);
        end else begin
            //TODO fork join just one thread?
            /* fork */
                /* begin */
                    fork
                        @(sigs.mon.address);
                        @(sigs.mon.wr_n);
                    join_any
                    disable fork;
                    tr.address = sigs.mon.address;
                    tr.data = sigs.mon.data;
                    if(!sigs.mon.wr_n) begin
                        tr.kind = host_data::WRITE;
                    end else begin
                        tr.kind = host_data::READ;
                    end
                /* end */
            /* join */
        end
        `uvm_info("HOST_MONITOR", "starting. ", UVM_MEDIUM)
    endtask: data_rw
endclass : host_monitor
`endif
