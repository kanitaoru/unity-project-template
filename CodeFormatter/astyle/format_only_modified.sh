#! /bin/sh -e

echo "format only modified files."

# どこからでも呼び出せるようにする。
cd `git rev-parse --show-toplevel`

source CodeFormatter/astyle/targets.sh

# ブランチ分岐元から現在までに更新された *.cs ファイルを抽出する
# delete差分を対象にするとエラーになるのでdiff-filter使って要りそうなやつだけ対象にする
DIFF_CS_FILES=$(git diff --name-only --diff-filter=ACMRTX $(git show-branch --merge-base master HEAD) "${TARGETS[@]}")

if [ -z "$DIFF_CS_FILES" ]; then
    echo "no modified cs files."
    echo "done."
    exit 0
fi

if [ "$OS" == 'Windows_NT' ]; then
    ASTYLE_BIN='CodeFormatter/astyle/Astyle-for-Win.exe';
else
    ASTYLE_BIN='CodeFormatter/astyle/astyle';
fi

${ASTYLE_BIN} $DIFF_CS_FILES -I --options=CodeFormatter/options/csharp.txt

echo "done."
