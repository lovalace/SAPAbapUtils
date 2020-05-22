class ZCL_SD_SALV_F4 definition
  public
  final
  create public .

"Erkan KARATEPE 08.04.2020
public section.

  class-methods GET_SELECTED_VALUE
    importing
      TABLENAME type STRING
      DISPLAY_COLUMNS type STRING default '*'
      SELECTED_COL type STRING
      !WHERE type STRING optional
      MAXCOUNT type I optional
      TOP type I default 3
      BOTTOM type I default 25
      LEFT type I default 25
      RIGHT type I default 80
    returning
      value(RESULT) type STRING .
  class-methods GET_TABLE_VALUE
    importing TABLE type ref to DATA
              SELECTED_COL type STRING
    returning value(RESULT) type STRING .
PROTECTED SECTION.
private section.

  class-data COMPONENTS type ABAP_COMPONENT_TAB .
  class-methods RECURSIVE importing TAB type ABAP_COMPONENT_TAB .
ENDCLASS.



CLASS ZCL_SD_SALV_F4 IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_SALV_F4=>GET_SELECTED_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] TABLENAME                   TYPE        STRING
* | [--->] DISPLAY_COLUMNS              TYPE        STRING (default ='*')
* | [--->] SELECTED_COL                   TYPE        STRING
* | [--->] WHERE                        TYPE        STRING(optional)
* | [--->] MAXCOUNT                  TYPE        I(optional)
* | [--->] TOP                          TYPE        I (default =3)
* | [--->] BOTTOM                       TYPE        I (default =25)
* | [--->] LEFT                         TYPE        I (default =25)
* | [--->] RIGHT                        TYPE        I (default =80)
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
    METHOD get_selected_value.

    result = ''.
    TRY.
        IF display_columns NE ''.
          DATA: otable TYPE REF TO data.
          DATA: orow TYPE REF TO data.

          FIELD-SYMBOLS: <table> TYPE STANDARD TABLE.
          FIELD-SYMBOLS: <row> TYPE any.

          CREATE DATA otable TYPE STANDARD TABLE OF (TABLENAME).
          ASSIGN otable->* TO <table>.

          CREATE DATA orow LIKE LINE OF <table>.
          ASSIGN orow->* TO <row>.

* CREATE SELECT STATEMENT
          IF MAXCOUNT IS NOT INITIAL.
            IF where IS NOT INITIAL.
              SELECT (display_columns) FROM (TABLENAME) WHERE (where) INTO CORRESPONDING FIELDS OF TABLE @<table> UP TO @MAXCOUNT ROWS.
            ELSE.
               SELECT (display_columns) FROM (TABLENAME) INTO CORRESPONDING FIELDS OF TABLE @<table> UP TO @MAXCOUNT ROWS.
            ENDIF.
          ELSE.
            IF where IS NOT INITIAL.
              SELECT (display_columns) FROM (TABLENAME) WHERE (where) INTO CORRESPONDING FIELDS OF TABLE @<table>.
            ELSE.
               SELECT (display_columns) FROM (TABLENAME) INTO CORRESPONDING FIELDS OF TABLE @<table>.
            ENDIF.
          ENDIF.

          cl_salv_table=>factory( IMPORTING r_salv_table = DATA(_salv)
                                  CHANGING  t_table      = <table> ).

          _salv->get_functions( )->set_default( abap_true ).
          _salv->get_columns( )->set_optimize( abap_true ).
          _salv->get_display_settings( )->set_striped_pattern( abap_true ).
          _salv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>single ).
          _salv->get_display_settings( )->set_list_header( 'F4 Yardımı' ).

          DATA: o_struct TYPE REF TO cl_abap_structdescr.
          o_struct ?= cl_abap_typedescr=>describe_by_data( <row> ).
*--------------------------------------------------------------------*
*          DATA(components) = o_struct->get_components( ).
*          recursive( components ).

"Dinamik bulmaya çalıştım ancak bazı include larda structure ekleri aldığı için olmadı örn: Matdoc ta Currency_A1

*          LOOP AT COMPONENTS INTO DATA(lv_comp).
*            TRY .
*               IF lv_comp-name IS  NOT INITIAL AND lv_comp-as_include = abap_false.
*                  DATA(test) = _columns->get_column( |{ lv_comp-name }| ).
*                  lv_col ?= _columns->get_column( |{ lv_comp-name }| ).
*               IF ( display_columns CS lv_comp-name ) OR ( display_columns = '*' ).
*                  lv_col->set_visible( abap_true ).
*               ELSE.
*                  lv_col->set_visible( abap_false ).
*               ENDIF.
*               ENDIF.
*            CATCH cx_root INTO DATA(hata).
*              BREAK-POINT.
*              lv_col->set_visible( abap_false ).
*            ENDTRY.
*
*          ENDLOOP.
*--------------------------------------------------------------------*
          DATA(_columns) = _salv->get_columns( ).
          _columns->set_optimize( abap_true ).
          DATA: lv_col TYPE REF TO cl_salv_column.

         SPLIT display_columns AT ',' INTO TABLE DATA(display_colums).
         DATA: FieldNames TYPE TABLE OF selopt.
         LOOP AT display_colums ASSIGNING FIELD-SYMBOL(<line>).
         APPEND VALUE #( sign = 'I' option = 'EQ' low = <line> high = '' ) to fieldnames.
         ENDLOOP.


         DATA: lo_columns  TYPE REF TO cl_salv_columns_table,
               lt_cols     TYPE        salv_t_column_ref.

            lo_columns = _salv->get_columns( ).
            lt_cols    = lo_columns->get( ).

           LOOP AT lt_cols INTO DATA(_col).
            lv_col ?= _columns->get_column( |{ _col-columnname }| ).
            IF (  _col-columnname in fieldnames ) OR ( display_columns = '*' ).
            lv_col->set_visible( abap_true ).
            ELSE.
            lv_col->set_visible( abap_false ).
            ENDIF.
           ENDLOOP.


          _salv->set_screen_popup( start_column = left
                                    end_column   = right
                                    start_line   = top
                                    end_line     = bottom ).

          _salv->display( ).
          DATA(it_sel_rows) = _salv->get_selections( )->get_selected_rows( ).

          ASSIGN COMPONENT SELECTED_COL OF STRUCTURE <table>[ it_sel_rows[ 1 ] ] TO FIELD-SYMBOL(<cell>).
          result = <cell>.
        ENDIF.
      CATCH cx_root INTO DATA(e).
    ENDTRY.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_SALV_F4=>GET_TABLE_VALUE
* +-------------------------------------------------------------------------------------------------+
* | [--->] TABLE                        TYPE REF TO DATA
* | [--->] SELECTED_COL                   TYPE        STRING
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method GET_TABLE_VALUE.
   FIELD-SYMBOLS: <table> TYPE STANDARD TABLE.
   FIELD-SYMBOLS: <line> TYPE ANY .
   ASSIGN table->* TO <table>.
   DATA(_f4) = cl_reca_gui_f4_popup=>factory_grid( id_title   = 'F4 Yardımı'
                                                    if_multi   = abap_false
                                                    it_f4value = <table> ).

  _f4->display( IMPORTING et_result = <table> ).

  IF lines( <table> ) > 0.
    ASSIGN <table>[ 1 ] to <line>.
    ASSIGN COMPONENT SELECTED_COL OF STRUCTURE <line> TO FIELD-SYMBOL(<value>).
    result = <value>.
  ENDIF.

  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_SD_SALV_F4=>RECURSIVE
* +-------------------------------------------------------------------------------------------------+
* | [--->] TAB                            TYPE        ABAP_COMPONENTS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD recursive.
    DATA: o_struct TYPE REF TO cl_abap_structdescr.
    LOOP AT tab REFERENCE INTO DATA(component).
    IF component->as_include = abap_true.
    o_struct ?= component->type.
    DATA(as_include) = o_struct->get_components( ).
    recursive( as_include ).
    ELSE.
    APPEND component->* TO COMPONENTS.
    ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
