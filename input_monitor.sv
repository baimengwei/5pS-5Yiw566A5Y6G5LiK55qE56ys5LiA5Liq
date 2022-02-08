`ifndef _INPUT_MONITOR_SV_
`define _INPUT_MONITOR_SV_
class input_monitor extends uvm_monitor;
    // data or class properties
    `uvm_component_utils(input_monitor)

    uvm_analysis_port#(packet) analysis_port;
    virtual router_io sigs;
    int port_id = -1;

    // initialization
    function new(string name="input_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        analysis_port = new("analysis_port", this);
        uvm_config_db#(int)::get(this, "", "port_id", port_id);
        uvm_config_db#(virtual router_io)::get(this, "", "router_io", sigs);
        if(sigs == null)
            `uvm_fatal("CONFIG_DB_ERROR", "sigs set failed!");
    endfunction: build_phase


    virtual task run_phase(uvm_phase phase);
        forever begin
            packet tr = packet::type_id::create("packet");
            get_packet(tr);
            analysis_port.write(tr);
            `uvm_info("MONITOR_INPUT_SEND", $sformatf("port_id %0d send a packet", port_id), UVM_LOW)
        end
    endtask: run_phase

    virtual task get_packet(packet tr);
        @(negedge sigs.iMonClk.frame_n[port_id]);
        for (int i = 0; i < 4; i++) begin
            tr.da[i] = sigs.iMonClk.din[port_id];
            @(sigs.iMonClk);
        end

        for (int i = 0; i < 5; i++) begin
            if(!sigs.iMonClk.frame_n[port_id]) begin
                if(sigs.iMonClk.valid_n[port_id] && sigs.iMonClk.din[port_id]) begin
                end else begin
                    `uvm_fatal("BUS_ERROR", $sformatf("valid_n %d or din %d error",
                        sigs.iMonClk.valid_n[port_id], sigs.iMonClk.din[port_id]))
                end
            end else begin
                `uvm_fatal("BUS_ERROR", "frame head is not 0")
            end

            if(sigs.iMonClk.din[port_id] != 1 || 
                sigs.iMonClk.frame_n[port_id] != 0 ||
                sigs.iMonClk.valid_n[port_id] != 1)
                `uvm_fatal("BUS_ERROR", "invalid between addr and payload")
            @(sigs.iMonClk);
        end

        while(!(sigs.iMonClk.busy_n[port_id] == 1 )) begin
            @(sigs.iMonClk.busy_n[port_id]);
        end
        while(!(sigs.iMonClk.valid_n[port_id] == 0 )) begin
            @(sigs.iMonClk.valid_n[port_id]);
        end
        forever begin
            bit [7:0] payload_each;

            for (int i = 0; i < 8; i=i) begin
                if(!(sigs.iMonClk.valid_n[port_id])) begin
                    if(sigs.iMonClk.busy_n[port_id]) begin
                        payload_each[i] = sigs.iMonClk.din[port_id];
                        i++;
                        if(i == 8) begin
                            tr.payload.push_back(payload_each);
                        end
                    end else begin
                        `uvm_fatal("BUS_ERROR", "invalid in busy_n")
                    end
                end
                if(sigs.iMonClk.frame_n[port_id]) begin
                    if( i==8 ) begin
                        return;
                    end else begin
                        `uvm_fatal("BUS_ERROR", "payload is not enough")
                    end
                end
                @(sigs.iMonClk);
            end


        end
        
    endtask: get_packet
endclass : input_monitor
`endif
