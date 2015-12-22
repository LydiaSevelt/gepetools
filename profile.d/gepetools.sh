# Set necessary variables for a job.

# set JOB_ID for interactive jobs
if [[ ! -n $JOB_ID ]]; then
  sge_process=$(ps -p $PPID -o cmd= | grep sge_shepherd)
  if [[ $? == 0 ]]; then
    export JOB_ID=$(echo "$sge_process" | awk '{ print $1 }' | cut -d'-' -f2)
  fi
fi

if [[ -n $JOB_ID ]]; then
  # set host files, if they exist
  [[ -f $TMPDIR/machines ]]          && export PE_HOSTFILE="$TMPDIR/machines"
  [[ -f $TMPDIR/machines.mpich ]]    && export MPICH_HOSTS="$TMPDIR/machines.mpich"
  [[ -f $TMPDIR/machines.mvapich ]]  && export MVAPICH_HOSTS="$TMPDIR/machines.mvapich"
  [[ -f $TMPDIR/machines.mvapich2 ]] && export MVAPICH2_HOSTS="$TMPDIR/machines.mvapich2"
  [[ -f $TMPDIR/machines.mpich2 ]]   && export MPICH2_HOSTS="$TMPDIR/machines.mpich2"
  [[ -f $TMPDIR/machines.hpmpi ]]    && export HPMPI_HOSTS="$TMPDIR/machines.hpmpi"
  [[ -f $TMPDIR/machines.intelmpi ]] && export INTELMPI_HOSTS="$TMPDIR/machines.intelmpi"

  # set OpenMP threads
  if [[ -n $PE_PROCESSES_PER_RANK ]]; then
    export OMP_NUM_THREADS=$PE_PROCESSES_PER_RANK
  elif [[ -n $NSLOTS && $NHOSTS == 1 ]]; then
    export OMP_NUM_THREADS=$NSLOTS
    export MKL_NUM_THREADS=$NSLOTS
    export OPENBLAS_NUM_THREADS=$NSLOTS
  fi
fi
