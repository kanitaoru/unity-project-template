#!/bin/sh -e

CMDNAME=`basename $0`

PROJECT_NAME="ProjectTemplate"
GIT_ROOT=`git rev-parse --show-toplevel`
PROJECT_PATH="${GIT_ROOT}/${PROJECT_NAME}"
UNITY_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"

usage()
{
    echo "Usage: $CMDNAME [-t BUILD_TARGET(ios|android|etc)] [-e BUILD_ENV(dev|release|etc)] [-n BUILD_NUMBER(ex. 13)]"
    echo "-p : export as project."
    echo "-n : build number."
}

while getopts t:e:n:p OPT
do
  case $OPT in
    "t" ) OPT_TARGET="TRUE" ; readonly BUILD_TARGET="$OPTARG" ;;
    "e" ) OPT_ENV="TRUE" ; readonly BUILD_ENV="$OPTARG" ;;
    "n" ) OPT_BUILD_NUMBER="TRUE" ; readonly BUILD_NUMBER="-buildNumber $OPTARG" ;;
    "p" ) OPT_EXPORT_AS_PROJECT="TRUE" ; readonly BUILD_EXPORT_AS_PROJECT="-exportAsProject" ;;
      * ) echo "Option Error" 1>&2
          usage
          exit 1 ;;
  esac
done

OPT_COMPLETE="TRUE"

if [ "$OPT_TARGET" != "TRUE" ]; then
    echo 'Error: "-t" オプションで BuildTarget を指定してください。 [ios|android|osx]'
    OPT_COMPLETE="FALSE"
fi

if [ "$OPT_ENV" != "TRUE" ]; then
    echo 'Error: "-e" オプションで BuildEnvironment を指定してください。 [dev|release]'
    OPT_COMPLETE="FALSE"
fi

if [ "$OPT_COMPLETE" != "TRUE" ]; then
    echo 'Erorr: 何らかのオプションに不備があります。'
    usage
    exit 1
fi

"${UNITY_PATH}" -batchmode -projectPath $PROJECT_PATH -buildTarget $BUILD_TARGET -env $BUILD_ENV $BUILD_EXPORT_AS_PROJECT $BUILD_NUMBER -executeMethod AppBuilder.BuildByCommand -logFile /dev/stdout -quit

exit 0
