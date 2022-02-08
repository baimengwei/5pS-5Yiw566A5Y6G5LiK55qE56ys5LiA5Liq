`ifndef _PACKET_SEQUENCE_SV_
`define _PACKET_SEQUENCE_SV_
class packet_sequence extends uvm_sequence#(packet);
    // data or class properties
    int item_count=10;
    int port_id=-1;
    bit[15:0] da_enable='1;
    int valid_da[$];

    `uvm_object_utils(packet_sequence);

    // initialization
    function new(string name="packet_sequence");
        super.new(name);
    endfunction : new

    function void pre_randomize();
        uvm_config_db#(int)::get(m_sequencer, "", "item_count", item_count);
        uvm_config_db#(int)::get(m_sequencer, "", "port_id", port_id);
        uvm_config_db#(bit[15:0])::get(m_sequencer, "", "da_enable", da_enable);
        valid_da.delete();
        for (int i = 0; i < 16; i++) begin
            if (da_enable[i]==1) begin
                valid_da.push_back(i);
            end
        end
        `uvm_info("DATA_INFO",
            $sformatf("item_count %0d, port_id %0d, da_enable %0d", item_count, port_id, da_enable), UVM_MEDIUM)
    endfunction: pre_randomize

    virtual task body();
        uvm_sequence_base parent = get_parent_sequence();
        if (parent != null) begin
            starting_phase = parent.starting_phase;
        end

        if(starting_phase!=null) begin
            uvm_objection objection  = starting_phase.get_objection();
            objection.set_drain_time(this, 1us);
            starting_phase.raise_objection(this);
        end
        
        repeat (item_count) begin
            /* `uvm_do(req) */
            `uvm_do_with(req, {
                if(port_id==-1)
                    sa inside {[0:15]}; 
                else 
                    sa==port_id; 
                da inside valid_da;
            });
            `uvm_info("PACKET_SEND", $sformatf("port_id %0d %m", port_id), UVM_LOW)
        end

        if(starting_phase!=null)
            starting_phase.drop_objection(this);
    endtask: body

endclass : packet_sequence

`endif
