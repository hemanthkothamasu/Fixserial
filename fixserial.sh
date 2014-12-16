# CopyRight, Belong to Hemanth Kothamasu, and Written as a supplement for System Development(LINUX) course During Coursework at Northeastern University.

#!/bin/bash

# Checking the parameters for the serial file
if [ $# -lt 1 ]
then
  echo "Usage: `basename $0` <file>"
  exit 255
fi

_file=$1

# If file doesn't exist show error message and exit
if ! [ -f "${_file}" ]
then
  echo "File ${_file} does not exist."
  exit 254
fi

# Checking if serial presents in the file
if ! grep -i ";.*serial" ${_file} > /dev/null 2>&1
then
  echo "Serial not found in ${_file}"
  exit 253
fi

# Backup the file
cp -v "${_file}" "${_file}.bak"

# Initializing variables
_serial="$(grep -i ";.*serial" ${_file} | grep -o "[[:digit:]]*")"
serial_date="${_serial:0:8}"
serial_modnum="${_serial:8:2}"
current_date="$(date +"%Y%m%d")"
new_modnum=""
new_serial=""

# Checking the serial date
if [ "${serial_date}" -lt "${current_date}" ] # the date is in the past
then
  new_serial_date="${current_date}"
  new_modnum="01"
else 
  if [ "${serial_date}" -eq "${current_date}" ] # the date is today
  then
    new_serial_date="${current_date}"
    new_modnum="$((${serial_modnum}+1))" # incrementing modification number
    new_modnum="$(printf "%02d" "${new_modnum}")" # adding leading zero
  else
    if [ "${serial_date}" -gt "${current_date}" ] # the date is in the future
    then
      echo "This is future date"
      exit 252
    fi
  fi
fi

# Making the new serial string
new_serial="${new_serial_date}${new_modnum}"

# Let's now modify the file. If something fails, cancel changes
sed -i "/${_serial}.*;.*serial/s/${_serial}/${new_serial}/" ${_file} || (echo “It looks like something wrong”; cp -v "${_file}.bak" ${_file})
