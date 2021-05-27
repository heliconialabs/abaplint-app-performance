FUNCTION ZBUGTRACKER_WRITE_DOCUMENT.

* THIS FILE IS GENERATED. NEVER CHANGE IT MANUALLY, PLEASE!

  CALL FUNCTION 'CHANGEDOCUMENT_OPEN'
    EXPORTING
      OBJECTCLASS             = 'ZBUGTRACKER'
      OBJECTID                = OBJECTID
      PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
      PLANNED_OR_REAL_CHANGES = PLANNED_OR_REAL_CHANGES
    EXCEPTIONS
      SEQUENCE_INVALID        = 1
      OTHERS                  = 2.

  CASE SY-SUBRC.
    WHEN 0.                                   "OK.
    WHEN 1. MESSAGE A600 WITH 'SEQUENCE INVALID'.
    WHEN 2. MESSAGE A600 WITH 'OPEN ERROR'.
  ENDCASE.

  IF UPD_ZBT_ATTACHMENT NE SPACE.
    IF ( XZBT_ATTACHMENT[] IS INITIAL ) AND
       ( YZBT_ATTACHMENT[] IS INITIAL ).
      UPD_ZBT_ATTACHMENT = SPACE.
    ENDIF.
  ENDIF.

  IF UPD_ZBT_ATTACHMENT NE SPACE.
    CALL FUNCTION 'CHANGEDOCUMENT_MULTIPLE_CASE'
      EXPORTING
        TABLENAME              = 'ZBT_ATTACHMENT'
        CHANGE_INDICATOR       = UPD_ZBT_ATTACHMENT
        DOCU_DELETE            = ''
        DOCU_INSERT            = ''
        DOCU_DELETE_IF         = 'X'
        DOCU_INSERT_IF         = ''
      TABLES
        TABLE_OLD              = YZBT_ATTACHMENT
        TABLE_NEW              = XZBT_ATTACHMENT
      EXCEPTIONS
        NAMETAB_ERROR          = 1
        OPEN_MISSING           = 2
        POSITION_INSERT_FAILED = 3
        OTHERS                 = 4.

    CASE SY-SUBRC.
      WHEN 0.                                "OK.
      WHEN 1. MESSAGE A600 WITH 'NAMETAB-ERROR'.
      WHEN 2. MESSAGE A600 WITH 'OPEN MISSING'.
      WHEN 3. MESSAGE A600 WITH 'INSERT ERROR'.
      WHEN 4. MESSAGE A600 WITH 'MULTIPLE ERROR'.
    ENDCASE.
  ENDIF.

  IF UPD_ZBT_BUG NE SPACE.
    IF ( O_OLD_BUG IS INITIAL ) AND
       (  N_ZBT_BUG IS INITIAL ).
      UPD_ZBT_BUG = SPACE.
    ENDIF.
  ENDIF.

  IF UPD_ZBT_BUG NE SPACE.
    CALL FUNCTION 'CHANGEDOCUMENT_SINGLE_CASE'
      EXPORTING
        TABLENAME              = 'ZBT_BUG'
        WORKAREA_OLD           = O_OLD_BUG
        WORKAREA_NEW           = N_ZBT_BUG
        CHANGE_INDICATOR       = UPD_ZBT_BUG
        DOCU_DELETE            = ''
        DOCU_INSERT            = ''
        DOCU_DELETE_IF         = 'X'
        DOCU_INSERT_IF         = ''
      EXCEPTIONS
        NAMETAB_ERROR          = 1
        OPEN_MISSING           = 2
        POSITION_INSERT_FAILED = 3
        OTHERS                 = 4.

    CASE SY-SUBRC.
      WHEN 0.                                "OK.
      WHEN 1. MESSAGE A600 WITH 'NAMETAB-ERROR'.
      WHEN 2. MESSAGE A600 WITH 'OPEN MISSING'.
      WHEN 3. MESSAGE A600 WITH 'INSERT ERROR'.
      WHEN 4. MESSAGE A600 WITH 'SINGLE ERROR'.
    ENDCASE.
  ENDIF.

  IF UPD_ZBT_BUGCOMMENT NE SPACE.
    IF ( XZBT_BUGCOMMENT IS INITIAL ) AND
       ( YZBT_BUGCOMMENT IS INITIAL ).
      UPD_ZBT_BUGCOMMENT = SPACE.
    ENDIF.
  ENDIF.

  IF UPD_ZBT_BUGCOMMENT NE SPACE.
    CALL FUNCTION 'CHANGEDOCUMENT_MULTIPLE_CASE2'
      EXPORTING
        TABLENAME              = 'ZBT_BUGCOMMENT'
        CHANGE_INDICATOR       = UPD_ZBT_BUGCOMMENT
        DOCU_DELETE            = ''
        DOCU_INSERT            = ''
        DOCU_DELETE_IF         = 'X'
        DOCU_INSERT_IF         = ''
        TABLE_OLD              = YZBT_BUGCOMMENT
        TABLE_NEW              = XZBT_BUGCOMMENT
      EXCEPTIONS
        NAMETAB_ERROR          = 1
        OPEN_MISSING           = 2
        POSITION_INSERT_FAILED = 3
        OTHERS                 = 4.

    CASE SY-SUBRC.
      WHEN 0.                                "OK.
      WHEN 1. MESSAGE A600 WITH 'NAMETAB-ERROR'.
      WHEN 2. MESSAGE A600 WITH 'OPEN MISSING'.
      WHEN 3. MESSAGE A600 WITH 'INSERT ERROR'.
      WHEN 4. MESSAGE A600 WITH 'MULTIPLE ERROR'.
    ENDCASE.
  ENDIF.

  IF UPD_ZBT_BUGSECCION NE SPACE.
    IF ( XZBT_BUGSECCION[] IS INITIAL ) AND
       ( YZBT_BUGSECCION[] IS INITIAL ).
      UPD_ZBT_BUGSECCION = SPACE.
    ENDIF.
  ENDIF.

  IF UPD_ZBT_BUGSECCION NE SPACE.
    CALL FUNCTION 'CHANGEDOCUMENT_MULTIPLE_CASE'
      EXPORTING
        TABLENAME              = 'ZBT_BUGSECCION'
        CHANGE_INDICATOR       = UPD_ZBT_BUGSECCION
        DOCU_DELETE            = ''
        DOCU_INSERT            = ''
        DOCU_DELETE_IF         = 'X'
        DOCU_INSERT_IF         = ''
      TABLES
        TABLE_OLD              = YZBT_BUGSECCION
        TABLE_NEW              = XZBT_BUGSECCION
      EXCEPTIONS
        NAMETAB_ERROR          = 1
        OPEN_MISSING           = 2
        POSITION_INSERT_FAILED = 3
        OTHERS                 = 4.

    CASE SY-SUBRC.
      WHEN 0.                                "OK.
      WHEN 1. MESSAGE A600 WITH 'NAMETAB-ERROR'.
      WHEN 2. MESSAGE A600 WITH 'OPEN MISSING'.
      WHEN 3. MESSAGE A600 WITH 'INSERT ERROR'.
      WHEN 4. MESSAGE A600 WITH 'MULTIPLE ERROR'.
    ENDCASE.
  ENDIF.

  IF UPD_ZBT_PROGRAMS NE SPACE.
    IF ( XZBT_PROGRAMS[] IS INITIAL ) AND
       ( YZBT_PROGRAMS[] IS INITIAL ).
      UPD_ZBT_PROGRAMS = SPACE.
    ENDIF.
  ENDIF.

  IF UPD_ZBT_PROGRAMS NE SPACE.
    CALL FUNCTION 'CHANGEDOCUMENT_MULTIPLE_CASE'
      EXPORTING
        TABLENAME              = 'ZBT_PROGRAMS'
        CHANGE_INDICATOR       = UPD_ZBT_PROGRAMS
        DOCU_DELETE            = ''
        DOCU_INSERT            = ''
        DOCU_DELETE_IF         = 'X'
        DOCU_INSERT_IF         = ''
      TABLES
        TABLE_OLD              = YZBT_PROGRAMS
        TABLE_NEW              = XZBT_PROGRAMS
      EXCEPTIONS
        NAMETAB_ERROR          = 1
        OPEN_MISSING           = 2
        POSITION_INSERT_FAILED = 3
        OTHERS                 = 4.

    CASE SY-SUBRC.
      WHEN 0.                                "OK.
      WHEN 1. MESSAGE A600 WITH 'NAMETAB-ERROR'.
      WHEN 2. MESSAGE A600 WITH 'OPEN MISSING'.
      WHEN 3. MESSAGE A600 WITH 'INSERT ERROR'.
      WHEN 4. MESSAGE A600 WITH 'MULTIPLE ERROR'.
    ENDCASE.
  ENDIF.

  IF UPD_ZBT_TRANSPORTER NE SPACE.
    IF ( XZBT_TRANSPORTER[] IS INITIAL ) AND
       ( YZBT_TRANSPORTER[] IS INITIAL ).
      UPD_ZBT_TRANSPORTER = SPACE.
    ENDIF.
  ENDIF.

  IF UPD_ZBT_TRANSPORTER NE SPACE.
    CALL FUNCTION 'CHANGEDOCUMENT_MULTIPLE_CASE'
      EXPORTING
        TABLENAME              = 'ZBT_TRANSPORTER'
        CHANGE_INDICATOR       = UPD_ZBT_TRANSPORTER
        DOCU_DELETE            = ''
        DOCU_INSERT            = ''
        DOCU_DELETE_IF         = 'X'
        DOCU_INSERT_IF         = ''
      TABLES
        TABLE_OLD              = YZBT_TRANSPORTER
        TABLE_NEW              = XZBT_TRANSPORTER
      EXCEPTIONS
        NAMETAB_ERROR          = 1
        OPEN_MISSING           = 2
        POSITION_INSERT_FAILED = 3
        OTHERS                 = 4.

    CASE SY-SUBRC.
      WHEN 0.                                "OK.
      WHEN 1. MESSAGE A600 WITH 'NAMETAB-ERROR'.
      WHEN 2. MESSAGE A600 WITH 'OPEN MISSING'.
      WHEN 3. MESSAGE A600 WITH 'INSERT ERROR'.
      WHEN 4. MESSAGE A600 WITH 'MULTIPLE ERROR'.
    ENDCASE.
  ENDIF.

  IF UPD_ICDTXT_ZBUGTRACKER NE SPACE.
     CALL FUNCTION 'CHANGEDOCUMENT_TEXT_CASE'
       TABLES
         TEXTTABLE              = ICDTXT_ZBUGTRACKER
       EXCEPTIONS
         OPEN_MISSING           = 1
         POSITION_INSERT_FAILED = 2
         OTHERS                 = 3.

    CASE SY-SUBRC.
      WHEN 0.                                "OK.
      WHEN 1. MESSAGE A600 WITH 'OPEN MISSING'.
      WHEN 2. MESSAGE A600 WITH 'INSERT ERROR'.
      WHEN 3. MESSAGE A600 WITH 'TEXT ERROR'.
    ENDCASE.
  ENDIF.

  CALL FUNCTION 'CHANGEDOCUMENT_CLOSE'
    EXPORTING
      OBJECTCLASS             = 'ZBUGTRACKER'
      OBJECTID                = OBJECTID
      DATE_OF_CHANGE          = UDATE
      TIME_OF_CHANGE          = UTIME
      TCODE                   = TCODE
      USERNAME                = USERNAME
      OBJECT_CHANGE_INDICATOR = OBJECT_CHANGE_INDICATOR
      NO_CHANGE_POINTERS      = NO_CHANGE_POINTERS
    EXCEPTIONS
      HEADER_INSERT_FAILED    = 1
      OBJECT_INVALID          = 2
      OPEN_MISSING            = 3
      NO_POSITION_INSERTED    = 4
      OTHERS                  = 5.

  CASE SY-SUBRC.
    WHEN 0.                                   "OK.
    WHEN 1. MESSAGE A600 WITH sy-msgv1.
    WHEN 2. MESSAGE A600 WITH 'OBJECT INVALID'.
    WHEN 3. MESSAGE A600 WITH 'OPEN MISSING'.
*    WHEN 4. MESSAGE A600 WITH 'NO_POSITION_INSERTED'.
* do not abort, if positions are not inserted!!!
    WHEN 5. MESSAGE A600 WITH 'CLOSE ERROR'.
  ENDCASE.

ENDFUNCTION.