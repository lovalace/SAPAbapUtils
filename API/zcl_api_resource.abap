CLASS zcl_api_resource DEFINITION
  PUBLIC INHERITING FROM cl_rest_resource
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  METHODS: if_rest_resource~get REDEFINITION,
           if_rest_resource~post REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_API_RESOURCE IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_RESOURCE->IF_REST_RESOURCE~GET
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_rest_resource~get.
  DATA(url) = mo_request->GET_URI_PATH( ) .
  DATA(Route) = mo_request->get_uri_attributes( ) .
  DATA(json) = /ui2/cl_json=>serialize( |{ url } OK| ).
   mo_response->create_entity( )->set_string_data( json ).
   mo_response->set_status(  cl_rest_status_code=>gc_success_ok  ).
  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API_RESOURCE->IF_REST_RESOURCE~POST
* +-------------------------------------------------------------------------------------------------+
* | [--->] IO_ENTITY                      TYPE REF TO IF_REST_ENTITY
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_rest_resource~post.
     DATA(url) = mo_request->GET_URI_PATH( ) .
     DATA(request_body) = mo_request->get_entity( )->get_string_data( ).
     DATA(lo_entity) = mo_response->create_entity( ).
     lo_entity->set_content_type( if_rest_media_type=>gc_appl_json ).
     if url = '/orders'. "Sales orders
     
     DATA(Result) = NEW zcl_api_data(  )->getdata( body = request_body  )."Custom Class for data.
     lo_entity->set_string_data( /ui2/cl_json=>serialize(  result   ) ).
     mo_response->set_status( cl_rest_status_code=>gc_success_ok ).

     ELSEIF url = '/extrapayment'. "İlave tutar onayları
     
     lo_entity->set_string_data( /ui2/cl_json=>serialize( | İlave Tutarlar: {  request_body } | ) ).
     mo_response->set_status( cl_rest_status_code=>gc_success_ok ).
     
     ELSE.
     
     lo_entity->set_string_data( /ui2/cl_json=>serialize( | EntitySet Hatalı { url } { request_body } | ) ).
     mo_response->set_status( cl_rest_status_code=>gc_success_ok ).
     
     ENDIF.
  ENDMETHOD.
ENDCLASS.
