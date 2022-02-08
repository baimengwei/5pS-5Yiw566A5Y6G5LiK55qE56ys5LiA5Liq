`ifndef _OUTPUT_MONITOR_SV_
`define _OUTPUT_MONITOR_SV_
class output_monitor extends uvm_monitor;
    // data or class properties
    `uvm_component_utils(output_monitor)
    uvm_analysis_port#(packet) analysis_port;

    virtual router_io sigs;
    int port_id = -1;

    // initialization
    function new(string name="output_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_port = new("analysis_port", this);
        uvm_config_db#(int)::get(this, "", "port_id", port_id);
        uvm_config_db#(virtual router_io)::get(this, "", "router_io", sigs);
        if (port_id==-1) begin
            `uvm_fatal("DATA_ERROR", "port_id is not set!")
        end
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase);
        forever begin
            packet tr = packet::type_id::create("packet");
            tr.da = port_id;
            get_packet(tr);
            analysis_port.write(tr);
            `uvm_info("MONITOR_OUTPUT_SEND", $sformatf("port_id %0d send a packet", port_id), UVM_LOW)
        end
    endtask: run_phase

    virtual task get_packet(packet tr);
        @(negedge sigs.oMonClk.frameo_n[port_id]);

        forever begin
            logic [7:0] payload_each;
            for (int i = 0; i < 8; i=i) begin
                if(!sigs.oMonClk.valido_n[port_id]) begin
                    payload_each[i] = sigs.oMonClk.dout[port_id];
                    i++;
                    if(i==8) begin
                        tr.payload.push_back(payload_each);
                    end
                    if(sigs.oMonClk.frameo_n[port_id]) begin
                        if(i==8) begin
                            return;
                        end else begin
                            `uvm_fatal("BUS_ERROR", "payload not aligned.")
                        end
                    end
                end
                @(sigs.oMonClk);
            end
        end
    endtask: get_packet

endclass : output_monitor

`endif
