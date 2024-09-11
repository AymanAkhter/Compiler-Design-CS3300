package visitor;
import syntaxtree.*;
import java.util.*;

public class Instruction{
      public ArrayList<String> use = new ArrayList<String>();
      public ArrayList<String> def = new ArrayList<String>();
      public ArrayList<Integer> suc = new ArrayList<Integer>();
      public ArrayList<String> in = new ArrayList<String>();
      public ArrayList<String> out = new ArrayList<String>();
   }