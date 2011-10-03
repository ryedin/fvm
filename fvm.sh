# feather Version Manager

# liberally based on:

# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

# adapted for use with feather by Ryan Gahl (ryan@thevolary.com)

# Auto detect the FVM_DIR
if [ ! -d "$FVM_DIR" ]; then
    export FVM_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}); pwd)
fi

# we'll make a hard dependency on wget wince curl had issues with github's auto tarballing urls
if [ ! `which wget` ]; then
    echo 'Need wget to proceed.' >&2;
    return 13
fi

# Expand a version using the version cache
fvm_version()
{
    PATTERN=$1
    VERSION=''
    # If it looks like an explicit version, don't do anything funny
    if [[ "$PATTERN" == v*.*.* ]]; then
        VERSION="$PATTERN"
    fi
    if [[ "$PATTERN" == ./ ]]; then
        VERSION="pwd"
    fi
    if [ ! "$VERSION" ]; then
        echo "N/A"
        return 13
    elif [ -e "$FVM_DIR/$VERSION" ]; then
        (cd $FVM_DIR; \ls -dG "$VERSION")
    else
        echo "$VERSION"
    fi
}

fvm()
{
  if [ $# -lt 1 ]; then
    fvm help
    return
  fi
  case $1 in
    "help" )
      echo
      echo "Feather Version Manager"
      echo
      echo "Usage:"
      echo "    fvm help                    Show this message"
      echo "    fvm install <version>       Download and install a <version>"
      echo "    fvm use <version>           Modify PATH to use <version>.  If <version> is omitted, display current version."
      echo "    fvm ls                      Display a list of installed versions."
      echo
      echo "Example:"
      echo "    fvm install v0.1.3          Install a specific version number"
      echo
    ;;
    "install" )
      if [ $# -ne 2 ]; then
        fvm help
        return
      fi
      VERSION=`fvm_version $2`
      if (
        mkdir -p "$FVM_DIR/$VERSION" && \
        mkdir -p "$FVM_DIR/src" && \
        cd "$FVM_DIR/src" && \
        mkdir -p "$VERSION" && \
        cd "$VERSION" && \
        wget "https://github.com/theVolary/feather/tarball/$VERSION" -O "$VERSION" && \
        tar -xzf "$VERSION" && \
        cd the* && \
        cp -r * ../../../${VERSION}/ && \
        cd ../../../${VERSION}/ && \
        modules=`cat bin/setup.sh | egrep -o 'MODULES=\(.*\)' | sed -E 's/MODULES=\( (.*) \)/\1/'`
        echo "modules = "${modules}
        npm install ${modules}        
        )
      then
        fvm use $VERSION
      else
        echo "fvm: install $VERSION failed!"
      fi
    ;;
    "use" )
      if [ $# -ne 2 ]; then
        if [[ "$FEATHER_HOME" != "" ]]; then
          echo "Currently using feather "`expr //$FEATHER_HOME : '.*/\(.*\)'`
        else
          printf "\033[1;31mNo FEATHER_HOME variable found, or it is empty.\e[0m"
          fvm help
        fi
        return
      fi
      VERSION=`fvm_version $2`
      if [ "$VERSION" == pwd ]; then
        featherpath=`pwd`
        FEATHER_HOME=$featherpath
        PATH="$featherpath/bin:$PATH"
        VERSION=$featherpath
      else
        if [ ! -d $FVM_DIR/$VERSION ]; then
          echo "$VERSION version is not installed yet"
          return;
        fi
        if [[ $PATH == *$FVM_DIR/*/bin* ]]; then
          PATH=${PATH%$FVM_DIR/*/bin*}$FVM_DIR/$VERSION/bin${PATH#*$FVM_DIR/*/bin}
        else
          PATH="$FVM_DIR/$VERSION/bin:$PATH"
        fi
        FEATHER_HOME=$FVM_DIR/$VERSION
      fi
      export PATH
      export FEATHER_HOME
      hash -r  
      echo "Now using feather $VERSION"
    ;;
    "ls" )
      echo "Installed Versions:"
      ls $FVM_DIR | grep ^v
    ;;
    "version" )
        fvm_version $2
    ;;
    * )
      fvm help
    ;;
  esac
}