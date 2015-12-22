#!/bin/bash
#
# The end-all, be-all pe start script
#

PATH=/bin:/usr/bin
unset LD_LIBRARY_PATH

# put us on fast, local disks
cd /tmp

PeHostfile2MPICHMachineFile() {
   while read -r line; do
      host=$(echo "$line" | cut -f1 -d" " | cut -f1 -d".")
      nslots=$(echo "$line" | cut -f2 -d" ")
      i=1
      while [ $i -le "$nslots" ]; do
         echo "$host"
         i=$((i + 1))
      done
   done < "$1"
}

PeHostfile2MPICH2MachineFile(){
    while read -r line; do
        host=$(echo "$line" | cut -f1 -d" " | cut -f1 -d".")
        nslots=$(echo "$line" | cut -f2 -d" ")
        echo "$host:$nslots"
    done < "$1"
}

me=$(basename "$0")


# test number of args
if [ $# -ne 1 ]; then
   echo "$me: got wrong number of arguments" >&2
   exit 1
fi

# get arguments
pe_hostfile=$1

# ensure pe_hostfile is readable
if [ ! -r "$pe_hostfile" ]; then
   echo "$me: can't read $pe_hostfile" >&2
   exit 1
fi

# modify hostfile for hybrid jobs
[[ -n $PE_PROCESSES_PER_RANK ]] || PE_PROCESSES_PER_RANK=1
while read -r line; do
  infos=( $line )
  host=${infos[0]}
  slots=${infos[1]}
  queue=${infos[2]}
  processor_range=${infos[3]}

  echo "$host $((slots/PE_PROCESSES_PER_RANK)) $queue $processor_range" >> "$TMPDIR/machines"
done < "$pe_hostfile"
pe_hostfile="$TMPDIR/machines"

# create machine-files for MPIs
PeHostfile2MPICHMachineFile "$pe_hostfile" >> "$TMPDIR/machines.mpich"
PeHostfile2MPICHMachineFile "$pe_hostfile" >> "$TMPDIR/machines.mvapich"
PeHostfile2MPICHMachineFile "$pe_hostfile" >> "$TMPDIR/machines.mvapich2"
PeHostfile2MPICH2MachineFile "$pe_hostfile" >> "$TMPDIR/machines.mpich2"
PeHostfile2MPICHMachineFile "$pe_hostfile" >> "$TMPDIR/machines.hpmpi"
PeHostfile2MPICH2MachineFile "$pe_hostfile" >> "$TMPDIR/machines.intelmpi"

# Make script wrapper for 'rsh' available in jobs tmp dir
rsh_wrapper=%%INSTALL_DIR%%/rsh
if [ ! -x $rsh_wrapper ]; then
   echo "$me: can't execute $rsh_wrapper" >&2
   echo "     maybe it resides at a file system not available at this machine" >&2
   exit 1
fi

rshcmd=rsh
ln -s $rsh_wrapper "$TMPDIR/$rshcmd"

# signal success to caller
exit 0
