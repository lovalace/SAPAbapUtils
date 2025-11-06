REPORT zdemo001.

 DATA:
  lv_jobname    TYPE tbtcjob-jobname, "JOB Name
  lv_jobcount   TYPE tbtcjob-jobcount,
  lv_auth_user  TYPE sy-uname VALUE 'EKARABULUT', " User who will run the job
  lv_report     TYPE sy-repid VALUE 'ZEK_DEMO00002',
  lv_variant    TYPE RALDB-VARIANT VALUE 'TEST_VARI',
  lt_rsparams   TYPE  TABLE OF RSPARAMS,
  lt_varit      TYPE TABLE OF varit.

START-OF-SELECTION.

   lv_jobname = |ZJOB_NAME_{ sy-uzeit }|. "Dynamic JobName
  " 1. Create the job (Header)
  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      jobname          = lv_jobname
    IMPORTING
      jobcount         = lv_jobcount
    EXCEPTIONS
      cant_create_job  = 1
      invalid_job_data = 2
      jobname_missing  = 3
      OTHERS           = 4.

   "Add Variant Parameters.
   lt_rsparams = VALUE #( ( selname = '_LGORT'  kind = 'S' sign = 'I' option = 'EQ' low = '2025' )
                          ( selname = '_MATNR'  kind = 'S' sign = 'I' option = 'EQ' low = 'CRDLP' )
                         ).
   DATA(Vari_desc)  =  VALUE varid( report = lv_report
                                    variant = lv_variant ).


  "Change Exist Variant
   CALL FUNCTION 'RS_CHANGE_CREATED_VARIANT'
  EXPORTING
    CURR_REPORT              = lv_report
    curr_variant             = lv_variant
    VARI_DESC                = Vari_desc
  TABLES
    vari_contents       = lt_rsparams.

  " 2. Add the step to the job (Execute report)
  CALL FUNCTION 'JOB_SUBMIT'
    EXPORTING
      jobcount              = lv_jobcount
      jobname               = lv_jobname
      report                = lv_report
      authcknam             = lv_auth_user  "The user under which the step will run
      variant               = lv_variant
    EXCEPTIONS
      bad_reportname        = 1
      bad_variantname       = 2
      invalid_jobdata       = 3
      jobname_missing       = 4
      job_notex             = 5
      job_submit_failed     = 6
      lock_failed           = 7
      program_missing       = 8
      prog_auth_check_fail  = 9  " Authorization error
      variant_does_not_exist = 10
      OTHERS                = 11.


  " 3. Release the job (To run scheduled or immediately)
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      jobcount              = lv_jobcount
      jobname               = lv_jobname
      strtimmed             = 'X'  " 'X' Start immediately
    EXCEPTIONS
      cant_start_immediate  = 1
      invalid_startdate     = 2
      jobname_missing       = 3
      job_close_failed      = 4
      job_nosteps           = 5
      job_notex             = 6
      lock_failed           = 7
      OTHERS                = 8.

  ##todo_other_things.
