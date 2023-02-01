    cl_salv_bs_runtime_info=>set( EXPORTING display  = abap_false
                                            metadata = abap_true
                                            data     = abap_true ).
    DATA: paramtable TYPE TABLE OF rsparams.
    DATA(lastmonth) = VALUE datum( ).

    APPEND VALUE #( selname = 'S_VKORG'  kind    = 'S' sign    = 'I' option  = 'BT' low = '0003' high = '0006'  ) TO paramtable.
    APPEND VALUE #( selname = 'S_FKDAT'  kind    = 'S' sign    = 'I' option  = 'BT' low = lastmonth  high = sy-datum ) TO paramtable.
    APPEND VALUE #( selname = 'S_VKGRP'  kind    = 'S' sign    = 'I' option  = 'BT' low = '001' high = '999'  ) TO paramtable.
    SUBMIT zsd_p_invoice WITH SELECTION-TABLE paramtable AND RETURN. "#EC CI_SUBMIT.
    TRY.
        DATA: o_alv_data TYPE REF TO data.
        cl_salv_bs_runtime_info=>get_data_ref( IMPORTING r_data = o_alv_data ).
        IF o_alv_data IS BOUND.
          FIELD-SYMBOLS: <alv> TYPE ANY TABLE.
          ASSIGN o_alv_data->* TO <alv>.
          IF <alv> IS ASSIGNED.
*            DATA(lv_metadata) = cl_salv_bs_runtime_info=>get_metadata( ).
          ENDIF.
        ENDIF.
      CATCH cx_salv_bs_sc_runtime_info INTO DATA(e_txt).
    ENDTRY.
    r_data = REF #( <alv> ).
    
    cl_salv_bs_runtime_info=>clear_all( ).
