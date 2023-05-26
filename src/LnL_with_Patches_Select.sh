#!/bin/bash # script CustomizationSelect.sh

BUILD_DIR=~/Downloads/BuildLoop

#!inline common.sh

# Set default values only if they haven't been defined as environment variables
: ${SCRIPT_BRANCH:="main"}

############################################################
# The rest of this is specific to the particular script
############################################################

function display_applied_patches() {
    has_applied_patches=false
    for i in ${!name[@]}; do
        if git apply --reverse --check "${mytmpdir}/${file[$i]}.patch" --directory="${folder[$i]}" >/dev/null 2>&1; then
            if [ "$has_applied_patches" = false ]; then
                echo -e "${INFO_FONT}Currently applied customizations:${NC}"
                has_applied_patches=true
            fi
            echo "* ${name[$i]}"
        fi
    done
    if [ "$has_applied_patches" = true ]; then
        echo
    fi
}

function display_unapplicable_patches() {
    local has_unapplicable_patches=false
    for i in ${!name[@]}; do
        if ! git apply --check "${mytmpdir}/${file[$i]}.patch" --directory="${folder[$i]}" >/dev/null 2>&1 && \
           ! git apply --reverse --check "${mytmpdir}/${file[$i]}.patch" --directory="${folder[$i]}" >/dev/null 2>&1; then
            if [ "$has_unapplicable_patches" = false ]; then
                echo -e "${INFO_FONT}Unavailable customizations due to conflicts:${NC}"
                has_unapplicable_patches=true
            fi
            echo "* ${name[$i]}"
        fi
    done
    if [ "$has_unapplicable_patches" = true ]; then
        echo
    fi
}

function has_available_customizations() {
    for i in ${!name[@]}; do
        if git apply --check "${mytmpdir}/${file[$i]}.patch" --directory="${folder[$i]}" >/dev/null 2>&1; then
            return 0
        fi
    done
    return 1
}

function apply() {
    local name="$1"
    local patch_file="${mytmpdir}/$2.patch"
    local directory="$3"
    echo 
    # Check if the patch has already been applied
    if git apply --reverse --check "${patch_file}" --directory="${directory}" >/dev/null 2>&1; then
        echo -e "${ERROR_FONT}Requested Customization is already applied.${NC}"
        echo "    ${name}"
    else
        # Try to apply the patch
        if git apply --check "${patch_file}" --directory="${directory}" >/dev/null 2>&1; then
            echo "${name} - Applying..."
            git apply "${patch_file}" --directory="${directory}"
            exit_code=$?
            if [ $exit_code -eq 0 ]; then
                echo -e "  ${SUCCESS_FONT}Successful!${NC}"
            else
                echo -e "  ${ERROR_FONT}Failed!${NC}"
            fi
        else
            echo -e "${ERROR_FONT}Requested Customization cannot be applied.${NC}"
            echo "    ${name}"
        fi
    fi
}

function revert() {
    local name="$1"
    local patch_file="${mytmpdir}/$2.patch"
    local directory="$3"
    echo 
    if git apply --reverse --check "${patch_file}" --directory="${directory}" >/dev/null 2>&1; then
        echo "${name} - Removing..."
        git apply --reverse "${patch_file}" --directory="${directory}"
        exit_code=$?
        if [ $exit_code -eq 0 ]; then
            echo -e "  ${SUCCESS_FONT}Successful!${NC}"
        else
            echo -e "  ${ERROR_FONT}Failed!${NC}"
        fi
    else
        if git apply --check "${mytmpdir}/${patch_file}.patch" --directory="${directory}" >/dev/null 2>&1; then
            echo -e "${ERROR_FONT}Requested Customization was not applied.${NC}"
            echo "    ${name}"
        else
            echo -e "${ERROR_FONT}Requested Customization cannot be removed.${NC}"
            echo "    ${name}"
        fi
    fi
}

function add_patch() {
    name+=("$1")
    file+=("$2")
    folder+=("$3")
    url+=("$4")
}

# Deletes the temp directory
function cleanup {      
    echo "Deleting temp working directory $mytmpdir"
    rm -r "$mytmpdir"
    tput cuu1 && tput el
    exit_script
}

section_separator
echo -e "${INFO_FONT}Loop with Patches Add or Reverse Feature${NC}"

cd "$STARTING_DIR"

if [ "$(basename "$PWD")" != "LoopWorkspace" ]; then
    target_dir=$(find ${BUILD_DIR/#\~/$HOME} -maxdepth 1 -type d -name "Loop*" -exec [ -d "{}"/LoopWorkspace ] \; -print 2>/dev/null | xargs -I {} stat -f "%m %N" {} | sort -rn | head -n 1 | awk '{print $2"/LoopWorkspace"}')
    if [ -z "$target_dir" ]; then
        echo -e "${ERROR_FONT}Error: No folder containing LoopWorkspace found in${NC}"
        echo "    $BUILD_DIR"
    else
        cd "$target_dir"
    fi
fi

# Verify current folder
if [ $(basename $PWD) = "LoopWorkspace" ]; then
    echo "Creating temporary folder"
    workingdir=$PWD
    mytmpdir=$(mktemp -d)

    # Check if tmp dir was created
    if [[ ! "$mytmpdir" || ! -d "$mytmpdir" ]]; then
        echo "Could not create temporary folder"
        exit 1
    fi
    tput cuu1 && tput el

    # Register the cleanup function to be called on the EXIT signal
    trap cleanup EXIT

    #Declare all patches
    #Using simple arrays since bash 3 which is shipped with mac does not support associative arrays
    name=() #Displayed name
    file=() #File to retrieve (optional)
    folder=() #Optional folder if the patch is not workspace level
    url=() #Optional url to patch, it will be stored as "file"-name

    add_patch "Add CGM interface: xDrip4iOS and GlucoseDirect" "add_cgm_interface" "" "https://github.com/loopnlearn/LoopWorkspace/commit/4092277a21fa44a1258b693a5fbcce4d8d9dbd17.patch"
    add_patch "Modify Logo with LnL icon" "lnl_icon" "" "https://github.com/loopnlearn/LoopWorkspace/commit/7c1dd02e74508a171128de85741e44b09ccee118.patch"
    add_patch "CustomTypeOne LoopPatches - part 1" "cto_main_loop" "Loop" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/cto_Loop_3.2.x.patch"
    add_patch "CustomTypeOne LoopPatches - part 2" "cto_main_loopkit" "LoopKit" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/cto_LoopKit_3.2.x.patch"
    add_patch "CustomTypeOne LoopPatches Single Patch" "cto_main_loopworkspace" "" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/cto_LoopWorkspace_3.2.x.patch"
    add_patch "Replace switcher with ramp in AB strategy v3.2.2" "cto_with_ramp_main" "" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/cto_LoopWorkspace_3.2.x.patch"
    add_patch "Replace switcher with ramp in AB strategy dev_0493004" "cto_with_ramp_dev_0493004" "" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/cto_LoopWorkspace_3.2.x.patch"
    add_patch "Replace switcher with ramp in AB strategy dev" "cto_with_ramp_dev" "" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/add_ab_ramp_plus_cto_no_switcher_LoopWorkspace_dev.patch"
    add_patch "Add ramp in AB strategy v3.2.2" "ramp_main" "" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/add_ab_ramp_option_LoopWorkspace_3.2.x.patch"
    add_patch "Add ramp in AB strategy dev_0493004" "ramp_dev_0493004" "" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/add_ab_ramp_option_LoopWorkspace_dev_0493004.patch"
    add_patch "Add ramp in AB strategy dev" "ramp_dev" "" "https://raw.githubusercontent.com/marionbarker/loopbuildscripts/$SCRIPT_BRANCH/patch_cto/add_ab_ramp_option_LoopWorkspace_dev.patch"



    echo -e "${INFO_FONT}Downloading customizations, please wait...${NC}"
    cd $mytmpdir
    for i in ${!name[@]}
    do
        if [ -z "${url[$i]}" ]; then
            curl -fsSLOJ "https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/$SCRIPT_BRANCH/patch/${file[$i]}.patch"
        else
            curl -fsSL --output "${file[$i]}.patch" "${url[$i]}"
        fi
    done
    tput cuu1 && tput el
    cd $workingdir

    echo
    while true; do
        echo "This script enables addition or removal of features"
        echo "  that are provided as part of the Loop with Patches selection"
        echo "  in the Build Select Script"
        echo
        echo "These features are documented on the Loop and Learn web site"
        echo "  https://www.loopandlearn.org/main-lnl-patches/"
        echo
        echo "This script lets you add or remove these features individually"
        echo
        echo "For proper operation, add or remove both"
        echo "  CustomTypeOne LoopPatches part 1 and 2"
        echo
        echo -e "${INFO_FONT}Directory where customizations will be applied:${NC}"
        echo -e "${INFO_FONT}  ${workingdir/$HOME/~}${NC}"
        echo

        display_applied_patches
        display_unapplicable_patches

        if has_available_customizations; then
            echo -e "${INFO_FONT}Select a customization to apply or another option in the list:${NC}"
        else
            echo -e "${INFO_FONT}There are no available customizations. Select an option in the list:${NC}"
        fi
        for i in ${!name[@]}; do
            if git apply --check "${mytmpdir}/${file[$i]}.patch" --directory="${folder[$i]}" >/dev/null 2>&1; then
                echo "$((${i}+1))) ${name[$i]}"
            fi
        done

        if [ "$has_applied_patches" = true ]; then
            echo "$((${#name[@]}+1))) Remove a customization"
        fi
        echo "$((${#name[@]}+2))) $(exit_or_return_menu)"
        echo "$((${#name[@]}+3))) $(exit_or_return_menu) and open Xcode"

        read -p "Enter your choice: " choice
        if [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le $((${#name[@]}+3)) ]]; then
            if [[ $choice -le ${#name[@]} ]]; then
                index=$(($choice-1))
                apply "${name[$index]}" "${file[$index]}" "${folder[$index]}";
                return_when_ready
            elif [[ $choice -eq $((${#name[@]}+1)) ]]; then
                section_separator
                echo -e "${INFO_FONT}Select a customization to remove:${NC}"

                for i in ${!name[@]}; do
                    if git apply --reverse --check "${mytmpdir}/${file[$i]}.patch" --directory="${folder[$i]}" >/dev/null 2>&1; then
                        echo "$((${i}+1))) ${name[$i]}"
                    fi
                done

                echo "*) Any other key will exit to last menu"
                read -p "Enter your choice: " choice
                if [[ $choice =~ ^[0-9]+$ && $choice -ge 1 && $choice -le ${#name[@]} ]]; then
                    index=$(($choice-1))
                    revert "${name[$index]}" "${file[$index]}" "${folder[$index]}";
                    return_when_ready
                fi
            elif [[ $choice -eq $((${#name[@]}+2)) ]]; then
                exit 0
            elif [[ $choice -eq $((${#name[@]}+3)) ]]; then
                echo -e "${INFO_FONT}Starting Xcode, please wait...${NC}"
                xed .
                exit 0
            fi
        else
            echo
            echo -e "${ERROR_FONT}Invalid choice.${NC}"
            return_when_ready
        fi
        section_separator
    done
else
    exit 1
fi
