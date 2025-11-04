REPORT zdemo001.

  DATA:
  lv_jobname    TYPE tbtcjob-jobname VALUE 'Z_SAMPLE_JOB', "JOB Name
  lv_jobcount   TYPE tbtcjob-jobcount,
  lv_auth_user  TYPE sy-uname VALUE 'USERNAE', " User who will run the job
  lv_report     TYPE sy-repid VALUE 'ZSD_R_STOCK'.

START-OF-SELECTION.

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


  " 2. Add the step to the job (Execute report)
  CALL FUNCTION 'JOB_SUBMIT'
    EXPORTING
      jobcount              = lv_jobcount
      jobname               = lv_jobname
      report                = lv_report
      authcknam             = lv_auth_user  "The user under which the step will run
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
