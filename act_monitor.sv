/*
 *********************************************************************************** 
 * Class     : act_monitor
 *
 * Details   : Here Monitor are sending act/exp PKTs with random data
 *             to test Out-Of-Order SB
 *
 **********************************************************************************
 */ 
class act_monitor extends uvm_component;

  //-----------------------------------------------
  // TLM Ports
  //-----------------------------------------------
  uvm_analysis_port #(act_transaction) ap;

  //------------------------------------------------
  // UVM Automation Macros
  //------------------------------------------------
  `uvm_component_utils(act_monitor)

  /*
   * Method    : new
   * 
   * Details   : The class constructor
   *
   * Parameter : name   : The name assign to object of this class type
   *             parent : The class parent 
   *
   */
  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  /*
   * Method    : run_phase
   * 
   * Details   : Main thread : send act/exp fifo
   *
   * Parameter : Phase : The UVM Phase
   *
   */
  task run_phase(uvm_phase phase);
    act_transaction txn;
    forever begin
      txn = act_transaction::type_id::create("txn");
      void'(txn.randomize());
      ap.write(txn);
      #10ns;
    end
  endtask

endclass
