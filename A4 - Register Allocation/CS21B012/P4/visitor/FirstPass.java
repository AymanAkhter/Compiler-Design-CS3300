//
// Generated by JTB 1.3.2
//

package visitor;
import syntaxtree.*;
import java.util.*;

/**
 * Provides default methods which visit each node in the tree in depth-first
 * order.  Your visitors may extend this class.
 */
class Interval{
   int start;
   int end;
   String name;
   public Interval(int start, int end, String name) {
      this.start = start;
      this.end = end;
      this.name = name;
  }
}

public class FirstPass<R,A> implements GJVisitor<R,A> {
   //
   // Auto class visitors--probably don't need to be overridden.
   //

    public Map<Integer,Instruction> instrMap;
    public Map<String,Integer> labelMap;
    public Integer lineNumber = 0;
    public boolean inStmt = false;
    public Map<String,Method> methodMap = new HashMap<String,Method>();
    public String currentMethodName;
    int callArgs=0;
    int stackLocationCnt=0;
    boolean inCallArgs;
    boolean lblFlag = false;

    public void printDefUse(){
      for(Map.Entry<Integer,Instruction> entry: instrMap.entrySet()){

         Integer line = entry.getKey();
         Instruction instr = entry.getValue();

         System.out.println("DefVars for line "+ line + instr.def);
         System.out.println("UseVars for line "+ line + instr.use);
      }  
    }

    public void printInOut(){

         // for(Map.Entry<String,Method> entry : methodMap.entrySet()){
         //    String methodName = entry.getKey();
         //    Method curMethod = entry.getValue();
         // }
         for(Map.Entry<Integer,Instruction> entry: instrMap.entrySet()){

            Integer line = entry.getKey();
            Instruction instr = entry.getValue();

            System.out.println("InVars for line "+ line + instr.in);
            System.out.println("OutVars for line "+ line + instr.out);
        }   
    }

    public void printLiveRanges(){
         for(Map.Entry<String,Method> entry: methodMap.entrySet()){

            String methodName = entry.getKey();
            Method curMethod = entry.getValue();
            System.out.println("Method : " + methodName);
            
            for(Map.Entry<String,Integer> entry2: curMethod.liveStart.entrySet()){

               String tempName = entry2.getKey();
               Integer startLine = entry2.getValue();
               Integer endLine = curMethod.liveEnd.get(tempName);

               System.out.println("    TEMP " + tempName + " --> Start = " + startLine + ", End = " + endLine);

            }
         }
    }

    public void sortIntervalsList(ArrayList<Interval> intervals){

         ArrayList<Interval> retList = new ArrayList<Interval>();
         int n = intervals.size();
         for(int i=0; i<n; i++){
            int minInd=0;
            for(int j=0; j<intervals.size(); j++){
               if(intervals.get(j).start < intervals.get(minInd).start){
                  minInd=j;
               }
            }
            retList.add(intervals.get(minInd));
            intervals.remove(minInd);
         }
         for(int i=0; i<retList.size(); i++){
            intervals.add(retList.get(i));
         }
         // intervals = retList;
         
   }

   public void addToActive(Interval newInterval, ArrayList<Interval> active){

         int n = active.size();
         int pos = n;
         for(int i=0; i<n; i++){
            if(newInterval.end < active.get(i).end){
               pos = i;
               break;
            }
         }
         active.add(pos,newInterval);
   }

   public void removeFromActive(Interval remInterval, ArrayList<Interval> active){

         int n = active.size();
         int remPos = n;
         for(int i=0; i<n; i++){
            if(remInterval.equals(active.get(i))){
               remPos = i;
               break;
            }
         }
         // System.out.println(remPos);
         active.remove(remPos);
   }

    public void expireOldIntervals(Method curMethod, int i, ArrayList<Interval> intervals, ArrayList<String> registers, ArrayList<Interval> active){
         ArrayList<Interval> removeIntervals = new ArrayList<Interval>();
         for(int j=0; j<active.size(); j++){
            if(active.get(j).end >= intervals.get(i).start)
               break;
            removeIntervals.add(active.get(j));
            registers.add(curMethod.register.get(active.get(j).name));
         }
         for(int j=0; j<removeIntervals.size(); j++){
            removeFromActive(removeIntervals.get(j), active);
         }
    }

    public void spillAtInterval(Method curMethod, int i, ArrayList<Interval> intervals, ArrayList<String> registers, ArrayList<Interval> active){
         Interval spill = active.get(active.size()-1);
         String locName = Integer.toString(stackLocationCnt++);
         if(spill.end > intervals.get(i).end){
            curMethod.register.put(intervals.get(i).name, curMethod.register.get(spill.name));
            curMethod.register.put(spill.name, "SPILLEDARG " + locName);
            active.remove(active.size()-1);
            addToActive(intervals.get(i), active);
         }
         else{
            curMethod.register.put(intervals.get(i).name, "SPILLEDARG " + locName);
         }
    }

    public void assignRegister(Method curMethod, int i, ArrayList<Interval> intervals, ArrayList<String> registers, ArrayList<Interval> active){
         curMethod.register.put(intervals.get(i).name, registers.get(0));
         addToActive(intervals.get(i), active);
         registers.remove(0);
    }

    public void printAllocation(){
      for(Map.Entry<String,Method> entry : methodMap.entrySet()){

         String methodName = entry.getKey();
         Method curMethod = entry.getValue();
         System.out.println("METHOD : " + methodName);
         for(Map.Entry<String, String> entry2 : curMethod.register.entrySet()){
            String tempName = entry2.getKey();
            String regName = entry2.getValue();
            System.out.println("    TEMP " + tempName + " --> " + regName);
         }

      }
    }

   //  public void removeName(String name, ArrayList<Interval> intervals){


   //       ArrayList<Interval> removeIntervals = new ArrayList<Interval>();
   //       for(int j=0; j<intervals.size(); j++){
   //          if((intervals.get(j).name).equals(name)){
   //             removeIntervals
   //          }
   //             break;
   //          removeIntervals.add(active.get(j));
   //          registers.add(curMethod.register.get(active.get(j).name));
   //       }
   //       for(int j=0; j<removeIntervals.size(); j++){
   //          removeFromActive(removeIntervals.get(j), active);
   //       }

   //  }


    public void allocateRegisters(){

      for(Map.Entry<String,Method> entry: methodMap.entrySet()){

         String methodName = entry.getKey();
         Method curMethod = entry.getValue();
         // System.out.println("MAXCALL = " + curMethod.maxCallArgs);
         ArrayList<Interval> intervals = new ArrayList<Interval>();
         ArrayList<String> registers = new ArrayList<String>();
         ArrayList<Interval> active = new ArrayList<Interval>();
         int R = 18;
         // int stackLocationCnt;
         if(curMethod.args<=4){
            stackLocationCnt = 18;
         }
         else{
            stackLocationCnt = 18 + curMethod.args-4;
         }

         for(int i=0; i<8; i++){
            registers.add("s"+Integer.toString(i));
         }
         for(int i=0; i<10; i++){
            registers.add("t"+Integer.toString(i));
         }
         
         
         for(Map.Entry<String,Integer> entry2: curMethod.liveStart.entrySet()){

            String tempName = entry2.getKey();
            Integer startLine = entry2.getValue();
            Integer endLine = curMethod.liveEnd.get(tempName);
            if(curMethod.args>=4){
               if(Integer.valueOf(tempName) >= 4 && Integer.valueOf(tempName) < curMethod.args){
                  curMethod.register.put(tempName, "SPILLEDARG " + (Integer.valueOf(tempName)-4));
                  continue;
               }
            }
            intervals.add(new Interval(startLine,endLine,tempName));
         }

         // for(int i=4; i<curMethod.args; i++){
         //    removeName(String.valueOf(i), intervals);
         // }

         sortIntervalsList(intervals);
         // for(int i=0; i<intervals.size(); i++){
         //    System.out.println("TEMP " + intervals.get(i).name + " --> " + intervals.get(i).start + " " + intervals.get(i).end);
         // }
         int spillCnt=0;
         int n=intervals.size();
         for(int i=0; i<n; i++){
            expireOldIntervals(curMethod,i,intervals,registers,active);
            if(active.size()==R){
               spillAtInterval(curMethod,i,intervals,registers,active);
               spillCnt++;
               // System.out.println("YOOOOO");
            }
               
            else
               assignRegister(curMethod,i,intervals,registers,active);
         }
         curMethod.totalSpilledInAlloc = spillCnt;
         // System.out.println("aaaa" + spillCnt);
      }  
    }

    public int findElement(ArrayList<String> list, String elem){
        for(int i=0; i<list.size(); i++){
            if(list.get(i).equals(elem))
                return i;
        }
        return -1;
    }

    public ArrayList<String> union(ArrayList<String> list1, ArrayList<String> list2){
        ArrayList<String> unionList = list1;
        for(int i=0; i<list2.size(); i++){
            String listElem = list2.get(i);
            if(findElement(list1,listElem)==-1){
                unionList.add(listElem);
            }
        }
        return unionList;
    }

    public ArrayList<String> diff(ArrayList<String> list1, ArrayList<String> list2){
        ArrayList<String> diffList = list1;
        for(int i=0; i<list2.size(); i++){
            String listElem = list2.get(i);
            int position = findElement(list1,list2.get(i));
            if(position!=-1){
                diffList.remove(position);
            }
        }
        return diffList;
    }

    public boolean checkSame(ArrayList<String> list1, ArrayList<String> list2){
         if(list1.size()!=list2.size())
            return false;
         for(int i=0; i<list1.size(); i++){
            if(!list2.contains(list1.get(i))){
               return false;
            }
         }
         return true;
    }

    public void runLiveness(){
        
        boolean changed = false;
        for(Map.Entry<Integer,Instruction> entry: instrMap.entrySet()){

            Integer line = entry.getKey();
            Instruction instr = entry.getValue();

            ArrayList<String> prevIn = new ArrayList<String>();
            ArrayList<String> prevOut = new ArrayList<String>();
            for(int i=0; i<instr.in.size(); i++){
               prevIn.add(instr.in.get(i));
            }
            for(int i=0; i<instr.out.size(); i++){
               prevOut.add(instr.out.get(i));
            }
            instr.in = union(instr.use, diff(instr.out, instr.def));
            ArrayList<String> newOut = new ArrayList<String>();
            for(int i=0; i<instr.suc.size(); i++){
                newOut = union(newOut, instrMap.get(instr.suc.get(Integer.valueOf(i))).in);
            }
            instr.out = newOut;

            if(!checkSame(instr.in, prevIn) || !checkSame(instr.out, prevOut))
                changed = true;
            // instrMap.get(line).in = instr.in;
            // instrMap.get(line).out = instr.out;
            // System.out.println("In : " + instr.in);
            // System.out.println("Out : " + instr.out);
        }   
        if(changed)
            runLiveness();
    }

    public void getLiveRanges(){
        for(Map.Entry<String,Method> entry: methodMap.entrySet()){

            String methodName = entry.getKey();
            Method curMethod = entry.getValue();

            for(int i=curMethod.startLine; i<=curMethod.endLine; i++){
               // System.out.println("YO" + i);
                Instruction curInstr = instrMap.get(Integer.valueOf(i));
                for(int j=0; j<curInstr.out.size(); j++){
                    String curTemp = curInstr.out.get(Integer.valueOf(j));
                    if(curMethod.liveStart.get(curTemp)==null){
                        curMethod.liveStart.put(curTemp, i);
                    }
                }
                for(int j=0; j<curInstr.in.size(); j++){
                    String curTemp = curInstr.in.get(Integer.valueOf(j));
                    curMethod.liveEnd.put(curTemp, i);
                }
            }
        }
    }

   public R visit(NodeList n, A argu) {
      R _ret=null;
      int _count=0;
      for ( Enumeration<Node> e = n.elements(); e.hasMoreElements(); ) {
         e.nextElement().accept(this,argu);
         _count++;
      }
      return _ret;
   }

   public R visit(NodeListOptional n, A argu) {
      if ( n.present() ) {
         R _ret=null;
         int _count=0;
         for ( Enumeration<Node> e = n.elements(); e.hasMoreElements(); ) {
            e.nextElement().accept(this,argu);
            _count++;
         }
         return _ret;
      }
      else
         return null;
   }

   public R visit(NodeOptional n, A argu) {
      if ( n.present() )
         return n.node.accept(this,argu);
      else
         return null;
   }

   public R visit(NodeSequence n, A argu) {
      R _ret=null;
      int _count=0;
      for ( Enumeration<Node> e = n.elements(); e.hasMoreElements(); ) {
         e.nextElement().accept(this,argu);
         _count++;
      }
      return _ret;
   }

   public R visit(NodeToken n, A argu) { return null; }

   //
   // User-generated visitor methods below
   //

   /**
    * f0 -> "MAIN"
    * f1 -> StmtList()
    * f2 -> "END"
    * f3 -> ( Procedure() )*
    * f4 -> <EOF>
    */
   public R visit(Goal n, A argu) {
      R _ret=null;
      
      Collector passedObj = (Collector)(argu);
      instrMap = passedObj.instrMap;
      labelMap = passedObj.labelMap;
      argu=(A)"";
      // printDefUse();
      n.f0.accept(this, argu);
      String methodName = "MAIN";
      currentMethodName = methodName;
      Method newMethod = new Method();
      newMethod.startLine = lineNumber+1;
      methodMap.put(methodName, newMethod);
      n.f1.accept(this, argu);
      lineNumber++;
      methodMap.get(methodName).endLine = lineNumber;
      // newMethod.endLine = lineNumber;
      n.f2.accept(this, argu);
      n.f3.accept(this, argu);
      n.f4.accept(this, argu);
      runLiveness();
      getLiveRanges();
      // printInOut();
      // printLiveRanges();
      allocateRegisters();
      // printAllocation();
      return (R)methodMap;
   }

   /**
    * f0 -> ( ( Label() )? Stmt() )*
    */
   public R visit(StmtList n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      return _ret;
   }

   /**
    * f0 -> Label()
    * f1 -> "["
    * f2 -> IntegerLiteral()
    * f3 -> "]"
    * f4 -> StmtExp()
    */
   public R visit(Procedure n, A argu) {
      R _ret=null;
      lblFlag = true;
      String methodName = (String)(n.f0.accept(this, argu));
      lblFlag = false;
      currentMethodName = methodName;
      Method newMethod = new Method();
      newMethod.startLine = lineNumber;
      methodMap.put(methodName, newMethod);

      n.f1.accept(this, argu);
      
      methodMap.get(methodName).args = Integer.valueOf(((String)(n.f2.accept(this, argu))));
      n.f3.accept(this, argu);
      n.f4.accept(this, argu);
      lineNumber++;
      methodMap.get(methodName).endLine = lineNumber;
      
      return _ret;
   }

   /**
    * f0 -> NoOpStmt()
    *       | ErrorStmt()
    *       | CJumpStmt()
    *       | JumpStmt()
    *       | HStoreStmt()
    *       | HLoadStmt()
    *       | MoveStmt()
    *       | PrintStmt()
    */
   public R visit(Stmt n, A argu) {
      R _ret=null;
      lineNumber++;
      inStmt = true;
      n.f0.accept(this, argu);
      inStmt=false;
      return _ret;
   }

   /**
    * f0 -> "NOOP"
    */
   public R visit(NoOpStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      // if(instrMap.get(lineNumber)==null)
      //    System.out.println("NullHere");
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      return _ret;
   }

   /**
    * f0 -> "ERROR"
    */
   public R visit(ErrorStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      return _ret;
   }

   /**
    * f0 -> "CJUMP"
    * f1 -> Temp()
    * f2 -> Label()
    */
   public R visit(CJumpStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      String labelName = (String)(n.f2.accept(this, argu));
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      instrMap.get(lineNumber).suc.add(labelMap.get(labelName));
      return _ret;
   }

   /**
    * f0 -> "JUMP"
    * f1 -> Label()
    */
   public R visit(JumpStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      String labelName = (String)(n.f1.accept(this, argu));
      instrMap.get(lineNumber).suc.add(labelMap.get(labelName));
      return _ret;
   }

   /**
    * f0 -> "HSTORE"
    * f1 -> Temp()
    * f2 -> IntegerLiteral()
    * f3 -> Temp()
    */
   public R visit(HStoreStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      n.f2.accept(this, argu);
      n.f3.accept(this, argu);
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      return _ret;
   }

   /**
    * f0 -> "HLOAD"
    * f1 -> Temp()
    * f2 -> Temp()
    * f3 -> IntegerLiteral()
    */
   public R visit(HLoadStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      n.f2.accept(this, argu);
      n.f3.accept(this, argu);
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      return _ret;
   }

   /**
    * f0 -> "MOVE"
    * f1 -> Temp()
    * f2 -> Exp()
    */
   public R visit(MoveStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      n.f2.accept(this, argu);
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      return _ret;
   }

   /**
    * f0 -> "PRINT"
    * f1 -> SimpleExp()
    */
   public R visit(PrintStmt n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      return _ret;
   }

   /**
    * f0 -> Call()
    *       | HAllocate()
    *       | BinOp()
    *       | SimpleExp()
    */
   public R visit(Exp n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      return _ret;
   }

   /**
    * f0 -> "BEGIN"
    * f1 -> StmtList()
    * f2 -> "RETURN"
    * f3 -> SimpleExp()
    * f4 -> "END"
    */
   public R visit(StmtExp n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      lineNumber++;
      instrMap.get(lineNumber).suc.add(lineNumber+1);
      n.f2.accept(this, argu);
      n.f3.accept(this, argu);
      n.f4.accept(this, argu);
      return _ret;
   }

   /**
    * f0 -> "CALL"
    * f1 -> SimpleExp()
    * f2 -> "("
    * f3 -> ( Temp() )*
    * f4 -> ")"
    */
   public R visit(Call n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      n.f2.accept(this, argu);
      inCallArgs = true;
      n.f3.accept(this, argu);
      inCallArgs = false;
      if(methodMap.get(currentMethodName).maxCallArgs < callArgs){
         methodMap.get(currentMethodName).maxCallArgs = callArgs;
      }
      callArgs=0;
      n.f4.accept(this, argu);
      return _ret;
   }

   /**
    * f0 -> "HALLOCATE"
    * f1 -> SimpleExp()
    */
   public R visit(HAllocate n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      return _ret;
   }

   /**
    * f0 -> Operator()
    * f1 -> Temp()
    * f2 -> SimpleExp()
    */
   public R visit(BinOp n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      n.f1.accept(this, argu);
      n.f2.accept(this, argu);
      return _ret;
   }

   /**
    * f0 -> "LE"
    *       | "NE"
    *       | "PLUS"
    *       | "MINUS"
    *       | "TIMES"
    *       | "DIV"
    */
   public R visit(Operator n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      return _ret;
   }

   /**
    * f0 -> Temp()
    *       | IntegerLiteral()
    *       | Label()
    */
   public R visit(SimpleExp n, A argu) {
      R _ret=null;
      lblFlag = true;
      n.f0.accept(this, argu);
      lblFlag = false;
      return _ret;
   }

   /**
    * f0 -> "TEMP"
    * f1 -> IntegerLiteral()
    */
   public R visit(Temp n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      if(inCallArgs)
         callArgs++;
      String curTemp = (String)(n.f1.accept(this, argu));
      Method curMethod = methodMap.get(currentMethodName);
      if(Integer.parseInt(curMethod.lastTemp)<Integer.parseInt(curTemp)){
         curMethod.lastTemp = curTemp;
      }
      return _ret;
   }

   /**
    * f0 -> <INTEGER_LITERAL>
    */
   public R visit(IntegerLiteral n, A argu) {
      R _ret=null;
      n.f0.accept(this, argu);
      String intName = (String)(n.f0.tokenImage);
      return (R)intName;
   }

   /**
    * f0 -> <IDENTIFIER>
    */
   public R visit(Label n, A argu) {
      R _ret=null;
      if(!inStmt){
        lineNumber++;
        instrMap.get(lineNumber).suc.add(lineNumber+1);
      }
      n.f0.accept(this, argu);
      String name = (String)(n.f0.tokenImage);
      if(!lblFlag)
         name = (name + currentMethodName);
      return (R)name;
   }

}
