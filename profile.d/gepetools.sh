# Define some vars if TMPDIR is set (inside a job)
if [ -n "$TMPDIR" ]; then
  MPICH_HOSTS=$TMPDIR/machines.mpich
  MVAPICH_HOSTS=$TMPDIR/machines.mvapich
  MVAPICH2_HOSTS=$TMPDIR/machines.mvapich2
  MPICH2_HOSTS=$TMPDIR/machines.mpich2
  HPMPI_HOSTS=$TMPDIR/machines.hpmpi
  INTELMPI_HOSTS=$TMPDIR/machines.intelmpi
fi

export MPICH_HOSTS MVAPICH_HOSTS MVAPICH2_HOSTS MPICH2_HOSTS \
  HPMPI_HOSTS INTELMPI_HOSTS
