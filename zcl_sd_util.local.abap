CLASS Core DEFINITION.
PUBLIC SECTION.

CLASS-METHODS: GetCharacteristicsList IMPORTING table TYPE REF TO data
                                       map_matnr TYPE fieldname OPTIONAL
                                       map_charg TYPE Fieldname OPTIONAL
                                       programName TYPE zbct002-programname
                                      RETURNING VALUE(Result) TYPE type=>tt_ausp.

PRIVATE SECTION.
  CLASS-METHODS GetList IMPORTING it_data TYPE type=>tt_data
    RETURNING VALUE(r_result) TYPE type=>tt_ausp.
CLASS-METHODS: GetMatnrAndCharg IMPORTING table TYPE REF TO data
                                map_matnr TYPE fieldname OPTIONAL
                                map_charg TYPE Fieldname OPTIONAL
                                RETURNING VALUE(Result) TYPE type=>tt_data.
CLASS-DATA: _programName TYPE zbct002-programname.
ENDCLASS.


CLASS Core IMPLEMENTATION.
  METHOD getcharacteristicslist.
    _programName =  COND #( WHEN programname is not initial then programname ELSE sy-cprog )..
    result = GetList( Core=>GetMatnrAndCharg( table )  ).
  ENDMETHOD.

  METHOD GetList.

   SELECT  DISTINCT char~matnr,
                   char~charg,
                   char~atnam,
                   char~atflv,
                   char~atwrt,
                   char~atfor,
                   char~anzst,
                   char~anzdz
                          FROM zmm_cds_char AS char
                          FOR ALL ENTRIES IN @it_data
                          WHERE char~matnr = @it_data-matnr AND
                                char~charg = @it_data-charg AND
                                char~atnam in ( SELECT atnam FROM zbct002 INNER JOIN cabn ON zbct002~atinn = cabn~atinn  WHERE zbct002~programname = @_programname )
                          INTO CORRESPONDING FIELDS OF TABLE @r_result .

  ENDMETHOD.



  METHOD GetMatnrAndCharg.

   FIELD-SYMBOLS: <_table> TYPE STANDARD TABLE.
   ASSIGN table->* TO <_table>.
   DATA(_Component_Matnr) = COND #( WHEN map_matnr is not initial THEN map_matnr else 'MATNR' ).
   DATA(_Component_Charg) = COND #( WHEN map_Charg is not initial THEN map_matnr else 'CHARG' ).
   LOOP AT <_table> ASSIGNING FIELD-SYMBOL(<line>).
   ASSIGN COMPONENT _Component_Matnr  OF STRUCTURE <line> TO FIELD-SYMBOL(<_matnr>).
   ASSIGN COMPONENT _Component_Charg  OF STRUCTURE <line> TO FIELD-SYMBOL(<_charg>).
   APPEND VALUE #( matnr = <_matnr> charg = <_charg>  ) TO result.
   ENDLOOP.
   DELETE result WHERE charg is INITIAL.
  ENDMETHOD.

ENDCLASS.

CLASS Business DEFINITION.
PUBLIC SECTION.
CLASS-METHODS: TransposeData IMPORTING map_matnr TYPE fieldname OPTIONAL
                                       map_charg TYPE Fieldname OPTIONAL
                             CHANGING table TYPE REF TO data
                                      List TYPE type=>tt_ausp,
               createitabdynamic IMPORTING ProgramName TYPE zbct002-programname OPTIONAL
                                           table TYPE REF TO data
                                 EXPORTING FieldCatalog TYPE lvc_t_fcat
                                 CHANGING Result TYPE REF TO data,
               getfieldcatalog IMPORTING  table TYPE REF TO data RETURNING VALUE(Result) TYPE lvc_t_fcat,
               setadditionfield
                     CHANGING
                       fieldcatalog TYPE lvc_t_fcat.
PRIVATE SECTION.
 TYPES: tt_Fields TYPE TABLE OF zbct007 WITH EMPTY KEY.
  CLASS-METHODS CreateFieldCatalog
    IMPORTING
      i_table TYPE REF TO data RETURNING VALUE(Result) TYPE lvc_t_fcat.
  CLASS-METHODS addcharacteristicsfcat
    CHANGING
      fieldcatalog TYPE lvc_t_fcat
      List TYPE type=>tty_cabn.
  CLASS-METHODS getcharlist IMPORTING ProgramName TYPE zbct002-programname OPTIONAL
    RETURNING value(result) TYPE type=>tty_cabn.
  CLASS-METHODS createitab
    CHANGING
      fieldcatalog TYPE lvc_t_fcat
      table        TYPE data.
  CLASS-METHODS SetTextFieldFieldcatalog
    IMPORTING
      i_salv TYPE REF TO cl_salv_table
    CHANGING
      c_result TYPE lvc_t_fcat.
  CLASS-METHODS getfields RETURNING value(result) TYPE tt_Fields.
  CLASS-METHODS SetFields
    IMPORTING  fieldnames TYPE business=>tt_fields
    CHANGING   fieldcatalog TYPE lvc_t_fcat.
ENDCLASS.


CLASS Business IMPLEMENTATION.
METHOD TransposeData.
  DATA: lr_any TYPE REF TO data.
  FIELD-SYMBOLS: <any> TYPE ANY.
  Field-SYMBOLS: <otable> TYPE STANDARD TABLE.
  ASSIGN table->* to <otable>.


  LOOP AT <otable> ASSIGNING FIELD-SYMBOL(<line>).
     DATA(_Component_Matnr) = COND #( WHEN map_matnr is not initial THEN map_matnr else 'MATNR' ).
     DATA(_Component_Charg) = COND #( WHEN map_Charg is not initial THEN map_matnr else 'CHARG' ).
      ASSIGN COMPONENT _Component_Matnr OF STRUCTURE <line> TO FIELD-SYMBOL(<matnr>).
      ASSIGN COMPONENT _Component_Charg OF STRUCTURE <line> TO FIELD-SYMBOL(<charg>).
      CHECK <matnr> is ASSIGNED AND <charg> is ASSIGNED.
      LOOP AT List ASSIGNING FIELD-SYMBOL(<_List>).
        ASSIGN COMPONENT <_List>-atnam OF STRUCTURE <line> TO FIELD-SYMBOL(<value>).
        CHECK <value> is ASSIGNED.
        IF <_List>-atfor = 'NUM'.
          CREATE DATA lr_any TYPE p LENGTH <_List>-anzst DECIMALS <_List>-anzdz.
          ASSIGN lr_any->* TO <any>.
          <any> = VALUE #( List[ matnr = <matnr> charg = <charg> atnam = <_List>-atnam  ]-atflv DEFAULT '0'  ).
          <value> = <any>.
        ELSE.
        <value> =  VALUE #( List[ matnr = <matnr> charg = <charg> atnam = <_List>-atnam  ]-atwrt DEFAULT space ).
        ENDIF.
      ENDLOOP.
  ENDLOOP.

ENDMETHOD.


  METHOD createitabdynamic.
          Data(_FieldCatalog) = CreateFieldCatalog( table ).
          DATA(_List) = GetCharList( programName = programname  ).
          addcharacteristicsfcat( CHANGING fieldcatalog = _fieldcatalog
                                           List = _List ).
          CreateItab( CHANGING FieldCatalog =  _fieldcatalog
                               Table = result ).
          "Result => yeni oluşan tablo yapısını object olarak geri döndürmek için
          fieldcatalog = _fieldcatalog. "Yeni oluşan Fcat i geri döndürmek için.
  ENDMETHOD.

  METHOD CreateFieldCatalog.

   FIELD-SYMBOLS: <_table> TYPE STANDARD TABLE.
   ASSIGN i_table->* TO <_table>.

   cl_salv_table=>factory( IMPORTING r_salv_table = DATA(o_salv)
                           CHANGING  t_table      = <_table> ).
*    DD04T
   result  = cl_salv_controller_metadata=>get_lvc_fieldcatalog( r_columns      = o_salv->get_columns( )
                                                                r_aggregations = o_salv->get_aggregations( ) ).
   SetTextFieldFieldcatalog( EXPORTING i_salv = o_salv
                             CHANGING  c_result = result ).
  ENDMETHOD.

  METHOD SetTextFieldFieldcatalog.

   DATA(salv_columns) = i_salv->get_columns( )->get(  ).
   LOOP AT salv_columns INTO DATA(_columns).
   DATA(FcatLine) = c_result[ fieldname = _columns-columnname ].
   SELECT SINGLE * INTO @DATA(_domainText) FROM dd04t WHERE rollname = @_columns-columnname AND ddlanguage = @sy-langu.
   IF sy-subrc EQ 0 AND _domaintext IS NOT INITIAL.
   fcatline = VALUE #( BASE fcatline scrtext_l = _domaintext-scrtext_l scrtext_m = _domaintext-scrtext_m scrtext_s = _domaintext-scrtext_s
                                     reptext = _domaintext-reptext  rollname = _domaintext-rollname
                     ).
   ELSE.
   """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   DATA(_Rolname) = |%{ _columns-columnname }%|.
   SELECT SINGLE rollname INTO @DATA(_domain) FROM dd03l WHERE domname = @_columns-columnname AND rollname LIKE @_rolname.
    IF _domain IS NOT INITIAL.
    SELECT SINGLE * INTO @_domainText FROM dd04t WHERE rollname = @_domain AND ddlanguage = @sy-langu.
    IF sy-subrc EQ 0 AND _domaintext IS NOT INITIAL.
   fcatline = VALUE #( BASE fcatline scrtext_l = _domaintext-scrtext_l scrtext_m = _domaintext-scrtext_m scrtext_s = _domaintext-scrtext_s
                                     reptext = _domaintext-reptext  rollname = _domaintext-rollname
                     ).
   ENDIF.
   ELSE.
 """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
   fcatline = VALUE #( BASE fcatline scrtext_l = _columns-columnname scrtext_m = _columns-columnname scrtext_s = _columns-columnname ).
   ENDIF.
   ENDIF.
   fcatline-scrtext_l = _columns-r_column->get_short_text(  ).
   fcatline-outputlen = _columns-r_column->get_output_length(  ).
   fcatline-dd_outlen = _columns-r_column->get_ddic_outputlen(  ).
   "Modify line
   c_result[ fieldname = _columns-columnname ] = fcatline.
   CLEAR: _domaintext,_rolname,_domain.
   ENDLOOP.
  "Referans alanlardan biri boş ise diğerini de temizle.
  LOOP AT c_result ASSIGNING FIELD-SYMBOL(<e>).
  IF <e>-ref_field IS INITIAL or <e>-ref_table is INITIAL.
   CLEAR:  <e>-ref_field, <e>-ref_table.
  ENDIF.
  ENDLOOP.

  ENDMETHOD.






  METHOD addcharacteristicsfcat.
    DATA(colposcount) = lines( fieldcatalog ).
      LOOP AT List ASSIGNING FIELD-SYMBOL(<line>).
      APPEND VALUE #( fieldname = <line>-atnam datatype = <line>-atfor inttype = '' intlen = ( <line>-anzst + <line>-anzdz )
                      reptext = <line>-atbez scrtext_s = <line>-atbez scrtext_m = <line>-atbez scrtext_l = <line>-atbez
                      decimals_o = <line>-anzdz decimals = <line>-anzdz
                      col_pos = colposcount + sy-tabix   domname = ''
                    ) TO fieldcatalog.
      ENDLOOP.
  ENDMETHOD.


  METHOD getcharlist.
   DATA(_ProgramName) = COND #( WHEN ProgramName is NOT initial THEN  programname ELSE sy-cprog ).
   SELECT DISTINCT cabn~atnam,
                   cabn~atfor,
                   cabn~anzst,
                   cabn~anzdz,
                   cabnt~atbez    FROM zbct002
                          INNER JOIN cabn ON zbct002~atinn = cabn~atinn
                          INNER JOIN cabnt ON cabnt~atinn = cabn~atinn AND cabnt~spras = 'T'
                          WHERE programname = @_ProgramName
                          INTO  TABLE @result .
  SORT result BY atnam.
  ENDMETHOD.


  METHOD createitab.
   cl_alv_table_create=>create_dynamic_table( EXPORTING it_fieldcatalog = fieldcatalog
                                                IMPORTING ep_table        = table ).
  ENDMETHOD.


  METHOD getfieldcatalog.
         result = CreateFieldCatalog( table ).
  ENDMETHOD.


  METHOD setadditionfield.

   DATA(_Fieldnames) = GetFields(  ).


      SetFields( EXPORTING fieldnames = _fieldnames
                 CHANGING  fieldcatalog = fieldcatalog ).
  ENDMETHOD.

  METHOD SetFields.

      DATA(colposcount) = lines( fieldcatalog ).
      LOOP AT fieldnames ASSIGNING FIELD-SYMBOL(<line>).
      DATA(_line) = VALUE #( fieldcatalog[ fieldname = <line>-fieldname ] OPTIONAL ).
      DATA(_IsHas) = COND #(  WHEN _line  IS NOT INITIAL THEN abap_true ELSE abap_false ).
      IF _ishas = abap_true.
       _line = VALUE #( BASE _line
                       col_pos = COND  #(  WHEN <line>-col_pos IS NOT INITIAL THEN <line>-col_pos ELSE _line-col_pos )
                       coltext = COND  #(  WHEN <line>-coltext IS NOT INITIAL THEN <line>-coltext ELSE _line-coltext )
                       reptext = <line>-coltext scrtext_s = <line>-coltext scrtext_m = <line>-coltext scrtext_l = <line>-coltext
                       key =     COND  #(  WHEN <line>-iskey IS NOT INITIAL THEN   <line>-iskey ELSE _line-key )
                       no_zero =  <line>-no_zero
                       lzero =    <line>-lzero
                       edit =    <line>-edit
                       Lowercase = <line>-lowercase
                       no_out = <line>-no_out
                       emphasize = <line>-emphasize
                       datatype = COND #( WHEN  <line>-datatype IS NOT INITIAL THEN <line>-datatype ELSE _line-datatype )
                       inttype = COND #( WHEN <line>-inttype IS NOT INITIAL THEN <line>-inttype ELSE _line-inttype )
                       outputlen = COND #( WHEN <line>-intlen  IS NOT INITIAL THEN  <line>-intlen ELSE _line-intlen ) "intlen ile aynı alındı
                       intlen =  COND #( WHEN <line>-intlen  IS NOT INITIAL THEN  <line>-intlen ELSE _line-intlen )
                       Ref_field = COND #( WHEN  <line>-ref_field IS NOT INITIAL THEN  <line>-ref_field ELSE _line-ref_field )
                       ref_table = COND #( WHEN  <line>-ref_table IS NOT INITIAL THEN  <line>-ref_Table ELSE _line-ref_table )
                       rollname = COND #( WHEN  <line>-rollname IS NOT INITIAL THEN <line>-rollname ELSE _line-rollname )
                      ).
       fieldcatalog[ fieldname = <line>-fieldname ] = _line.
       CLEAR: _line.
      ELSE.
       APPEND VALUE #(  col_pos = colposcount + sy-tabix
                        fieldname = <line>-fieldname
                        coltext = <line>-coltext
                        reptext = <line>-coltext scrtext_s = <line>-coltext scrtext_m = <line>-coltext scrtext_l = <line>-coltext
                        key = <line>-iskey
                        no_zero =  <line>-no_zero
                        lzero =    <line>-lzero
                        edit =    <line>-edit
                        Lowercase = <line>-lowercase
                        no_out = <line>-no_out
                        emphasize = <line>-emphasize
                        datatype = <line>-datatype
                        inttype = <line>-inttype
                        intlen = <line>-intlen
                        Ref_field = <line>-ref_field
                        ref_table =   <line>-ref_table
                        rollname =  <line>-rollname
*                       decimals_o = <line>-anzdz decimals = <line>-anzdz
*                        domname = ''
                    ) TO fieldcatalog.
      ENDIF.
      ENDLOOP.

  ENDMETHOD.




  METHOD getfields.
       SELECT   PROGRAMNAME, FCATNAME,
                FIELDNAME,
                COL_POS,
                COLTEXT,
                ISKEY,
                NO_ZERO,
                LZERO,
                EDIT,
                LOWERCASE,
                NO_OUT,
                ISNEW,
                EMPHASIZE,
                DATATYPE,
                INTTYPE,
                INTLEN,
                REF_FIELD,
                REF_TABLE,
                ROLLNAME INTO CORRESPONDING FIELDS OF TABLE @result
                         FROM zbct007 WHERE programname = @sy-cprog  .
  ENDMETHOD.

ENDCLASS.
