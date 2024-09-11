import java.util.*;

class Cycle {

    private static int clk = 0;
    private static boolean cycle = false;
    private static Map<String, String> parent = new HashMap<String, String>();
    private static Map<String, Boolean> vis = new HashMap<String, Boolean>();
    private static Map<String, Integer> start = new HashMap<String, Integer>();
    private static Map<String, Integer> end = new HashMap<String, Integer>();

    public static void main(String[] a) {
        int num;
        // System.out.println(new Fac().ComputeFac((10 + 0)));
        // Map<String, Integer> myMap = new HashMap<String, Integer>();
        

        parent.put("a", "b");
        vis.put("a",false);
        start.put("a",-1);
        end.put("a",-1);

        parent.put("b", "c");
        vis.put("b",false);
        start.put("b",-1);
        end.put("b",-1);

        parent.put("c", "d");
        vis.put("c",false);
        start.put("c",-1);
        end.put("c",-1);

        parent.put("c", "a");
        vis.put("c",false);
        start.put("c",-1);
        end.put("c",-1);
        // System.out.println(new Fac().ComputeFac(num));
        findCycle();
    }

    public static void findCycle() {

        for (Map.Entry<String, String> entry : parent.entrySet()) {
            String key = entry.getKey();
            // Integer value = entry.getValue();
            // System.out.println("Key: " + key + ", Value: " + value);
            if(!vis.get(key))
            {
                dfs(key);
            }
        }
        if(cycle==true){
            System.out.println("YES\n");
        }
        else{
            System.out.println("NO\n");
        }
    }

    public static void dfs(String cur)
    {
        vis.put(cur,true);
        start.put(cur,clk++);
        String par = parent.get(cur);
        if(parent.containsKey(par))
        {
            if(start.get(par)!=-1 && end.get(par)==-1)
            {
                // System.out.println(cur + " " + par);
                cycle = true;
                return;
            }
            dfs(par);
        }

        
        end.put(cur,clk++);
    }
}
