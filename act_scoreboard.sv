/*
 *********************************************************************************** 
 * Class     : act_scoreboard
 *
 * Details   : This is a generic SB componenet which can work
 *             to compare out of order packets
 *
 * Parameter : T   : Transaction Type
 *             IDX : Transaction Index
 *
 **********************************************************************************
 */             
class act_scoreboard#(type T = int, type IDX = int) extends uvm_component; 

  //------------------------------------------------
  // UVM Automation Macros
  //------------------------------------------------
  typedef act_scoreboard #(T, IDX) this_type; 
  `uvm_component_param_utils(this_type)

  //-----------------------------------------------
  // Fields
  // ----------------------------------------------
  typedef   T      q_of_T[$]; 
  protected int    m_matches, m_mismatches; 
  protected q_of_T received_data[IDX]; 
  protected int    rcv_count[IDX]; 

  //-----------------------------------------------
  // TLM Ports
  //-----------------------------------------------
  uvm_analysis_export #(T) before_axp, after_axp; 
  protected uvm_tlm_analysis_fifo #(T) before_fifo, after_fifo; 

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
  endfunction : new

  /*
   * Method    : build_phase
   * 
   * Details   : Building and Configuring
   *
   * Parameter : phase   : UVM Phase
   *
   */
  function void build_phase( uvm_phase phase ); 
    before_axp  = new("before_axp", this);
    after_axp   = new("after_axp", this); 
    before_fifo = new("before", this); 
    after_fifo  = new("after", this); 
  endfunction : build_phase

  /*
   * Method    : connect_phase
   * 
   * Details   : Connecting the components
   *
   * Parameter : phase   : UVM Phase
   *
   */
  function void connect_phase( uvm_phase phase ); 
    before_axp.connect(before_fifo.analysis_export); 
    after_axp.connect(after_fifo.analysis_export); 
  endfunction : connect_phase 

  /*
   * Method    : get_data
   * 
   * Details   : The method forks two concurrent instantiations
   *             of this task, Each instant monitors and input
   *             analysis fifo
   *
   * Parameter : txn_fifo  : transaction fifo
   *             is_before : to detect act/exp pkt 
   *
   */
  protected task get_data(ref uvm_tlm_analysis_fifo #(T) txn_fifo, input bit is_before); 
   
    T       txn_data, txn_existing; 
    IDX     idx; 
    q_of_T  tmpq; 
    bit     need_to_compare; 

    forever begin 
      
      // Get the transaction object, block if no transaction available 
      txn_fifo.get(txn_data); 
      idx = txn_data.index_id(); 
 
      `uvm_info(get_type_name, $sformatf("get_data :: pkt = %0s",txn_data.sprint()), UVM_LOW)
      `uvm_info(get_type_name, $sformatf("rcn_count= %0p",rcv_count), UVM_LOW)
    
      // Check to see if there is an existing object to compare 
      need_to_compare = (rcv_count.exists(idx) && ((is_before && rcv_count[idx] > 0) || (!is_before && rcv_count[idx] < 0))); 
  
      `uvm_info(get_type_name,$sformatf("need to compare=%0d",need_to_compare),UVM_LOW)

      if (need_to_compare) begin 
        // Compare objects using compare() method of transaction 
        tmpq               = received_data[idx]; 
        txn_existing       = tmpq.pop_front(); 

        if (txn_data.compare(txn_existing)) begin
          m_matches++; 
          `uvm_info(get_type_name,$sformatf("PKT MATCHED"),UVM_LOW)
        end
        else  begin
          m_mismatches++; 
          `uvm_info(get_type_name,$sformatf("PKT MIS-MATCHED"),UVM_LOW)
        end
      end 
      else begin 
        // If no compare happened, add the new entry 
        if (received_data.exists(idx)) begin 
          tmpq = received_data[idx]; 
        end
        else begin
          tmpq = {};
        end

        tmpq.push_back(txn_data); 
        received_data[idx] = tmpq;
      end 

      // Update the index count 
      if (is_before) begin
        if (rcv_count.exists(idx)) begin 
          rcv_count[idx]--; 
        end 
        else begin
          rcv_count[idx] = -1; 
        end
      end
      else  begin
        if (rcv_count.exists(idx)) begin 
          rcv_count[idx]++; 
        end 
        else begin
          rcv_count[idx] = 1; 
        end
      end

      `uvm_info(get_type_name, $sformatf("rcn_count= %0p",rcv_count), UVM_LOW)

      // If index count is balanced, remove entry from the arrays 
      if (rcv_count[idx] == 0) begin 
        received_data.delete(idx); 
        rcv_count.delete(idx); 
      end 

      `uvm_info(get_type_name, $sformatf("rcn_count= %0p",rcv_count), UVM_LOW)

    end // forever 

  endtask 

  /*
   * Method    : get_matches
   * 
   * Details   : Debug/User Method : no. of matched pkt
   *
   */
  virtual function int get_matches(); 
    return m_matches; 
  endfunction : get_matches

  /*
   * Method    : get_matches
   * 
   * Details   : Debug/User Method : no. of mis-matched pkt
   *
   */
  virtual function int get_mismatches(); 
    return m_mismatches; 
  endfunction : get_mismatches

  /*
   * Method    : get_matches
   * 
   * Details   : Debug/User Method : no. of missing IDX which is not compared
   *
   */
  virtual function int get_total_missing(); 
    int num_missing; 
  
    foreach (rcv_count[i]) begin 
      num_missing += (rcv_count[i] < 0 ? -rcv_count[i] : rcv_count[i]); 
    end 

    return num_missing; 
  endfunction : get_total_missing

  /*
   * Method    : get_missing_index_count
   * 
   * Details   : Debug/User Method : which pkt is missing as per IDX
   *
   */
  virtual function int get_missing_index_count(IDX i); 
    // If count is < 0, more "before" txns were received 
    // If count is > 0, more "after" txns were received 
    if (rcv_count.exists(i)) 
      return rcv_count[i]; 
    else 
      return 0; 
  endfunction : get_missing_index_count

  /*
   * Method    : run_phase
   * 
   * Details   : Main thread : send act/exp fifo
   *
   * Parameter : Phase : The UVM Phase
   *
   */
  task run_phase( uvm_phase phase ); 
    fork 
      get_data(before_fifo, 1); 
      get_data(after_fifo, 0); 
    join 
  endtask : run_phase 

endclass : act_scoreboard
