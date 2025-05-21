/*
 *********************************************************************************** 
 * Class     : act_env
 *
 * Details   : Env component which create, build and connect monitor and SB
 *
 **********************************************************************************
 */  
class act_env extends uvm_env;

  //-----------------------------------------------
  // Fields
  // ----------------------------------------------
  act_scoreboard #(act_transaction, int) comparator;
  act_monitor                            before_monitor;
  act_monitor                            after_monitor;

  //------------------------------------------------
  // UVM Automation Macros
  //------------------------------------------------
  `uvm_component_utils(act_env)

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
  endfunction

  /*
   * Method    : build_phase
   * 
   * Details   : Building and Configuring
   *
   * Parameter : phase   : UVM Phase
   *
   */
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    comparator = act_scoreboard#(act_transaction, int)::type_id::create("comparator", this);
    before_monitor = act_monitor::type_id::create("before_monitor", this);
    after_monitor  = act_monitor::type_id::create("after_monitor", this);
  endfunction

  /*
   * Method    : connect_phase
   * 
   * Details   : Connecting the components
   *
   * Parameter : phase   : UVM Phase
   *
   */
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    before_monitor.ap.connect(comparator.before_axp);
    after_monitor.ap.connect(comparator.after_axp);
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
    phase.raise_objection(this, "Raised Objection");
    #50ns;
    phase.drop_objection(this, "Dropped Objection");
  endtask

endclass
