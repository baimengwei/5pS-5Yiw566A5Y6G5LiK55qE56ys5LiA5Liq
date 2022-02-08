`ifndef _PACKET_SV_
`define _PACKET_SV_
class packet extends uvm_sequence_item;
    // data or class properties
    /* `uvm_object_utils(packet) */
    rand bit [3:0] sa, da;
    rand bit [7:0] payload[$];

    `uvm_object_utils_begin(packet)
        `uvm_field_int(sa, UVM_ALL_ON)
        `uvm_field_int(da, UVM_ALL_ON)
        `uvm_field_queue_int(payload, UVM_ALL_ON)
    `uvm_object_utils_end


    // initialization
    function new(string name="packet");
        super.new(name);
    endfunction : new

    constraint pl_size{
        payload.size inside {[1:3]};
    }

endclass : packet
`endif
