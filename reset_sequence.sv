`ifndef _RESET_SEQUENCE_SV_
`define _RESET_SEQUENCE_SV_
class reset_sequence extends uvm_sequence#(reset_transaction);
    // data or class properties
    `uvm_object_utils(reset_sequence);

    // initialization
    function new(string name="reset_sequence");
        super.new(name);
    endfunction : new

    virtual task body();
        if(starting_phase!=null)
            starting_phase.raise_objection(this);
      
        `uvm_do_with(req, {kind==ASSERT; cycle_cnt==2;});
        `uvm_info("RESET_SEND", {"\n", req.sprint}, UVM_HIGH)
        `uvm_do_with(req, {kind==DEASSERT; cycle_cnt==15;});
        `uvm_info("RESET_SEND", {"\n", $sformatf("%s", req.sprint())}, UVM_HIGH)

        if(starting_phase!=null)
            starting_phase.drop_objection(this);
    endtask: body

endclass : reset_sequence
`endif
