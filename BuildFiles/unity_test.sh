# /bin/sh -e

# リポジトリ外から実行されたときでも意図通り動作するように移動しておく
cd $(dirname $0)

PROJECT_NAME="ProjectTemplate"
PROJECT_ROOT=`git rev-parse --show-toplevel`
UNITY_PROJECT="${PROJECT_ROOT}/${PROJECT_NAME}"
UNITY_PATH="/Applications/Unity/Unity.app/Contents/MacOS/Unity"

TEST_REPORT_DIR="${PROJECT_ROOT}/Build/test_report"
mkdir -p $TEST_REPORT_DIR

# Unity-TestRunnerの実行
# http://docs.unity3d.com/ja/current/Manual/CommandLineArguments.html
function test()
{
    local target=$1
    local result=$2
    
    # note: runEditorTestsが指定されている時、自動で終了するのでquitは必要ない
    time ${UNITY_PATH} -batchmode -projectPath $UNITY_PROJECT -buildTarget $target -runEditorTests -logFile /dev/stdout -editorTestsResultFile $result
    exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        exit $exit_code
    fi
}

test ios $TEST_REPORT_DIR/result_ios.xml
test android $TEST_REPORT_DIR/result_android.xml

exit 0
