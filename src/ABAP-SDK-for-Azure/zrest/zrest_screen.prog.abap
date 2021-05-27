  REPORT zrest_screen.
*---------------------------------------------------------------------------------------------*
* Programmer                                                      Anupriya Gagnejs             *
*----------------------------------------------------------------------------------------------*
* Program developed to report the REST calls made out of the system. Report provides ability to
* View payloed , download payload , headers , response and request data
*----------------------------------------------------------------------------------------------*

*----------------------------------------------------------------------*
*                       Modification History                           *
*----------------------------------------------------------------------*
* Date      | USER ID  |  VSTF  | Transport  | Remarks                 *
*-----------|----------|--------|------------|-------------------------*
* 04|28|2016|V-DEVEER  |2163894 | DGDK903413 | Authorization Check
*----------------------------------------------------------------------*
* 05|05|2016|V-DEVEER  |2163894 | DGDK903444 | Errors in SIT
*----------------------------------------------------------------------*
* 12|08|2016|V-JAVEDA  |2163894 | MS2K948543 | Enhance delete function
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZREST_SCREEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
  INCLUDE <icon>.

* Predefine a local class for event handling to allow the
* declaration of a reference variable before the class is defined.
  CLASS lcl_event_receiver DEFINITION DEFERRED.
*&---------------------------------------------------------------------*

********ty is the type that includes the table zrest_monitor
* with the lights columnn added to show if the request was a
*success or error.*****************************************
  TYPES: BEGIN OF ty.
          INCLUDE TYPE zrest_monitor.
  TYPES   : lights(1) TYPE c.
  TYPES:  END OF ty.

***********************************************************

  DATA: itab      TYPE STANDARD TABLE OF ty, "Output Internal table
        fieldcat  TYPE lvc_t_fcat, "Field catalog
        wa        TYPE ty,
        w_variant TYPE disvariant, "Variant
        w_layout  TYPE lvc_s_layo. "Layout structure
  DATA : lv_textid TYPE REF TO zcx_http_client_failed,
         lv_clnt_failed TYPE REF TO zcx_http_client_failed,
         lv_text2  TYPE scx_t100key.

  TABLES zrest_config. "Include table zrest_config
  DATA: ok_code           LIKE sy-ucomm, "capture the user action
        gt_monitor        TYPE TABLE OF zrest_monitor, "internal table of type zrest_monitor
        g_repid           LIKE sy-repid, "holds value of the report name
        cont_on_main      TYPE scrfname VALUE 'BCALVC_TOOLBAR_D100_C1', "container name for the screen.
        grid1             TYPE REF TO cl_gui_alv_grid,   "grid for the screen
        custom_container1 TYPE REF TO cl_gui_custom_container, "container for the screen
        event_receiver    TYPE REF TO lcl_event_receiver. "event receiver
  TABLES: icon.
* Screen 100 to display the alv report
  SET SCREEN 100.

****** class definition******************************************
  CLASS lcl_event_receiver DEFINITION.
    PUBLIC SECTION.
      "Selection Screen Parameters
      DATA: r_monitor   TYPE RANGE OF ty-zmessageid,
            r_startdate TYPE RANGE OF ty-zexedate,
            r_starttime TYPE RANGE OF ty-zexetime,
            r_compdate  TYPE RANGE OF ty-zcompdate,
            r_comptime  TYPE RANGE OF ty-zcomptime.
      METHODS:
        "Append own buttons on toolbar
        handle_toolbar
                      FOR EVENT toolbar OF cl_gui_alv_grid
          IMPORTING e_object e_interactive,
        "Handle user events
        handle_user_command
                      FOR EVENT user_command OF cl_gui_alv_grid
          IMPORTING e_ucomm,
        get_data.

    PRIVATE SECTION.

  ENDCLASS.                    "lcl_event_receiver DEFINITION
**********************************************************************

  DATA: lo_report TYPE REF TO lcl_event_receiver. "Creating Selection screen
  "Selection screen parameters
  DATA: w_carrid   TYPE ty-zmessageid,
        w_startd   TYPE ty-zexedate,
        w_start    TYPE ty-zexetime,
        w_compdate TYPE ty-zcompdate,
        w_comptime TYPE ty-zcomptime,
        w_id       TYPE zrest_monitor-businessid,
        w_httpst   TYPE ty-httpstatus.   "v-javeda - MS2K948543
  DATA: lt_tab TYPE TABLE OF zrest_config."v-javeda - MS2K948543 "for F4 values
  "Start of Selection Screen
  SELECTION-SCREEN: BEGIN OF BLOCK blk0 WITH FRAME TITLE text-000.
  SELECT-OPTIONS: s_id FOR zrest_config-interface_id.
  SELECTION-SCREEN: END   OF BLOCK blk0.


  SELECTION-SCREEN: BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS: s_startd FOR w_startd DEFAULT sy-datum TO sy-datum," v-javeda - MS2K948543 - default today
                  s_stime FOR w_start,
                  s_compdt FOR w_compdate,
                  s_comptm FOR w_comptime.
  SELECTION-SCREEN: END   OF BLOCK blk1.

  SELECTION-SCREEN: BEGIN OF BLOCK blk2 WITH FRAME TITLE text-002.
  SELECT-OPTIONS: s_httpst FOR w_httpst.
  SELECT-OPTIONS: s_msgid FOR w_carrid.
  SELECT-OPTIONS: s_busid FOR w_id.

  SELECTION-SCREEN: END   OF BLOCK blk2.

** Initialization
  INITIALIZATION.
* object for the report
    CREATE OBJECT lo_report.

**  F4help for Interface ID. - v-javeda - MS2K948543
  AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_id-low.
    REFRESH lt_tab.
    SELECT *  FROM  zrest_config INTO TABLE lt_tab.
    IF sy-subrc = 0.ENDIF.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = 'INTERFACE_ID'
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = 'S_ID-LOW'
        value_org   = 'S'
      TABLES
        value_tab   = lt_tab[].
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

  AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_id-high.
    REFRESH lt_tab.
    SELECT *  FROM  zrest_config INTO TABLE lt_tab.
    IF sy-subrc = 0.ENDIF.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = 'INTERFACE_ID'
        dynpprog    = sy-repid
        dynpnr      = sy-dynnr
        dynprofield = 'S_ID-HIGH'
        value_org   = 'S'
      TABLES
        value_tab   = lt_tab[].
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.

* Start of Selection
  START-OF-SELECTION.
* Get data
    lo_report->r_monitor = s_msgid[].
    lo_report->r_startdate = s_startd[].
    lo_report->r_starttime = s_stime[].
    lo_report->r_compdate = s_compdt[].
    lo_report->r_comptime = s_comptm[].
    lo_report->get_data( ).

**************class lcl_event_receiver (Implementation)**************
  CLASS lcl_event_receiver IMPLEMENTATION.
    "Get the data from the parameters in the selection screen.
    METHOD get_data.
      SELECT * FROM zrest_monitor INTO CORRESPONDING FIELDS OF
       TABLE itab WHERE zmessageid IN s_msgid
                    AND zexedate   IN s_startd
                    AND zexetime   IN s_stime
                    AND zcompdate  IN s_compdt
                    AND zcomptime  IN s_comptm
                    AND httpstatus IN s_httpst   "v-javeda - MS2K948543 -  status in selscreen
                    AND businessid IN s_busid
                    AND interface_id IN s_id
                  ORDER BY zcompdate DESCENDING zcomptime DESCENDING.
      IF sy-dbcnt IS INITIAL.
        MESSAGE s398(00) WITH 'No data selected'.
      ENDIF.
    ENDMETHOD.                    "get_data
    "Add buttons to the toolbar
    METHOD handle_toolbar.
      DATA: ls_toolbar  TYPE stb_button.
*      add delete button "v-javeda - MS2K948543
      CLEAR ls_toolbar.
      MOVE 'DELETE' TO ls_toolbar-function.
      MOVE  icon_delete_row TO ls_toolbar-icon.
      MOVE 'Delete Payload' TO ls_toolbar-quickinfo.
      MOVE 'Delete' TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
      "append download payload button
      CLEAR ls_toolbar.
      MOVE 'DOWNLOAD' TO ls_toolbar-function.
      MOVE icon_message TO ls_toolbar-icon.
      MOVE 'Download Payload'(111) TO ls_toolbar-quickinfo.
      MOVE 'Download'(112) TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
      "append an icon to show headers
      CLEAR ls_toolbar.
      MOVE 'HEADERS' TO ls_toolbar-function.
      MOVE icon_header TO ls_toolbar-icon.
      MOVE 'Show headers'(111) TO ls_toolbar-quickinfo.
      MOVE 'Headers'(112) TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
      "append an icon to show retry
      CLEAR ls_toolbar.
      MOVE 'RETRY' TO ls_toolbar-function.
      MOVE icon_refresh TO ls_toolbar-icon.
      MOVE 'Try Again'(111) TO ls_toolbar-quickinfo.
      MOVE 'Retry'(112) TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
      "append an icon to show payload
      CLEAR ls_toolbar.
      MOVE 'SHOW PAYLOAD' TO ls_toolbar-function.
      MOVE icon_display TO ls_toolbar-icon.
      MOVE 'Payload'(111) TO ls_toolbar-quickinfo.
      MOVE 'Payload'(112) TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.
      "append an icon to show response
      CLEAR ls_toolbar.
      MOVE 'SHOW RESPONSE' TO ls_toolbar-function.
      MOVE icon_display TO ls_toolbar-icon.
      MOVE 'Response'(111) TO ls_toolbar-quickinfo.
      MOVE 'Response'(112) TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

      CLEAR ls_toolbar.
      MOVE 'RETRY_LOG' TO ls_toolbar-function.
      MOVE icon_display TO ls_toolbar-icon.
      MOVE 'Retry Log' TO ls_toolbar-quickinfo.
      MOVE 'Retry Log' TO ls_toolbar-text.
      MOVE ' ' TO ls_toolbar-disabled.
      APPEND ls_toolbar TO e_object->mt_toolbar.

*     Added for VSTF 2163894 / DGDK903444
      SORT e_object->mt_toolbar BY function.
      DELETE ADJACENT DUPLICATES FROM e_object->mt_toolbar COMPARING function.
*     End of addition for VSTF 2163894 / DGDK903444
    ENDMETHOD.                    "handle_toolbar
*-------------------------------------------------------------------
*&---- Handle button click events------------------------------------
    METHOD handle_user_command.
      DATA: lt_rows     TYPE lvc_t_row,
            l_row       TYPE lvc_s_row,
            sel_row     LIKE LINE OF itab,
            message_val TYPE string,
            sel_tab     TYPE TABLE OF ty,
            lw_monitor  TYPE zrest_monitor, "v-javeda - MS2K948543
            lv_ans      TYPE char1.         "v-javeda - MS2K948543
      CASE e_ucomm.
** v-javeda - MS2K948543 : Delete function added
        WHEN 'DELETE'.
          CALL METHOD grid1->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = g_repid
                txt2  = sy-subrc
                txt1  = 'Error in Flush'(500).
          ELSE.
            IF lt_rows IS INITIAL.
              MESSAGE 'Please select a row.'(003) TYPE 'I'.
              EXIT.
            ELSEIF lines( lt_rows ) > 1.
              MESSAGE 'Please select only one row.'(004) TYPE 'I'.
              EXIT.
            ENDIF.
            CALL METHOD cl_gui_cfw=>flush.
            IF sy-subrc NE 0.
              CALL FUNCTION 'POPUP_TO_INFORM'
                EXPORTING
                  titel = g_repid
                  txt2  = sy-subrc
                  txt1  = 'Error in Flush'(500).
            ELSE.
              CALL FUNCTION 'POPUP_TO_CONFIRM'
                EXPORTING
                  text_question         = 'Do you want to Proceed for deletion'
                  text_button_1         = 'Yes'
                  icon_button_1         = 'ICON_CHECKED'
                  text_button_2         = 'No'
                  icon_button_2         = 'ICON_INCOMPLETE'
                  display_cancel_button = 'X'
                  start_column          = 25
                  start_row             = 6
                IMPORTING
                  answer                = lv_ans.
              IF sy-subrc  <>   0.
* Implement suitable error handling here
              ENDIF.
              IF lv_ans = '1'.
                FREE MEMORY ID 'ABCD'.
                READ TABLE lt_rows INDEX 1 INTO l_row.
                READ TABLE itab INDEX l_row-index INTO sel_row.
                IF sy-subrc = 0 .
                  SELECT SINGLE * FROM zrest_monitor INTO lw_monitor WHERE zmessageid = sel_row-zmessageid.
                  IF sy-subrc = 0.
                    lw_monitor-zdelete = 'X'.
                    lw_monitor-deleteuser = sy-uname.
                    lw_monitor-deletedate = sy-datum.
                    lw_monitor-deletetime = sy-uzeit.
                    MODIFY zrest_monitor FROM lw_monitor." WHERE messageid = sel_row-zmessageid.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          lo_report->get_data( ).
          PERFORM layout.
          PERFORM display_output.
**

        WHEN 'DOWNLOAD'.
          CALL METHOD grid1->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = g_repid
                txt2  = sy-subrc
                txt1  = 'Error in Flush'(500).
          ELSE.
            DATA: count_row TYPE i.
            DESCRIBE TABLE lt_rows LINES count_row.
            IF count_row <> 1.
              DATA: lv_id TYPE icon-id.
              SELECT SINGLE id
                FROM icon
                INTO lv_id
                WHERE name = 'ICON_MESSAGE_WARNING'.
              CALL FUNCTION 'POPUP_TO_INFORM'
                EXPORTING
                  titel  = 'Warning'
                  txt1   = lv_id
                  txt2   = 'Select only one row.'
                EXCEPTIONS
                  OTHERS = 1.
            ELSE.
              FREE MEMORY ID 'ABCD'.
              READ TABLE lt_rows INDEX 1 INTO l_row.
              READ TABLE itab INDEX l_row-index INTO sel_row.
              DATA: pay_body TYPE zrest_mo_payload-payload.
              SELECT payload FROM  zrest_mo_payload INTO pay_body WHERE messageid = sel_row-zmessageid.
              ENDSELECT.
              TRY.
                  CALL METHOD zcl_rest_utility_class=>download_payload_file( xstring = pay_body message_id = sel_row-zmessageid ).
*                Authorization check VSTF # 2163894 | DGDK903413

                CATCH zcx_http_client_failed INTO lv_textid.
                  lv_text2 = lv_textid->if_t100_message~t100key.
                  MESSAGE ID lv_text2-msgid TYPE 'I' NUMBER lv_text2-msgno.
                  EXIT.
              ENDTRY.
*             end of changes VSTF # 2163894 | DGDK903413
            ENDIF.
          ENDIF.

        WHEN 'HEADERS'.
          CALL METHOD grid1->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          IF lt_rows IS INITIAL.
            MESSAGE 'Please select a row.'(003) TYPE 'I'.
            EXIT.
          ELSEIF lines( lt_rows ) > 1.
            MESSAGE 'Please select only one row.'(004) TYPE 'I'.
            EXIT.
          ENDIF.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = g_repid
                txt2  = sy-subrc
                txt1  = 'Error in Flush'(500).
          ELSE.
            FREE MEMORY ID 'ABCD'.
            CLEAR sel_tab.
            FREE MEMORY ID 'ABCD'.
            READ TABLE lt_rows INDEX 1 INTO l_row.
            READ TABLE itab INDEX l_row-index INTO sel_row.
            TRY.
                CALL METHOD zcl_rest_utility_class=>show_submitted_headers
                  EXPORTING
                    message_id = sel_row-zmessageid.
*             Changed for Authorization Check VSTF # 2163894 | DGDK903413
              CATCH zcx_http_client_failed INTO lv_textid.
                lv_text2 = lv_textid->if_t100_message~t100key.
                MESSAGE ID lv_text2-msgid TYPE 'I' NUMBER lv_text2-msgno.
                EXIT.
            ENDTRY.
*           End of changes VSTF # 2163894 | DGDK903413
          ENDIF.

        WHEN 'RETRY'.
          CALL METHOD grid1->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = g_repid
                txt2  = sy-subrc
                txt1  = 'Error in Flush'(500).
          ELSE.
            FREE MEMORY ID 'ABCD'.
            DATA obj TYPE REF TO zcl_rest_utility_class.
            CREATE OBJECT obj .
            LOOP AT lt_rows INTO l_row.
              READ TABLE itab INDEX l_row-index INTO sel_row.
**   v-javeda - MS2K948543 - validation for not retrying deleted payload
              SELECT SINGLE *  FROM zrest_monitor INTO lw_monitor
                               WHERE zmessageid = sel_row-zmessageid
                               AND zdelete EQ 'X'.
              IF sy-subrc = 0.
                CALL FUNCTION 'POPUP_TO_INFORM'
                  EXPORTING
                    titel = g_repid
                    txt2  = sel_row-zmessageid
                    txt1  = 'Cannot process for Deleted message id : '(500).
              ELSE.
**         v-javeda - MS2K948543
                IF obj IS BOUND.
                  TRY.
                      CALL METHOD obj->retry( message_id = sel_row-zmessageid method = 'None' ).
*                Authorization check VSTF # 2163894 | DGDK903413
                    CATCH zcx_http_client_failed INTO lv_clnt_failed.
                      lv_text2 = lv_clnt_failed->if_t100_message~t100key.
                      MESSAGE ID lv_text2-msgid TYPE 'I' NUMBER lv_text2-msgno.
                      EXIT.
                  ENDTRY.
*             end of changes VSTF # 2163894 | DGDK903413
                ENDIF.
              ENDIF."              v-javeda - MS2K948543
            ENDLOOP.
          ENDIF.
          lo_report->get_data( ).
          PERFORM layout.
          PERFORM display_output.

        WHEN 'SHOW PAYLOAD'.
          CALL METHOD grid1->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          IF lt_rows IS INITIAL.
            MESSAGE 'Please select a row.'(003) TYPE 'I'.
            EXIT.
          ELSEIF lines( lt_rows ) > 1.
            MESSAGE 'Please select only one row.'(004) TYPE 'I'.
            EXIT.
          ENDIF.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = g_repid
                txt2  = sy-subrc
                txt1  = 'Error in Flush'(500).
          ELSE.
            FREE MEMORY ID 'ABCD'.
            READ TABLE lt_rows INDEX 1 INTO l_row.
            READ TABLE itab INDEX l_row-index INTO sel_row.
            DATA: payload_body TYPE zrest_mo_payload-payload.
            DATA ob TYPE REF TO zcl_rest_utility_class.
            CREATE OBJECT ob .
            IF ob IS BOUND.
*             Changed for Authorization Check VSTF # 2163894 | DGDK903413
              TRY.
                  CALL METHOD ob->show_payload( message_id = sel_row-zmessageid ).
                CATCH zcx_http_client_failed INTO lv_textid.
                  lv_text2 = lv_textid->if_t100_message~t100key.
                  MESSAGE ID lv_text2-msgid TYPE 'I' NUMBER lv_text2-msgno.
                  EXIT.
              ENDTRY.
*             end of changes VSTF # 2163894 | DGDK903413
            ENDIF.
          ENDIF.

        WHEN 'SHOW RESPONSE'.
          CALL METHOD grid1->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          IF lt_rows IS INITIAL.
            MESSAGE 'Please select a row.'(003) TYPE 'I'.
            EXIT.
          ELSEIF lines( lt_rows ) > 1.
            MESSAGE 'Please select only one row.'(004) TYPE 'I'.
            EXIT.
          ENDIF.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = g_repid
                txt2  = sy-subrc
                txt1  = 'Error in Flush'(500).
          ELSE.
            FREE MEMORY ID 'ABCD'.
            READ TABLE lt_rows INDEX 1 INTO l_row.
            READ TABLE itab INDEX l_row-index INTO sel_row.
            CREATE OBJECT ob .
            IF ob IS BOUND.
              TRY.
                  CALL METHOD ob->show_payload( message_id = sel_row-zmessageid response = abap_true ).
*              Authorization changes V-DEVEER
                CATCH zcx_http_client_failed INTO lv_textid.
                  lv_text2 = lv_textid->if_t100_message~t100key.
                  MESSAGE ID lv_text2-msgid TYPE 'I' NUMBER lv_text2-msgno.
                  EXIT.
              ENDTRY.
*             end of changes V-DEVEER
            ENDIF.
          ENDIF.
        WHEN 'RETRY_LOG'.
          CALL METHOD grid1->get_selected_rows
            IMPORTING
              et_index_rows = lt_rows.
          IF lt_rows IS INITIAL.
            MESSAGE 'Please select a row.'(003) TYPE 'I'.
            EXIT.
          ELSEIF lines( lt_rows ) > 1.
            MESSAGE 'Please select only one row.'(004) TYPE 'I'.
            EXIT.
          ENDIF.
          CALL METHOD cl_gui_cfw=>flush.
          IF sy-subrc NE 0.
            CALL FUNCTION 'POPUP_TO_INFORM'
              EXPORTING
                titel = g_repid
                txt2  = sy-subrc
                txt1  = 'Error in Flush'(500).
          ELSE.
            FREE MEMORY ID 'ABCD'.
            READ TABLE lt_rows INDEX 1 INTO l_row.
            READ TABLE itab INDEX l_row-index INTO sel_row.
            CREATE OBJECT ob .
            IF ob IS BOUND.
              TRY.
                  CALL METHOD ob->retry_log( message_id = sel_row-zmessageid response = abap_true ).
*              Authorization changes V-DEVEER
                CATCH zcx_http_client_failed INTO lv_textid.
                  lv_text2 = lv_textid->if_t100_message~t100key.
                  MESSAGE ID lv_text2-msgid TYPE 'I' NUMBER lv_text2-msgno.
                  EXIT.
              ENDTRY.
*             end of changes V-DEVEER
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDMETHOD.                           "handle_user_command
*-----------------------------------------------------------------
  ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION
*
* lcl_event_receiver (Implementation)
*===================================================================

*---------------------------------------------------------------------*
*       FORM EXIT_PROGRAM                                             *
*---------------------------------------------------------------------*
  FORM exit_program.

    CALL METHOD custom_container1->free.

    CALL METHOD cl_gui_cfw=>flush.
    IF sy-subrc NE 0.
* add your handling, for example
      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          titel = g_repid
          txt2  = sy-subrc
          txt1  = 'Error in Flush'(500).
    ENDIF.
    IF ok_code = 'EXIT'.
      LEAVE PROGRAM.
    ELSEIF ok_code = 'BACK'.
      LEAVE TO TRANSACTION 'ZREST_UTIL'.
*      CALL METHOD grid1->refresh_table_display.
*      CALL METHOD grid1->free.
*      CALL SELECTION-SCREEN 1000.
    ENDIF.
  ENDFORM.                    "exit_program
*&---------------------------------------------------------------------*
*&      Module  PBO_100  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  MODULE pbo_100 OUTPUT.
    SET PF-STATUS 'MAIN100'.
    SET TITLEBAR 'MAIN100'.
    g_repid = sy-repid.
    IF custom_container1 IS INITIAL OR grid1 IS INITIAL.
* Creating Docking Container and grid
      PERFORM create_object.
    ENDIF.

* Filling the fieldcatalog table
    PERFORM fieldcatatalog.
* Setting layout
    PERFORM layout.
*  Displaying the output
    PERFORM display_output.


    CREATE OBJECT event_receiver.
    SET HANDLER event_receiver->handle_user_command FOR grid1.
    SET HANDLER event_receiver->handle_toolbar FOR grid1.
* Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    CALL METHOD grid1->set_toolbar_interactive.
    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = grid1.


  ENDMODULE.                 " PBO_100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PAI_100  OUTPUT
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  MODULE pai_100 INPUT.
    DATA: lt_rows     TYPE lvc_t_row,
          l_row       TYPE lvc_s_row,
          sel_row     LIKE LINE OF itab,
          message_val TYPE string,
          sel_tab     TYPE TABLE OF ty.

    CASE ok_code.
      WHEN 'EXIT' OR 'BACK'.
        PERFORM exit_program.
      WHEN 'REFRESH'.
*        lo_report->get_data( ).
*       Added for VSTF 2163894 / DGDK903444
*        CALL METHOD cl_gui_cfw=>flush.
*       End of addition for VSTF 2163894 / DGDK903444
*       Commented for VSTF 2163894 / DGDK903444
*        CALL METHOD custom_container1->free.
*        PERFORM create_object.
* Filling the fieldcatalog table
*        PERFORM fieldcatatalog.
* Setting layout
*        PERFORM layout.
* Displaying the output
*        PERFORM display_output.
*        End of changes for VSTF 2163894 / DGDK903444
    ENDCASE.
    CLEAR ok_code.
  ENDMODULE.                    "pai_100 INPUT

*&---------------------------------------------------------------------*
*&      Form  create_object
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
  FORM create_object .

    IF custom_container1 IS INITIAL.
* Creating Docking Container
      CREATE OBJECT custom_container1
        EXPORTING
          container_name              = cont_on_main
        EXCEPTIONS
          cntl_error                  = 1
          cntl_system_error           = 2
          create_error                = 3
          lifetime_error              = 4
          lifetime_dynpro_dynpro_link = 5.
      IF sy-subrc NE 0.
        CALL FUNCTION 'POPUP_TO_INFORM'
          EXPORTING
            titel = g_repid
            txt2  = sy-subrc
            txt1  = 'The control could not be created'(510).
      ENDIF.
    ENDIF.
    IF grid1 IS INITIAL.
* create an instance of alv control
      CREATE OBJECT grid1
        EXPORTING
          i_parent = cl_gui_custom_container=>screen0.
    ENDIF.
  ENDFORM.                    "create_object

*&---------------------------------------------------------------------*
*&      FORM create_fieldcat
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  FORM create_fieldcat .
* Filling the fieldcatalog table
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'ZREST_MONITOR'
      CHANGING
        ct_fieldcat            = fieldcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
  ENDFORM. " create_fieldcat

*&---------------------------------------------------------------------*
*&     Form display_output
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  FORM display_output .


* Displaying the output
    w_layout-sel_mode = 'A'.
    CALL METHOD grid1->set_table_for_first_display
      EXPORTING
        is_variant                    = w_variant
        i_save                        = 'A'
        is_layout                     = w_layout
      CHANGING
        it_outtab                     = itab
        it_fieldcatalog               = fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.


  ENDFORM. " display_output

*&---------------------------------------------------------------------*
*&      FORM Fieldcatalog
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  FORM fieldcatatalog .
    DATA: ls_fcat TYPE lvc_s_fcat.
    REFRESH: fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Corelation Id'.
    ls_fcat-fieldname  = 'ZMESSAGEID'.
    ls_fcat-ref_table  = 'WT_CUST'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Httpstatus'.
    ls_fcat-fieldname  = 'HTTPSTATUS'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '5'.
    ls_fcat-col_pos    = '2'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Operation'.
    ls_fcat-fieldname  = 'METHOD'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '5'.
    ls_fcat-col_pos    = '1'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Status'.
    ls_fcat-fieldname  = 'STATUS'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '5'.
    ls_fcat-col_pos    = '1'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Execution date'.
    ls_fcat-fieldname  = 'ZEXEDATE'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '6'.
    ls_fcat-datatype = 'DATS'.
    ls_fcat-inttype = 'D'.
    ls_fcat-intlen = '000008'.
    ls_fcat-dd_outlen = '000010'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Execution Time'.
    ls_fcat-fieldname  = 'ZEXETIME'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '7'.
    ls_fcat-datatype = 'TIMS'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Completed date'.
    ls_fcat-fieldname  = 'ZCOMPDATE'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '8'.
    ls_fcat-datatype = 'DATS'.
    ls_fcat-inttype = 'D'.
    ls_fcat-intlen = '000008'.
    ls_fcat-dd_outlen = '000010'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Completed time'.
    ls_fcat-fieldname  = 'ZCOMPTIME'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '9'.
    ls_fcat-datatype = 'TIMS'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Time-ms'.
    ls_fcat-fieldname  = 'ZDURATION'.
*    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '9'.
*    ls_fcat-datatype = 'TIMS'.
    ls_fcat-decimals_o = 0.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Retry Attempt'.
    ls_fcat-fieldname  = 'RERTYNUM'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '11'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Retry Date'.
    ls_fcat-fieldname  = 'ZRETRYDATE'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '10'.
    ls_fcat-datatype = 'DATS'.
    ls_fcat-inttype = 'D'.
    ls_fcat-intlen = '000008'.
    ls_fcat-dd_outlen = '000010'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Retry Time'.
    ls_fcat-fieldname  = 'ZRETRYTIME'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '11'.
    ls_fcat-datatype = 'TIMS'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Host'.
    ls_fcat-fieldname  = 'HOST'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '13'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'URI'.
    ls_fcat-fieldname  = 'URI'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '13'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Interface Id'.
    ls_fcat-fieldname  = 'INTERFACE_ID'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '14'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.


    ls_fcat-reptext    = 'Calling Program'.
    ls_fcat-fieldname  = 'CALLING_PROGRAM'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '16'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Calling Method'.
    ls_fcat-fieldname  = 'CALLING_METHOD'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '15'.
    ls_fcat-col_pos    = '17'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.



    ls_fcat-reptext    = 'User Alias'.
    ls_fcat-fieldname  = 'ZUSER'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '10'.
    ls_fcat-col_pos    = '19'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Submitted Date'.
    ls_fcat-fieldname  = 'SUBMIT_DATE'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '10'.
    ls_fcat-col_pos    = '20'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Submitted Time'.
    ls_fcat-fieldname  = 'SUBMIT_TIME'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '10'.
    ls_fcat-col_pos    = '21'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Business Identifier'.
    ls_fcat-fieldname  = 'BUSINESSID'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '10'.
    ls_fcat-col_pos    = '21'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

*    v-javeda - MS2K948543 Adding delete indicator fields

    ls_fcat-reptext    = 'Delete Indicator'.
    ls_fcat-fieldname  = 'ZDELETE'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '2'.
    ls_fcat-col_pos    = '22'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Deleted by User'.
    ls_fcat-fieldname  = 'DELETEUSER'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '12'.
    ls_fcat-col_pos    = '23'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Deleted Date'.
    ls_fcat-fieldname  = 'DELETEDATE'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '10'.
    ls_fcat-col_pos    = '24'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

    ls_fcat-reptext    = 'Deleted time'.
    ls_fcat-fieldname  = 'DELETETIME'.
    ls_fcat-ref_table  = 'WT_CUST'.
    ls_fcat-outputlen  = '6'.
    ls_fcat-col_pos    = '25'.
    APPEND ls_fcat TO fieldcat.
    CLEAR: ls_fcat.

  ENDFORM.                    "fieldcatatalog

*&---------------------------------------------------------------------*
*&     Form layout
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
  FORM layout .
    LOOP AT itab INTO wa.
      IF wa-httpstatus >= 300 OR wa-httpstatus <= 100.
        wa-lights  = '1'.
      ELSE.
        wa-lights  = '3'.
      ENDIF.
      IF wa-httpstatus = 0.
        wa-lights  = '2'.

      ENDIF.
      MODIFY itab FROM wa TRANSPORTING lights.
    ENDLOOP.

    w_layout-excp_fname = 'LIGHTS'.
    w_layout-cwidth_opt = 'X'.
  ENDFORM.                    "layout
