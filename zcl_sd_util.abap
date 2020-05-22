class ZCL_SD_UTIL definition
  public
  final
  create public .

public section.
  CLASS-DATA: oTable TYPE REF TO data.
  CLASS-METHODS add_characteristics  IMPORTING table TYPE REF TO data
                                               map_matnr TYPE fieldname OPTIONAL
                                               map_charg TYPE Fieldname OPTIONAL
                                               programName TYPE zbct002-programname OPTIONAL
                                     EXPORTING FieldCatalog TYPE lvc_t_Fcat
                                     RETURNING VALUE(Result) TYPE REF TO data.

  CLASS-METHODS Get_Fieldcatalog   IMPORTING table TYPE REF TO data
                                   RETURNING VALUE(Result) TYPE  lvc_t_Fcat.

  CLASS-METHODS Set_Fieldcatalog   IMPORTING Fieldcatalog TYPE lvc_T_fcat OPTIONAL
                                             FieldCatalogName TYPE ZBCT007-fcatname OPTIONAL
                                             ProgramName TYPE ZBCT007-programname OPTIONAL
                                             table TYPE REF TO data OPTIONAL
                                   RETURNING VALUE(Result) TYPE  lvc_t_fcat.
protected section.
private section.
ENDCLASS.



CLASS ZCL_SD_UTIL IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_UTIL=>ADD_CHARACTERISTICS
* +-------------------------------------------------------------------------------------------------+
* | [--->] TABLE                          TYPE REF TO DATA
* | [--->] MAP_MATNR                      TYPE        FIELDNAME(optional)
* | [--->] MAP_CHARG                      TYPE        FIELDNAME(optional)
* | [--->] PROGRAMNAME                    TYPE        ZBCT002-PROGRAMNAME(optional)
* | [<---] FIELDCATALOG                   TYPE        LVC_T_FCAT
* | [<-()] RESULT                         TYPE REF TO DATA
* +--------------------------------------------------------------------------------------</SIGNATURE>
  method ADD_CHARACTERISTICS.
  otable = table.
  DATA(List) =  core=>getcharacteristicslist(  table = otable
                                               map_matnr = map_matnr
                                               map_charg = map_charg
                                               programName = programname
                                            ).
    Business=>CreateItabDynamic( EXPORTING  programname = programname
                                             table = otable
                                 IMPORTING   FieldCatalog = Fieldcatalog
                                 CHANGING    Result = Result
                                ).

   ASSIGN Result->* TO FIELD-SYMBOL(<Result>).
   ASSIGN otable->* TO FIELD-SYMBOL(<tab>).
   <result> = CORRESPONDING #( <tab> ).

    Business=>TransposeData( EXPORTING   map_matnr = map_matnr
                                         map_charg = map_charg
                             CHANGING table = Result
                                      List =  List )   .
*   return Result.
  endmethod.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_UTIL=>GET_FIELDCATALOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] TABLE                          TYPE REF TO DATA
* | [<-()] RESULT                         TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD GET_FIELDCATALOG.
      result  = Business=>GetFieldcatalog( table  ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_SD_UTIL=>SET_FIELDCATALOG
* +-------------------------------------------------------------------------------------------------+
* | [--->] FIELDCATALOG                   TYPE        LVC_T_FCAT(optional)
* | [--->] FIELDCATALOGNAME               TYPE        ZBCT007-FCATNAME(optional)
* | [--->] PROGRAMNAME                    TYPE        ZBCT007-PROGRAMNAME(optional)
* | [--->] TABLE                          TYPE REF TO DATA(optional)
* | [<-()] RESULT                         TYPE        LVC_T_FCAT
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD SET_FIELDCATALOG.
   result = COND #(  WHEN fieldcatalog is initial THEN Business=>GetFieldcatalog( table  )
                                                  ELSE fieldcatalog ).
   business=>SetAdditionField( CHANGING FieldCatalog = result ).


  ENDMETHOD.
ENDCLASS.
