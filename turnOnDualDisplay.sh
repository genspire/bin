#!/bin/sh
exec /home/robin/tools/scala/bin/scala "$0" "$@" 
!#
//#2> /home/robin/dualdisplay.error

 import scala.swing.Dialog
 import scala.swing.Dialog.Result
 import scala.sys.process._
 
 object DualDisplay {
   def main(args: Array[String]) {
     val laptopPrefix = "LVDS"
     val externalPrefix = "HDMI"
     
        
     if(args.size == 0 || Dialog.showConfirmation(message="Turn on dual display?", title="Dual Display?").equals(Result.Yes) )
        turnOnDual(externalPrefix, laptopPrefix)
//        Seq("turnOnDualDisplay.sh", displayNumber("LVDS"), displayNumber("HDMI")).!
     
   }
 }

 def displayNumber(name : String) : String = { ("xrandr" #| ("grep " + name) ).!!.split(" ").filter(_.startsWith(name)).collectFirst({ case s if s.size > name.size => s.charAt(name.size)}).get.toString }

 def turnOnDual(mainDisplayName : String, rightDisplayName : String) = {
    
    val main = mainDisplayName + displayNumber(mainDisplayName)
    val right = rightDisplayName + displayNumber(rightDisplayName)
    
    println("Making " + main + " the main display and " + right + " the right display")
    
    //bind mode to monitor
    ("xrandr --addmode " + main + " 1920x1080").!

    //set monitor resolution
    ("xrandr --output " + main + " --mode 1920x1080").!

    //set monitor postition
    ("xrandr --output " + main+ " --left-of " + right).!

    //set monitor position 2
    ("xrandr --output " + right+ " --right-of " + main).!

    //set primary monitor
    ("xrandr --output " + main+ " --primary").!

    //set primary monitor 2
    ("xrandr --output " + right + " --primary").!
 
 }

 DualDisplay.main(args)
  
  
