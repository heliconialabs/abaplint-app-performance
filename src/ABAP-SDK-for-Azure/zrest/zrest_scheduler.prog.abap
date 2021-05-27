REPORT zrest_scheduler.
*----------------------------------------------------------------------------------------------*
* Programmer                                                      Sasidhar Puranam             *
*----------------------------------------------------------------------------------------------*
* REST Scheduler reads all messages which are not 200 OK and resubmits them. The number of times
* retried maintained is controlled by config
*----------------------------------------------------------------------------------------------*
*----------------------------------------------------------------------*
*                       Modification History                           *
*----------------------------------------------------------------------*
* Date      | USER ID  |  VSTF  | Transport  | Remarks                 *
*-----------|----------|--------|------------|-------------------------*
* 04|28|2016|V-DEVEER  |2163894 | DGDK903413 | Authorization Check
*----------------------------------------------------------------------*
*----------------------------------------------------------------------------------------------*
* SELECTION SCREEN
*-----------------------------------------------------------------------------------------------*
TABLES zrest_config.
SELECTION-SCREEN: BEGIN OF BLOCK blk0 WITH FRAME TITLE text-001 .
SELECT-OPTIONS: s_id FOR zrest_config-interface_id.
SELECTION-SCREEN: END   OF BLOCK blk0.

*----------------------------------------------------------------------------------------------*
CLASS lcl_process_data DEFINITION.
  PUBLIC SECTION.
    METHODS cleanse_records.
    METHODS get_process.
ENDCLASS.                    "lcl_process_data DEFINITION
*----------------------------------------------------------------------------------------------*
CLASS lcl_process_data IMPLEMENTATION.
*----------------------------------------------------------------------------------------------*
* Process the ones which are waiting in 0 state in the payload table                           *
*----------------------------------------------------------------------------------------------*
  METHOD get_process.
    DATA : rest_utility TYPE REF TO zcl_rest_utility_class.
    DATA : it_unprocessed_data TYPE zrt_payload.
    DATA : wa_unprocessed_data TYPE zrest_mo_payload.
    it_unprocessed_data = zcl_rest_utility_class=>unprocessed_data( ).
    DELETE it_unprocessed_data WHERE interface_id NOT IN s_id.

* Check if table is initial , if yes exit.
    IF it_unprocessed_data IS INITIAL.
      WRITE:/10 '*******************************************************************************'.
      WRITE:/10 '*************Nothing to be processed              *****************************'.
      WRITE:/10 '*******************************************************************************'.
      EXIT.
    ELSE.
*   Loop at unprocessed_data and retry.
      LOOP AT it_unprocessed_data INTO wa_unprocessed_data.
*   Create utility object
        CREATE OBJECT rest_utility.
*   Call the retry method and set async to false , retry to true.
        TRY .
            CALL METHOD rest_utility->retry(
                message_id     = wa_unprocessed_data-messageid
                method         = wa_unprocessed_data-method
                from_scheduler = 'X' ).
          CATCH zcx_interace_config_missing .
            WRITE:/10 '*******************************************************************************'.
            WRITE:/10 'Processed Message ID' , 30 wa_unprocessed_data-messageid  , 65 'Failed'.
            WRITE:/10 '*******************************************************************************'.
          CATCH zcx_http_client_failed .
            WRITE:/10 '*******************************************************************************'.
            WRITE:/10 'Processed Message ID' , 30 wa_unprocessed_data-messageid  , 65 'Failed'.
            WRITE:/10 '*******************************************************************************'.
        ENDTRY.
*   Clear the object reference
        FREE rest_utility.
        WRITE:/10 '*******************************************************************************'.
        WRITE:/10 'Processed Message ID' , 30 wa_unprocessed_data-messageid  , 65 'Failed'.
        WRITE:/10 '*******************************************************************************'.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.                    "get_process
*----------------------------------------------------------------------------------------------*
* Apply the retention period  - 30 days for succesful and errors stay forever !                *
*----------------------------------------------------------------------------------------------*
  METHOD cleanse_records.
    TRY.
        zcl_rest_utility_class=>reset_all_data( ).
*    Changes for Authorization VSTF # 2163894 | DGDK903413
      CATCH zcx_http_client_failed.
    ENDTRY.
*    End of changes VSTF # 2163894 | DGDK903413
    WRITE:/10 '*******************************************************************************'.
    WRITE:/10 '*************Messages older than 30 days cleansed******************************'.
    WRITE:/10 '*******************************************************************************'.
  ENDMETHOD.                    "cleanse_records
ENDCLASS.                    "lcl_process_data IMPLEMENTATION

*----------------------------------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------------------------------*
  DATA lc_process_object TYPE REF TO lcl_process_data.
  CREATE OBJECT lc_process_object.
*----------------------------------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------------------------------*
* Cleanse the records older than 30 days
  lc_process_object->cleanse_records( ).
* Reprocess the error and records which are waiting to be executed.
  lc_process_object->get_process( ).
