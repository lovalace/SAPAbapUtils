REPORT zsd_r_job_activate.
INCLUDE zsd_i_job_activate.


START-OF-SELECTION.

data(lo_class) = NEW callJob( ).
*--------------------------------------------------------------*
DEFINE CallJob.
IF lo_class->checkjob( &1 ). "Çalışan job kontrolü
lo_class->job_open( &1 ).    "Job oluştur
lo_class->submit( jobname = &1 variantName = &2  ).     "Job ta çalışacak programı çağır
lo_class->job_close( &1  ).  "Job i kapat.
ENDIF.
END-OF-DEFINITION.
*--------------------------------------------------------------*

calljob 'job_1' 'Variant_1'.      
calljob 'job_2' 'Variant_2'.       
calljob 'job_3' 'Variant_3'. 
