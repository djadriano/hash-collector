# --------------------------------------------------------------------------------------
# How to Use:
# The script needs the following parameters:
# hash commit or .txt with list of commits
#
# Example:
# $ ./hash-collector.sh 577fc5e7e1beb8f8692485f8e005fe982578d5a9
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
path_project=""
default_branch="master"

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

function read_hash {
  hash=$1

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

      read_hash $hash
    fi

  done < "$txt_file"
}

function checkout_branch {
  if [ -n "$next_line" ]
  then
      git checkout $next_line
  else
      if [ -n "$path_project" ]
      then
        echo "have path project"
        git checkout $default_branch
      else
        echo "don't have path project"
        git checkout $current_branch
      fi

      echo "\n${Purple}------------------------------------------------------------------------------${Color_Off}"
      echo "${Purple}Opening destiny folder:${Color_Off}"
      echo "${White}${bold}${destiny_folder}${normal}${Color_Off}"
      echo "${Purple}------------------------------------------------------------------------------${Color_Off}\n"

      open $destiny_folder
  fi
}

function check_has_git_folder {
  if ! [ -d "./.git" ]; then
    echo "\n${Red}------------------------------------------------------------------------------${Color_Off}"
    echo "${Red}There is not a git in this project! ${Color_Off}"
    echo "${Red}------------------------------------------------------------------------------${Color_Off}\n"
    exit
  fi
}

function question_2 {
  read -e -p "${bold}2. Please set the destiny folder to save the zip(s) file(s):${normal} " READ_QUESTION_2

  if ! [[ -d $READ_QUESTION_2 ]];
  then
    question_2
  else
    destiny_folder=$READ_QUESTION_2
    question_3
  fi
}

function question_3 {
  read -e -p "${bold}3. Please set the name of folder to be zipped:${normal} " READ_QUESTION_3

  if [ -z "$READ_QUESTION_3" ]
  then
    question_3
  else
    folder_to_be_zipped=$READ_QUESTION_3

    if [ -f "$txt_file" ]
    then
      read_file
    else
      read_hash $txt_file
    fi

  fi
}

function question_1 {
  read -e -p "${bold}1. Are you in the root of project (y/n)?${normal} " READ_QUESTION_1

  if [ -z "$READ_QUESTION_1" ]
  then
    question_1
  else
    if [ "$READ_QUESTION_1" == 'n' ]
    then
      question_1_1
    else
      check_has_git_folder
      question_2
    fi
  fi
}

function question_1_1 {
  read -e -p "${bold}1.1 Please set the path of your project:${normal} " READ_QUESTION_1_1

  if [ -z "$READ_QUESTION_1_1" ]
  then
    question_1_1
  else
    path_project=$READ_QUESTION_1_1
    question_1_2
  fi
}

function question_1_2 {
  read -e -p "${bold}1.2 What the branch you are? [${default_branch}]${normal} " READ_QUESTION_1_2

  cd $path_project

  if [ "$READ_QUESTION_1_2" == '' ]
  then
    git checkout $default_branch
  else
    default_branch=$READ_QUESTION_1_2
    git checkout $READ_QUESTION_1_2
  fi

  question_2
}

function initialize {

  # check if passed txt file
  if [ -z "$txt_file" ]
  then
    echo "\n${Red}------------------------------------------------------------------------------${Color_Off}"
    echo "${Red}Please set hash or the .txt file with hashes${Color_Off}"
    echo "${White}Example: $ ./hash-collector.sh ${bold}name-of-file.txt or hash ${normal}${Color_Off}"
    echo "${Red}------------------------------------------------------------------------------${Color_Off}\n"
    exit
  fi

  question_1

}

# -----------------------------------------------------
# Start the code
# -----------------------------------------------------

initialize
