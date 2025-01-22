# ANTLRV4 Production Readme Notes

**Overview** - Our leo project utilizes the Antlr4 Java runtime as a parser generator. The following notes serve as a guide for generation of the *Leo* language grammar via ANTLR-V4. ANTLR is a Adaptive LL(*) Parser. (ALL) whereas most other parser generators are LALR. LL Grammars work top down. 
- **Installing ANTLR-V4**
- **Alias ANTLR-V4 Tools**
- **Generating Go Code**
- **Generating ANTLR-4 Parser with Tool Access for Verification**

## Installing ANTLR-V4

Download ANTLRV4 library from [Antlr.org](https://www.antlr.org/download.html) using the latest library. Most users will download the Java binaries JAR and install into their `usr/local/lib`


Go to your local user bash profile and add ANTLR to your java classpath
```{sh}
export CLASSPATH=".:usr/local/lib/antlr4-4.13.3-complete.jar:{$CLASSPATH}"
```

## Alias ANTLR-V4 Tools

Use the following command to alias `antlr4` and `grun` command line name to the `TestRig` for ANTLR. Helpful to add to your `.zprofile`

Alternatively you can use `pip install antlr4` however these are not always the latest tools and you will need to find where it installs the jar files usually the `{user}/.m2/` directory.

```
alias antlr4='java -Xmx500M -cp "/usr/local/lib/antlr4-4.13.3-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
alias grun='java -Xmx500M -cp "/usr/local/lib/antlr4-4.13.3-complete.jar:$CLASSPATH" org.antlr.v4.gui.TestRig'
```


You can optionally test your Grammars using the utility `TestRig` known as grun.

```
grun <grammar-name> <rule-to-test> <input-filename(s)>
```

If you want to use the testing tool, you need to generate a Java parser, even if your program is written in another language. This can be done just by selecting a different option with antlr4.

Grun is useful when testing manually the first draft of your grammar. As it becomes more stable, you may want to relay on automated tests (we will see how to write them).

Grun also has a few useful options: -tokens, to show the tokens detected,  -gui to generate an image of the AST.


## Generating Go Code

Go generate is a powerful and neccessary tool, there are instances where, in universal computation we should be able to generate code. This property is neccessary for universal computation and turing completeness.

When using a third-party code generator the Go tool may not have a mechanism to run a code generator.

`go generate` tool scans for special comments in the Go source code and runs commands. This is not part of `go build`. 

In our case we decide to run `go generate ./generate.sh`. Which is a bash shell program. 

To run it during the build process we add the line 

//go:generate ./generate.sh

This shell file could include our sequence of ANTLR-V4 commands

## Generating ANTLR-4 Parser with Tool Access for Verification
For our parser in normal circumstances we would like to create both the **Vistor** and **Listener** APIs. Which for our case we generate a Visitor and Listener for the *Lexer* and the *Parser* grammars.

```
 antlr4 -visitor -listener -Dlanguage=Java -o parser/java leo_lexer.g4 
 antlr4 -visitor -listener -Dlanguage=Java -o parser/java leo_parser.g4 
 antlr4 -visitor -listener -Dlanguage=Go -o parser leo_lexer.g4 
 antlr4 -visitor -listener -Dlanguage=Go -o parser leo_parser.g4 
```

This outputs the Go parser into the `antlr/parser` folder and the Java parser into the `antlr/parser/java` folder


## Cleanup

There's an ANLTR bug where the tokenizer may not be able to evaluate a closing bracket. For now when generating the grammar in GoLang the `func (p *leo_parser) closingBracket()` function is left undefined for Go code. 

**Solution**

Add the follwing function to `leo_parser_parser.go`:

```
func (p *LeoParser) closingBracket() bool{
	stream := p.GetTokenStream()
	prevTokenType := stream.LA(1)
	return prevTokenType == LeoLexerR_PAREN || prevTokenType == LeoLexerR_CURLY
}
```

And in the function `func (p *leo_parser) StatementList()` change the `closingBracket()` function to `p.closingBracket()`


** For our Java Output** we must do the same. 

In `leo_parser.java` add the following to the leo_parser class:

```
	public final boolean closingBracket(){
	
		TokenStream stream = this.getInputStream();
		int prev_token = stream.LA(1);
		if(prev_token == R_PAREN || prev_token == R_CURLY){
			return true;
		}

		return false;

	}

```

And make sure all references to closingBracket() use `this.closingBracket()`

# Running Grun Test Harness

First make sure that your Grun attached CLASSPATH is the same as your ANTLR4 runtime version.

Ensure the `javac` has access to the external `antlr4-4.13.3-complete.jar`

We have added an IntelliJ project that should be able to be used for building otherwise you can compiles the files with `javac -D lib *.java`

Once the version history is sorted out you want to navigate to where you output your java class files when compiling the output java parser.

In our case that is `antlr/parser/java/lib` if we manually compiled.

If we compile with IntelliJ IDE then it will be in `antlr/parser/java/out/production/parser`


Once this is all set up to run grun we unfortunately have to navigate to the location of our `.class` files.

In `test_files` add:

```
export LEO_ARTIFACTS="/Users/briananderson/go/src/github.com/andewx/leo/src/parser/java/out/production/parser"
```

```
grun Leo sourceFile ../test_files/interface.go2 -gui
```

To run a test with visual result on the grammar











