# --------------------------------------------------------------------------------------
# How to Use:
# The script needs the following parameters:
# File.txt / folder to save the zips / folder that will be zipped in project
#
# Example:
# $ ./hash-collector.sh file.txt ~/Documents dist/
# --------------------------------------------------------------------------------------


clear

# -----------------------------------------------------
# Color Variables
# -----------------------------------------------------

Color_Off='\033[0m'       # Text Reset
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# -----------------------------------------------------
# Parameters
# -----------------------------------------------------

txt_file=$1
destiny_folder=$2
folder_to_be_zipped=$3

# -----------------------------------------------------
# Default variables
# -----------------------------------------------------

count=1
next_line=""
current_branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
bold=$(tput bold)
normal=$(tput sgr0)

# -----------------------------------------------------
# Methods
# -----------------------------------------------------

function generate_zip_folder {
  hash=$1

  echo "\n${Green}Zip folder:${Color_Off}"
  echo "${White}${bold}${hash}.zip${normal}${Color_Off}"

  zip -qr "$hash.zip" "./$folder_to_be_zipped"

  echo "\n${Green}Copy to:${Color_Off}"
  echo "${White}${bold}${destiny_folder}${normal}${Color_Off}"

  cp -r "$hash.zip" $destiny_folder

  echo "\n${Blue}Removing zip file:${Color_Off}"
  echo "${White}${bold}${hash}.zip${normal}${Color_Off}\n"

  rm -r "$hash.zip"
}

function read_file {
  while IFS='' read -r hash || [[ -n "$hash" ]]; do

    count=$(($count + 1))
    next_line=$(sed -n "$count"p $txt_file)

    # check if hash is not null
    if [ -n "$hash" ]
    then

      echo "\n${Green}------------------------------------------------------------------------------${Color_Off}"
      echo "${Green}Reading hash:${Color_Off}"
      echo "${White}${bold}${hash}${normal}${Color_Off}"
      echo "${Green}------------------------------------------------------------------------------${Color_Off}\n"

      # check if exist hash in git project
      if git merge-base --is-ancestor $hash HEAD; then
        git checkout $hash

        if [ -d "./$folder_to_be_zipped" ]; then
          generate_zip_folder $hash
          checkout_branch
        fi
      else

        echo "\n${Red}------------------------------------------------------------------------------${Color_Off}"
        echo "${Red}Hash not found:${Color_Off}"
        echo "${White}${bold}${hash}${normal}${Color_Off}"
        echo "${Red}------------------------------------------------------------------------------${Color_Off}\n"

      fi
    fi

  done < "$txt_file"
}

function checkout_branch {
  if [ -n "$next_line" ]
  then
      git checkout $next_line
  else
      git checkout $current_branch

      echo "\n${Purple}------------------------------------------------------------------------------${Color_Off}"
      echo "${Purple}Opening destiny folder:${Color_Off}"
      echo "${White}${bold}${destiny_folder}${normal}${Color_Off}"
      echo "${Purple}------------------------------------------------------------------------------${Color_Off}\n"

      open $destiny_folder
  fi
}

function init {

  if ! [ -d "./.git" ]; then
    echo "\n${Red}------------------------------------------------------------------------------${Color_Off}"
    echo "${Red}There is not a git in this project! ${Color_Off}"
    echo "${Red}------------------------------------------------------------------------------${Color_Off}\n"
    exit
  fi

  # check if passed txt file
  if [ -z "$txt_file" ]
  then
    echo "\n${Red}------------------------------------------------------------------------------${Color_Off}"
    echo "${Red}Please set the .txt file with hashes${Color_Off}"
    echo "${White}Example: $ ./hash.sh ${bold}name-of-file.txt ${normal}path-to-destiny-folder folder-to-be-zipped${Color_Off}"
    echo "${Red}------------------------------------------------------------------------------${Color_Off}\n"
    exit
  fi

  # check if passed destiny folder
  if [ -z "$destiny_folder" ]
  then
    echo "\n${Red}-----------------------------------------------------------------------${Color_Off}"
    echo "${Red}Please set the destiny folder${Color_Off}"
    echo "${White}Example: $ ./hash.sh name-of-file.txt ${bold}path-to-destiny-folder ${normal}folder-to-be-zipped${Color_Off}"
    echo "${Red}-----------------------------------------------------------------------${Color_Off}\n"
    exit
  fi

  # check if passed folder to be zipped
  if [ -z "$folder_to_be_zipped" ]
  then
    echo "\n${Red}-----------------------------------------------------------------------${Color_Off}"
    echo "${Red}Please set the folder that will be zipped in project${Color_Off}"
    echo "${White}Example: $ ./hash.sh name-of-file.txt path-to-destiny-folder ${bold}folder-to-be-zipped${normal}${Color_Off}"
    echo "${Red}-----------------------------------------------------------------------${Color_Off}\n"
    exit
  fi

  read_file

}

# -----------------------------------------------------
# Start the code
# -----------------------------------------------------

init