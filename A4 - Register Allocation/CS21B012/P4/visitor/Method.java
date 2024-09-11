package visitor;
import syntaxtree.*;
import java.util.*;

public class Method{
    public int startLine;
    public int endLine;
    public String lastTemp = "0";
    public int args;
    public int maxCallArgs = -1;
    public int totalSpilledInAlloc = 0;
    public Map<String, Integer> liveStart = new HashMap<String, Integer>();  
    public Map<String, Integer> liveEnd = new HashMap<String, Integer>();  
    public Map<String, String> register = new HashMap<String,String>();
}