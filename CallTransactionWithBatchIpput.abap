  METHOD BatchCharacteristic.
    DATA: it_batchdata TYPE STANDARD TABLE OF bdcdata.
    DATA: it_msg TYPE STANDARD TABLE OF bdcmsgcoll.
    FREE: it_batchdata, it_msg.
    ASSIGN COMPONENT 'CHARG' OF STRUCTURE i_line TO FIELD-SYMBOL(<_charg>).
    ASSIGN COMPONENT 'MATNR' OF STRUCTURE i_line TO FIELD-SYMBOL(<_matnr>).
     CHECK <_charg> is not INITIAL.

* Batch-Input
    it_batchdata = VALUE #( ( program = 'SAPLCHRG' dynpro = '1000' dynbegin = 'X' fnam = '' fval = '' )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'BDC_SUBSCR' fval = 'SAPLCHRG                                1111SUBSCR_BATCH_MASTER' )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'BDC_SUBSCR' fval = 'SAPLCHRG                                1501SUBSCR_HEADER' )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'BDC_CURSOR' fval = 'DFBATCH-MATNR' )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'DFBATCH-MATNR' fval = <_matnr> )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'DFBATCH-CHARG' fval = <_charg> )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'BDC_SUBSCR' fval = 'SAPLCHRG                                2000SUBSCR_TABSTRIP' )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'BDC_SUBSCR' fval = 'SAPLCHRG                                2100SUBSCR_BODY' )
                            ( program = 'SAPLCHRG' dynpro = '1000' dynbegin = 'X' fnam = '' fval = '' )
                            ( program = '' dynpro = '' dynbegin = '' fnam = 'BDC_OKCODE' fval = '=CLAS' )
                            ).

    CALL TRANSACTION 'MSC3N' WITHOUT AUTHORITY-CHECK USING it_batchdata MODE 'E' MESSAGES INTO it_msg.


  ENDMETHOD.
