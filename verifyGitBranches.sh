#!/bin/sh
exec scala "$0" "$@"
!#
/* This script takes in a list of ticket numbers and outputs whether each ticket is found on resolved or po_ready. 
   If the ticket cannot be found in either, then git is queried to find out if there exists a branch for the ticket
*/ 

import sys.process._
import java.io.File

val inResolved = Seq("git", "branch", "-a", "--merged", "origin/resolved")
//val resolvedLogs = Seq("git", "log", "resolved")
val inPoReady = Seq("git", "branch", "-a", "--merged", "origin/po_ready")
//val poReadyLogs = Seq("git", "log", "po_ready")
val inOooPilot = Seq("git", "branch", "-a", "--merged", "origin/ooo_pilot")
val branch = Seq("git", "branch", "-r")

val latestCommit = Seq("git", "log", "-1", "--format=%H")
val commitSearch = Seq("git", "branch", "-r", "--contains")


def foundTicket(ticketId :String, command : Seq[String]) = (command #| Seq("grep", ticketId)).lineStream_! nonEmpty
def ticketBranch(ticketId:String) = "origin/t" + ticketId
def latestBranchCommit(branch:String) = (latestCommit :+ branch).!!.trim
def foundCommitInBranch(commit:String, branch:String) =  ((commitSearch :+ commit) #| Seq("grep", branch)).lineStream_! nonEmpty

for(ticketId <- args.sorted) 
	yield {
		println("\n***** Ticket " + ticketId + " ******")

		val latestTicketCommit = latestBranchCommit(ticketBranch(ticketId))

		println(s"Latest ticket branch commit: $latestTicketCommit\n")

		if(!foundTicket(ticketId, inResolved)) println("Not found in resolved")
		else{
			if(foundCommitInBranch(latestTicketCommit, "origin/resolved")) println("Found in resolved")
			else println("Latest commit not found on resolved branch")
		}

		if(!foundTicket(ticketId, inPoReady)) println("Not found in po_ready")
		else{
			if(foundCommitInBranch(latestTicketCommit, "origin/po_ready")) println("Found in po_ready")
			else println("Latest commit not found on po_ready branch")
		}

		if(!foundTicket(ticketId, inOooPilot)) println("Not found in ooo_pilot")
		else{
			if(foundCommitInBranch(latestTicketCommit, "origin/ooo_pilot"))	println("Found in ooo_pilot")
			else println("Latest commit not found on ooo_pilot branch")
		}
	}

println("\n***************************************************************\n*** List commits which differ between resolved and po_ready ***\n")
println(Seq("git", "show-branch", "origin/resolved", "origin/po_ready").!!)


println("\n************************** GIT LAST UPDATE ***************************")
if(! new File(".git/FETCH_HEAD").exists){
	println("WARNING: You must be in the project's root directory to get the last git update time\n")
}
else{
	print("This audit uses git data last updated on: ")
	("stat -c @%Y .git/FETCH_HEAD" #> "date --file=-" !)
	println("")
}
