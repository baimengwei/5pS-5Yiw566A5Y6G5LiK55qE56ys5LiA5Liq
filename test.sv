program test ();
    import uvm_pkg::*;

    `include "test_collection.sv"
    initial begin
        $timeformat(-9, 1, "ns", 30);
        run_test();
    end
endprogram : test
