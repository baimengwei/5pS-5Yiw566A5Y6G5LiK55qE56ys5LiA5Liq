`ifndef _HOST_SEQUENCE_SV_
`define _HOST_SEQUENCE_SV_
class host_sequence extends uvm_sequence#(host_data);
    // data or class properties
    `uvm_object_utils(host_sequence)

    // initialization
    function new(string name="host_sequence");
        super.new(name);
    endfunction : new

    virtual task body();
        if(starting_phase!=null) begin
            starting_phase.raise_objection(this);
        end
        `uvm_info("HOST_START", "starting...", UVM_MEDIUM)
        `uvm_do_with(req, {address=='h100; kind==host_data::READ;})
        `uvm_info("HOST_SEND", req.sprint, UVM_MEDIUM)
        `uvm_do_with(req, {address=='h100; data=='1; kind==host_data::WRITE;})
        `uvm_info("HOST_SEND", req.sprint, UVM_MEDIUM)
        `uvm_do_with(req, {address=='h100; kind==host_data::READ;})
        `uvm_info("HOST_SEND", req.sprint, UVM_MEDIUM)

        if(starting_phase!=null) begin
            starting_phase.drop_objection(this);
        end
    endtask: body

endclass : host_sequence

`endif
