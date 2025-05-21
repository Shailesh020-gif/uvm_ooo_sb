/*
 *********************************************************************************** 
 * Class     : act_test
 *
 * Details   : Test component which create UVM env
 *
 **********************************************************************************
 */  
class act_test extends uvm_test;
  
  //-----------------------------------------------
  // Fields
  // ----------------------------------------------
  act_env env;

  //------------------------------------------------
  // UVM Automation Macros
  //------------------------------------------------
  `uvm_component_utils(act_test)

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
    env = act_env::type_id::create("env", this);
  endfunction

endclass
