About
=====

This is a fork of the excellent [IMPIMBA gepetools](https://github.com/IMPIMBA/gepetools), which is 
itself a fork of the original [gepetools](https://github.com/brlindblom/gepetools).

The purpose of this fork is specifically to support OpenMPI/OpenMP hybrid environments on 
Univa Grid Engine, though it should be compatible with Son of Grid engine. Changes introduced 
in this fork include:

 * Univa grid engine compatibility
 * Univa grid engine specific setup documentation
 * Univa grid engine run time examples
 * Minor fixes

This package contains various scripts and code for creating "universal" parallel
environments (PE). It also supports setting up hybrid OpenMPI/multihreaded PEs.
These PEs are capable of handling jobs utilizing the following MPI implementations:

 * OpenMPI
 * HPMPI
 * Intel MPI
 * MVAPICH/MVAPICH2
 * MPICH/MPICH2

It introduces the syntax of node, ranks-per-node (rpn) and processes-per-rank (ppn)
for MPI jobs. This is called nrp notation in this document.

Testing has only been done for the OpenMPI case.

Installation
============

1. Edit config_install with proper values, I recommend you only install on a single queue, example:
   ```
   QUEUE_PREFIX=mpimp
   
   # QUEUE_LIST=$(qconf -sql)
   QUEUE_LIST="openmpi-hybrid.q"
   
   MAX_NUMBER_OF_SLOTS=300
   MAX_NODE_SIZE=24
   ```

2. Run the install.sh script providing the install directory (within your $SGE_ROOT) from within 
   the gepetools directory. This process requires you run from an admin host as either your 
   Grid engine admin user or root in order to write files to your $SGE_ROOT
   ```
   #$ cd gepetools/
   #$ ./install.sh $SGE_ROOT/mpi_hybrid
   ``` 

Quick Start Example
===================

```
qsub -b y -q openmpi-hybrid.q -l mnodes=3,rpn=10,ppr=2 -jsv /opt/UGE/mpi-mp/pe.jsv \
"mpirun -np 30 -hostfile $TMPDIR/machines mpihello"
```

This reserves 60 slots in total. There will be 10 ranks per node, with
2 processes per rank.
When using rpn notation, following additional environment variables will be set:

* PE_RANKS_PER_NODE will be 10
* PE_PROCESSES_PER_RANK will be 2
* OMP_NUM_THREADS will be 2 - we are setting OMP_NUM_THREADS, so the user does not
  need to (also MKL and OpenBLAS equivalents)


Description of Files
====================

startpe.sh
----------

  Called by start\_proc\_args, sets up necessary environment including machines files in $TMPDIR,
  rsh symlinks, etc.  Available machine files are:
  * machines.mpich
  * machines.mvapich
  * machines.mpich2
  * machines.mvapich2
  * machines.intelmpi
  * machines.hpmpi

  Only OpenMPI is tested at this time.

stoppe.sh
----------

  Cleans up the mess created by startpe.sh

pe.jsv
------

  Job submit verification that translates the node, rpn, ppr syntax to GE
  native format. Also checks if the job fits on the available nodes and does
  not exceed slot limits (defined statically in the JSV - if the limits change
  the JSV needs to be updated).


Installation
============

This package can be extracted anywhere by the final installation directory.  
Its best if the installation directory is on a shared directory.

Edit config_install to reflect your environment. Then run:

```
./install.sh <install_dir>
```

You will also need to source the files in profile.d at job startup. For
these startup scripts to work you need to modify the hardcoded SGE_ROOT path.

Example Jobs
============

1. OpenMPI Hybrid Job

  ```
  #$ ...
  #$ -jsv $SGE_ROOT/mpi_hybrid/pe.jsv
  #$ -l mnodes=8,rpn=10,ppr=2 # 160 slots, 10 ranks-per-node, 2 processes-per-rank
  #$ ...

  module add mpi/openmpi/1.4.4

  mpirun -np 80 -hostfile $TMPDIR/machines myexecutable
  ```

  Option -jsv to use the pe.jsv for hybrid jobs is required.

  MPI will not create the correct number of ranks or on the proper nodes unless
  -np and -hostfile are provided manually.

  The -np number should be the number of nodes * number of ranks, in the example 
  this number is 80.

  The -hostfile path for OpenMPI jobs is $TMPDIR/machines, other files are 
  listed above, though are untested.

  File formats may need to be adjusted.
