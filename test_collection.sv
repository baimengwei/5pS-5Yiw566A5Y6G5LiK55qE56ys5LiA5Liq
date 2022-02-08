`ifndef _TEST_COLLECTION_SV_
`define _TEST_COLLECTION_SV_
`include "router_env.sv"
class test_collection extends uvm_test;
    // data or class properties
    `uvm_component_utils(test_collection);

    router_env env;

    // initialization
    function new(string name="test_collection", uvm_component parent);
        super.new(name, parent);
        `uvm_info("TRACE", "%m", "UVM_HIGH");
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = router_env::type_id::create("env", this);
        uvm_config_db#(virtual router_io)::set(this, "env.i_agt[*]", "router_io", router_test_top.sigs);
        uvm_config_db#(virtual router_io)::set(this, "env.o_agt[*]", "router_io", router_test_top.sigs);
        uvm_config_db#(virtual router_io)::set(this, "env.r_agt", "router_io", router_test_top.sigs);
        uvm_config_db#(virtual host_io)::set(this, "env.h_agt", "host_io", router_test_top.host);
    endfunction: build_phase

    virtual function void start_of_simulation_phase(uvm_phase phase);
        /* uvm_top.print_topology(); */
        /* factory.print(); */
        /* uvm_top.print(); */
    endfunction: start_of_simulation_phase
endclass : test_collection

class test_da_pl extends test_collection;
    // data or class properties
    `uvm_component_utils(test_da_pl);

    // initialization
    function new(string name="test_da_pl", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_inst_override_by_type("env.i_agt[*].seqr.*", packet::get_type(), packet_da_pl::get_type());
        /* set_type_override_by_type(packet::get_type(), packet_da_pl::get_type()); */
    endfunction: build_phase
endclass : test_da_pl

class test_seq_ctl extends test_collection;
    // data or class properties
    `uvm_component_utils(test_seq_ctl);
    // initialization
    function new(string name="test_seq_ctl", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        uvm_config_db#(int)::set(this, "env.i_agt[*].seqr", "item_count", 20);
        uvm_config_db#(bit[15:0])::set(this, "env.i_agt[*].seqr", "da_enable", 16'b0000_0000_0001_1111);
    endfunction: build_phase
endclass : test_seq_ctl

class test_seq_lib extends test_collection;
    // data or class properties
    `uvm_component_utils(test_seq_lib)
    uvm_sequence_library_cfg seq_cfg;

    // initialization
    function new(string name="test_seq_lib", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // set 2 times seq execute.
        seq_cfg = new("seq_cfg", UVM_SEQ_LIB_RAND, 2, 2);
        uvm_config_db#(uvm_sequence_library_cfg)::set(
            this, "env.i_agt[*].seqr.main_phase", "default_sequence.config", seq_cfg);

        packet_seq_lib::add_typewide_sequence(packet_sequence::get_type());

        set_type_override_by_type(inout_agent::get_type(), inout_lib_agent::get_type());
    endfunction: build_phase

endclass : test_seq_lib

class test_ral_seq extends test_collection;
    // data or class properties
    `uvm_component_utils(test_ral_seq)

    // initialization
    function new(string name="test_ral_seq", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(host_agent::get_type(), ral_host_agent::get_type());
    endfunction: build_phase

endclass : test_ral_seq
`endif
