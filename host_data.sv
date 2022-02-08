`ifndef _HOST_DATA_SV_
`define _HOST_DATA_SV_
class host_data extends uvm_sequence_item;
    // data or class properties
    typedef enum{READ, WRITE} kind_e;
    rand kind_e kind;
    rand bit[15:0] address;
    rand bit[15:0] data;

    `uvm_object_utils_begin(host_data)
        `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
        `uvm_field_int(address, UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
    `uvm_object_utils_end

    // initialization
    function new(string name="host_data");
        super.new(name);
    endfunction : new

endclass : host_data

`endif
