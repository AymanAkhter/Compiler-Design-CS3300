#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(char *s)
{
  printf("%s\n",s);
  exit(0);
}

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
  if(replMacro->macroType==2 && replMacro->empty==1)
  {
    char* ttt = (char*)malloc(2*sizeof(char));
    ttt[0] = ' ';
    ttt[1] = '\0';
    return ttt;
  }
  
  if(replMacro==NULL)
  {
    yyerror(strdup("Macro Not Found\n"));
  }
  if(replMacro->macroType!=type)
  {
    yyerror(strdup("Macro type mismatch\n"));
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

int main(){

    char a[100],a2[100],a3[100],a4[100],a5[100];
    strcpy(a,"#define ADD ( X , Y ) ( X + Y )");
    // strcpy(a2,"#define ZERO ( ) ( 0 + 0 )");
    // strcpy(a3,"#define LEL ( xl , yee , zhs ) ( 2 + yee * 3 * xl / zhs + 0 )");
    // strcpy(a4,"#define MYEXP ( x , y ) { x = Hello ; y = hi ; }");
    // strcpy(a5,"#define print ( arg  ) {  }");
    makeMacro(a);
    // makeMacro(a2);
    // makeMacro(a3);
    // makeMacro(a4);
    // makeMacro(a5);
    char b[100],b2[100],b3[100],b4[100],b5[100];
    strcpy(b,"ADD ( ( a + b ) , b )");
    // strcpy(b2,"ZERO ( )");
    // strcpy(b3,"LEL ( tree , yooh , h )");
    // strcpy(b4,"MYEXP ( hi , bye )");
    // strcpy(b5,"print ( ( 0 + 0 ) )");
    // printf("%s\n",replaceMacro(b3,1));
    // printf("%s\n",replaceMacro(b2,1));
    printf("%s\n",replaceMacro(b,1));
    // printf("%s\n",replaceMacro(b4,2));
    // printf("%s\n",replaceMacro(b5,2));

  // char str[80] = "   This is www.tutorialspoint.com  -  website   ";
  //  const char s[2] = " ";
  //  char *token;
   
  //  /* get the first token */
  //  token = strtok(str, s);
   
  //  /* walk through other tokens */
  //  while( token != NULL ) {
  //     printf( " %s\n", token );
    
  //     token = strtok(NULL, s);
  //  }
    
    return 0;
}