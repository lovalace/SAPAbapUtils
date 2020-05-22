CLASS zcl_string DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zif_string_decision .
    INTERFACES zif_string_format .
    INTERFACES zif_string_operation .
    INTERFACES zif_basestring .

    ALIASES join
      FOR zif_basestring~join .
    ALIASES tostring
      FOR zif_basestring~tostring .

    CLASS-METHODS class_constructor .
  PROTECTED SECTION.

    ALIASES length
      FOR zif_basestring~length .
    ALIASES string
      FOR zif_basestring~string .
  PRIVATE SECTION.

    CLASS-DATA instance TYPE REF TO zcl_string .
    CLASS-DATA char TYPE char255 .
ENDCLASS.



CLASS ZCL_STRING IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_STRING=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD class_constructor.
    instance  = COND #( WHEN instance IS INITIAL THEN NEW zcl_string( ) ELSE instance ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_BASESTRING~JOIN
* +-------------------------------------------------------------------------------------------------+
* | [--->] _STRING                        TYPE        STRING
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_basestring~join.
    me->string = me->string && _string.
    result = me->string.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_BASESTRING~TOSTRING
* +-------------------------------------------------------------------------------------------------+
* | [--->] _STRING                        TYPE        ANY
* | [<-()] RESULT                         TYPE REF TO ZIF_BASESTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_basestring~tostring.
    me->length = strlen( _string ).
    me->string = CONV string( _string ).
    result ?= me->instance.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_DECISION~CONTAINSPATTERN
* +-------------------------------------------------------------------------------------------------+
* | [--->] PATTERN                        TYPE        STRING
* | [<-()] RESULT                         TYPE        BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_decision~containspattern.
    result = COND #( WHEN me->string CS pattern THEN abap_true ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_DECISION~ENDSWITH
* +-------------------------------------------------------------------------------------------------+
* | [--->] VALUE                          TYPE        STRING
* | [<-()] RESULT                         TYPE        BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_decision~endswith.
    SHIFT me->string LEFT DELETING LEADING '0'.
    DATA(lv_val) =  '*' && value.
    result = COND #( WHEN  me->string CP lv_val THEN abap_true   ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_DECISION~ISNULLOREMPTY
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_decision~isnullorempty.
    result = COND #( WHEN me->string IS INITIAL OR me->string = '' THEN abap_true ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_DECISION~ISNUMBER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_decision~isnumber.
    result = COND #( WHEN me->string CO '0123456789' THEN abap_true ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_DECISION~STARTSWITH
* +-------------------------------------------------------------------------------------------------+
* | [--->] VALUE                          TYPE        STRING
* | [<-()] RESULT                         TYPE        BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_decision~startswith.
    SHIFT me->string LEFT DELETING LEADING '0'.
    DATA(lv_val) =  value && '*' .
    result = COND #( WHEN  me->string CP lv_val THEN abap_true   ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_FORMAT~LOCALDATE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_format~localdate.
    result = me->string+6(2) && '.' &&  me->string+4(2) && '.' && me->string(4).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_FORMAT~TODATE
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        DATS
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_format~todate.
    result = CONV #( me->string ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~APPEND
* +-------------------------------------------------------------------------------------------------+
* | [--->] ADD                            TYPE        STRING
* | [<-()] RESULT                         TYPE REF TO ZIF_BASESTRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~append.
    me->string = me->string && add.
    CONCATENATE me->string add INTO me->string.
    result = instance.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~REPLACE
* +-------------------------------------------------------------------------------------------------+
* | [--->] REPLACE                        TYPE        STRING
* | [--->] TO                             TYPE        STRING
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~replace.
    REPLACE ALL OCCURRENCES OF replace IN me->string WITH to.
   result = me->string.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~SPLIT
* +-------------------------------------------------------------------------------------------------+
* | [--->] SEPERATOR                      TYPE        CHAR1
* | [<-()] RESULT                         TYPE        STRING_TABLE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~split.
    SPLIT me->string AT seperator INTO TABLE result.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~STARTWITHLOWER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~startwithlower.
    result = to_lower(  me->string(1) ) && me->string+1.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~STARTWITHUPPER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~startwithupper.
    result = to_upper(  me->string(1) ) && me->string+1.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~SUBSTRING
* +-------------------------------------------------------------------------------------------------+
* | [--->] FROM                           TYPE        INT4
* | [--->] TO                             TYPE        INT4
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~substring.
    DATA(lv_strlen) = strlen( string ).
    SUBTRACT from FROM lv_strlen.
    IF to LE lv_strlen.
      string = string+from(to).
    ENDIF.
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~TOLOWER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~tolower.
    result = to_lower( string ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~TOUPPER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~toupper.
    result = to_upper( string ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_STRING->ZIF_STRING_OPERATION~TRIM
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RESULT                         TYPE        STRING
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD zif_string_operation~trim.
    result = condense( me->string ).
  ENDMETHOD.
ENDCLASS.
