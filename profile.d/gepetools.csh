# Set necessary variables for a job.

if ( ! $?JOB_ID ) then
  set ppid="`ps -p $$ -o ppid=`"
  set sge_process="`ps -p $ppid -o cmd= | grep sge_shepherd`"
  if ( ${%sge_process} > 0 ) then
    setenv JOB_ID "`echo $sge_process | awk '{ print $1 }' | cut -d'-' -f2`"
  endif
endif

if ( $?JOB_ID ) then
    if ( -f "${TMPDIR}/machines.mpich" ) setenv MPICH_HOSTS ${TMPDIR}/machines.mpich
    if ( -f "${TMPDIR}/machines.mvapich" ) setenv MVAPICH_HOSTS ${TMPDIR}/machines.mvapich
    if ( -f "${TMPDIR}/machines.mvapich2" ) setenv MVAPICH2_HOSTS ${TMPDIR}/machines.mvapich2
    if ( -f "${TMPDIR}/machines.mpich2" ) setenv MPICH2_HOSTS ${TMPDIR}/machines.mpich2
    if ( -f "${TMPDIR}/machines.hpmpi" ) setenv HPMPI_HOSTS ${TMPDIR}/machines.hpmpi
    if ( -f "${TMPDIR}/machines.intelmpi" ) setenv INTELMPI_HOSTS ${TMPDIR}/machines.intelmpi
endif
