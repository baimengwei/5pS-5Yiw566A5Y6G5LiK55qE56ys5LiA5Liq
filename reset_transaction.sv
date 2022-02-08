`ifndef _RESET_TRANSACTION_SV_
`define _RESET_TRANSACTION_SV_
class reset_transaction extends uvm_sequence_item;
    // data or class properties
    typedef enum {ASSERT, DEASSERT} kind_e;

    rand int cycle_cnt=1;
    rand kind_e kind; 

    `uvm_object_utils_begin(reset_transaction)
        `uvm_field_int(cycle_cnt, UVM_ALL_ON)
        `uvm_field_enum(kind_e, kind, UVM_ALL_ON)
    `uvm_object_utils_end

    // initialization
    function new(string name="reset_transaction");
        super.new(name);
        `uvm_info("TRACE", $sformatf("%m"), UVM_LOW)
    endfunction : new


endclass : reset_transaction
`endif
