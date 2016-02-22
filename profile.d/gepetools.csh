# Set necessary variables for a job.

if ( ! $?JOB_ID ) then
  set ppid="`ps -p $$ -o ppid=`"
  set sge_process="`ps -p $ppid -o cmd= | grep sge_shepherd`"
  if ( ${%sge_process} > 0 ) then
    setenv JOB_ID "`echo $sge_process | awk '{ print $1 }' | cut -d'-' -f2`"
    # Path is hardcoded because $SGE_ROOT could not be set yet
    set hardcoded_sgeroot="/path/to/sgeroot"
    set ENVFILE="$hardcoded_sgeroot/spool/`hostname -s`/active_jobs/$JOB_ID.1/environment"

    # set environment variables for interactive session
    if ( -r $ENVFILE ) then
      eval `egrep -v "^(PATH|LD_LIBRARY_PATH|DISPLAY)" $ENVFILE | sed 's/^/export /g'`

      set NP="`awk -F'=' '/^PATH/ { print $2 }' $ENVFILE`"
      set NLLP="`awk -F'=' '/^LD_LIBRARY_PATH/ { print $2 }' $ENVFILE`"

      if ( $NP != "" ) then
        set PATH="$NP:$PATH"
      endif

      if ( $NLLP != "" ) then
        set LD_LIBRARY_PATH="$NLLP:$LD_LIBRARY_PATH"
      endif

      setenv PATH "$PATH"
      setenv LD_LIBRARY_PATH "$LD_LIBRARY_PATH"
    endif
  endif
endif

if ( $?JOB_ID ) then
    if ( -f "${TMPDIR}/machines.mpich" ) setenv MPICH_HOSTS ${TMPDIR}/machines.mpich
    if ( -f "${TMPDIR}/machines.mvapich" ) setenv MVAPICH_HOSTS ${TMPDIR}/machines.mvapich
    if ( -f "${TMPDIR}/machines.mvapich2" ) setenv MVAPICH2_HOSTS ${TMPDIR}/machines.mvapich2
    if ( -f "${TMPDIR}/machines.mpich2" ) setenv MPICH2_HOSTS ${TMPDIR}/machines.mpich2
    if ( -f "${TMPDIR}/machines.hpmpi" ) setenv HPMPI_HOSTS ${TMPDIR}/machines.hpmpi
    if ( -f "${TMPDIR}/machines.intelmpi" ) setenv INTELMPI_HOSTS ${TMPDIR}/machines.intelmpi

    if ( $?PE_PROCESSES_PER_RANK ) then
      setenv OMP_NUM_THREADS $PE_PROCESSES_PER_RANK
      setenv MKL_NUM_THREADS $PE_PROCESSES_PER_RANK
      setenv OPENBLAS_NUM_THREADS $PE_PROCESSES_PER_RANK
    else if ( $?NSLOTS && $NHOSTS == 1 ) then
      setenv OMP_NUM_THREADS $NSLOTS
      setenv MKL_NUM_THREADS $NSLOTS
      setenv OPENBLAS_NUM_THREADS $NSLOTS
    endif
endif
