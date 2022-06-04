#!/usr/bin/env bash
# usage: ./synthesize.sh [bistream_destination]
# If you do not specify the bitstream destination it will be saved to the
# current directory

CUR_DIR=$(pwd)

QUARTUS_PROJECT_ROOT_DEFAULT="$CUR_DIR/quartus_project"

# exit when error occurs
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command exited with code $?."' EXIT

quartus_project_root="${QUARTUS_PROJECT_ROOT_DEFAULT}"

# run synthesis
cd $quartus_project_root/hardware_test_design
quartus_syn --read_settings_files=on --write_settings_files=off alt_ehipc2_hw -c alt_ehipc2_hw
quartus_fit --read_settings_files=on --write_settings_files=off alt_ehipc2_hw -c alt_ehipc2_hw
quartus_sta alt_ehipc2_hw -c alt_ehipc2_hw --mode=finalize
quartus_asm --read_settings_files=on --write_settings_files=off alt_ehipc2_hw -c alt_ehipc2_hw
#cd $CUR_DIR
#cp "$quartus_project_root/hardware_test_design/output_files/alt_ehipc2_hw.sof" \
#    "$BITSTREAM_DESTINATION"
