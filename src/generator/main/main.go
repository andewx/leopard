package main

import (
	"bufio"
	"io"
	"log"
	"os"
	"strings"

	"github.com/andewx/leopard/src/generator"
)

func main() {
	in := bufio.NewReader(os.Stdin)
	for {
		if _, err := os.Stdout.WriteString("> "); err != nil {
			log.Fatalf("WriteString: %s", err)
		}

		line, err := in.ReadBytes('\n')
		if err == io.EOF {
			return
		}
		if err != nil {
			log.Fatalf("ReadBytes: %s", err)
		}

		if strings.Contains(string(line), "exit") {
			return
		}

		lexer := generator.LeoLex{Source: line, Stream: line}
		generator.LeoParse(&lexer)
	}
}
