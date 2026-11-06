#!/bin/bash
# Regenerates openhab.js, openhab.min.js and README.md from python-openhab-rest-client.
# Only Python is needed:  pip install python-openhab-rest-client rjsmin
#   bash tools/build.sh [path/to/python-openhab-rest-client/openhab]
set -e
cd "$(dirname "$0")/.."
PY=${1:-$(python3 -c 'import openhab, os; print(os.path.dirname(openhab.__file__))')}
python3 tools/py2js.py "$PY" > tools/.classes.js
{ cat tools/core_head.js tools/.classes.js tools/core_tail.js; cat <<'X'

// All classes are global (class declarations of a classic script) and also under window.openHAB
window.openHAB = openHAB;
X
} > openhab.js
rm tools/.classes.js
python3 - <<'X'
import re, rjsmin
src = open("openhab.js", encoding="utf-8").read()
licence = re.match(r"/\*\*.*?\*/", src, re.S).group(0)
open("openhab.min.js", "w", encoding="utf-8").write(licence + "\n" + rjsmin.jsmin(src) + "\n")
X
python3 tools/py2js.py "$PY" --markdown > tools/reference.md
cat tools/readme_head.md tools/reference.md tools/readme_tail.md > README.md
echo "built from $PY: $(wc -l < openhab.js) lines, openhab.min.js $(wc -c < openhab.min.js) bytes"
