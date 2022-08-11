#!/bin/bash # script BuildLoopFixedDev.sh

############################################################
# this code must be repeated in any build script that uses build_functions.sh
############################################################

BUILD_DIR=~/Downloads/BuildLoop
SCRIPT_DIR=$BUILD_DIR"/"Scripts

if [ ! -d ${BUILD_DIR} ]; then
    mkdir $BUILD_DIR
fi
if [ ! -d ${SCRIPT_DIR} ]; then
    mkdir $SCRIPT_DIR
fi

# define branch (to make it easier when updating)
# typically branch is main
SCRIPT_BRANCH=main

# store a copy of build_functions.sh in script directory
curl -fsSLo $SCRIPT_DIR/build_functions.sh https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/$SCRIPT_BRANCH/build_functions.sh

# This runs the common build_functions.sh
cd $SCRIPT_DIR
source ./build_functions.sh

############################################################
# The rest of this is specific to  BuildLoopFixedDev.sh
############################################################

# store a copy of this script.sh in script directory
curl -fsSLo ${SCRIPT_DIR}/BuildLoopFixedDev.sh https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/$SCRIPT_BRANCH/BuildLoopFixedDev.sh

# Stable Dev SHA
LOOP_DEV_TESTED_SHA=b6a3671
LOOP_DEV_TESTED_DATE="Aug 4, 2022"
FAPS_DEV_TESTED_SHA=76b4630
FAPS_DEV_TESTED_DATE="Aug 9, 2022"
FIXED_SHA=0

echo -e "\n--------------------------------\n"
BRANCH_LOOP=dev
BRANCH_FREE=freeaps_dev
LOOPCONFIGOVERRIDE_VALID=1
echo -e "\n ${RED}${BOLD}You are running the script for the development version${NC}"
echo -e " -- If you choose Loop,    branch is ${RED}${BOLD}${BRANCH_LOOP}${NC}"
echo -e " -- If you choose FreeAPS, branch is ${RED}${BOLD}${BRANCH_FREE}${NC}"
echo -e " ${RED}${BOLD}Be aware that a development version may require frequent rebuilds${NC}\n"
echo -e " If you have not read this section of LoopDocs - please review before continuing"
echo -e "    https://loopkit.github.io/loopdocs/faqs/branch-faqs/#loop-development"
echo -e "\nThis script chooses a version (commit) of the development branch"
echo -e "    that has been built and lightly tested"
echo -e "${RED}${BOLD}Loop    development branch version:"
echo -e "     ${LOOP_DEV_TESTED_DATE} workspace revision ${LOOP_DEV_TESTED_SHA}"
echo -e "FreeAPS development branch version:"
echo -e "     ${FAPS_DEV_TESTED_DATE} workspace revision ${FAPS_DEV_TESTED_SHA}"
echo -e "${NC}\nBefore you begin, please ensure that"
echo -e "  you have Xcode and Xcode command line tools installed, and"
echo -e "  your phone is plugged into your computer\n"
echo -e "Please select which version of Loop you would like to download and build"

choose_or_cancel
options=("Loop dev" "FreeAPS dev" "Cancel")
select opt in "${options[@]}"
do
    case $opt in
        "Loop dev")
            FORK_NAME=Loop
            REPO=https://github.com/LoopKit/LoopWorkspace
            BRANCH=dev
            FIXED_SHA=$LOOP_DEV_TESTED_SHA
            LOOPCONFIGOVERRIDE_VALID=1
            break
            ;;
        "FreeAPS dev")
            FORK_NAME=FreeAPS
            REPO=https://github.com/loopnlearn/LoopWorkspace
            BRANCH=freeaps_dev
            FIXED_SHA=$FAPS_DEV_TESTED_SHA
            LOOPCONFIGOVERRIDE_VALID=1
            break
            ;;
        "Cancel")
            cancel_entry
            ;;
        *)
            invalid_entry
            ;;
    esac
done

LOOP_DIR=$BUILD_DIR"/"$FORK_NAME"-"$BRANCH"-"$DOWNLOAD_DATE"_"$FIXED_SHA
if [ ${FRESH_CLONE} == 1 ]; then
    mkdir $LOOP_DIR
    cd $LOOP_DIR
fi
echo -e "\n\n\n\n"
echo -e "\n--------------------------------\n"
if [ ${FRESH_CLONE} == 1 ]; then
    echo -e " -- Downloading ${FORK_NAME} ${BRANCH} to your Downloads folder --"
    echo -e "      ${LOOP_DIR}\n"
    echo -e "Issuing this command:"
    echo -e "    git clone --branch=${BRANCH} --recurse-submodules ${REPO}"
    git clone --branch=$BRANCH --recurse-submodules $REPO
fi
echo -e "\n--------------------------------\n"
echo -e "🛑 Please check for errors in the window above before proceeding."
echo -e "   If there are no errors listed, code has successfully downloaded.\n"
echo -e "Type 1 and return to continue if and ONLY if"
echo -e "  there are no errors - scroll up in terminal window to look for the word error"
choose_or_cancel
options=("Continue" "Cancel")
select opt in "${options[@]}"
do
    case $opt in
        "Continue")
            cd LoopWorkspace
            this_dir=$(pwd)
            echo -e "In ${this_dir}"
            if [ ${FRESH_CLONE} == 0 ]; then
                echo -e "\nScript used with test flag, extra steps to prepare downloaded code\n"
                echo -e "  Updating to latest commit"
                git checkout $BRANCH
                git pull
            fi
            echo -e "  Checking out commit ${FIXED_SHA}\n"
            git checkout $FIXED_SHA --recurse-submodules --quiet
            git branch
            echo -e "Continue if no errors reported"
            choose_or_cancel
            options=("Continue" "Cancel")
            select opt in "${options[@]}"
            do
                case $opt in
                    "Continue")
                        break
                        ;;
                    "Cancel")
                        cancel_entry
                        ;;
                      *) # Invalid option
                         invalid_entry
                         ;;
                esac
            done
            if [ ${LOOPCONFIGOVERRIDE_VALID} == 1 ]; then
                check_config_override_existence_offer_to_configure
            fi

            echo -e "\nThe following items will open (when you are ready)"
            echo -e "* Webpage with abbreviated build steps (Loop and Learn)"
            echo -e "* Webpage with detailed build steps (LoopDocs)"
            echo -e "* Xcode ready to prep your current download for build\n"
            echo -e "     Do not forget to select Loop(Workspace)\n"
            return_when_ready
            # the helper page displayed depends on validity of persistent override
            if [ ${LOOPCONFIGOVERRIDE_VALID} == 1 ]; then
                # change this page to the one (not yet written) for persistent override
                # open https://www.loopandlearn.org/workspace-build-loop
                echo -e "loop and learn page not yet updated - skipping that"
            else
                open https://www.loopandlearn.org/workspace-build-loop
            fi
            sleep 5
            if [ ${FIXED_SHA} == 0 ]; then
                open "https://loopkit.github.io/loopdocs/build/step14/#prepare-to-build"
            else
                open "https://loopkit.github.io/loopdocs/build/step13/#build-loop"
            fi
            sleep 5
            xed .
            echo -e "\nShell Script Completed\n"
            echo -e " * You may close the terminal window now if you want"
            echo -e "  or"
            echo -e " * You can press the up arrow ⬆️  on the keyboard"
            echo -e "    and return to repeat script from beginning.\n\n";
            exit 0
            break
            ;;
        "Cancel")
            cancel_entry
            ;;
        *)
            invalid_entry
            ;;
    esac
done