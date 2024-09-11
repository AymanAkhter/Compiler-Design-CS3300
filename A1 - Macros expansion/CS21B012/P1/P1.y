%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #include <stdarg.h>

extern int yylex();
extern int yyparse();
// extern FILE* yyin;
void yyerror(char *s);

struct MacroNode{
  char* name;
  char** argList;
  char* content;
  struct MacroNode* next;
  int totalCharsDiff;
  int argsNum;
  int macroType;
  int empty;
};

int findNextNonSpace(char *s, int i)
{
  while(s[i]==' ' || s[i]=='\n' || s[i]=='\t')
  {
    i++;
  }
  return i;
}
int findPrevNonSpace(char *s, int i)
{
  while(s[i]==' ' || s[i]=='\n' || s[i]=='\t')
  {
    i--;
  }
  return i;
}

char* mySubstr(char* s, int start, int end)
{
    char* ret = (char*)malloc((end-start+2)*sizeof(char));
    int i=0;
    for(int j=start; j<=end; j++)
    {
        ret[i] = s[j];
        i++;
    }
    ret[i]='\0';
    return ret;
}

struct MacroNode* head;

void insertMacro(struct MacroNode* newMacro)
{
  newMacro->next = head;
  head = newMacro;
}

struct MacroNode* findMacro(char *id)
{
  struct MacroNode* cur = head;
  while(cur!=NULL)
  {
    if(strcmp(cur->name,id)==0)
      return cur;
    cur = cur->next;
  }
  return NULL;
}

int isDelimiter(char c)
{
  if(!(c-'0'<=9 && c-'0'>=0) && !(c-'a'<=25 && c-'a'>=0) && !(c-'A'<=25 && c-'A'>=0) && (c!='_') && (c!='$'))
    return 1;
  return 0;
}

int getNum(struct MacroNode* mac, char* s)
{
    for(int i=0; i<mac->argsNum; i++)
    {
        if(strcmp(s,mac->argList[i])==0)
            return i;
    }
    return -1;

}

char* replaceMacro(char* s, int type)
{
  // if(type==2)
  // {
  //   printf("\n%s\n",s);
  // }
  char* ret;
  int n = strlen(s);
  char* id;
  
  int i=findNextNonSpace(s,0);
  for(; i<n; i++)
  {
    if(s[i]==' ')
    {
      id = strdup(mySubstr(s,0,i-1));
      i=findNextNonSpace(s,i);
      break;
    }
  }
  i=findNextNonSpace(s,i+1);
  struct MacroNode* replMacro = findMacro(id);
  
  
  if(replMacro==NULL)
  {
    yyerror(strdup("Macro Not Found\n"));
  }
  if(replMacro->macroType!=type)
  {
    yyerror(strdup("Macro type mismatch\n"));
  }

  if(replMacro->macroType==2 && replMacro->empty==1)
  {
    char* ttt = (char*)malloc(2*sizeof(char));
    ttt[0] = ' ';
    ttt[1] = '\0';
    return ttt;
  }

  int curCount;
  if(s[i]==')')
  {
    curCount=0;
  }
  else
  {
    curCount=1;
    for(int j=i; j<n; j++)
    {
        if(s[j]==',') curCount++;
    }
  }
  if(curCount!=replMacro->argsNum)
  {
    yyerror(strdup("Macro type mismatch\n"));
  }


  char** idList = (char**)malloc(replMacro->argsNum*sizeof(char*));
    int prev = i;
    int idNum=0;
    int duplen=0;
    while(i<n-1)
    {
        // printf("%c\n", s[i]);
        if(s[i]==','){
            idList[idNum] = strdup(mySubstr(s,prev,findPrevNonSpace(s,i-1)));
            duplen+=(findPrevNonSpace(s,i-1)-prev+1);
            idNum++;
            i=findNextNonSpace(s,i+1);
            prev = i;
        }
        else
            i++;
        
    }
    if(replMacro->argsNum>0)
    {
        idList[idNum] = strdup(mySubstr(s,prev,findPrevNonSpace(s,i-1)));
        duplen+=(findPrevNonSpace(s,i-1)-prev+1);
    }
    // for(int i=0; i<replMacro->argsNum; i++)
    // {
    //     printf("%s|",idList[i]);
    // }
    
    idNum++;

    // for(int jj=0; jj<replMacro->argsNum; jj++)
    // {
    //     printf("%s\n", idList[jj]);
    // }

  int retSize = duplen + replMacro->totalCharsDiff;
  if(replMacro->macroType==1)
    ret = (char*)malloc((3+retSize)*sizeof(char));
  else
    ret = (char*)malloc((1+retSize)*sizeof(char));

  strcpy(ret,"");
  // if(replMacro->macroType==1)
  // {
  //   strcat(ret,"(");
  // }
  int travlen = strlen(replMacro->content);
  int prevv=0;
  int j=0;
  for(; j<travlen;)
  {
    if(replMacro->content[j]==' ')
    {
        int argNum = getNum(replMacro, mySubstr((replMacro->content),prevv,j-1));
        if(argNum!=-1)
        {
          strcat(ret, idList[argNum]);
          strcat(ret," ");
        }
        else
        {
          strcat(ret, mySubstr((replMacro->content),prevv,j-1));
          strcat(ret," ");
        }
        
        // strcat(ret, mySubstr((replMacro->content),j,j));
        j=findNextNonSpace(replMacro->content,j);
        prevv=j;
    }
    else
        j++;
  }

  int argNum = getNum(replMacro, mySubstr((replMacro->content),prevv,j-1));
  if(argNum!=-1)
  {
    strcat(ret, idList[argNum]);
  }
  else
  {
    strcat(ret, mySubstr((replMacro->content),prevv,j-1));
  }

  
  // ret[j]='\0';
  // if(replMacro->macroType==1)
  // {
  //   // printf("Hello\n");
  //   strcat(ret,")");
  // }
  return ret;

}

void makeMacro(char* s){

  int n = strlen(s);
  int i = findNextNonSpace(s,0);
  struct MacroNode* newMacro = (struct MacroNode*)malloc(sizeof(struct MacroNode));
  newMacro->empty=0;
  i+=7;
  i = findNextNonSpace(s,i);
  int prev=i;
  for(; i<n; i++)
  {
    if(isDelimiter(s[i])==1)
    {
      newMacro->name = strdup(mySubstr(s,prev,i-1));
      i=findNextNonSpace(s,i);
      prev=i;
      break;
    }
  }
  if(findMacro(newMacro->name)!=NULL)
  {
    yyerror(strdup("Macro exists\n"));
  }
  i=findNextNonSpace(s,i+1);
  prev=i;
  int argsiz;
  if(s[i]==')')
  {
    argsiz=0;
  }
  else
  {
    argsiz=1;
    for(int j=i; s[j]!=')'; j++)
    {
        if(s[j]==',') argsiz++;
    }
  }
  
//   argsiz++;
  int argNum=0;
  newMacro->argList = (char**)malloc(argsiz*sizeof(char*));
  newMacro->argsNum = argsiz;

  while(s[i]!=')')
  {
    if(s[i]==',')
    {
      newMacro->argList[argNum] = strdup(mySubstr(s,prev,findPrevNonSpace(s,i-1)));
      argNum++;
      i=findNextNonSpace(s,i+1);
      prev=i;
    }
    else
        i++;
    
  }
  if(argsiz>0)
  {
    char* kek = mySubstr(s,prev,findPrevNonSpace(s,i-1));
    newMacro->argList[argNum] = strdup(kek);
  }

  // for(int i=0; i<argsiz; i++)
  // {
  //   printf("%s|", newMacro->argList[i]);
  // }
  i=findNextNonSpace(s,i+1);
  
  if(s[i]=='(')
    newMacro->macroType=1;
  else
    newMacro->macroType=2;

  if(newMacro->macroType==1)
  {
    newMacro->content = strdup(strdup(mySubstr(s,i,findPrevNonSpace(s,n-1))));
  }
  else
  {
    if(s[findNextNonSpace(s,i+1)]!='}')
    {
      i=findNextNonSpace(s,i+1);
      newMacro->content = strdup(strdup(mySubstr(s,i,findPrevNonSpace(s,findPrevNonSpace(s,n-1)-1))));
    }
      
    else{
      
      newMacro->empty=1;
      char* ttt = (char*)malloc(2*sizeof(char));
      ttt[0] = ' ';
      ttt[1] = '\0';
      newMacro->content = ttt;

    }
    
  }
  
  int tot=0;
  for(int kk=0; kk<argsiz; kk++)
  {
    tot = tot + strlen(newMacro->argList[kk]);
  }
  newMacro->totalCharsDiff = strlen(newMacro->content) - tot;
  insertMacro(newMacro);

}

char* concone(char* s1){
  int siz = strlen(s1)+1;
    char* ret = (char*)calloc(siz,sizeof(char));
    // malloc(, siz);
    // ret = strdup(s1);
    strcpy(ret,s1);
    // strcat(ret,s2);
    // free(s1);
    return ret;
}


char* concat(char* s1, char* s2){
    int siz = strlen(s1) + strlen(s2)+2;
    char* ret = (char*)calloc(siz,sizeof(char));
    // malloc(, siz);
    // ret = strdup(s1);
    strcpy(ret,s1);
    strcat(ret," ");
    strcat(ret,s2);
    // free(s1); free(s2);
    return ret;
}

char* concat3(char* s1, char* s2, char* s3){
    int siz = strlen(s1) + strlen(s2) + strlen(s3)+3;
    char* ret = (char*)calloc(siz,sizeof(char));
    // malloc(, siz);
    strcpy(ret,s1);
    strcat(ret," ");
    strcat(ret,s2);
    strcat(ret," ");
    strcat(ret,s3);
    // free(s1); free(s2); free(s3);
    return ret;
}

char* concat4(char* s1, char* s2, char* s3, char* s4){
    int siz = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4)+4;
    char* ret = (char*)calloc(siz,sizeof(char));
    // s1 = malloc(, siz);
    strcpy(ret,s1);
    strcat(ret," ");
    strcat(ret,s2);
    strcat(ret," ");
    strcat(ret,s3);
    strcat(ret," ");
    strcat(ret,s4);
    // free(s1); free(s2); free(s3); free(s4);
    return ret;
}

char* concat5(char* s1, char* s2, char* s3, char* s4, char* s5){
    int siz = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5)+5;
    char* ret = (char*)calloc(siz,sizeof(char));
    // malloc(, siz);
    strcpy(ret,s1);
    strcat(ret," ");
    strcat(ret,s2);
    strcat(ret," ");
    strcat(ret,s3);
    strcat(ret," ");
    strcat(ret,s4);
    strcat(ret," ");
    strcat(ret,s5);
    // free(s1); free(s2); free(s3); free(s4); free(s5);
    return ret;
}

char* concat6(char* s1, char* s2, char* s3, char* s4, char* s5, char* s6){
    int siz = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) + strlen(s6) +6;
    char* ret = (char*)calloc(siz,sizeof(char));
    // ret = strdup(s1);
    strcpy(ret,s1);
    strcat(ret," ");
    strcat(ret,s2);
    strcat(ret," ");
    strcat(ret,s3);
    strcat(ret," ");
    strcat(ret,s4);
    strcat(ret," ");
    strcat(ret,s5);
    strcat(ret," ");
    strcat(ret,s6);
    // free(s1); free(s2); free(s3); free(s4); free(s5); free(s6); 
    return ret;
}

char* concat7(char* s1, char* s2, char* s3, char* s4, char* s5, char* s6, char* s7) {
    int siz = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) + strlen(s6) + strlen(s7) +7;
    char* ret = (char*)calloc(siz,sizeof(char)); 
    strcpy(ret, s1);
    strcat(ret," ");
    strcat(ret, s2);
    strcat(ret," ");
    strcat(ret, s3);
    strcat(ret," ");
    strcat(ret, s4);
    strcat(ret," ");
    strcat(ret, s5);
    strcat(ret," ");
    strcat(ret, s6);
    strcat(ret," ");
    strcat(ret, s7);
    return ret;
}

char* concat8(char* s1, char* s2, char* s3, char* s4, char* s5, char* s6, char* s7, char* s8) {
    int siz = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) + strlen(s6) + strlen(s7) + strlen(s8) +8;
    char* ret = (char*)calloc(siz, sizeof(char)); 
    strcpy(ret, s1);
    strcat(ret," ");
    strcat(ret, s2);
    strcat(ret," ");
    strcat(ret, s3);
    strcat(ret," ");
    strcat(ret, s4);
    strcat(ret," ");
    strcat(ret, s5);
    strcat(ret," ");
    strcat(ret, s6);
    strcat(ret," ");
    strcat(ret, s7);
    strcat(ret," ");
    strcat(ret, s8);
    return ret;
}

char* concat13(char* s1, char* s2, char* s3, char* s4, char* s5, char* s6, char* s7, char* s8, char* s9, char* s10, char* s11, char* s12, char* s13) {
    int siz = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) + strlen(s6) + strlen(s7) + strlen(s8) + strlen(s9) + strlen(s10) + strlen(s11) + strlen(s12) + strlen(s13) +13;
    char* ret = (char*)calloc((siz), sizeof(char));
    strcpy(ret, s1);
    strcat(ret," ");
    strcat(ret, s2);
    strcat(ret," ");
    strcat(ret, s3);
    strcat(ret," ");
    strcat(ret, s4);
    strcat(ret," ");
    strcat(ret, s5);
    strcat(ret," ");
    strcat(ret, s6);
    strcat(ret," ");
    strcat(ret, s7);
    strcat(ret," ");
    strcat(ret, s8);
    strcat(ret," ");
    strcat(ret, s9);
    strcat(ret," ");
    strcat(ret, s10);
    strcat(ret," ");
    strcat(ret, s11);
    strcat(ret," ");
    strcat(ret, s12);
    strcat(ret," ");
    strcat(ret, s13);
    return ret;
}

char* concat21(char* s1, char* s2, char* s3, char* s4, char* s5,
               char* s6, char* s7, char* s8, char* s9, char* s10,
               char* s11, char* s12, char* s13, char* s14, char* s15,
               char* s16, char* s17, char* s18, char* s19, char* s20,
               char* s21) {
    int totalSize = strlen(s1) + strlen(s2) + strlen(s3) + strlen(s4) + strlen(s5) +
                    strlen(s6) + strlen(s7) + strlen(s8) + strlen(s9) + strlen(s10) +
                    strlen(s11) + strlen(s12) + strlen(s13) + strlen(s14) + strlen(s15) +
                    strlen(s16) + strlen(s17) + strlen(s18) + strlen(s19) + strlen(s20) +
                    strlen(s21) + 21;

    char* ret = (char*)calloc((totalSize), sizeof(char));

    strcpy(ret, s1);
    strcat(ret," ");
    strcat(ret, s2);
    strcat(ret," ");
    strcat(ret, s3);
    strcat(ret," ");
    strcat(ret, s4);
    strcat(ret," ");
    strcat(ret, s5);
    strcat(ret," ");
    strcat(ret, s6);
    strcat(ret," ");
    strcat(ret, s7);
    strcat(ret," ");
    strcat(ret, s8);
    strcat(ret," ");
    strcat(ret, s9);
    strcat(ret," ");
    strcat(ret, s10);
    strcat(ret," ");
    strcat(ret, s11);
    strcat(ret," ");
    strcat(ret, s12);
    strcat(ret," ");
    strcat(ret, s13);
    strcat(ret," ");
    strcat(ret, s14);
    strcat(ret," ");
    strcat(ret, s15);
    strcat(ret," ");
    strcat(ret, s16);
    strcat(ret," ");
    strcat(ret, s17);
    strcat(ret," ");
    strcat(ret, s18);
    strcat(ret," ");
    strcat(ret, s19);
    strcat(ret," ");
    strcat(ret, s20);
    strcat(ret," ");
    strcat(ret, s21);

    return ret;
}

%}

%union{
  char* txt;
}

%type<txt> Goal MainClass TypeDeclaration MethodDeclaration Type Statement
%type<txt> Expression PrimaryExpression MacroDefinition MacroDefStatement
%type<txt> MacroDefExpression Identifier Integer TypeIdentifierSemicolonStar 
%type<txt> CommaTypeIdentifierStar TypeDeclarationStar MethodDeclarationStar 
%type<txt> StatementStar CommaExpressionStar
%type<txt> MacroDefinitionStar CommaIdentifierStar MultipleTypeIdentifiers 
%type<txt> MultipleExpressions MultipleIdentifiers

%token<txt> ID
%token<txt> LEFTROUND RIGHTROUND LEFTSQUARE RIGHTSQUARE LEFTCURLY RIGHTCURLY
%token<txt> CLASS PUBLIC STATIC VOID MAIN STRINGG SYSTEMPRINT NOTEQUAL
%token<txt> SEMICOLON EXTENDS COMMA RETURN INT BOOLEAN EQUAL IF ELSE DO
%token<txt> WHILE ANDAND OROR NOT LESSEQUAL PLUS MINUS DIVIDE DOT LENGTH
%token<txt> TRUE FALSE THIS NEW HASHDEFINE NUM MULTIPLY
/* %token ID */
%start Goal

%%

Goal : MacroDefinitionStar MainClass TypeDeclarationStar 
       {$$ = concat3($1, $2, $3); printf("%s\n", $$);}
;

/* Goal : Identifier {printf("etf is happening1\n");}
; */

MainClass : CLASS Identifier LEFTCURLY PUBLIC STATIC VOID MAIN LEFTROUND STRINGG LEFTSQUARE RIGHTSQUARE Identifier RIGHTROUND LEFTCURLY SYSTEMPRINT LEFTROUND Expression RIGHTROUND SEMICOLON RIGHTCURLY RIGHTCURLY
            {$$ = concat21($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21);}
;

TypeDeclaration : CLASS Identifier LEFTCURLY TypeIdentifierSemicolonStar MethodDeclarationStar RIGHTCURLY
                  {$$=concat6($1,$2,$3,$4,$5,$6);}
                  | CLASS Identifier EXTENDS Identifier LEFTCURLY TypeIdentifierSemicolonStar MethodDeclarationStar RIGHTCURLY
                  {$$ = concat8($1,$2,$3,$4,$5,$6,$7,$8);}
;

MethodDeclaration : PUBLIC Type Identifier LEFTROUND MultipleTypeIdentifiers RIGHTROUND LEFTCURLY TypeIdentifierSemicolonStar StatementStar RETURN Expression SEMICOLON RIGHTCURLY 
                    {$$ = concat13($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13);}
;

Type : INT LEFTSQUARE RIGHTSQUARE {$$ = concat3($1,$2,$3);}
       | BOOLEAN {$$ = concone($1);}
       | INT {$$ = concone($1);}
       | Identifier {$$ = concone($1);}
;

Statement : LEFTCURLY StatementStar RIGHTCURLY {$$ = concat3($1,$2,$3);}
            | SYSTEMPRINT LEFTROUND Expression RIGHTROUND SEMICOLON {$$ = concat5($1,$2,$3,$4,$5);}
            | Identifier EQUAL Expression SEMICOLON {$$ = concat4($1,$2,$3,$4);}
            | Identifier LEFTSQUARE Expression RIGHTSQUARE EQUAL Expression SEMICOLON 
            {$$ = concat7($1,$2,$3,$4,$5,$6,$7);}
            | IF LEFTROUND Expression RIGHTROUND Statement {$$ = concat5($1,$2,$3,$4,$5);}
            | IF LEFTROUND Expression RIGHTROUND Statement ELSE Statement {$$ = concat7($1,$2,$3,$4,$5,$6,$7);}
            | DO Statement WHILE LEFTROUND Expression RIGHTROUND SEMICOLON {$$ = concat7($1,$2,$3,$4,$5,$6,$7);}
            | WHILE LEFTROUND Expression RIGHTROUND Statement {$$ = concat5($1,$2,$3,$4,$5);}
            | Identifier LEFTROUND MultipleExpressions RIGHTROUND SEMICOLON {$$ = concat5($1,$2,$3,$4,$5); $$ = replaceMacro(concat4($1,$2,$3,$4),2);}
;

Expression : PrimaryExpression ANDAND PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression OROR PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression NOTEQUAL PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression LESSEQUAL PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression PLUS PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression MINUS PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression MULTIPLY PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression DIVIDE PrimaryExpression {$$ = concat3($1,$2,$3); }
             | PrimaryExpression LEFTSQUARE PrimaryExpression RIGHTSQUARE {$$ = concat4($1,$2,$3,$4);  }
             | PrimaryExpression DOT LENGTH {$$ = concat3($1,$2,$3); }
             | PrimaryExpression {$$ = concone($1); }
             | PrimaryExpression DOT Identifier LEFTROUND MultipleExpressions RIGHTROUND 
             {$$ = concat6($1,$2,$3,$4,$5,$6);}
             | Identifier LEFTROUND MultipleExpressions RIGHTROUND {$$ = concat4($1,$2,$3,$4); $$ = replaceMacro($$,1);}
;

PrimaryExpression : Integer {$$ = concone($1); }
                    | TRUE {$$ = concone($1); }
                    | FALSE {$$ = concone($1); }
                    | Identifier {$$ = concone($1); }
                    | THIS {$$ = concone($1); }
                    | NEW INT LEFTSQUARE Expression RIGHTSQUARE {$$ = concat5($1,$2,$3,$4,$5);   }
                    | NEW Identifier LEFTROUND RIGHTROUND {$$ = concat4($1,$2,$3,$4);  }
                    | NOT Expression {$$ = concat($1,$2); }
                    | LEFTROUND Expression RIGHTROUND {$$ = concat3($1,$2,$3); }
;

MacroDefinition : MacroDefExpression {$$ = concone($1);}
                  | MacroDefStatement {$$ = concone($1);}
;

MacroDefStatement : HASHDEFINE Identifier LEFTROUND MultipleIdentifiers RIGHTROUND LEFTCURLY StatementStar RIGHTCURLY
                    {$$ = concat8($1,$2,$3,$4,$5,$6,$7,$8); makeMacro($$); $$="";}
;

MacroDefExpression : HASHDEFINE Identifier LEFTROUND MultipleIdentifiers RIGHTROUND LEFTROUND Expression RIGHTROUND
                     {$$ = concat8($1,$2,$3,$4,$5,$6,$7,$8); makeMacro($$); $$="";}
;

Identifier : ID {$$ = concone($1);}
;

Integer : NUM {$$ = concone($1);}
;

//Helpers for A* type regular expressions
TypeIdentifierSemicolonStar : TypeIdentifierSemicolonStar Type Identifier SEMICOLON {$$ = concat4($1,$2,$3,$4);  }
                              | { $$ = ""; }
;

CommaTypeIdentifierStar : CommaTypeIdentifierStar COMMA Type Identifier {$$ = concat4($1,$2,$3,$4);  }
                          | { $$ = ""; }
;

TypeDeclarationStar : TypeDeclarationStar TypeDeclaration {$$ = concat($1,$2);  }
                      | { $$ = ""; }
;

MethodDeclarationStar : MethodDeclarationStar MethodDeclaration {$$ = concat($1,$2);  }
                        | { $$ = ""; }
;

StatementStar : Statement StatementStar {$$ = concat($1,$2); }
                | { $$ = ""; }
;

CommaExpressionStar : CommaExpressionStar COMMA Expression {$$ = concat3($1,$2,$3); }
                      | { $$ = ""; }
;

MacroDefinitionStar : MacroDefinitionStar MacroDefinition {$$ = concat($1,$2);}
                      | { $$ = ""; }
;

CommaIdentifierStar : CommaIdentifierStar COMMA Identifier {$$ = concat3($1,$2,$3); }
                 | { $$ = ""; }
;

// Helpers for A? type regular expressions

MultipleTypeIdentifiers : Type Identifier CommaTypeIdentifierStar {$$ = concat3($1,$2,$3); }
                          | { $$ = ""; }
;

MultipleExpressions : Expression CommaExpressionStar {$$ = concat($1,$2); }
                      | { $$ = ""; }
;

MultipleIdentifiers : Identifier CommaIdentifierStar {$$ = concat($1,$2); }
                      | { $$ = ""; }
;

%%

int yywrap(){
  return 1;
}

void yyerror(char *s){
  printf("// Failed to parse macrojava code.");
  exit(1);
}

int main()
{
  /* char* result = NULL; */
    /* result = yyparse(); */
    /* printf("%s", result); */
    yyparse();
    return 0;
}