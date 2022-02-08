`ifndef _REG_ADAPTER_SV_
`define _REG_ADAPTER_SV_
class reg_adapter extends uvm_reg_adapter;
    // data or class properties
    `uvm_object_utils(reg_adapter)

    // initialization
    function new(string name="reg_adapter");
        super.new(name);
    endfunction : new

    virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        host_data tr;
        tr = host_data::type_id::create("tr");
        tr.kind = (rw.kind == UVM_READ) ? host_data::READ: host_data::WRITE;
        tr.address = rw.addr;
        tr.data = rw.data;
        return tr;
    endfunction: reg2bus

    virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        host_data tr;
        if (!$cast(tr, bus_item)) begin
            `uvm_fatal("DATA_ERROR", "bus_item convert to tr error")
        end
        rw.kind = (tr.kind == host_data::READ)? UVM_READ: UVM_WRITE;
        rw.addr = tr.address;
        rw.data = tr.data;
        rw.status = UVM_IS_OK;
    endfunction: bus2reg
endclass : reg_adapter
`endif
