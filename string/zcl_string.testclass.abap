"* use this source file for your ABAP unit test classes

CLASS zcl_testing_for_string DEFINITION FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
.
*?<asx:abap xmlns:asx="http://www.sap.com/abapxml" version="1.0">
*?<asx:values>
*?<TESTCLASS_OPTIONS>
*?<TEST_CLASS>zcl_Testing_For_String
*?</TEST_CLASS>
*?<TEST_MEMBER>f_Cut
*?</TEST_MEMBER>
*?<OBJECT_UNDER_TEST>ZCL_STRING
*?</OBJECT_UNDER_TEST>
*?<OBJECT_IS_LOCAL/>
*?<GENERATE_FIXTURE>X
*?</GENERATE_FIXTURE>
*?<GENERATE_CLASS_FIXTURE>X
*?</GENERATE_CLASS_FIXTURE>
*?<GENERATE_INVOCATION>X
*?</GENERATE_INVOCATION>
*?<GENERATE_ASSERT_EQUAL>X
*?</GENERATE_ASSERT_EQUAL>
*?</TESTCLASS_OPTIONS>
*?</asx:values>
*?</asx:abap>
  PRIVATE SECTION.
    DATA:
      f_cut TYPE REF TO zcl_string.  "class under test

    CLASS-METHODS: class_setup.
    CLASS-METHODS: class_teardown.
    METHODS: setup.
    METHODS: teardown.
    METHODS: containspattern FOR TESTING.
    METHODS: endswith FOR TESTING.
    METHODS: isnullorempty FOR TESTING.
    METHODS: isnumber FOR TESTING.
    METHODS: startswith FOR TESTING.
    METHODS: localdate FOR TESTING.
    METHODS: todate FOR TESTING.
    METHODS: append FOR TESTING.
    METHODS: replace FOR TESTING.
    METHODS: split FOR TESTING.
    METHODS: startwithlower FOR TESTING.
    METHODS: startwithupper FOR TESTING.
    METHODS: substring FOR TESTING.
    METHODS: tolower FOR TESTING.
    METHODS: toupper FOR TESTING.
    METHODS: trim FOR TESTING.
    METHODS: join FOR TESTING.
    METHODS: tostring FOR TESTING.
ENDCLASS.       "zcl_Testing_For_String


CLASS zcl_testing_for_string IMPLEMENTATION.

  METHOD class_setup.
  ENDMETHOD.


  METHOD class_teardown.
  ENDMETHOD.


  METHOD setup.
    CREATE OBJECT f_cut.
  ENDMETHOD.


  METHOD teardown.

  ENDMETHOD.


  METHOD containspattern.

    DATA pattern TYPE string.
    DATA result TYPE boolean.
    f_cut->zif_basestring~string = 'GAL1P'.
    pattern ='P'.
    result = f_cut->zif_string_decision~containspattern( pattern ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = abap_true          "<--- please adapt expected value
     msg   = 'Test: GAL1P--> P içeriyor mu'
*     level =
    ).

*    f_cut->zif_basestring~string = '0000000010335600'.
*    pattern ='335'.
*    result = f_Cut->zif_String_Decision~containspattern( pattern ).
*
*    cl_Abap_Unit_Assert=>assert_Equals(
*      act   = result
*      exp   = abap_true          "<--- please adapt expected value
*     msg   = 'Test: 0000000010335600--> 335 içeriyor mu'
**     level =
*    ).
  ENDMETHOD.


  METHOD endswith.

    DATA value TYPE string.
    DATA result TYPE boolean.

    result = f_cut->zif_string_decision~endswith( value ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD isnullorempty.

    DATA result TYPE boolean.

    result = f_cut->zif_string_decision~isnullorempty(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD isnumber.

    DATA result TYPE boolean.
    f_cut->zif_basestring~string = '2'.
    result = f_cut->zif_string_decision~isnumber(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = abap_true          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
   ).
    f_cut->zif_basestring~string = 'A'.
    result = f_cut->zif_string_decision~isnumber(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = abap_false          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD startswith.

    DATA value TYPE string.
    DATA result TYPE boolean.

    result = f_cut->zif_string_decision~startswith( value ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD localdate.

    DATA result TYPE string.
   f_cut->zif_basestring~string = '20181231'.
    result = f_cut->zif_string_format~localdate(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = '31.12.2018'          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD todate.

    DATA result TYPE dats.

    result = f_cut->zif_string_format~todate(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD append.

    DATA add TYPE string.
    DATA result TYPE REF TO zif_basestring.

    result = f_cut->zif_string_operation~append( add ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD replace.

    DATA replace TYPE string.
    DATA to TYPE string.
    DATA result TYPE string.
    f_cut->zif_basestring~string = 'GAL1P'.
    replace = 'P'.
    to = ''.
    result = f_cut->zif_string_operation~replace(
        replace = replace
        to = to ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = 'GAL1'          "<--- please adapt expected value
      msg   = 'Test: GAL1P --> P ile space değiştirildi. Beklenen GAL1'
*     level =
    ).
  ENDMETHOD.


  METHOD split.

    DATA seperator TYPE char1.
    DATA result TYPE string_table.
    DATA sonuc TYPE string_table.
*   sonuc = VALUE string( (  'GAL'  ) ( 'P' ) ).
    APPEND 'GAL' TO sonuc.
    APPEND 'P' TO sonuc.
    seperator = '1'.
    f_cut->zif_basestring~string = 'GAL1P'.
    result = f_cut->zif_string_operation~split( seperator ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = sonuc          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD startwithlower.

    DATA result TYPE string.

    result = f_cut->zif_string_operation~startwithlower(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD startwithupper.

    DATA result TYPE string.
    f_cut->zif_basestring~string = 'GAL1P'.
    result = f_cut->zif_string_operation~startwithupper(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD substring.

    DATA from TYPE int4.
    DATA to TYPE int4.
    from = 2.
    to = 4.
    f_cut->zif_basestring~string = 'GAL1DLP'.
    f_cut->zif_string_operation~substring(
        from = from
        to = to ).

  ENDMETHOD.


  METHOD tolower.

    DATA result TYPE string.
    f_cut->zif_basestring~string = 'GAL1P'.
    result = f_cut->zif_string_operation~tolower(  ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = 'gal1p'          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD toupper.

    DATA result TYPE string.
    f_cut->zif_basestring~string = 'gal1p'.
    result = f_cut->zif_string_operation~toupper(  ).
    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = 'GAL1P'          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD trim.

    DATA result TYPE string.
    f_cut->zif_basestring~string = '   MATERIAL  GAL1P     10   '.
    result = f_cut->zif_string_operation~trim(  ).
    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = 'MATERIAL GAL1P 10'          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD join.

    DATA _string TYPE string.
    DATA result TYPE string.
    f_cut->zif_basestring~string = 'GAL'.
    _string ='1P'.
    result = f_cut->zif_basestring~join( _string ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = 'GAL1P'          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.


  METHOD tostring.

*    data _string type any.
    DATA _string TYPE string.

    DATA result TYPE REF TO zif_basestring.

    result = f_cut->zif_basestring~tostring( _string ).

    cl_abap_unit_assert=>assert_equals(
      act   = result
      exp   = result          "<--- please adapt expected value
    " msg   = 'Testing value result'
*     level =
    ).
  ENDMETHOD.

ENDCLASS.
