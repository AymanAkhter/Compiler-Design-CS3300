import syntaxtree.*;
import visitor.*;
// import util.*;

public class P3 {
   public static void main(String [] args) {
      try {
         Node root = new MiniJavaParser(System.in).Goal();
         Object myObj = root.accept(new FirstPass(), "");
         root.accept(new SecondPass(), myObj);
      }
      catch (ParseException e) {
         System.out.println(e.toString());
      }
   }
} 