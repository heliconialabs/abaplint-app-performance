REPORT zrest_call_demo.
************************************************************************
*     Test program to make rest call using the frameworkl              *
************************************************************************
DATA : rest_handler TYPE REF TO zcl_rest_framework,
       go_response  TYPE REF TO if_rest_entity,
       go_request   TYPE REF TO if_rest_entity,
       lv_requestid TYPE string.
************************************************************************
CONSTANTS: c_interface   TYPE zinterface_id VALUE '1VT_OUTBND'.
************************************************************************
DATA: cx_interface TYPE REF TO zcx_interace_config_missing.
CREATE OBJECT cx_interface.
DATA: cx_http TYPE REF TO zcx_http_client_failed.
DATA: v_string TYPE string.
CREATE OBJECT cx_http.
TRY .
    CREATE OBJECT rest_handler
      EXPORTING
        interface_name      = c_interface               "Mandatory
        business_identifier = 'Inv/SO/Deli-ID'
        method              = zif_rest_http_constants=>c_http_method_post.    "For troubleshooting
  CATCH zcx_interace_config_missing INTO cx_interface.
    WRITE:/10 'Handle logic Here-Interface Missing'.
  CATCH zcx_http_client_failed INTO cx_http .
    WRITE:/10 'Handle logic Here-HTTP Failed'.
ENDTRY.
************************************************************************
*----------------------Build the query params +Set the Payload here----*
************************************************************************
*Optional - To help developer understand the origin of call
rest_handler->set_callingmethod( 'CALL DEMO' ).
*Optional - To help developer understand the origin of call
rest_handler->set_callingprogram( 'ZREST_CALL_DEMO' ).
rest_handler->set_request_header( iv_name = 'header1' iv_value = 'value for header1' ).
rest_handler->set_request_header( iv_name = 'header2' iv_value = 'value for header2' ).
************************************************************************
lv_requestid = 'Microsoft'.  "Vetting by Organization
CONCATENATE '/org1/' lv_requestid INTO lv_requestid.
rest_handler->set_uri( lv_requestid ).

*------------------------read requests---------------------------------*
DATA : ts  TYPE timestampl,
       ts1 TYPE timestampl.
GET TIME STAMP FIELD ts.
go_response = rest_handler->zif_rest_framework~execute( io_entity = go_request async = abap_false is_retry = abap_false ).
************************************************************************
GET TIME STAMP FIELD ts1.
WRITE:/10 ts , 50 ts1.
DATA : r_secs TYPE tzntstmpl.

r_secs = cl_abap_tstmp=>subtract(
    tstmp1 = ts1
    tstmp2 = ts ).
WRITE:/10 r_secs.

IF go_response IS BOUND.
  v_string = go_response->get_string_data( ).
  WRITE:/10 v_string.
ENDIF.
