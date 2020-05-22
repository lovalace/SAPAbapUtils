CLASS ZCL_API DEFINITION
  PUBLIC INHERITING FROM cl_rest_http_handler
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS: if_rest_application~get_root_handler REDEFINITION.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_API IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_API->IF_REST_APPLICATION~GET_ROOT_HANDLER
* +-------------------------------------------------------------------------------------------------+
* | [<-()] RO_ROOT_HANDLER                TYPE REF TO IF_REST_HANDLER
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD if_rest_application~get_root_handler.
    DATA(lo_router) = NEW cl_rest_router( ).
    lo_router->attach( iv_template = '/orders' iv_handler_class = 'ZCL_API_RESOURCE' ).
    lo_router->attach( iv_template = '/payment' iv_handler_class = 'ZCL_API_RESOURCE' ).
    ro_root_handler = lo_router.
  ENDMETHOD.
ENDCLASS.
