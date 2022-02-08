`ifndef _RAL_HOST_AGENT_SV_
`define _RAL_HOST_AGENT_SV_

`include "host_agent.sv"
`include "ral_host_sequence.sv"
`include "reg_adapter.sv"

class ral_host_agent extends host_agent;
    // data or class properties

    ral_block_host_regmodel regmodel;
    string hdl_path;
    reg_adapter adapter;
    ral_host_sequence seq;

    `uvm_component_utils(ral_host_agent)

    // initialization
    function new(string name="ral_host_agent", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // switch to ral model 
        uvm_config_db#(uvm_object_wrapper)::set(this, "seqr.configure_phase", "default_sequence", null);
        // start.
        regmodel = ral_block_host_regmodel::type_id::create("ral_block_host_regmodel", this);
        adapter = reg_adapter::type_id::create("reg_adapter", this);

        
        uvm_config_db#(string)::get(this, "", "hdl_path", hdl_path);
        regmodel.build();
        regmodel.lock_model();
        regmodel.set_hdl_path_root(hdl_path); 
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        regmodel.default_map.set_sequencer(seqr, adapter);
    endfunction: connect_phase

    virtual task configure_phase(uvm_phase phase);
        super.configure_phase(phase);
        `uvm_info("RAL_HOST_AGENT", $sformatf("%m"), UVM_MEDIUM)

        seq = ral_host_sequence::type_id::create("host_seq", this);
        seq.regmodel = this.regmodel;
        phase.raise_objection(this);
        seq.start(null);
        phase.drop_objection(this);
    endtask: configure_phase

endclass : ral_host_agent

`endif

