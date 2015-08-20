#!/bin/sh
exec scala "$0" "$@"
!#
/* This script takes in a list of ticket numbers and outputs whether each ticket is found on our release branches. 
   If the ticket cannot be found in either, then git is queried to find out if there exists a branch for the ticket
*/ 

import sys.process._
import java.io.File

val bugBranchName = None
val testBranchName = "resolved"
val stagingBranchName = "master"

val inTestBranch = Seq("git", "branch", "-a", "--merged", s"origin/$testBranchName")
val inStagingBranch = Seq("git", "branch", "-a", "--merged", s"origin/$stagingBranchName")

val inBug = Seq("git", "branch", "-a", "--merged", s"origin/$bugBranchName")
val branchExists = Seq("git", "branch", "-ar")

val latestCommit = Seq("git", "log", "-1", "--format=%H")
val commitSearch = Seq("git", "branch", "-r", "--contains")


def foundTicket(ticketId :String, command : Seq[String]) = (command #| Seq("grep", ticketId)).lineStream_! nonEmpty
def ticketBranch(ticketId:String) = {
	var pre = ""
	try{
		Integer.parseInt(ticketId.substring(0,1))
		pre = "t"
	}
	catch {
  		case e:Exception =>
  	}
	"origin/" + pre + ticketId
}
def latestBranchCommit(branch:String) = (latestCommit :+ branch).!!.trim
def foundCommitInBranch(commit:String, branch:String) =  ((commitSearch :+ commit) #| Seq("grep", branch)).lineStream_! nonEmpty

for(ticketId <- args.sorted) 
	yield {
		println("\n***** Ticket " + ticketId + " ******")

		if(foundTicket(ticketId, branchExists)){
			val latestTicketCommit = latestBranchCommit(ticketBranch(ticketId))

			println(s"Latest ticket branch commit: $latestTicketCommit\n")

			//TODO: this should be made generic with a list of branches to check
			if(!foundTicket(ticketId, inTestBranch)) println(s"Not found in $testBranchName (or latest commit is missing)")
			else{
				if(foundCommitInBranch(latestTicketCommit, s"origin/$testBranchName")) println(s"Found in $testBranchName")
				else println(s"Latest commit not found on $testBranchName branch")
			}

			if(!foundTicket(ticketId, inStagingBranch)) println(s"Not found in $stagingBranchName (or latest commit is missing)")
			else{
				if(foundCommitInBranch(latestTicketCommit, s"origin/$stagingBranchName")) println(s"Found in $stagingBranchName")
				else println(s"Latest commit not found on $stagingBranchName branch")
			}

			if(bugBranchName != None){
				if(!foundTicket(ticketId, inBug)) println(s"Not found in $bugBranchName (or latest commit is missing)")
				else{
					if(foundCommitInBranch(latestTicketCommit, s"origin/$bugBranchName"))	println(s"Found in $bugBranchName")
					else println(s"Latest commit not found on $bugBranchName branch")
				}
			}
		}
		else{
			println("No branch exists for this ticket")
		}
	}

println(s"\n***************************************************************\n*** List commits which differ between $testBranchName and $stagingBranchName ***\n")
println(Seq("git", "show-branch", s"origin/$testBranchName", s"origin/$stagingBranchName").!!)


println("\n************************** GIT LAST UPDATE ***************************")
if(! new File(".git/FETCH_HEAD").exists){
	println("WARNING: You must be in the project's root directory to get the last git update time\n")
}
else{
	print("This audit uses git data last updated on: ")
	("stat -c @%Y .git/FETCH_HEAD" #> "date --file=-" !)
	println("")
}
