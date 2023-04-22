# LoopBuildScripts

These scripts simplify some tasks for building Loop and other DIY code from the GitHub repositories.

There are several build scripts for specific code.
* The BuildLoop script guides the user through building Loop or Loop Follow and has some useful Utilities.
* The other BuildXXX scripts are for a single repository of code.

### Build Select script

This is documented in

* [LnL: Build-Select](https://www.loopandlearn.org/build-select)
* [LoopDocs: Build-Select](https://loopkit.github.io/loopdocs/build/step14/#download-loop)

1. Open terminal
2. Copy/Paste this code into terminal (use copy icon, bottom right): 

```
/bin/bash -c "$(curl -fsSL \
  https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/BuildLoop.sh)"
```

3. Hit Enter and follow prompts


### Other Scripts

The other scripts can be run with the following commands

1. Open terminal
2. Copy/Paste selected code into terminal (use copy icon, bottom right):
3. Hit Enter and follow prompts

#### BuildLoopCaregiver.sh - be sure to read about [LoopCaregiver](https://loopkit.github.io/loopdocs/nightscout/remote-overrides/#loopcaregiver)

```
/bin/bash -c "$(curl -fsSL \
  https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/BuildLoopCaregiver.sh)"
```

#### BuildFreeAPS.sh - this version is based on Loop 2.2.x and is not being updated
```
/bin/bash -c "$(curl -fsSL 
  https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/BuildFreeAPS.sh)"
```

#### BuildLoopFixedDev.sh - not being updated frequently (see details below)
```
/bin/bash -c "$(curl -fsSL \
  https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/main/BuildLoopFixedDev.sh)"
```
* BuildLoopFixedDev.sh was used a lot prior to the release of Loop 3
  * It clones the development branch for Loop
  * Then it performs a git checkout to a specific commit
  * After the release of Loop 3, this is not being updated often
  * If you are testing the dev branch, this is a fine script for the initial download, but then you should update it manually to the latest dev
  * Once script completes, in the same terminal window, issue these commands:
    * `cd LoopWorkspace; git checkout dev; git pull --recurse`
    * and then build
  * The rest of the bullets might become true later - but are not true right now - the script is rarely updated
    * The commit number for this script is updated after it has been lightly tested
    * Why is this done?
      - Avoids using the script to build a commit that has an issue and requires updating
      - This is a rare occurrence, but it does happen during development

## Developer Tips

When these scripts are being modified and tested, the developers use some special flags to enable them to test certain functions quickly.

When testing in a different branch, prior to merging into main, use the following command format where you replace "main" with the branch name you are testing.

```
export SCRIPT_BRANCH="main"&&/bin/bash -c "$(curl -fsSL \
  https://raw.githubusercontent.com/loopnlearn/LoopBuildScripts/$SCRIPT_BRANCH/BuildLoop.sh)"

```

When testing locally, there are other test variables you can configure. Be sure to read these two files:
* custom_config.sh
* clear_custom_config.sh
