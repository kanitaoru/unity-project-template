#!/bin/sh

# どこからでも呼び出せるようにする。
cd `git rev-parse --show-toplevel`

if [ "$OS" == 'Windows_NT' ]; then
    ASTYLE_BIN='CodeFormatter/astyle/Astyle-for-Win.exe';
else
    ASTYLE_BIN='CodeFormatter/astyle/astyle';
fi

source CodeFormatter/astyle/targets.sh

${ASTYLE_BIN} --recursive "${TARGETS[@]}" -I --options=CodeFormatter/options/csharp.txt
