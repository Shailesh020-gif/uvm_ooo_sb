/*
 *********************************************************************************** 
 * Class     : act_tb
 *
 * Details   : Transaction class to verify Out-Of-Order SB works fine
 *
 **********************************************************************************
 */  

class act_transaction extends uvm_sequence_item;
  
  //-----------------------------------------------
  // Fields
  // ----------------------------------------------
  rand bit[2:0] data;
  rand bit[2:0] index;

  //------------------------------------------------
  // UVM Automation Macros
  //------------------------------------------------
  `uvm_object_utils(act_transaction)

  /*
   * Method    : new
   * 
   * Details   : The class constructor
   *
   * Parameter : name   : The name assign to object of this class type
   *             parent : The class parent 
   *
   */
  function new(string name = "act_transaction");
    super.new(name);
  endfunction

  /*
   * Method    : index_id
   * 
   * Details   : return Index
   *
   */
  function int index_id();
    return index;
  endfunction

  /*
   * Method    : compare
   * 
   * Details   : compare transaction
   *
   */
  function bit compare(act_transaction rhs);
    return this.data == rhs.data;
  endfunction

  /*
   * Method    : do_print
   * 
   * Details   : Simple uses the printer function to print pkt
   *
   */
  virtual function void do_print(uvm_printer printer);
    super.do_print(printer);
    printer.print_field_int("data", data, $bits(data), UVM_HEX);
    printer.print_field_int("idx", index, $bits(index), UVM_HEX);
  endfunction


endclass
