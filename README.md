About
=====

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

This is a fork of the excellent [gepetools](https://github.com/brlindblom/gepetools).
We got rid of the non-MPI support, as well as some of the additional stuff that has been in
gepetools. Some bugs have been fixed, some features added, most notably:

* Hybrid job support (OpenMPI/multihreaded)
* Improved installation procedure

Testing has only been done for the OpenMPI case.

Quick Start Example
===================

```
qsub -b y -q mpi.q -l nodes=3,rpn=10,ppr=2 "mpirun mpihello"
```

This reserves 60 slots in total. There will be 10 ranks per node, with
2 processes per rank.
When using rpn notation, following additional environment variables will be set:

* PE_RANKS_PER_NODE will be 10
* PE_PROCESSES_PER_RANK will be 2
* OMP_NUM_THREADS will be 2 - we are setting OMP_NUM_THREADS, so the user does not
  need to


Description of Files
====================

startpe.sh
----------

  Called by start\_proc\_args, sets up necessary environment including machines files in $TMPDIR,
  rsh symlinks, etc.  Available machine files are
  * machines.mpich
  * machines.mvapich
  * machines.mpich2
  * machines.mvapich2
  * machines.intelmpi
  * machines.hpmpi

stoppe.sh:
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

Example Jobs
============


1. OpenMPI

  ```
  #$ ...
  #$ -l nodes=8,rpn=12 # 96 slots, 12 ranks-per-node, 1 processes-per-rank
  #$ ...

  module add mpi/openmpi/1.4.4

  mpirun myexecutable
  ###
  ```

2. OpenMPI Hybrid Job

  ```
  #$ ...
  #$ -l nodes=8,rpn=10,ppr=2 # 160 slots, 10 ranks-per-node, 2 processes-per-rank
  #$ ...

  module add mpi/openmpi/1.4.4

  mpirun myexecutable
  ###
  ```
