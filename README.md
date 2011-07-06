fvm
===

fvm auto downloads tagged packages from [https://github.com/theVolary/feather](theVolary's feather repo) and sets up environment variables so you can easily switch between released(tagged) versions of feather runtimes.

### Installation
- clone this repo or just copy fvm.sh into a folder called 'fvm' (name isn't really important but for sake of these directions we're assuming you went with 'fvm').
- source the fvm.sh file (`. fvm.sh`)
- install/use:
  - `fvm install v0.1.3` (note: `install` automatically calls `use` when it's finished)
  - `fvm use v0.1.2` (uses a previously installed version)
  - `fvm use ./` (this version of the use command allows you to use a custom or bleeding edge version that's on your local machine. You must, of course, use this only from within the top-level `feather` folder that you wish to make the current working version)

### Automation
Just like with nvm, we like to edit our .bashrc file so that fvm.sh is sourced at startup:
    
    FVM_HOME=~/mainline/fvm
    . $FVM_HOME/fvm.sh
    fvm use v0.1.3
   
(and of course you would update the final line to use a new version as you upgrade the "default" version on your machine)