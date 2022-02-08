package packet_seq_lib_pkg;
    import uvm_pkg::*;
    class packet extends uvm_sequence_item;
        // independent with the project
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

    class packet_seq_lib extends uvm_sequence_library#(packet);
        // data or class properties
        `uvm_object_utils(packet_seq_lib)
        `uvm_sequence_library_utils(packet_seq_lib)

        // initialization
        function new(string name="packet_seq_lib");
            super.new(name);
            init_sequence_library();
        endfunction : new

    endclass : packet_seq_lib
endpackage
