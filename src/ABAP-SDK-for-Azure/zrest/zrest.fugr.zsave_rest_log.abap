FUNCTION zsave_rest_log.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(FRAMEWORK_CLASS) TYPE REF TO  ZCL_REST_FRAMEWORK
*"     REFERENCE(UPDATE_TASK) TYPE  CHAR1
*"----------------------------------------------------------------------
*                       MAIN LOG                                        *
*"----------------------------------------------------------------------*
  object = framework_class.
*"----------------------------------------------------------------------*
  PERFORM set_log.
*"----------------------------------------------------------------------*
  PERFORM set_requests.
*"----------------------------------------------------------------------*
  PERFORM set_responses.
*"----------------------------------------------------------------------*
  PERFORM set_string_data.
*"----------------------------------------------------------------------*
  PERFORM set_payload.
*"----------------------------------------------------------------------*
* Update the database for further processign and analysis
*"----------------------------------------------------------------------*
  retry_log-mandt       = sy-mandt.
  retry_log-zmessageid  = lwa_payload-messageid.
  retry_log-retry_num   = lwa_payload-retry_num.
  retry_log-retrydate   = gwa_log-zretrydate.
  retry_log-retrytime   = gwa_log-zretrytime.

*// Set lock on the tables
  DATA: lv_message   TYPE char100,
        lv_messageid TYPE char50,
        lv_return    TYPE char1.

  CONSTANTS: lc_object     TYPE balobj_d  VALUE 'Z_REST_LOG',
             lc_object_sub TYPE balsubobj VALUE 'Z_REST_SUB'.

  DATA: lt_alog   TYPE zrt_applog_message,
        lw_alog   TYPE zrest_applog_message,
        lv_extnum TYPE balnrext,
        lv_jobcnt TYPE tbtcm-jobcount,
        lv_jobnme TYPE tbtcm-jobname.

  CLEAR: lv_messageid, lv_return, lv_message, lt_alog, lv_extnum,
         lv_jobcnt, lv_jobnme, lw_alog.

  lv_messageid = lwa_payload-messageid.
  CONCATENATE 'Table lock failed for'(001) lv_messageid
  INTO lv_message SEPARATED BY space.

  CALL FUNCTION 'ENQUEUE_EZ_ZREST_PAYLOAD'
    EXPORTING
      mandt          = sy-mandt
      messageid      = lwa_payload-messageid
      status         = lwa_payload-status
      retry_num      = lwa_payload-retry_num
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE lv_message TYPE 'I'.
    lw_alog-zmsgv3 = 'ZREST_MO_PAYLOAD'.
    lv_return = 'X'.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_ZREST_MONITOR'
    EXPORTING
      mandt          = sy-mandt
      zmessageid     = gwa_log-zmessageid
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE lv_message TYPE 'I'.
    lw_alog-zmsgv3 = 'ZREST_MONITOR'.
    lv_return = 'X'.
  ENDIF.

  CALL FUNCTION 'ENQUEUE_EZ_ZREST_RETRY'
    EXPORTING
      mandt          = sy-mandt
      zmessageid     = retry_log-zmessageid
      retry_num      = retry_log-retry_num
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    MESSAGE lv_message TYPE 'I'.
    lw_alog-zmsgv3 = 'ZREST_RETRIES'.
    lv_return = 'X'.
  ENDIF.
*// If locking failed write to Application log and do not proceed
  IF lv_return = 'X'.
    IF sy-batch IS NOT INITIAL.
      CALL FUNCTION 'GET_JOB_RUNTIME_INFO'
        IMPORTING
          jobcount        = lv_jobcnt
          jobname         = lv_jobnme
        EXCEPTIONS
          no_runtime_info = 1
          OTHERS          = 2.
      IF sy-subrc = 0.
        CONCATENATE lv_jobcnt lv_jobnme INTO lv_extnum SEPARATED BY '_'.
      ENDIF.
    ELSE.
      lv_extnum = sy-cprog.
    ENDIF.
    lw_alog-zmsgty = 'E'.
    lw_alog-zmsgv1 = text-002.
    lw_alog-zmsgv2 = retry_log-zmessageid.

    APPEND lw_alog TO lt_alog.

*// Call the application Log
    CALL METHOD zcl_rest_utility_class=>write_application_log
      EXPORTING
        iv_object    = lc_object
        iv_subobject = lc_object_sub
        iv_extnumber = lv_extnum
        it_message   = lt_alog.
    RETURN.
  ENDIF.

  IF update_task EQ space.
    CALL FUNCTION 'ZUPDATES_TABLES'
      EXPORTING
        payload = lwa_payload
        monitor = gwa_log
        retry   = retry_log.
  ELSE.
    CALL FUNCTION 'ZUPDATES_TABLES_UPDATE'
      EXPORTING
        payload = lwa_payload
        monitor = gwa_log
        retry   = retry_log.
  ENDIF.

*// Dequeue the tables
  CALL FUNCTION 'DEQUEUE_EZ_ZREST_PAYLOAD'
    EXPORTING
      mandt     = sy-mandt
      messageid = lwa_payload-messageid
      status    = lwa_payload-status
      retry_num = lwa_payload-retry_num.

  CALL FUNCTION 'DEQUEUE_EZ_ZREST_MONITOR'
    EXPORTING
      mandt      = sy-mandt
      zmessageid = gwa_log-zmessageid.

  CALL FUNCTION 'DEQUEUE_EZ_ZREST_RETRY'
    EXPORTING
      mandt      = sy-mandt
      zmessageid = retry_log-zmessageid
      retry_num  = retry_log-retry_num.

  CLEAR lwa_payload. "v-javeda | MS2K948978
ENDFUNCTION.
