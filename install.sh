#!/bin/bash
#
# Copyright 2012, Brian Smith
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
# 
# Install script
#

. config_install

# add our PEs
function pe_exists(){
  qconf -spl 2>&1 | grep -q "^$1\$"
  return $?
}

export installDir=$1

if [[ -z "$installDir" ]]; then
  echo "Please specify an installation directory: "
  echo "./install.sh <installation_dir>"
  exit 1
fi

mkdir -p "$installDir"
chmod 755 "$installDir"

ppns=($(seq 1 "$MAX_NODE_SIZE"))
for queue in $QUEUE_LIST; do
  if pe_exists "${QUEUE_PREFIX}_${queue}"; then
    echo "PE '${QUEUE_PREFIX}_${queue}' already exists! Skipping..."
    continue
  fi

  sed "s|%%INSTALL_DIR%%|$installDir|g" > /tmp/pefile.$$ <<EOF
pe_name        ${QUEUE_PREFIX}_${queue}
slots        9999 
user_lists       NONE
xuser_lists      NONE
start_proc_args    %%INSTALL_DIR%%/startpe.sh \$pe_hostfile
stop_proc_args     %%INSTALL_DIR%%/stoppe.sh
allocation_rule    \$fill_up
control_slaves     TRUE
job_is_first_task  FALSE
urgency_slots    min
accounting_summary FALSE
EOF
  qconf -Ap /tmp/pefile.$$
  qconf -mattr queue pe_list "${QUEUE_PREFIX}_${queue}" "$queue"
done

for queue in $QUEUE_LIST; do
  for ppn in "${ppns[@]}"; do
    pe=${QUEUE_PREFIX}_${queue}.${ppn}
   
    if pe_exists "$pe"; then
      echo "PE '$pe' already exists! Skipping..."
      rm -f /tmp/pefile.$$
      continue
    fi

    sed "s|%%INSTALL_DIR%%|$installDir|g" >/tmp/pefile.$$ <<EOF
pe_name        $pe
slots        9999
user_lists       NONE
xuser_lists      NONE
start_proc_args    %%INSTALL_DIR%%/startpe.sh \$pe_hostfile
stop_proc_args     %%INSTALL_DIR%%/stoppe.sh
allocation_rule    $ppn
control_slaves     TRUE
job_is_first_task  FALSE
urgency_slots    min
accounting_summary FALSE
EOF
    qconf -Ap /tmp/pefile.$$
    qconf -mattr queue pe_list "$pe" "$queue"
  done
done

rm -f /tmp/pefile.$$

install --mode=755 startpe.sh "$installDir/"
sed -i "s|%%INSTALL_DIR%%|$installDir|g" "$installDir/startpe.sh"

install --mode=755 stoppe.sh "$installDir/"
sed -i "s|%%INSTALL_DIR%%|$installDir|g" "$installDir/stoppe.sh"

install --mode=755 getjidprocinfo "$installDir/"
sed -i "s|%%INSTALL_DIR%%|$installDir|g" "$installDir/getjidprocinfo"

install --mode=755 extJobInfo "$installDir/"
sed -i "s|%%INSTALL_DIR%%|$installDir|g" "$installDir/extJobInfo"

install --mode=755 rshExtJobInfo "$installDir/"
sed -i "s|%%INSTALL_DIR%%|$installDir|g" "$installDir/rshExtJobInfo"

install --mode=755 rshExtWrap "$installDir/"
sed -i "s|%%INSTALL_DIR%%|$installDir|g" "$installDir/rshExtWrap"

install --mode=755 rsh "$installDir/"

install --mode=755 pe.jsv "$installDir/"
sed -i "s|%%QUEUE_PREFIX%%|$QUEUE_PREFIX|g" "$installDir/pe.jsv"
sed -i "s|%%MAX_NODE_SIZE%%|$MAX_NODE_SIZE|g" "$installDir/pe.jsv"
sed -i "s|%%MAX_NUMBER_OF_SLOTS%%|$MAX_NUMBER_OF_SLOTS|g" "$installDir/pe.jsv"

install --mode=644 pe_env_setup "$installDir/"
sed -i "s|%%INSTALL_DIR%%|$installDir|g" "$installDir/pe_env_setup"

cp config_install "$installDir/.gepetools.install"

# Add complex attributes
qconf -sc >> /tmp/complexAttribs.$$
cat >>/tmp/complexAttribs.$$ <<EOF
pcpus              pcpus               INT       <=    YES       NO     0      0
nodes              nodes               INT       <=    YES       NO     0      0
ranks_per_node     rpn                 INT       <=    YES       NO     0      0
processes_per_rank ppr                 INT       <=    YES       NO     0      0
EOF
qconf -Mc /tmp/complexAttribs.$$
rm -f  /tmp/complexAttribs.$$

# Add complex values to queues
# TODO: Change this to global host configuration
for queue in $QUEUE_LIST; do
  qconf -mattr queue complex_values pcpus=99999 "$queue"
  qconf -mattr queue complex_values nodes=99999 "$queue"
  qconf -mattr queue complex_values ranks_per_node=99999 "$queue"
  qconf -mattr queue complex_values processes_per_rank=99999 "$queue"
done

exit
