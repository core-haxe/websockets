package;

using StringTools;

class DebugUtils {
    public static function printHeader(title:String) {
        #if sys
        Sys.println("-------------------------------------------------------");
        Sys.print("| ");
        Sys.print(title.rpad(" ", 40));
        Sys.println("| Time (ms) |");
        Sys.println("-------------------------------------------------------");
        #end
    }

    public static function printRow(name:String, data:Any, isLast:Bool = false) {
        #if sys
        Sys.print("| ");
        Sys.print(name.rpad(" ", 40));
        Sys.print("| ");
        Sys.print(Std.string(data).rpad(" ", 9));
        Sys.println(" |");

        if (isLast) {
            Sys.println("-------------------------------------------------------");
        }
        #end
    }
}