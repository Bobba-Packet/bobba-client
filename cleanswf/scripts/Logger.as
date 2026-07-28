package
{
   import com.sulake.core.runtime.ILogger;
   import flash.filesystem.File;
   import flash.filesystem.FileMode;
   import flash.filesystem.FileStream;
   
   public class Logger
   {
      
      public static var listener:ILogger;
      
      public function Logger()
      {
         super();
      }
      
      public static function log(... rest) : void
      {
         var line:String = "";
         var i:int = 0;
         var stream:FileStream = null;
         var file:File = null;
         for(i = 0; i < rest.length; i++)
         {
            if(i > 0)
            {
               line += " ";
            }
            line += rest[i] != null ? String(rest[i]) : "null";
         }
         trace("[Bobba]",line);
         try
         {
            file = File.applicationStorageDirectory.resolvePath("bobba_debug.log");
            stream = new FileStream();
            stream.open(file,FileMode.APPEND);
            stream.writeUTFBytes(line + "\n");
            stream.close();
         }
         catch(e:Error)
         {
            trace("[Bobba][log-file-fail]",e.message);
         }
         if(listener != null)
         {
            try
            {
               listener.log(rest);
            }
            catch(e2:Error)
            {
            }
         }
      }
   }
}
