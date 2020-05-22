class ZCL_CALLAPI definition
  public
  final
  create public .

public section.

  class-methods CallApi
    importing
      !MaterialType type STRING
      !Vbeln type VBELN optional
    changing
      !RESPONSE type STRING optional .
  PROTECTED SECTION.
private section.

  class-data HTTP_CLIENT type ref to IF_HTTP_CLIENT .
  class-data URL type STRING value 'http://10.11.XX.XX:XXXX/MATERIAL/' ##NO_TEXT.
  class-data IMGURL type STRING value 'http://10.11.XX.XX:XXXX/' ##NO_TEXT.
  class-data JSON type TY_JSON .

  class-methods CHECKMATERIAL
    importing !Material type MATNR
    returning value(R_VAL) type BOOLEAN .
ENDCLASS.



CLASS ZCL_CALLAPI IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Private Method ZCL_CALLAPI=>CHECKMATERIAL
* +-------------------------------------------------------------------------------------------------+
* | [--->] HURDATIPI                      TYPE        MATNR
* | [<-()] R_VAL                          TYPE        BOOLEAN
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD checkmaterial.
  SELECT SINGLE matnr INTO @data(_matnr) FROM mara WHERE matnr =  @material.
  r_val = xsdbool( _matnr <> ' '  ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_CALLAPI=>HURDABILDIRIMI
* +-------------------------------------------------------------------------------------------------+
* | [--->] HURDATIPI                      TYPE        STRING
* | [--->] TESLIMATNO                     TYPE        VBELN(optional)
* | [<-->] RESPONSE                       TYPE        STRING(optional)
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD CallApi.
    DATA(_url) = url && MATERIAL.
    if CheckMaterial( CONV #( material ) ).
    cl_http_client=>create_by_url( EXPORTING  url  = _url
                               IMPORTING  client = http_client
                               EXCEPTIONS argument_not_found = 1
                                          plugin_not_active  = 2
                                          internal_error     = 3
                                          OTHERS             = 4 ).
                                          
    http_client->send( EXCEPTIONS http_communication_failure = 1
                                   http_invalid_state         = 2 ).

    http_client->receive( EXCEPTIONS http_communication_failure = 1
                                     http_invalid_state         = 2
                                     http_processing_failed     = 3 ).

    Response = http_client->response->get_cdata( ).
    /ui2/cl_json=>deserialize( EXPORTING json = response pretty_name = /ui2/cl_json=>pretty_mode-camel_case
                               CHANGING  data = json ).
                               
    if json-imageurl is NOT INITIAL.
    DATA(_imageUrl) = imgurl && json-imageurl.
    CALL FUNCTION 'ZSD_F_SHOWIMAGE' " show image in container.
      EXPORTING
        predictiondata = json-predictiondata
        imageurl       =   _imageUrl.
    ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
