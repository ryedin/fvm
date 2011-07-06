# feather Version Manager

# liberally based on:

# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

# Auto detect the FVM_DIR
if [ ! -d "$FVM_DIR" ]; then
    export FVM_DIR=$(cd $(dirname ${BASH_SOURCE[0]:-$0}); pwd)
fi

# Emulate curl with wget, if necessary
if [ ! `which wget` ]; then
    echo 'Need wget to proceed.' >&2;
    return 13
fi

# Expand a version using the version cache
fvm_version()
{
    PATTERN=$1
    VERSION=''
    # if [ -f "$FVM_DIR/alias/$PATTERN" ]; then
    #     fvm_version `cat $FVM_DIR/alias/$PATTERN`
    #     return
    # fi
    # If it looks like an explicit version, don't do anything funny
    if [[ "$PATTERN" == v*.*.* ]]; then
        VERSION="$PATTERN"
    fi
    if [[ "$PATTERN" == ./ ]]; then
        VERSION="pwd"
    fi
    # The default version is the current one
    # if [ ! "$PATTERN" -o "$PATTERN" = 'current' ]; then
    #     VERSION=`node -v 2>/dev/null`
    # fi
    # if [ "$PATTERN" = 'stable' ]; then
    #     PATTERN='*.*[02468].'
    # fi
    # if [ "$PATTERN" = 'latest' ]; then
    #     PATTERN='*.*.'
    # fi
    # if [ "$PATTERN" = 'all' ]; then
    #     (cd $FVM_DIR; \ls -dG v* 2>/dev/null || echo "N/A")
    #     return
    # fi
    # if [ ! "$VERSION" ]; then
    #     VERSION=`(cd $FVM_DIR; \ls -d v${PATTERN}* 2>/dev/null) | sort -t. -k 2,1n -k 2,2n -k 3,3n | tail -n1`
    # fi
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
      echo "    fvm use <version>           Modify PATH to use <version>"
      # echo "    fvm ls                      List versions (installed versions are blue)"
      # echo "    fvm ls <version>            List versions matching a given description"
      # echo "    fvm deactivate              Undo effects of FVM on current shell"
      # echo "    fvm sync                    Update the local cache of available versions"
      # echo "    fvm alias [<pattern>]       Show all aliases beginning with <pattern>"
      # echo "    fvm alias <name> <version>  Set an alias named <name> pointing to <version>"
      echo
      echo "Example:"
      echo "    fvm install v0.1.3          Install a specific version number"
      # echo "    fvm use stable              Use the stable release"
      # echo "    fvm install latest          Install the latest, possibly unstable version"
      # echo "    fvm use 0.2                 Use the latest available 0.2.x release"
      # echo "    fvm alias default v0.4.0    Set v0.4.0 as the default" 
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
        wget "https://github.com/theVolary/feather/tarball/$VERSION" && \
        tar -xzf "$VERSION" && \
        cd the* && \
        cp -r * ../../../${VERSION}/ && \
        cd ../../../${VERSION}/ && \
        modules=`cat bin/setup.sh | egrep -o 'MODULES=\(\s([^"]*)\s\)' | sed -r 's/MODULES=\(\s([^"]*)\s\)/\1/'`
        echo "modules = "${modules}
        npm install ${modules}        
        )
      then
        fvm use $VERSION
      else
        echo "fvm: install $VERSION failed!"
      fi
    ;;
    # "deactivate" )
    #   if [[ $PATH == *$FVM_DIR/*/bin* ]]; then
    #     export PATH=${PATH%$FVM_DIR/*/bin*}${PATH#*$FVM_DIR/*/bin:}
    #     hash -r
    #     echo "$FVM_DIR/*/bin removed from \$PATH"
    #   else
    #     echo "Could not find $FVM_DIR/*/bin in \$PATH"
    #   fi
    #   if [[ $MANPATH == *$FVM_DIR/*/share/man* ]]; then
    #     export MANPATH=${MANPATH%$FVM_DIR/*/share/man*}${MANPATH#*$FVM_DIR/*/share/man:}
    #     echo "$FVM_DIR/*/share/man removed from \$MANPATH"
    #   else
    #     echo "Could not find $FVM_DIR/*/share/man in \$MANPATH"
    #   fi
    # ;;
    "use" )
      if [ $# -ne 2 ]; then
        fvm help
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
      # if [[ $MANPATH == *$FVM_DIR/*/share/man* ]]; then
      #   MANPATH=${MANPATH%$FVM_DIR/*/share/man*}$FVM_DIR/$VERSION/share/man${MANPATH#*$FVM_DIR/*/share/man}
      # else
      #   MANPATH="$FVM_DIR/$VERSION/share/man:$MANPATH"
      # fi
      export PATH
      export FEATHER_HOME
      hash -r
      # export MANPATH
      # export FVM_PATH="$FVM_DIR/$VERSION/lib/node"
      # export FVM_BIN="$FVM_DIR/$VERSION/bin"      
      echo "Now using feather $VERSION"
    ;;
    # "ls" )
    #   if [ $# -ne 1 ]; then
    #     fvm_version $2
    #     return
    #   fi
    #   fvm_version all
    #   for P in {stable,latest,current}; do
    #       echo -ne "$P: \t"; fvm_version $P
    #   done
    #   fvm alias
    #   echo "# use 'fvm sync' to update from nodejs.org"
    # ;;
    # "alias" )
    #   mkdir -p $FVM_DIR/alias
    #   if [ $# -le 2 ]; then
    #     (cd $FVM_DIR/alias && for ALIAS in `\ls $2* 2>/dev/null`; do
    #         DEST=`cat $ALIAS`
    #         VERSION=`fvm_version $DEST`
    #         if [ "$DEST" = "$VERSION" ]; then
    #             echo "$ALIAS -> $DEST"
    #         else
    #             echo "$ALIAS -> $DEST (-> $VERSION)"
    #         fi
    #     done)
    #     return
    #   fi
    #   if [ ! "$3" ]; then
    #       rm -f $FVM_DIR/alias/$2
    #       echo "$2 -> *poof*"
    #       return
    #   fi
    #   mkdir -p $FVM_DIR/alias
    #   VERSION=`fvm_version $3`
    #   if [ $? -ne 0 ]; then
    #     echo "! WARNING: Version '$3' does not exist." >&2 
    #   fi
    #   echo $3 > "$FVM_DIR/alias/$2"
    #   if [ ! "$3" = "$VERSION" ]; then
    #       echo "$2 -> $3 (-> $VERSION)"
    #       echo "! WARNING: Moving target. Aliases to implicit versions may change without warning."
    #   else
    #     echo "$2 -> $3"
    #   fi
    # ;;
    # "sync" )
    #     [ "$NOCURL" ] && curl && return
    #     LATEST=`fvm_version latest`
    #     STABLE=`fvm_version stable`
    #     (cd $FVM_DIR
    #     rm -f v* 2>/dev/null
    #     printf "# syncing with nodejs.org..."
    #     for VER in `curl -s http://nodejs.org/dist/ -o - | grep 'node-v.*\.tar\.gz' | sed -e 's/.*node-//' -e 's/\.tar\.gz.*//'`; do
    #         touch $VER
    #     done
    #     echo " done."
    #     )
    #     [ "$STABLE" = `fvm_version stable` ] || echo "NEW stable: `fvm_version stable`"
    #     [ "$LATEST" = `fvm_version latest` ] || echo "NEW latest: `fvm_version latest`"
    # ;;
    # "clear-cache" )
    #     rm -f $FVM_DIR/v* 2>/dev/null
    #     echo "Cache cleared."
    # ;;
    "version" )
        fvm_version $2
    ;;
    * )
      fvm help
    ;;
  esac
}

# fvm ls default >/dev/null 2>&1 && fvm use default >/dev/null
