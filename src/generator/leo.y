// Copyright 2013 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// This is an example of a goyacc program.
// To build it:
// goyacc -p "expr" expr.y (produces y.go)
// go build -o expr y.go
// expr
// > <type an expression>

%{

package generator

import (
	"bytes"
    "bufio"
	"io"
	"log"
	"os"
	"unicode/utf8"
    "regexp"
    "math/big"
    "fmt"
)

type Pos struct {
    Line int
    Column int
}

const LEX_ERROR = -1

type Node struct{
    Parent *Node
	Children []*Node
	Value string
    Position Pos
    Buffer *bytes.Buffer
    Rule string
    BigInt *big.Int
    BigFloat *big.Float
}

func NewNode(p *Node, name string, yylval *LeoSymType) *Node {
    var n *Node
    n = &Node{Parent: p, Rule:name, Children: make([]*Node,0),Buffer: bytes.NewBufferString("")}
    if yylval != nil{
        n.Position.Line = yylval.Tokenline
        n.Position.Column = yylval.Tokencolumn
        n.Value = yylval.Tokenstring
        n.Buffer.WriteString(yylval.Tokenstring)
        n.BigInt = yylval.Tokenint
        n.BigFloat = yylval.Tokenfloat
    }
    return n
}

func (n *Node) AddChild(c *Node) *Node {
    c.Parent = n
    n.Children = append(n.Children, c)
    return n
}

%}


%union {
    Tokentype int
    Tokenrule int
    Tokensubtype int
    Tokenbuffer *bytes.Buffer
    Tokenstring string
    Tokenname string
    Tokenline int
    Tokencolumn int
    Tokenpackage string
    Tokennode *Node
    Tokensymbol_index int
    Tokenerror error
    Tokenint *big.Int
    Tokenfloat *big.Float
}


    // Lexer Tokens
%token     INT  
%token     FLOAT  
%token     IMAGINARY  
%token    HEX  
%token     OCTAL  
%token     BINARY  

    // Strings and Characters
%token     STRING_LITERAL  
%token     CHAR_LITERAL  
%token    RUNE_LITERAL  

    // Whitespace, Tabs, Newlines, and Comments
%token     WHITESPACE  
%token     TAB  
%token     NEWLINE  
%token     COMMENT  

    // Identifiers
%token     IDENTIFIER  

    // Keywords
%token     PACKAGE  
%token     IMPORT  
%token     FUNC  
%token     VAR  
%token     CONST  
%token     TYPE  
%token     STRUCT  
%token     INTERFACE  
%token     MAP  
%token     CHANNEL  
%token     LAUNCH  
%token     SELECT  
%token     CASE  
%token     DEFAULT  
%token     FOR  
%token     RANGE  
%token     BREAK  
%token     CONTINUE  
%token     GOTO  
%token     IF  
%token    ELSE  
%token    SWITCH  
%token    RETURN  
%token    FALLTHROUGH  
%token    SAFE  

    
    // Keyword Type Primitives
%token    INT_TYPE  
%token    INT8_TYPE  
%token    INT16_TYPE  
%token    INT32_TYPE  
%token    INT64_TYPE  

%token    UINT_TYPE  
%token    UINT8_TYPE  
%token    UINT16_TYPE  
%token    UINT32_TYPE  
%token    UINT64_TYPE  

%token    FLOAT_TYPE  
%token    FLOAT16_TYPE  
%token    FLOAT32_TYPE  
%token    FLOAT64_TYPE  

%token    COMPLEX_TYPE  
%token    COMPLEX16_TYPE  
%token    COMPLEX32_TYPE  
%token    COMPLEX64_TYPE  

%token    BOOL_TYPE  
%token    STRING_TYPE  
%token    BYTE_TYPE  
%token    RUNE_TYPE  
%token    CHAR_TYPE   
%token    ERROR_TYPE  


    // Operators and Punctuation
%token    SEMICOLON  
%token    COLON  
%token    COMMA  
%token    PERIOD  
%token    ELLIPSIS  
%token    STAR  
%token    AMPERSAND  
%token    LBRACK  
%token    RBRACK  
%token    LBRACE  
%token    RBRACE  
%token    LPAREN  
%token    RPAREN  
%token    LANGLE  
%token   RANGLE  

%token    ASSIGN  
%token    NEW_ASSIGN  
%token    ADD_ASSIGN  
%token    SUB_ASSIGN  
%token    MUL_ASSIGN  
%token    QUO_ASSIGN  
%token    REM_ASSIGN  
%token    AND_ASSIGN  
%token    OR_ASSIGN  

%token    PLUS  
%token    MINUS  
%token    MUL  
%token    DIV  
%token    MOD  
%token    SHL  
%token    SHR  
%token    AND  
%token    OR  
%token    NOT  
%token    EQ  
%token    NEQ  
%token    LT  
%token   GT  
%token    LTE  
%token    GTE  
%token    NOT_AND  
%token    NOT_OR  

%token    SHL_ROTATE  
%token    SHR_ROTATE  
%token    BITWISE_AND  
%token    BITWISE_OR  
%token    BITWISE_XOR  
%token    BITWISE_NOT  
%token    NOT_EQ

// Special Tokens
%token    EOF  
%token    ILLEGAL  
%token    COMMENT_START  
%token    COMMENT_END  
%token    COMMENT_LINE  
%token    COMMENT_BLOCK  
%token    COMMENT_DOC  

// Additional Language Specific Tokens

%token    BRIDGE  
%token    CHANNEL_SEND  
%token    CHANNEL_RECEIVE  
%token    CHANNEL_CLOSE  
%token    CHANNEL_SELECT  
%token    TRANSFER  

%token    POINTER  
%token    REFERENCE  
%token    INDIRECT  
%token    TERMINAL 
%token    ILLEGAL


%type <Tokentype> INT FLOAT IMAGINARY HEX OCTAL BINARY STRING_LITERAL CHAR_LITERAL RUNE_LITERAL
%type <Tokentype> WHITESPACE TAB NEWLINE COMMENT
%type <Tokentype> IDENTIFIER
%type <Tokentype> PACKAGE IMPORT FUNC VAR CONST TYPE STRUCT INTERFACE MAP CHANNEL LAUNCH SELECT CASE DEFAULT FOR RANGE BREAK CONTINUE GOTO IF ELSE SWITCH RETURN FALLTHROUGH SAFE
%type <Tokentype> INT_TYPE INT8_TYPE INT16_TYPE INT32_TYPE INT64_TYPE UINT_TYPE UINT8_TYPE UINT16_TYPE UINT32_TYPE UINT64_TYPE FLOAT_TYPE FLOAT16_TYPE FLOAT32_TYPE FLOAT64_TYPE COMPLEX_TYPE COMPLEX16_TYPE COMPLEX32_TYPE COMPLEX64_TYPE BOOL_TYPE STRING_TYPE BYTE_TYPE RUNE_TYPE CHAR_TYPE ERROR_TYPE
%type <Tokentype> SEMICOLON COLON COMMA PERIOD ELLIPSIS STAR AMPERSAND LBRACK RBRACK LBRACE RBRACE LPAREN RPAREN LANGLE RANGLE
%type <Tokentype> ASSIGN NEW_ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN AND_ASSIGN OR_ASSIGN
%type <Tokentype> PLUS MINUS MUL DIV MOD SHL SHR AND OR NOT EQ NEQ LT GT LTE GTE NOT_AND NOT_OR
%type <Tokentype> SHL_ROTATE SHR_ROTATE BITWISE_AND BITWISE_OR BITWISE_XOR BITWISE_NOT
%type <Tokentype> BRIDGE CHANNEL_SEND CHANNEL_RECEIVE CHANNEL_CLOSE CHANNEL_SELECT TRANSFER
%type <Tokentype> POINTER REFERENCE INDIRECT
%type <Tokentype> EOF ILLEGAL COMMENT_START COMMENT_END COMMENT COMMENT_LINE COMMENT_BLOCK COMMENT_DOC TERMINAL

//Assign Left Right Precedence
%left PLUS MINUS
%left MUL DIV MOD

//Assign Left Right Boolean Conditional Preference
%left EQ NEQ LT GT LTE GTE
%left NOT_AND NOT_OR

//Assign Left Right Bitwise Preference
%left SHL SHR
%left AND OR
%left BITWISE_AND BITWISE_OR BITWISE_XOR
%left BITWISE_NOT

//Right Associative Prefix Operators
%right NOT

//Left Associative Assign
%left ASSIGN NEW_ASSIGN ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN QUO_ASSIGN REM_ASSIGN AND_ASSIGN OR_ASSIGN

//Declare Leo Language Grammar Rules
%start file_
%type <Tokennode> file_
%type <Tokennode> package_
%type <Tokennode> import_
%type <Tokennode> import_list
%type <Tokennode> top_declaration
%type <Tokennode> top_declaration_list
%type <Tokennode> func_
%type <Tokennode> var_
%type <Tokennode> const_
%type <Tokennode> type_
%type <Tokennode> struct_
%type <Tokennode> interface_
%type <Tokennode> map_
%type <Tokennode> channel_
%type <Tokennode> launch
%type <Tokennode> select_
%type <Tokennode> case_
%type <Tokennode> default_
%type <Tokennode> for_
%type <Tokennode> range_
%type <Tokennode> break_
%type <Tokennode> continue_
%type <Tokennode> goto_
%type <Tokennode> if_
%type <Tokennode> else_
%type <Tokennode> switch_
%type <Tokennode> return_
%type <Tokennode> fallthrough_
%type <Tokennode> safe
%type <Tokennode> id
%type <Tokennode> expr
%type <Tokennode> group_expr
%type <Tokennode> unary_expr
%type <Tokennode> binary_expr
%type <Tokennode> ternary_expr
%type <Tokennode> assign_expr
%type <Tokennode> new_assign_expr
%type <Tokennode> add_assign_expr
%type <Tokennode> accessor_expr
%type <Tokennode> index_expr
%type <Tokennode> slice_expr
%type <Tokennode> call_expr
%type <Tokennode> channel_send_expr
%type <Tokennode> channel_receive_expr
%type <Tokennode> range_expr
%type <Tokennode> bridge_expr
%type <Tokennode> transfer_expr
%type <Tokennode> statement
%type <Tokennode> block
%type <Tokennode> statement_list
%type <Tokennode> method
%type <Tokennode> field
%type <Tokennode> parameter
%type <Tokennode> parameter_list
%type <Tokennode> return_expr
%type <Tokennode> argument
%type <Tokennode> argument_list
%type <Tokennode> array_declaration
%type <Tokennode> slice_declaration
%type <Tokennode> symbol
%type <Tokennode> symbol_list
%type <Tokennode> array_index
%type <Tokennode> slice_index
%type <Tokennode> for_init
%type <Tokennode> for_condition
%type <Tokennode> for_post
%type <Tokennode> case_condition
%type <Tokennode> case_list
%type <Tokennode> case_clause
%type <Tokennode> default_clause
%type <Tokennode> for_range
%type <Tokennode> template_params
%type <Tokennode> return_params
%type <Tokennode> var_assign
%type <Tokennode> new_assign
%type <Tokennode> field_list;
%type <Tokennode> interface_method_list;
%type <Tokennode> interface_method;
%type <Tokennode> field;
%type <Tokennode> terminal;
%type <Tokennode> string_literal;

%%

terminal: SEMICOLON {$$ = NewNode(nil, "terminal", &LeoVAL)} | NEWLINE {$$ = NewNode(nil, "terminal", &LeoVAL)} | EOF {$$ = NewNode(nil, "terminal", &LeoVAL)} | ILLEGAL {$$ = NewNode(nil, "terminal", &LeoVAL)};
 
file_: package_ import_list top_declaration_list EOF 
    {
        fmt.Println(" File -> ")
        $$ = NewNode(nil, "file", &LeoVAL)
        $$.AddChild($1)
        $$.AddChild($2)
        $$.AddChild($3)
    };
package_: PACKAGE id terminal
    {
        fmt.Println(" Package -> ")
        $$ = NewNode(nil, "package", &LeoVAL)
        $$.AddChild($2)
    };
import_: IMPORT string_literal terminal
    {
         fmt.Println(" Import -> ")
        $$ = NewNode(nil, "import", &LeoVAL)
        $$.AddChild($2)
    };

import_list: /*empty*/ {$$ = NewNode(nil, "import_list", &LeoVAL)}| import_ {$$ = NewNode(nil, "import_list", &LeoVAL)} | import_list import_
    {
        $$ = $1
        $$.AddChild($2)
    };
string_literal: STRING_LITERAL
    {
        $$ = NewNode(nil, "string_literal", &LeoVAL)
    };
top_declaration:  func_ | method | var_ | const_ | type_ | struct_ | interface_
    {
        $$ = NewNode(nil, "top_declaration", &LeoVAL)
        $$.AddChild($1)
    };
top_declaration_list: /*empty*/ {$$ = NewNode(nil, "top_decl_list", &LeoVAL)}|top_declaration {$$ = NewNode(nil, "top_declaration_list", &LeoVAL)} | top_declaration_list top_declaration
    {
        $$ = $1
        $$.AddChild($2)
    };

func_: FUNC id template_params LPAREN parameter_list RPAREN block
    {
        $$ = NewNode(nil, "func", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($3)
        $$.AddChild($5)
        $$.AddChild($7)
    };

template_params: /*empty*/{$$ = NewNode(nil, "template_params", &LeoVAL)}
    | LBRACK parameter_list RBRACK{
        $$ = NewNode(nil, "template_params", &LeoVAL)
        $$.AddChild($2)
    };

return_params: parameter { $$ = NewNode(nil, "return_params", &LeoVAL)} | LPAREN parameter_list RPAREN
    {
        $$ = NewNode(nil, "return_params", &LeoVAL)
        $$.AddChild($2)
    };

parameter_list: parameter {$$ = NewNode(nil, "parameter_list", &LeoVAL)}| parameter_list COMMA parameter
    {
        $$ = $1
        $$.AddChild($3)
    };

parameter: id symbol
    {
        $$ = NewNode(nil, "parameter", &LeoVAL)
        $$.AddChild($1)
        $$.AddChild($2)
    };

block: LBRACE statement_list RBRACE
    {
        $$ = NewNode(nil, "block", &LeoVAL)
        $$.AddChild($2)
    };

statement_list: statement {$$ = NewNode(nil, "statement_list", &LeoVAL); }| statement_list terminal statement
    {
        $$ = $1
        $$.AddChild($2)
    };

statement: block terminal | expr terminal | return_ terminal | var_assign terminal | new_assign terminal | if_ terminal | else_ terminal | switch_ terminal | for_ terminal | range_ terminal | break_ terminal| continue_ terminal | goto_ terminal| fallthrough_ terminal| safe terminal
    {
        $$ = NewNode(nil, "statement", &LeoVAL)
        $$.AddChild($1)
    };

method: FUNC symbol template_params PERIOD id LPAREN parameter_list RPAREN return_params block
    {
        $$ = NewNode(nil, "method", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($3)
        $$.AddChild($5)
        $$.AddChild($7)
        $$.AddChild($9)
        $$.AddChild($10)
    };

var_: VAR id symbol
    {
        $$ = NewNode(nil, "var", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($3)
    };

const_: CONST id symbol
    {
        $$ = NewNode(nil, "const", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($3)
    };

type_: TYPE id template_params symbol {$$ = NewNode(nil, "type", &LeoVAL);$$.AddChild($2);$$.AddChild($3); $$.AddChild($4);}
 | TYPE id template_params struct_{$$ = NewNode(nil, "type", &LeoVAL);$$.AddChild($2);$$.AddChild($3); $$.AddChild($4);}
 | TYPE id template_params interface_ {$$ = NewNode(nil, "type", &LeoVAL);$$.AddChild($2);$$.AddChild($3); $$.AddChild($4);}
 | TYPE id template_params map_ {$$ = NewNode(nil, "type", &LeoVAL);$$.AddChild($2);$$.AddChild($3); $$.AddChild($4);}
 | TYPE id template_params channel_{$$ = NewNode(nil, "type", &LeoVAL);$$.AddChild($2);$$.AddChild($3); $$.AddChild($4);};

symbol: id {$$ = NewNode(nil, "symbol", &LeoVAL)} | symbol PERIOD symbol
    {
        $$ = $1
        $$.AddChild($3)
    };

struct_: STRUCT id LBRACE field_list RBRACE
    {
        $$ = NewNode(nil, "struct", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };

interface_: INTERFACE id LBRACE interface_method_list RBRACE
    {
        $$ = NewNode(nil, "interface", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };

field_list: field { $$ = NewNode(nil, "field_list", &LeoVAL)} | field_list field
    {
        $$ = $1
        $$.AddChild($2)
    };

field: id symbol {$$ = NewNode(nil, "field", &LeoVAL);$$.AddChild($1);$$.AddChild($2)};

interface_method_list: interface_method { $$ = NewNode(nil, "interface_method_list", &LeoVAL)} | interface_method_list interface_method
    {
        $$ = $1
        $$.AddChild($2)
    };
interface_method: id symbol LPAREN parameter_list RPAREN return_params
    {
        $$ = NewNode(nil, "interface_method", &LeoVAL)
        $$.AddChild($1)
        $$.AddChild($2)
        $$.AddChild($4)
        $$.AddChild($6)
    };
block: LBRACE statement_list RBRACE
    {
        $$ = NewNode(nil, "block", &LeoVAL)
        $$.AddChild($2)
    };
return_: RETURN expr terminal {$$ = NewNode(nil, "return", &LeoVAL);$$.AddChild($2);}
| RETURN terminal{$$ = NewNode(nil, "return", &LeoVAL);};


var_assign: VAR id ASSIGN expr terminal
    {
        $$ = NewNode(nil, "var_assign", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };
new_assign: NEW_ASSIGN id ASSIGN expr terminal
    {
        $$ = NewNode(nil, "new_assign", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };

if_: IF expr block {$$ = NewNode(nil, "if", &LeoVAL);$$.AddChild($2);$$.AddChild($3)};
| IF expr block else_{$$ = NewNode(nil, "if", &LeoVAL);$$.AddChild($2);$$.AddChild($3);$$.AddChild($4)};


else_: ELSE block {$$ = NewNode(nil, "else", &LeoVAL);$$.AddChild($2)}
| ELSE if_ block{$$ = NewNode(nil, "else", &LeoVAL);$$.AddChild($3)};


switch_: SWITCH expr LBRACE case_list RBRACE
    {
        $$ = NewNode(nil, "switch", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };
case_list: case_clause { $$ = NewNode(nil, "case_list", &LeoVAL)} | case_list case_clause
    {
        $$ = $1
        $$.AddChild($2)
    };
case_clause: CASE case_condition COLON statement_list {$$ = NewNode(nil, "case_clause", &LeoVAL); $$.AddChild($2); $$.AddChild($4)} 
| DEFAULT COLON statement_list{
        $$ = NewNode(nil, "case_clause", &LeoVAL)
        $$.AddChild($3)
    };
case_condition: expr {$$ = NewNode(nil, "case_condition", &LeoVAL); $$.AddChild($1)} | expr COMMA case_condition
    {
        $$ = NewNode(nil, "case_condition", &LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };
for_: FOR for_init for_condition for_post block
    {
        $$ = NewNode(nil, "for", &LeoVAL)
        $$.AddChild($2)
        $$.AddChild($3)
        $$.AddChild($4)
        $$.AddChild($5)
    };

for_init: /*empty*/ {$$=NewNode(nil, "for_init", &LeoVAL)}
    |expr {$$=NewNode(nil, "for_init", &LeoVAL); $$.AddChild($1)}
    | var_assign {$$=NewNode(nil, "for_init", &LeoVAL); $$.AddChild($1)}
    | new_assign {$$=NewNode(nil, "for_init", &LeoVAL); $$.AddChild($1)}
    | for_condition
    {
        $$ = NewNode(nil, "for_init", &LeoVAL)
        $$.AddChild($1)
    };
for_condition: /*empty*/ {$$=NewNode(nil, "for_cond", &LeoVAL);}
    | expr {$$=NewNode(nil, "for_cond", &LeoVAL); $$.AddChild($1)}
    | for_condition
    {
        $$ = NewNode(nil, "for_condition", &LeoVAL)
        $$.AddChild($1)
    };

for_post: expr {$$=NewNode(nil, "for_post", &LeoVAL);$$.AddChild($1)}
    | for_post
    {
        $$ = NewNode(nil, "for_post", &LeoVAL)
        $$.AddChild($1)
    };
range_: RANGE expr block
    {
        $$ = NewNode(nil, "range",&LeoVAL)
        $$.AddChild($2)
        $$.AddChild($3)
    };
break_: BREAK terminal
    {
        $$ = NewNode(nil, "break",&LeoVAL)
    };
continue_: CONTINUE terminal
    {
        $$ = NewNode(nil, "continue",&LeoVAL)
    };
goto_: GOTO id terminal
    {
        $$ = NewNode(nil, "goto",&LeoVAL)
        $$.AddChild($2)
    };
fallthrough_: FALLTHROUGH terminal
    {
        $$ = NewNode(nil, "fallthrough",&LeoVAL)
    };
safe: SAFE terminal
    {
        $$ = NewNode(nil, "safe",&LeoVAL)
    };
expr: unary_expr | binary_expr | ternary_expr | assign_expr | new_assign_expr | accessor_expr | index_expr | slice_expr | call_expr | channel_send_expr | channel_receive_expr  | bridge_expr | transfer_expr |range_expr | symbol
    {
        $$ = NewNode(nil, "expr",&LeoVAL)
        $$.AddChild($1)
    };
unary_expr: PLUS expr { $$ = NewNode(nil, "unary_expr",&LeoVAL); } //This has no operation
    | MINUS expr { $$ = NewNode(nil, "unary_expr",&LeoVAL);}
    | NOT expr { $$ = NewNode(nil, "unary_expr",&LeoVAL);}
   
binary_expr: expr PLUS expr | expr MINUS expr | expr MUL expr | expr DIV expr | expr MOD expr
    {
        $$ = NewNode(nil, "binary_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };
ternary_expr: expr EQ expr | expr NEQ expr | expr LT expr | expr GT expr | expr LTE expr | expr GTE expr | expr NOT_AND expr | expr NOT_OR expr
    {
        $$ = NewNode(nil, "ternary_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };
assign_expr: expr ASSIGN expr | expr ADD_ASSIGN expr | expr SUB_ASSIGN expr | expr MUL_ASSIGN expr | expr QUO_ASSIGN expr | expr REM_ASSIGN expr | expr AND_ASSIGN expr | expr OR_ASSIGN expr
    {
        $$ = NewNode(nil, "assign_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };
new_assign_expr: NEW_ASSIGN id ASSIGN expr
    {
        $$ = NewNode(nil, "new_assign_expr",&LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };
accessor_expr: expr PERIOD id
    {
        $$ = NewNode(nil, "accessor_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };
index_expr: expr LBRACK expr RBRACK
    {
        $$ = NewNode(nil, "index_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };
slice_expr: expr LBRACK expr COLON expr RBRACK
    {
        $$ = NewNode(nil, "slice_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
        $$.AddChild($5)
    };
call_expr: expr LPAREN argument_list RPAREN
    {
        $$ = NewNode(nil, "call_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };


// TODO: Map Implementation
map_: MAP LBRACK symbol RBRACK symbol
    {
        $$ = NewNode(nil, "map",&LeoVAL)
        $$.AddChild($3)
        $$.AddChild($5)
    };
array_index: LBRACK expr RBRACK
    {
        $$ = NewNode(nil, "array_index",&LeoVAL)
        $$.AddChild($2)
    };

slice_index: LBRACK expr COLON expr RBRACK
    {
        $$ = NewNode(nil, "slice_index",&LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };

for_range: FOR range_expr block
    {
        $$ = NewNode(nil, "for_range",&LeoVAL)
        $$.AddChild($3)
    };

range_expr: expr RANGE expr
    {
        $$ = NewNode(nil, "range_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };

//TODO: Channel Implementation

channel_: CHANNEL symbol
    {
        $$ = NewNode(nil, "channel",&LeoVAL)
        $$.AddChild($2)
    };

channel_send_expr: expr CHANNEL_SEND expr
    {
        $$ = NewNode(nil, "channel_send",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };

channel_receive_expr: expr NEW_ASSIGN CHANNEL_SEND symbol
    {
        $$ = NewNode(nil, "channel_receive",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($4)
    };


//TODO: Safe and Memory Handler Implementation

//TODO: Bridge and Transfer Implementation
bridge_expr: expr BRIDGE expr
    {
        $$ = NewNode(nil, "bridge",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    }

transfer_expr: expr TRANSFER expr
    {
        $$ = NewNode(nil, "transfer",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    }

return_expr: RETURN expr
    {
        $$ = NewNode(nil, "return",&LeoVAL)
        $$.AddChild($2)
    };

group_expr: LPAREN expr RPAREN
    {
        $$ = NewNode(nil, "group_expr",&LeoVAL)
        $$.AddChild($2)
    };

argument: expr
    {
        $$ = NewNode(nil, "argument",&LeoVAL)
        $$.AddChild($1)
    };

argument_list: argument {$$ = NewNode(nil, "argument_list",&LeoVAL)} | argument_list COMMA argument
    {
        $$ = $1
        $$.AddChild($3)
    };

symbol_list: symbol {$$ = NewNode(nil, "symbol_list",&LeoVAL)} | symbol_list COMMA symbol
    {
        $$ = $1
        $$.AddChild($3)
    };

id: IDENTIFIER
    {
        $$ = NewNode(nil, "id",&LeoVAL)
    };

add_assign_expr: expr ADD_ASSIGN expr
    {
        $$ = NewNode(nil, "add_assign_expr",&LeoVAL)
        $$.AddChild($1)
        $$.AddChild($3)
    };

default_: DEFAULT COLON block
    {
        $$ = NewNode(nil, "default",&LeoVAL)
        $$.AddChild($3)
    };

case_: CASE expr COLON block
    {
        $$ = NewNode(nil, "case",&LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };

launch: LAUNCH expr
    {
        $$ = NewNode(nil, "launch",&LeoVAL)
        $$.AddChild($2)
    };

select_: SELECT expr block
    {
        $$ = NewNode(nil, "select",&LeoVAL)
        $$.AddChild($2)
        $$.AddChild($3)
    };

array_declaration: LBRACK expr RBRACK
    {
        $$ = NewNode(nil, "array_declaration",&LeoVAL)
        $$.AddChild($2)
    };

slice_declaration: LBRACK expr COLON expr RBRACK
    {
        $$ = NewNode(nil, "slice_declaration",&LeoVAL)
        $$.AddChild($2)
        $$.AddChild($4)
    };

default_clause: DEFAULT COLON block
    {
        $$ = NewNode(nil, "default_clause",&LeoVAL)
        $$.AddChild($3)
    };



%%

// The parser expects the lexer to return 0 on EOF.
const eof = 0
const LEX_NORMAL = 0
const LEX_COMMENT = 1
const LEX_STRING = 2
const UNDEFINED = -3


// The parser uses the type <prefix>Lex as a lexer. It must provide
// the methods Lex(*<prefix>SymType) int and Error(string).
type LeoLex struct {
    //Lex Stream
	Source []byte
    Stream []byte
	peek rune
    Line int
    Column int
    Index int
    Sz int
    LexMode int

    //Regex Compiled Expressions
    reWhitespace *regexp.Regexp
    reSingleLineComment *regexp.Regexp
    reMultiLineComment *regexp.Regexp
    reTerminator *regexp.Regexp

    //Regex Decimal Patterns
    reInt *regexp.Regexp
    reFloat *regexp.Regexp
    reImaginary *regexp.Regexp
    reHex *regexp.Regexp
    reOctal *regexp.Regexp
    reBinary *regexp.Regexp


    //Regex String Patterns
    reString *regexp.Regexp
    reCharString *regexp.Regexp


    //Regex Keyword Patterns
    reKeyword *regexp.Regexp
    reSpecialTokens *regexp.Regexp
    reIdentifier *regexp.Regexp

}

// The parser yaccpar calls this method to get each new token.
func (x *LeoLex) Lex(yylval *LeoSymType) int {
	
    var tokens [7]int
    var token int
    var c rune
    x.ResetPeek()
    c = x.Peek()
    fmt.Printf("Lexing: %c\n", c)
    if c == eof{
        fmt.Printf("EOF\n")
        return eof
    }

    tokens[0] =  x.LexWhitespace(yylval)
    if tokens[0] != ILLEGAL{
        fmt.Println("Whitespace Found ")
        token = tokens[0]
        goto increment_char
    }

    tokens[1] = x.LexComments(yylval)
    if tokens[1] != ILLEGAL{
        fmt.Printf("Comments Found ")
        token = tokens[1]
        goto increment_char
    }

    tokens[2] = x.LexKeywords(yylval)
    if tokens[2] != ILLEGAL{
        fmt.Printf("Keywords Found ")
        token = tokens[2]
        goto increment_char
    }
    tokens[3] = x.LexNumbers(yylval)
    if tokens[3] != ILLEGAL{
        fmt.Printf("Numbers Found ")
        token = tokens[3]
        goto increment_char
    }
    tokens[4] = x.LexMultiTokens(yylval)
    if tokens[4] != ILLEGAL{
        fmt.Printf("Multi Tokens Found ")
        token = tokens[4]
        goto increment_char
    }
    tokens[5] = x.LexSimpleToken(c,yylval)
    if tokens[5] != ILLEGAL{
        fmt.Printf("Simple Tokens Found ")
         token = tokens[5]
         goto increment_char
    }
    tokens[6] = x.LexIdentifiers(yylval)
    if tokens[6] != ILLEGAL{
        fmt.Printf("Identifiers Found ")
         token = tokens[6]
         goto increment_char
    }

    increment_char:
        fmt.Printf("Incrementing Char\n ")
        x.Next(yylval)
        return token
    
    return token
}


func (x *LeoLex) LexWhitespace(yylval *LeoSymType)int{
 // Lex Whitesapce and Comments with RegEx
    whitespacePattern := `^([\s\t\n\r]+)`
    var err error

   // Compile the regex patterns
   if x.reWhitespace == nil{
        x.reWhitespace, err = regexp.Compile(whitespacePattern)
    }

    // Check Regex Compile Errors
    if err != nil{
        log.Fatalf("Bad Regexp: LexWhitespaceComments()\n %s", err.Error())
    }

    // Search for the longest matching string and return the token or eof
    whitespaceFindBytes := x.reWhitespace.Find(x.Stream)

    if whitespaceFindBytes != nil {
        if x.reWhitespace.FindIndex(x.Stream)[0] == 0{
            if x.LexMode == LEX_NORMAL{
                x.Stream = x.Stream[len(whitespaceFindBytes):]
                return WHITESPACE
            }
        }
    }
    x.ResetPeek()
    return ILLEGAL
}


func (x *LeoLex) LexComments(yylval *LeoSymType) int {

    // Lex Whitesapce and Comments with RegEx
    singleLineCommentPattern := `^(\/\/.*)`
    multiLineCommentPattern := `^(\/\*.*\*\/)`
    var err error

   // Compile the regex patterns
	if x.reSingleLineComment == nil{
        x.reSingleLineComment, err = regexp.Compile(singleLineCommentPattern)
    }
    if x.reMultiLineComment == nil{
        x.reMultiLineComment, err = regexp.Compile(multiLineCommentPattern)
    }

    // Check Regex Compile Errors
    if err != nil {
        log.Fatalf("Bag Regexp: %s", err.Error())
    }

    singleLineCommentFindBytes := x.reSingleLineComment.Find(x.Stream)

    if(singleLineCommentFindBytes != nil) {
        if x.reSingleLineComment.FindIndex(x.Stream)[0] == 0{
            x.Stream = x.Stream[len(singleLineCommentFindBytes):]
            return COMMENT
        }
    }

    multiLineCommentFindBytes := x.reMultiLineComment.Find(x.Stream)

    if(multiLineCommentFindBytes != nil) {
        if x.reMultiLineComment.FindIndex(x.Stream)[0] == 0{
            x.Stream = x.Stream[len(multiLineCommentFindBytes):]
            return COMMENT_BLOCK
        }
    }

    x.ResetPeek()
    return ILLEGAL

}

func (x *LeoLex) LexKeywords(yylval *LeoSymType)int{
    var err error
    reKeywordPattern := `^(package|import|func|var|const|type|struct|interface|map|channel|launch|select|case|default|for|range|break|continue|goto|if|else|switch|return|fallthrough|safe|int|int8|int16|int32|int64|uint|uint8|uint16|uint32|uint64|float|float16|float32|float64|complex|complex16|complex32|complex64|bool|string|byte|rune|char|error)`
    if x.reKeyword == nil {
        x.reKeyword, err = regexp.Compile(reKeywordPattern)
    }

    if err != nil {
        log.Fatalf("Bad Regexp: %s", err.Error())
    }

    keywordFindBytes := x.reKeyword.Find(x.Stream)

    if keywordFindBytes != nil {
        location := x.reKeyword.FindIndex(x.Stream)
        if location[0] == 0{
            //Now match and return the specific keywords
            keyword := x.Stream[:location[1]]
            keyword_string := string(keyword)
            x.Stream = x.Stream[len(keywordFindBytes):]
            yylval.Tokenstring = keyword_string
            x.ResetPeek()

            switch keyword_string{
                case "package":
                     fmt.Println(" ($package)")
                    return PACKAGE
                case "import":
                    fmt.Println(" ($import)")
                    return IMPORT
                case "func":
                    fmt.Println(" ($func)")
                    return FUNC
                case "var":
                    return VAR
                case "const":
                    return CONST
                case "type":   
                    return TYPE
                case "struct":
                    return STRUCT
                case "interface":
                    return INTERFACE
                case "map":
                    return MAP
                case "channel":
                    return CHANNEL 
                case "launch":
                    return LAUNCH
                case "select":
                    return SELECT
                case "case":  
                    return CASE
                case "default":
                    return DEFAULT
                case "for":
                    return FOR
                case "range":
                    return RANGE
                case "break":
                    return BREAK
                case "continue":
                    return CONTINUE
                case "goto":
                    return GOTO
                case "if":
                    return IF
                case "else":
                    return ELSE
                case "switch":
                    return SWITCH
                case "return":
                    return RETURN
                case "fallthrough":
                    return FALLTHROUGH
                case "safe":
                    return SAFE
                default:
                    return ILLEGAL
            }
        }
    }
    return ILLEGAL
}

func (x *LeoLex) LexSimpleToken(c rune, yylval *LeoSymType)int{
    switch c{
        case '*':
            yylval.Tokenstring = string(c)
            return STAR
        case '[':
            yylval.Tokenstring = string(c)
            return LBRACK
        case ']':
            yylval.Tokenstring = string(c)
            return RBRACK
        case '{':
            yylval.Tokenstring = string(c)
            return LBRACE
        case '}':
            yylval.Tokenstring = string(c)
            return RBRACE
        case '(':
            yylval.Tokenstring = string(c)
            return LPAREN
        case ')':
            yylval.Tokenstring = string(c)
            return RPAREN
        case '=':
            yylval.Tokenstring = string(c)
            return ASSIGN
        case '+':
            yylval.Tokenstring = string(c)
            return PLUS
        case '-':
            yylval.Tokenstring = string(c)
            return MINUS
        case '/':
            yylval.Tokenstring = string(c)
            return DIV
        case '%':
            yylval.Tokenstring = string(c)
            return MOD
        case '!':
            yylval.Tokenstring = string(c)
            return NOT
        case '<':
            yylval.Tokenstring = string(c)
            return LT
        case '>':
            yylval.Tokenstring = string(c)
            return GT
        case '&':
            yylval.Tokenstring = string(c)
            return AMPERSAND
        case '|':
            yylval.Tokenstring = string(c)
            return BITWISE_OR
        case '^':
            yylval.Tokenstring = string(c)
            return BITWISE_XOR
        case '~':
            yylval.Tokenstring = string(c)
            return BITWISE_NOT
        case '\n':
            yylval.Tokenstring = string(c)
            x.Line++
            x.Column = 0
            yylval.Tokenline = x.Line
            yylval.Tokencolumn = x.Column
            return NEWLINE
        case ';':
            yylval.Tokenstring = string(c)
            return SEMICOLON
        }

        return ILLEGAL
}


func (x *LeoLex) LexMultiTokens(yylval *LeoSymType)int{
    // Lex Operators and Punctuation with RegEx
    reSpecialTokensPattern := `^(:= | += | \.\.\. |-= | *= | /= | %= | &= | << | >> | == | != | !== |<= | >= | && | || | << | >>  <- | <-->)`
    var err error
    var b *bytes.Buffer
    b = bytes.NewBufferString("")
    // Compile the regex patterns
    if x.reSpecialTokens == nil {
        x.reSpecialTokens, err = regexp.Compile(reSpecialTokensPattern)
    }

    // Check Regex Compile Errors
    if err != nil{
        log.Fatalf("Bad Regexp: %s", err.Error())
    }

    // Search for the longest matching string and return the token or eof
    specialTokensFindBytes := x.reSpecialTokens.Find(x.Stream)
    if specialTokensFindBytes != nil {
        location := x.reSpecialTokens.FindIndex(x.Stream)
        if location[0] == 0{
            x.Stream = x.Stream[len(specialTokensFindBytes):]
            b.Write(specialTokensFindBytes)
            yylval.Tokenbuffer = b
            Tokenstring := string(specialTokensFindBytes)
            yylval.Tokenstring = Tokenstring
            x.ResetPeek()

            switch Tokenstring{
        
                case "...":
                    return ELLIPSIS
                case ":=":
                    return NEW_ASSIGN
                case "+=":
                    return ADD_ASSIGN
                case "-=":
                    return SUB_ASSIGN
                case "*=":
                    return MUL_ASSIGN
                case "/=":
                    return QUO_ASSIGN
                case "%=":
                    return REM_ASSIGN
                case "&=":
                    return AND_ASSIGN
                case "!==":
                    return NOT_EQ
                case "|=":
                    return OR_ASSIGN
                case "==":
                    return EQ
                case "!=":
                    return NEQ
                case "<=":
                    return LTE
                case ">=":
                    return GTE
                case "&&":
                    return NOT_AND
                case "||":
                   return NOT_OR
                case "<<":
                    return SHL_ROTATE
                case ">>":
                    return SHR_ROTATE
                case "<-":
                    return CHANNEL_SEND
                case "<-->":
                    return CHANNEL_RECEIVE
                default:
                    return ILLEGAL
            }

        }
    }
    return ILLEGAL
}

// Lex Numbers, Floats, Imaginary, Hex, Octal, Binary with RegExps
func (x *LeoLex) LexNumbers(yylval *LeoSymType) int {

    //Declare new buffer
    var b *bytes.Buffer
    b = bytes.NewBufferString("")
    var err error

    reIntPattern := `^0|[1-9][0-9]*`
    reFloatPattern := `^[0-9]+[\.][0-9]+`
    reImaginaryPattern := `^[0-9]+[i]`
    reHexPattern := `^0[xX][0-9a-fA-F]+`
    reOctalPattern := `^0c[0-7]+`
    reBinaryPattern := `^0b[01]+`

    // Compile the regex patterns
    if x.reInt == nil {
        x.reInt, err = regexp.Compile(reIntPattern)
    }
    if x.reFloat == nil {
        x.reFloat, err = regexp.Compile(reFloatPattern)
    }
    if x.reImaginary == nil {
        x.reImaginary, err = regexp.Compile(reImaginaryPattern)
    }
    if x.reHex == nil {
        x.reHex, err = regexp.Compile(reHexPattern)
    }
    if x.reOctal == nil {
        x.reOctal, err = regexp.Compile(reOctalPattern)
    }
    if x.reBinary == nil {
        x.reBinary, err = regexp.Compile(reBinaryPattern)
    }

    // Check Regex Compile Errors
    if err != nil{
        log.Fatalf("Bad Regexp: %s", err.Error())
    }


    // Search for the longest matching string and return the token or eof for float
    floatFindBytes := x.reFloat.Find(x.Stream)

    if floatFindBytes != nil {
        yylval.Tokenfloat = big.NewFloat(0)
        if x.reFloat.FindIndex(x.Stream)[0] == 0{
            fmt.Println("($float)")
            x.Stream = x.Stream[len(floatFindBytes):]
            b.Write(floatFindBytes)
            yylval.Tokenbuffer = b
            f, _, err := big.ParseFloat(string(floatFindBytes), 10, 0, big.ToNearestEven)
            if yylval.Tokenfloat == nil {
                log.Fatalf("Error parsing float %s", err)
            }
            yylval.Tokenfloat = f
            x.ResetPeek()
        return FLOAT
        }  
    }

    hexFindBytes := x.reHex.Find(x.Stream)

    if hexFindBytes != nil {
        if x.reHex.FindIndex(x.Stream)[0] == 0{
            x.Stream = x.Stream[len(hexFindBytes):]
            b.Write(hexFindBytes)
            yylval.Tokenbuffer = b
            x.ResetPeek()
            return HEX
        } 
    }

    octalFindBytes := x.reOctal.Find(x.Stream)

    if octalFindBytes != nil{
        if x.reOctal.FindIndex(x.Stream)[0] == 0{
            x.Stream = x.Stream[len(octalFindBytes):]
            b.Write(octalFindBytes)
            yylval.Tokenbuffer = b
            x.ResetPeek()
            return OCTAL
        }
    }


    binaryFindBytes := x.reBinary.Find(x.Stream)

    if binaryFindBytes != nil {
        if x.reBinary.FindIndex(x.Stream)[0] == 0{  
            x.Stream = x.Stream[len(binaryFindBytes):]
            b.Write(binaryFindBytes)
            yylval.Tokenbuffer = b
            x.ResetPeek()
            return BINARY
        }
    }

    // Search for the longest matching string and return the token or eof
    intFindBytes := x.reInt.Find(x.Stream)

    if intFindBytes != nil {
        yylval.Tokenint = big.NewInt(0)
        if x.reInt.FindIndex(x.Stream)[0] == 0{
            x.Stream = x.Stream[len(intFindBytes):]
            b.Write(intFindBytes)
            intString := string(intFindBytes)
            _, result := yylval.Tokenint.SetString(intString, 10)
            if(!result){
                log.Fatalf("Error parsing int")
            }
            yylval.Tokenbuffer = b
            x.ResetPeek()
            return INT
        }
    }
    return ILLEGAL
}

func (x *LeoLex) LexIdentifiers(yylval *LeoSymType)int{
    var err error
    reIdentifierPattern := `^[a-zA-Z_][a-zA-Z0-9_]*`
    if x.reIdentifier == nil {
        x.reIdentifier, err = regexp.Compile(reIdentifierPattern)
    }

    if err != nil{
        log.Fatalf("Bad Regexp: %s", err.Error())
    }

    identifierFindBytes := x.reIdentifier.Find(x.Stream)

    if identifierFindBytes != nil {
        location := x.reIdentifier.FindIndex(x.Stream)
        if location[0] == 0{
  
            identifier := x.Stream[:location[1]]
            identifier_string := string(identifier)
            x.Stream = x.Stream[len(identifierFindBytes):]
            fmt.Printf("($identifier): %s", identifier_string)
            x.ResetPeek()
            yylval.Tokenstring = identifier_string
            yylval.Tokenbuffer = bytes.NewBufferString(identifier_string)
            return IDENTIFIER
        }
    }
    return ILLEGAL
}

// Peek our next rune
func (x *LeoLex) Next(yylval *LeoSymType) rune {
	if x.peek == eof {
        return eof
	}
	if len(x.Stream) == 0 {
		return eof
	}

    //Decode the rune, return it and set the peek
	c, size := utf8.DecodeRune(x.Stream)
	if c == utf8.RuneError && size == 1 {
        log.Print("invalid utf8 encoding %\b", x.Stream[0])
        x.Column++
        yylval.Tokencolumn = x.Column;
		return x.Next(yylval)
	}else if c == utf8.RuneError && size == 0{
        return eof
    }else{
        x.Column += size
        yylval.Tokencolumn += x.Column
        x.Stream = x.Stream[size:]
    }
   
    if len(x.Stream) > 0 {
        x.peek, _ = utf8.DecodeRune(x.Stream)
    }else{
        x.peek = eof
    }

	return c
}

func (x *LeoLex) Peek()rune{
    if x.peek == eof {
        return eof
    }
    if len(x.Stream) == 0 {
        return eof
    }
    c, _ := utf8.DecodeRune(x.Stream)
    return c
}

func (x *LeoLex) ResetPeek(){
    if len(x.Stream) > 0 {
        x.peek, _= utf8.DecodeRune(x.Stream)
    }else{
        x.peek = eof
    }
}

// The parser calls this method on a parse error.
func (x *LeoLex) Error(s string) {
	log.Printf("parse error: %s", s)
}

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

		LeoParse(&LeoLex{Source: line, Stream: line})
	}
}


// Lex Strings, Characters, Runes with RegExps
func (x *LeoLex) LexStrings(yylval *LeoSymType) int {

    //Declare new buffer
    var err error
    var b *bytes.Buffer
    b = bytes.NewBufferString("")

    reStringPattern := `^\".*\"`
    reCharStringPattern := `\'[a-zA-Z0-9]\'`

    // Compile the regex patterns
    if x.reString == nil {
        x.reString, err= regexp.Compile(reStringPattern)
    }
    if err != nil {
        x.reCharString, err = regexp.Compile(reCharStringPattern)
    }

    // Check Regex Compile Errors
    if x.reString == nil || x.reCharString == nil {
        log.Fatalf("Bad Regexp: %s", err.Error())
    }

    // Search for the longest matching string and return the token or eof
    stringFindBytes := x.reString.Find(x.Stream)

    if stringFindBytes != nil {
        if x.reString.FindIndex(x.Stream)[0] == 0{
            x.Stream = x.Stream[len(stringFindBytes):]
            b.Write(stringFindBytes)
            yylval.Tokenbuffer = b
            return STRING_LITERAL
        }
    }

    charFindBytes := x.reCharString.Find(x.Stream)

    if charFindBytes != nil {
        if x.reCharString.FindIndex(x.Stream)[0] == 0{
            x.Stream = x.Stream[len(charFindBytes):]
            b.Write(charFindBytes)
            yylval.Tokenbuffer = b
            return CHAR_LITERAL
        }
    }
    return ILLEGAL
}