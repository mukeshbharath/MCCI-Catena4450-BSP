#!/bin/bash

##############################################################################
#
# Module:	gitboot.sh
#
# Function:
# 	Load the repositories for building this sketch
#
# Copyright notice:
# 	This file copyright (C) 2017 by
#
#		MCCI Corporation
#		3520 Krums Corners Road
#		Ithaca, NY 14850
#
#	Distributed under license.
#
# Author:
#	Terry Moore, MCCI	April 2017
#
##############################################################################

PNAME=$(basename "$0")
PDIR=$(dirname "$0")
OPTDEBUG=0
OPTVERBOSE=0

##############################################################################
# verbose output
##############################################################################

function _verbose {
	if [ "$OPTVERBOSE" -ne 0 ]; then
		echo "$PNAME:" "$@" 1>&2
	fi
}

#### _error: define a function that will echo an error message to STDERR.
#### using "$@" ensures proper handling of quoting.
function _error {
	echo "$@" 1>&2
}

#### _fatal: print an error message and then exit the script.
function _fatal {
	_error "$@" ; exit 1
}

##############################################################################
# LIBRARY_ROOT_DEFAULT: the path to the Arduino libraries on your
# system. If set in the environment, we use that; otherwise we set it
# according to the OS in use.
##############################################################################
UNAME=$(uname)
if [ X"$LIBRARY_ROOT_DEFAULT" != X ]; then
  if [ ! -d "$LIBRARY_ROOT_DEFAULT" ]; then
    _error "LIBRARY_ROOT_DEFAULT not a directory: ${LIBRARY_ROOT_DEFAULT}"
  elif [ ! -x "$LIBRARY_ROOT_DEFAULT" ]; then
    _error "LIBRARY_ROOT_DEFAULT not searchable: ${LIBRARY_ROOT_DEFAULT}"
  elif [ ! -w "$LIBRARY_ROOT_DEFAULT" ]; then
    _error "LIBRARY_ROOT_DEFAULT not writable: ${LIBRARY_ROOT_DEFAULT}"
  fi
elif [ "$UNAME" = "Linux" ]; then
  LIBRARY_ROOT_DEFAULT=~/Arduino/libraries
elif [ "$UNAME" = "Darwin" ]; then
  LIBRARY_ROOT_DEFAULT=~/Documents/Arduino/libraries
elif [ "${UNAME:0:5}" = "MINGW" ]; then
  LIBRARY_ROOT_DEFAULT=~/Documents/Arduino/libraries
else
  echo "Can't detect OS: set LIBRARY_ROOT_DEFAULT to path to Arduino libraries" 1>&2
  exit 1
fi

##############################################################################
# load the list of repos
##############################################################################

### use a long quoted string to get the repositories
### into LIBRARY_REPOS.  Multiple lines for readabilty.
LIBRARY_REPOS_DAT="${PDIR}/git-repos.dat"
if [ ! -f "${LIBRARY_REPOS_DAT}" ]; then
	_fatal "can't find suitable git-repos.dat:" "${LIBRARY_REPOS_DAT}"
fi

# parse the repo file, deleting comments
LIBRARY_REPOS=$(sed -e 's/#.*$//' ${PDIR}/git-repos.dat)

##############################################################################
# Scan the options
##############################################################################

LIBRARY_ROOT="${LIBRARY_ROOT_DEFAULT}"
USAGE="${PNAME} -[D H l* T u v]"

#OPTDEBUG and OPTVERBOS are above
OPTDRYRUN=0
OPTUPDATE=0

NEXTBOOL=1
while getopts DHl:nTuv c
do
	# postcondition: NEXTBOOL=0 iff previous option was -n
	# in all other cases, NEXTBOOL=1
	if [ $NEXTBOOL -eq -1 ]; then
		NEXTBOOL=0
	else
		NEXTBOOL=1
	fi

	case "$c" in
	D)	OPTDEBUG=$NEXTBOOL;;
	l)	LIBRARY_ROOT="$OPTARG";;
	n)	NEXTBOOL=-1;;
	T)	OPTDRYRUN=$NEXTBOOL;;
	u)	OPTUPDATE=$NEXTBOOL;;
	v)	OPTVERBOSE=$NEXTBOOL;;
	H)	less 1>&2 <<.
Pull all the repos for this project from github.

Usage:
	$USAGE

Switches:
	-D		turn on debug mode; -nD is the default.
	-l {path} 	sets the target "arduino library path".
			Default is $LIBRARY_ROOT_DEFAULT.
	-T		Do a trial run (go through the motions).
	-u		Do a git pull if repo already is found.
	-v		turns on verbose mode; -nv is the default.
	-H		prints this help message.
.
		exit 0;;
	\?)	echo "$USAGE" 1>&2
		exit 1;;
	esac
done

#### get rid of scanned options ####
shift `expr $OPTIND - 1`

if [ $# -ne 0 ]; then
	_error "extra arguments: $@"
fi

#### make sure LIBRARY_ROOT is really a directory
if [ ! -d "$LIBRARY_ROOT" ]; then
	_fatal "LIBRARY_ROOT: Can't find Arduino libraries:" "$LIBRARY_ROOT"
fi

#### make sure we can cd to that directory
cd "$LIBRARY_ROOT" || _fatal "can't cd:" "$LIBRARY_ROOT"

#### keep track of successes in CLONED_REPOS, failures in NG_REPOS,
#### and skipped repos in SKIPPED_REPOS
CLONED_REPOS=	#empty
NG_REPOS=	#empty
SKIPPED_REPOS=	#empty
PULLED_REPOS=	#empty

#### scan through each of the libraries. Don't quote LIBRARY_REPOS
#### because we want bash to split it into words.
for r in $LIBRARY_REPOS ; do
	# given "https://github.com/something/somerepo.git", set rname to "somerepo"
	rname=$(basename $r .git)

	#
	# if there already is a target Arduino library of that name,
	# skip the download.
	#
	if [ -d $rname ]; then
		if [ $OPTUPDATE -eq 0 ]; then
			echo "repo $r already exists as $rname, and -u not specfied"
			SKIPPED_REPOS="${SKIPPED_REPOS}${SKIPPED_REPOS:+ }$rname"
		else
			if [ "$OPTDRYRUN" -ne 0 ]; then
				_verbose Dry-run: skipping git pull "$r"
			elif ( cd $rname && _verbose $rname: && git pull ; ); then
				# add to the list; ${PULLED_REPOS:+ }
				# inserts a space after each repo (but nothing
				# if PULLED_REPOS is empty)
				PULLED_REPOS="${PULLED_REPOS}${PULLED_REPOS:+ }$rname"
			else
				# error; print message and remember.
				_error "Can't pull $r to $rname"
				NG_REPOS="${NG_REPOS}${NG_REPOS:+ }$rname"
			fi
		fi
	#
	# otherwise try to clone the repo.
	#
	else
		# clone the repo, and record results.
		if [ "$OPTDRYRUN" -ne 0 ]; then
			_verbose Dry-run: skipping git clone "$r"
		elif git clone "$r" ; then
			# add to the list; ${CLONED_REPOS:+ }
			# inserts a space after each repo (but nothing
			# if CLONED_REPOS is empty)
			CLONED_REPOS="${CLONED_REPOS}${CLONED_REPOS:+ }$rname"
		else
			# error; print message and remember.
			_error "Can't clone $r to $rname"
			NG_REPOS="${NG_REPOS}${NG_REPOS:+ }$rname"
		fi
	fi
done

#### print final messages
echo
echo "==== Summary ====="
if [ -z "${NG_REPOS}" ]; then
	echo "No repos with errors"
else
	echo "Repos with errors:     ${NG_REPOS}"
fi
if [ -z "${SKIPPED_REPOS}" ]; then
	echo "No repos skipped."
else
	echo "Repos skipped:         ${SKIPPED_REPOS}"
fi
if [ -z "${PULLED_REPOS}" ]; then
	echo "*** no repos were pulled ***"
else
	echo "Repos pulled:          ${PULLED_REPOS}"
fi
if [ -z "${CLONED_REPOS}" ]; then
	echo "*** no repos were cloned. ***"
else
	echo "Repos downloaded:      ${CLONED_REPOS}"
fi
if [ -z "${NG_REPOS}" ]; then
	exit 1
else
	exit 0
fi
