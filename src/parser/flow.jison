/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex

%%
"style"               return 'STYLE';
"graph"               return 'GRAPH';
"LR"                  return 'DIR';
"TD"                  return 'DIR';
\#[a-f0-9]+           return 'HEX';
[0-9]+                return 'NUM';
\#                    return 'BRKT';
"px"                  return 'UNIT';
"pt"                  return 'UNIT';
"dot"                 return 'UNIT';
":"                   return 'COLON';
";"                   return 'SEMI';
","                   return 'COMMA';
\-\-[x]                   return 'ARROW_CROSS';
\-\-\>                   return 'ARROW_POINT';
\-\-[o]               return 'ARROW_CIRCLE';
\-\-\-               return 'ARROW_OPEN';
\-                    return 'MINUS';
[a-zåäöæøA-ZÅÄÖÆØ]+   return 'ALPHA';
"|"                   return 'PIPE';
"("                   return 'PS';
")"                   return 'PE';
"["                   return 'SQS';
"]"                   return 'SQE';
"{"                   return 'DIAMOND_START'
"}"                   return 'DIAMOND_STOP'
\s                    return 'SPACE';
\n                    return 'NEWLINE';
<<EOF>>               return 'EOF';

/lex

/* operator associations and precedence */

%left '^'

%start expressions

%% /* language grammar */

expressions
    : graphConfig statements EOF
    | graphConfig spaceList statements EOF
        {$$=$1;}
    ;

graphConfig
    : GRAPH SPACE DIR SEMI
        { yy.setDirection($3);$$ = $3;}
    ;

statements
    : statements spaceList statement
    | statement
    ;

spaceList
    : SPACE spaceList
    | SPACE
    ;

statement
    : verticeStatement SEMI
    | styleStatement SEMI
    ;

verticeStatement:
    | vertex link vertex
        { yy.addLink($1,$3,$2);$$ = 'oy'}
    | vertex
        {$$ = 'yo';}
    ;

vertex:  alphaNum SQS text SQE
        {$$ = $1;yy.addVertex($1,$3,'square');}
    | alphaNum PS text PE
        {$$ = $1;yy.addVertex($1,$3,'round');}
    | alphaNum DIAMOND_START text DIAMOND_STOP
        {$$ = $1;yy.addVertex($1,$3,'diamond');}
    | alphaNum
        {$$ = $1;yy.addVertex($1);}
    ;

alphaNum
    : alphaNumStatement
    {$$=$1;}
    | alphaNumStatement alphaNum
    {$$=$1+''+$2;}
    ;

alphaNumStatement
    : alphaNumToken
        {$$=$1;}
    | alphaNumToken MINUS alphaNumToken
        {$$=$1+'-'+$3;}
    ;

alphaNumToken
    : ALPHA
    {$$=$1;}
    | NUM
    {$$=$1;}
    ;

link: linkStatement arrowText
    {$1.text = $2;$$ = $1;}
    | linkStatement
    {$$ = $1;}
    ;

linkStatement: ARROW_POINT
        {$$ = {"type":"arrow"};}
    | ARROW_CIRCLE
        {$$ = {"type":"arrow_circle"};}
    | ARROW_CROSS
        {$$ = {"type":"arrow_cross"};}
    | ARROW_OPEN
        {$$ = {"type":"arrow_open"};}
    ;

arrowText:
    PIPE text PIPE
    {$$ = $2;}
    ;

// Characters and spaces
text: alphaNum SPACE text
        {$$ = $1 + ' ' +$3;}
    | alphaNum spaceList MINUS spaceList text
         {$$ = $1 + ' - ' +$5;}
    | alphaNum
        {$$ = $1;}
    ;

styleStatement:STYLE SPACE alphaNum SPACE stylesOpt
    {$$ = $1;yy.addVertex($3,undefined,undefined,$5);}
    | STYLE SPACE HEX SPACE stylesOpt
          {$$ = $1;yy.updateLink($3,$5);}
    ;

stylesOpt: style
        {$$ = [$1]}
    | stylesOpt COMMA style
        {$1.push($3);$$ = $1;}
    ;

style: styleComponent
    {$$=$1;}
    |style styleComponent
    {$$ = $1 + $2;}
    ;

styleComponent: ALPHA
    {$$=$1}
    | COLON
    {$$=$1}
    | MINUS
    {$$=$1}
    | NUM
    {$$=$1}
    | UNIT
    {$$=$1}
    | SPACE
    {$$=$1}
    | HEX
    {$$=$1}
    ;
%%