### Leopard Language YACC


## Overview

Leopard Language Parser (LLP) requires  LALR(1) parse generator, therefore like golang found that YACC and specifically
`goyacc` to be suited to our needs.

You will need to install the golang command line tools and or potentially clone the `cmd/parser` from github.com

```
go install github.com/golang/tools/cmd@latest
```

Then you will need to `cd ~/projec_dir/generator` , `generator.go` lists the instructions to run to `goyacc` tool.

```
go generate
go build
cd main
go build
go run main.go
```
 This will run a test of the parser which takes keyoard input to parse `>` to exit type `exit`




### Current Development Progress With Parser

1. Need to parse attributes and pass them to the lex buffers
