// Below code is to test Back2Back axi_master_(VIP) & axi_slave_(VIP)
`uvm_analysis_imp_decl(_master)
`uvm_analysis_imp_decl(_slave)

class axi_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(axi_scoreboard)
    
    uvm_analysis_imp_master#(axi_transaction#(WIDTH, SIZE), axi_scoreboard) m_ap_imp;
    uvm_analysis_imp_slave#(axi_transaction#(WIDTH, SIZE), axi_scoreboard) s_ap_imp;
    
    axi_transaction#(WIDTH, SIZE) m_wtrans, m_rtrans, s_wtrans, s_rtrans;
    bit [1:0] w_rcvd, r_rcvd;
    int passCnt, failCnt;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void write_master(axi_transaction#(WIDTH, SIZE) trans);
        if(trans.id[8]) begin
            m_rtrans = trans;
            r_rcvd[0] = 1;
        end
            
        else begin
            m_wtrans = trans;
            w_rcvd[0] = 1;
        end
        check();
    endfunction

    function void write_slave(axi_transaction#(WIDTH, SIZE) trans);
        if(trans.id[8]) begin
            s_rtrans = trans;
            r_rcvd[1] = 1;
        end
            
        else begin
            s_wtrans = trans;
            w_rcvd[1] = 1;
        end
        check();
    endfunction

    function void check();
        if(w_rcvd == 2'b11) begin
            if(m_wtrans.compare(s_wtrans)) begin
                `uvm_info("SCB", $sformatf("ID %0d: PASSED", m_wtrans.id), UVM_NONE)
                passCnt++;
            end
            else begin
                `uvm_error("SCB", $sformatf("ID %0d: FAILED", m_wtrans.id))
                failCnt++;
            end
            w_rcvd = 2'b00;
        end

        if(r_rcvd == 2'b11) begin
            if(m_rtrans.compare(s_rtrans)) begin
                `uvm_info("SCB", $sformatf("ID %0d: PASSED", m_rtrans.id), UVM_NONE)
                passCnt++;
            end
            else begin
                `uvm_error("SCB", $sformatf("ID %0d: FAILED", m_rtrans.id))
                failCnt++;
            end
            r_rcvd = 2'b00;
        end
    endfunction

	function void axi_scoreboard::build_phase(uvm_phase phase);
		m_ap_imp = new("m_ap_imp", this);
		s_ap_imp = new("s_ap_imp", this);
	endfunction: build_phase

endclass //axi_scoreboard