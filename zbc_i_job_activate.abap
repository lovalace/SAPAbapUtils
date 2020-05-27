CLASS CallJob DEFINITION.
 PUBLIC SECTION.
DATA :ls_tbtco TYPE tbtco.
DATA: gv_yday  TYPE sy-datum,
      gv_jtime TYPE sy-uzeit,
      gv_jnr   TYPE  tbtcp-jobcount,
      gv_datum LIKE sy-datum,
      gv_rlsd  TYPE char1.

  METHODS:Constructor.
  METHODS: CheckJob IMPORTING jobname TYPE jobname
           RETURNING VALUE(r_Val) TYPE boolean,
           job_open IMPORTING jobname TYPE TBTCJOB-JOBNAME,
           job_close IMPORTING jobname TYPE TBTCJOB-JOBNAME,
           submit IMPORTING jobname TYPE TBTCJOB-JOBNAME
                            variantName TYPE VARIANT OPTIONAL.
ENDCLASS.

CLASS CallJob IMPLEMENTATION.
 METHOD Constructor .
  gv_datum = sy-datum.
  gv_yday = sy-datum - 1.
  gv_jtime = sy-uzeit + 45.
 ENDMETHOD.
 METHOD: CheckJob.
   CLEAR: ls_tbtco.
   SELECT SINGLE * INTO ls_tbtco  FROM tbtco
                 WHERE jobname EQ jobname
                   AND SDLSTRTDT BETWEEN me->gv_yday AND me->gv_datum
                   AND  status EQ 'R'.
   r_val = COND #( WHEN ls_tbtco IS NOT INITIAL THEN abap_False ELSE abap_true ).
 ENDMETHOD.

 METHOD: job_open.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        jobname          = jobname
        sdlstrtdt        = gv_datum
        sdlstrttm        = gv_jtime
      IMPORTING
        jobcount         = gv_jnr
      EXCEPTIONS
        cant_create_job  = 1
        invalid_job_data = 2
        jobname_missing  = 3
        OTHERS           = 4.
    IF sy-subrc <> 0.
      WRITE: 'job_open' && sy-subrc.
    ENDIF.
 ENDMETHOD.
 METHOD job_close.
     CALL FUNCTION 'JOB_CLOSE'
      EXPORTING
        jobcount             = gv_jnr
        jobname              = jobname
        sdlstrtdt            = gv_datum
        sdlstrttm            = gv_jtime
        strtimmed            = 'X'
      IMPORTING
        job_was_released     = gv_rlsd
      EXCEPTIONS
        cant_start_immediate = 1
        invalid_startdate    = 2
        jobname_missing      = 3
        job_close_failed     = 4
        job_nosteps          = 5
        job_notex            = 6
        lock_failed          = 7
        invalid_target       = 8
        OTHERS               = 9.
    IF sy-subrc <> 0 .
      WRITE: 'job_close' && sy-subrc.
    ENDIF.
 ENDMETHOD.
 METHOD submit.
      SUBMIT zcustom_program VIA JOB jobname NUMBER gv_jnr USING SELECTION-SET variantName
       AND RETURN.
 ENDMETHOD.
ENDCLASS.
