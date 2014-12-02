#!/bin/sh
exec scala "$0" "$@"
!#
import sys.process._

val inResolved = Seq("git", "branch", "--list", "-a", "--merged", "resolved")
val inPoReady = Seq("git", "branch", "--list", "-a", "--merged", "po_ready")
val branch = Seq("git", "branch", "-r")
var grep = Seq("grep")

def foundTicket(ticketId :String, command : Seq[String]) = 
	if( (command #| Seq("grep", ticketId)).lineStream_! nonEmpty) "Found " else "Not found " 

for(ticketId <- args.sorted) 
	yield {
		println("\n***** Ticket " + ticketId + " ******")
		println(foundTicket(ticketId, branch) + "to be a known branch")
		println(foundTicket(ticketId, inResolved) + "in resolved branch")
		println(foundTicket(ticketId, inPoReady) + "in po_ready branch")
	}
