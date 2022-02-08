`ifndef _PACKET_DA_PL_SV_
`define _PACKET_DA_PL_SV_
class packet_da_pl extends packet;
    // data or class properties
    `uvm_object_utils(packet_da_pl);

    // initialization
    function new(string name="packet_da_pl");
        super.new("packet_da_pl");
    endfunction : new

    constraint pl_size{
        payload.size == 2;
    }

    constraint da_valid{
        da == 'h3;
    }

endclass : packet_da_pl
`endif
