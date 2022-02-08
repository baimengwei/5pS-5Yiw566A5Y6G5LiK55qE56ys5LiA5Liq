`ifndef _SCOREBOARD_SV_
`define _SCOREBOARD_SV_

`uvm_analysis_imp_decl(_before)
`uvm_analysis_imp_decl(_after)

class scoreboard extends uvm_scoreboard;
    // data or class properties
    `uvm_component_utils(scoreboard)
    uvm_analysis_imp_before#(packet, scoreboard) export_before;
    uvm_analysis_imp_after#(packet, scoreboard) export_after;
    uvm_in_order_class_comparator#(packet) comparator[16];

    // initialization
    function new(string name="scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction : new

    virtual function void build_phase(uvm_phase phase);
        export_before = new("export_before", this);
        export_after = new("export_after", this);
        for (int i = 0; i < 16; i++) begin
            comparator[i] = uvm_in_order_class_comparator#(packet)::type_id::create(
                $sformatf("comparator[%0d]", i), this);
        end
    endfunction: build_phase

    virtual function void write_before(packet tr);
        `uvm_info($sformatf("SB_INPUT_GET%0d", tr.da), "scoreboard get a packet", UVM_LOW)
        comparator[tr.da].before_export.write(tr);
    endfunction: write_before

    virtual function void write_after(packet tr);
        `uvm_info($sformatf("SB_OUTPUT_GET%0d", tr.da), "scoreboard get a packet", UVM_LOW)
        comparator[tr.da].after_export.write(tr);
    endfunction: write_after

    virtual function void report_phase(uvm_phase phase);
        for (int i = 0; i < 16; i++) begin
            `uvm_info($sformatf("SB_REPORT[%0d]",i), $sformatf("Match %0d, MisMatch %0d",
                comparator[i].m_matches, comparator[i].m_mismatches[i]), UVM_LOW)
        end
    endfunction: report_phase
endclass : scoreboard
`endif
