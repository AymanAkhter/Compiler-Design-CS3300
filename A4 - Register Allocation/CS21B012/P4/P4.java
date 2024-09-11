import syntaxtree.*;
import visitor.*;

public class P4 {
   public static void main(String [] args) {
      try {
         Node root = new microIRParser(System.in).Goal();
         Object myObj = root.accept(new ZerothPass(), "");
         Object myObj2 = root.accept(new FirstPass(), myObj);
         root.accept(new SecondPass(), myObj2);
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
   }
} 
