`ifndef _DRIVER_SV_
`define _DRIVER_SV_
class driver extends uvm_driver#(packet);
    // data or class properties
    `uvm_component_utils(driver);
    virtual router_io sigs;
    int port_id = -1;

    // initialization
    function new(string name="driver", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(virtual router_io)::get(this, "", "router_io", sigs);
        uvm_config_db#(int)::get(this, "", "port_id", port_id);
    endfunction: build_phase

    virtual task run_phase(uvm_phase phase); 
        while (1) begin
            seq_item_port.get_next_item(req);
            send(req);
            seq_item_port.item_done();
            `uvm_info("PACKET_GET_DATA", {"\n", $sformatf("%s", req.sprint())}, UVM_HIGH);
            `uvm_info("PACKET_GET", $sformatf("port_id %0d get a packet", port_id), UVM_LOW);
        end
    endtask: run_phase

    virtual task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        if(port_id==-1) begin
            sigs.drvClk.frame_n <= '1;
            sigs.drvClk.valid_n <= '1;
            sigs.drvClk.din <= '0;
        end else begin
            sigs.drvClk.frame_n[port_id] <= '1;
            sigs.drvClk.valid_n[port_id] <= '1;
            sigs.drvClk.din[port_id] <= '0;
        end
        phase.drop_objection(this);
    endtask: reset_phase

    virtual task send(packet tr);
        send_address(tr);
        send_pad(tr);
        send_payload(tr);
    endtask: send

    virtual task send_address(packet tr);
        sigs.drvClk.frame_n[tr.sa] <= 0;
        for (int i = 0; i < 4; i++) begin
            sigs.drvClk.din[tr.sa] <= tr.da[i];
            @(sigs.drvClk);
        end
    endtask: send_address

    virtual task send_pad(packet tr);
        sigs.drvClk.valid_n[tr.sa] <= 1;
        sigs.drvClk.din[tr.sa] <= 1;
        for (int i = 0; i < 5; i++) begin
            @(sigs.drvClk);
        end
    endtask: send_pad

    virtual task send_payload(packet tr);
        bit [7:0] payload_each;

        while (!sigs.drvClk.busy_n[tr.sa]) begin
            @(sigs.drvClk);
        end
        sigs.drvClk.valid_n[tr.sa] <= 0;
        foreach (tr.payload[idx]) begin
            payload_each = tr.payload[idx];
            for (int i = 0; i < 8; i++) begin
                sigs.drvClk.din[tr.sa] <= payload_each[i];
                sigs.drvClk.frame_n[tr.sa] <= (tr.payload.size==idx+1) && (i == 7);
                @(sigs.drvClk);
            end
        end
        sigs.drvClk.valid_n[tr.sa] <= 1;
    endtask: send_payload

endclass : driver
`endif
