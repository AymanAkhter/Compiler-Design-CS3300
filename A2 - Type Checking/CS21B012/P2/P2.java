import syntaxtree.*;
import visitor.*;
// import util.*;

public class P2 {
   public static void main(String [] args) {
      try {
         Node root = new MiniJavaParser(System.in).Goal();
         // System.out.println("Program parsed success");
         // FirstPass vis = new FirstPass();
         // FirstPass.Global myGlobal = vis.global;
         // System.out.println("Type error");
         // System.exit(0);
         
          // Your assignment part is invoked here.
         Object myObj = root.accept(new FirstPass(), "");
         // Map<String, FirstPass.Class> passedMap = FirstPass.map;
         root.accept(new SecondPass(), myObj);
         System.out.println("Program type checked successfully");
         // SecondPass vis2 = new SecondPass(myGlobal);
         // root.accept(vis2, "");
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
      // catch(RuntimeException e){
      //    System.out.println("Program type checked successfully");
      // }
   }
} 