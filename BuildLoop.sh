# !/bin/bash

############################################################
# define some font styles and colors
############################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

############################################################
# set up nominal values
#   these can be later overwritten by flags
#   for convenience when testing (or for advanced usersS)
############################################################

# FRESH_CLONE
#   Default value is 1, which means:
#     Download fresh clone every time script is run
FRESH_CLONE=1

# BRANCH_TYPE
#   This determines the branch for git clone command
#   Default value is master
BRANCH_TYPE=master

# Prepare date-time stamp for folder
LOOP_BUILD=$(date +'%y%m%d-%H%M')

function usage() {
    echo -e "Allowed arguments:"
    echo -e "  -h or --help : print this help message"
    echo -e "  -t or --test : sets FRESH_CLONE=0"
    echo -e "      To test script, execute while in folder "
    echo -e "          between BuildLoop and LoopWorkspace"
    echo -e "  -d or --dev  : use dev branches (not master)"
}

############################################################
# Process flags, the input options as positional parameters
############################################################
while [ "$1" != "" ]; do
    case $1 in
        -h | --help ) # usage function for help
            usage
            exit
            ;;
        -t | --test )  # Do not download clone - useful for testing
            echo -e "  -t or --test selected, sets FRESH_CLONE=0"
            FRESH_CLONE=0
            sleep 1
            ;;
        -d | --dev )  # select dev branches
            echo -e "  -d or --dev selected, sets BRANCH_TYPE=dev"
            BRANCH_TYPE=dev
            LOOP_BUILD="dev"-${LOOP_BUILD}
            sleep 1
            ;;
        * )  # argument not recognized
            echo -e "\n${RED}${BOLD}Input argument not recognized${NC}\n"
            usage
            exit 1
    esac
    shift
done

############################################################
# Define the rest of the functions (usage above):
############################################################

function initial_greeting() {
    echo -e "${RED}${BOLD}\n\n--------------------------------\n\n"
    echo -e "IMPORTANT\n"
    echo -e "Please understand that this project:\n"
    echo -e "- Is Open Source software"
    echo -e "- Is not \"approved\" for therapy\n"
    echo -e "And that:"
    echo -e "- You take full responsibility for"
    echo -e "  reading and understanding the documenation"
    echo -e "  (LoopsDocs is found at https://loopdocs.org)"
    echo -e "  before building and running this system,"
    echo -e "  and do so at your own risk.\n"
    echo -e "${NC}If you find the font too small to read comfortably"
    echo -e "  Hold down the CMD key and hit + (or -)"
    echo -e "  to increase (decrease) size\n"
    echo -e "${RED}${BOLD}By typing 1 and ENTER, you indicate you agree"
    echo -e "  Any other entry cancels"
    echo -e "\n--------------------------------\n"
}

function invalid_entry() {
    echo -e "\n${RED}${BOLD}User entered an invalid option${NC}\n"
    exit_message
}

function exit_message() {
    echo -e "You can press the up arrow ⬆️  on the keyboard"
    echo -e "    and return to repeat script from beginning.\n\n";
    exit 0
}

function choose_or_cancel() {
    echo -e "Type a number from the list below and return to proceed."
    echo -e "${RED}${BOLD}  Any other entry cancels\n${NC}"
}

function configure_folders_download_script() {
    ############################################################
    # defines folder names and default locations
    # downloads copy of this script (main branch)
    ############################################################

    LOOP_DIR=~/Downloads/BuildLoop/
    SCRIPT_DIR=~/Downloads/BuildLoop/Scripts

    if [ ! -d ${LOOP_DIR} ]; then
        mkdir $LOOP_DIR
    fi
    if [ ! -d ${SCRIPT_DIR} ]; then
        mkdir $SCRIPT_DIR
    fi

    # store a copy of this script in script directory
    curl -fsSLo ${SCRIPT_DIR}/BuildLoop.sh https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/BuildLoop.sh
}

function return_when_ready() {
    read -p "Return when ready to continue  " dummy
}

function report_persistent_config_override() {
    echo -e "The file used by Xcode to sign your app is found at:"
    echo -e "   ~/Downloads/BuildLoop/LoopConfigOverride.xcconfig"
    echo -e "The last 3 lines of that file are shown next:\n"
    tail -3 ../LoopConfigOverride.xcconfig
    echo -e "\nIf the last line has your Apple Developer ID"
    echo -e "   with no slashes at the beginning of the line"
    echo -e "   your targets will be automatically signed"
    echo -e "Any line that starts with // is ignored"
    echo -e "If ID is wrong - you should manually edit the file or delete the file now\n"
    return_when_ready
}

function create_persistent_config_override() {
    echo -e "The Apple Developer page will open"
    echo -e "* Log in to the page and note your 10-character Team ID"
    echo -e " * If the Memebship page does not show, you may need to select it"
    echo -e " * If you already have your account open in your browser, you may need to go to the already opened page"
    echo -e " * Once you get your ID, return to terminal window"
    echo -e "This is the page that will open:"
    echo -e "   https://developer.apple.com/account/#!/membership\n"
    return_when_ready
    open "https://developer.apple.com/account/#!/membership"
    echo -e " * Click in terminal window\n"
    read -p "Enter the ID and return: " devID
    if [ ${#devID} -ne 10 ]; then
        echo -e "Something was wrong with entry"
        echo -e "You can manually sign each target in Xcode"
    else 
        echo -e "Creating ~/Downloads/BuildLoop/LoopConfigOverride.xcconfig"
        echo -e "   with your Apple Developer ID"
        cp -p LoopWorkspace/LoopConfigOverride.xcconfig ..
        echo -e "LOOP_DEVELOPMENT_TEAM = ${devID}" >> ../LoopConfigOverride.xcconfig
        report_persistent_config_override
        echo -e "\nThe next time you build, this permanent file with automatically sign your targets"
    fi
}


##############################################
#  BuildLoop script continues using functions
##############################################

# call function
initial_greeting

options=("Agree")
select opt in "${options[@]}"
do
    case $opt in
        "Agree")
            break
            ;;
        *)
            echo -e "\n${RED}${BOLD}User did not agree to terms of use.${NC}\n\n";
            exit_message
            break
            ;;
    esac
done

# user agreed; call function
configure_folders_download_script

echo -e "${NC}\n\n\n\n"

echo -e "\n--------------------------------\n"
echo -e "${BOLD}Welcome to the Loop and Learn\n  Build-Select Script\n${NC}"
echo -e "This script will assist you in one of these actions:"
echo -e "  1 Download and build Loop"
echo -e "      You will be asked to choose from Loop or FreeAPS"
echo -e "  2 Download and build LoopFollow"
echo -e "  3 Prepare your computer using a Utility Script"
echo -e "     when updating your computer or an app"
echo -e "\n--------------------------------\n"
choose_or_cancel
options=("Build Loop" "Build LoopFollow" "Utility Scripts")
select opt in "${options[@]}"
do
    case $opt in
        "Build Loop")
            WHICH=Loop
            break
            ;;
        "Build LoopFollow")
            WHICH=LoopFollow
            break
            ;;
        "Utility Scripts")
            WHICH=UtilityScripts
            break
            ;;
        *)
            invalid_entry
            break
            ;;
    esac
done

echo -e "\n\n\n\n"

if [ "$WHICH" = "Loop" ]; then
    echo -e "\n--------------------------------\n"
    echo -e "Before you begin, please ensure that you have Xcode installed,"
    echo -e "  Xcode command line tools installed, and"
    echo -e "  your phone is plugged into your computer\n"
    echo -e "Please select which version of Loop you would like to download and build.\n"
    if [ "$BRANCH_TYPE" = "dev" ]; then
        BRANCH_LOOP=dev
        BRANCH_FREE=freeaps_dev
        LOOPCONFIGOVERRIDE_VALID=1
        echo -e "\n ${RED}${BOLD}You are running the script with a -d flag${NC}\n"
        echo -e " -- If you choose Loop,    branch is ${RED}${BOLD}${BRANCH_LOOP}${NC}"
        echo -e " -- If you choose FreeAPS, branch is ${RED}${BOLD}${BRANCH_FREE}${NC}\n"
    else
        BRANCH_LOOP=master
        BRANCH_FREE=freeaps
        LOOPCONFIGOVERRIDE_VALID=0
    fi
    choose_or_cancel
    options=("Loop" "FreeAPS")
    select opt in "${options[@]}"
    do
        case $opt in
            "Loop")
                FOLDERNAME=Loop
                REPO=https://github.com/LoopKit/LoopWorkspace
                BRANCH=$BRANCH_LOOP
                break
                ;;
            "FreeAPS")
                FOLDERNAME=FreeAPS
                REPO=https://github.com/loopnlearn/LoopWorkspace
                BRANCH=$BRANCH_FREE
                break
                ;;
            *)
                invalid_entry
                break
                ;;
        esac
    done

    echo -e "\n\n\n\n"
    LOOP_DIR=~/Downloads/BuildLoop/$FOLDERNAME-$LOOP_BUILD
    if [ ${FRESH_CLONE} == 1 ]; then
        mkdir $LOOP_DIR
        cd $LOOP_DIR
    fi
    echo -e "\n\n\n\n"
    echo -e "\n--------------------------------\n"
    if [ ${FRESH_CLONE} == 1 ]; then
        echo -e " -- Downloading ${FOLDERNAME} ${BRANCH} to your Downloads folder --"
        echo -e "      ${LOOP_DIR}\n"
        echo -e "Issuing this command:"
        echo -e "    git clone --branch=${BRANCH} --recurse-submodules ${REPO}"
        git clone --branch=$BRANCH --recurse-submodules $REPO
    fi
    echo -e "\n--------------------------------\n"
    echo -e "🛑 Please check for errors in the window above before proceeding."
    echo -e "   If there are no errors listed, code has successfully downloaded.\n"
    echo -e "Type 1 and return to continue if and ONLY if"
    echo -e "  there are no errors (scroll up in terminal window to look for the word error)\n"
    #echo -e "${RED}${BOLD}  Any entry (other than 1) cancels\n${NC}"
    choose_or_cancel
    options=("Continue")
    select opt in "${options[@]}"
    do
        case $opt in
            "Continue")
                if [ ${LOOPCONFIGOVERRIDE_VALID} == 1 ]; then
                    echo -e "\n--------------------------------\n"
                    if [ -e ../LoopConfigOverride.xcconfig ]; then
                        report_persistent_config_override
                    else
                        # make sure the LoopConfigOverride.xcconfig exists in clone
                        if [ -e LoopWorkspace/LoopConfigOverride.xcconfig ]; then
                            echo -e "Choose to enter Apple ID or wait and Sign Manually (later in Xcode)"
                            echo -e "\nIf you choose Apple ID, script will help you find it\n"
                            choose_or_cancel
                            options=("Enter Apple ID" "Sign Manually")
                            select opt in "${options[@]}"
                            do
                                case $opt in
                                    "Enter Apple ID")
                                        create_persistent_config_override
                                        break
                                        ;;
                                    "Sign Manually")
                                        break
                                        ;;
                                      *) # Invalid option
                                         echo -e "Error: Invalid option"
                                         exit;;
                                esac
                            done
                        else
                            echo -e "This project requires you to sign the targets individually"
                            LOOPCONFIGOVERRIDE_VALID=0
                        fi
                    fi
                    echo -e "\n--------------------------------\n"
                fi
                echo -e "The following items will open (in a few seconds)"
                echo -e "* The Loop and Learn webpage with abbreviated build steps will be displayed in your browser"
                echo -e "* The LoopDocs webpage with detailed build steps will be displayed in your browser"
                echo -e "* Xcode will open with your current download (wait for it)\n"
                # the helper page displayed depends on validity of persistent override
                if [ ${LOOPCONFIGOVERRIDE_VALID} == 1 ]; then
                    # change this page to the one (not yet written) for persistent override
                    sleep 3
                    open https://www.loopandlearn.org/workspace-build-loop
                else
                    sleep 3
                    open https://www.loopandlearn.org/workspace-build-loop
                fi
                sleep 3
                open "https://loopkit.github.io/loopdocs/build/step14/#prepare-to-build"
                cd LoopWorkspace
                sleep 2
                xed .
                echo -e "\nShell Script Completed\n"
                echo -e " * You may close the terminal window now if you want"
                echo -e "  or"
                echo -e " * You can press the up arrow ⬆️  on the keyboard"
                echo -e "    and return to repeat script from beginning.\n\n";
                exit 0
                break
                ;;
            *)
                invalid_entry
                break
                ;;
        esac
    done

elif [ "$WHICH" = "LoopFollow" ]
then
    # Note that BuildLoopFollow.sh has a warning about Xcode and phone, not needed here
    cd $LOOP_DIR/Scripts
    echo -e "\n\n--------------------------------\n\n"
    echo -e "Downloading Loop Follow Script\n"
    echo -e "\n--------------------------------\n\n"
    curl -fsSLo ./BuildLoopFollow.sh https://raw.githubusercontent.com/jonfawcett/LoopFollow/Main/BuildLoopFollow.sh
    echo -e "\n\n\n\n"
    source ./BuildLoopFollow.sh
else
    cd $LOOP_DIR/Scripts
    echo -e "\n\n\n\n"
    echo -e "\n--------------------------------\n"
    echo -e "${BOLD}These utility scripts automate several cleanup actions${NC}"
    echo -e "\n--------------------------------\n"
    echo -e "1 ➡️  Clean Derived Data:\n"
    echo -e "    This script is used to clean up data from old builds."
    echo -e "    In other words, it frees up space on your disk."
    echo -e "    Xcode should be closed when running this script.\n"
    echo -e "2 ➡️  Xcode Cleanup (The Big One):\n"
    echo -e "    This script clears even more disk space filled up by using Xcode."
    echo -e "    It is typically used after uninstalling Xcode"
    echo -e "      and before installing a new version of Xcode."
    echo -e "    It can free up a substantial amount of disk space."
    echo -e "\n    You might be directed to use this script to resolve a problem."
    echo -e "\n${RED}${BOLD}    Beware that you might be required to fully uninstall"
    echo -e "      and reinstall Xcode if you run this script with Xcode installed.\n${NC}"
    echo -e "    Always a good idea to reboot your computer after Xcode Cleanup.\n"
    echo -e "3 ➡️  Clean Profiles & Derived Data:\n"
    echo -e "    For those with a paid Apple Developer ID,"
    echo -e "      this action configures you to have a full year"
    echo -e "      before you are forced to rebuild your app."
    echo -e "\n--------------------------------\n"
    echo -e "${RED}${BOLD}You may need to scroll up in the terminal to see details about options${NC}\n"
    choose_or_cancel
    options=("Clean Derived Data" "Xcode Cleanup (The Big One)" "Clean Profiles & Derived Data")
    select opt in "${options[@]}"
    do
        case $opt in
            "Clean Derived Data")
                echo -e "\n--------------------------------\n"
                echo -e "Downloading Derived Data Script"
                echo -e "\n--------------------------------\n"
                curl -fsSLo ./CleanCartDerived.sh https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/CleanCartDerived.sh
                echo -e "\n\n\n\n"
                source ./CleanCartDerived.sh
                break
                ;;
            "Xcode Cleanup (The Big One)")
                echo -e "\n--------------------------------\n"
                echo -e "Downloading Xcode Cleanup Script"
                echo -e "\n--------------------------------\n"
                curl -fsSLo ./XcodeClean.sh https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/XcodeClean.sh
                echo -e "\n\n\n\n"
                source ./XcodeClean.sh
                break
                ;;
            "Clean Profiles & Derived Data")
                echo -e "\n--------------------------------\n"
                echo -e "Downloading Profiles and Derived Data Script"
                echo -e "\n--------------------------------\n"
                curl -fsSLo ./CleanProfCartDerived.sh https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/CleanProfCartDerived.sh
                echo -e "\n\n\n\n"
                source ./CleanProfCartDerived.sh
                break
                ;;
            *)
                invalid_entry
                break
                ;;
        esac
    done
fi

