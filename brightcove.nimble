# Package

version       = "0.2.0"
author        = "Thiago Navarro"
description   = "Brightcove player parser"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 1.6.4"
requires "util"

task genDocs, "Generate documentation":
  exec "rm -r docs; nim doc -d:usestd --git.commit:master --git.url:https://github.com/thisago/brightcove --project -d:ssl --out:docs ./src/brightcove.nim"
