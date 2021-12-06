#!/usr/bin/perl
#
#   This script is used to run Gaussian testjobs.  All of the jobs must
#   include the extra-print flag in the route (i.e., "#p").  After the
#   files are done running, the new output files (*.log) are diff'd with
#   the saved output files (*.out).  Unimportant differences are skipped
#   over (for example the cpu time) and all of the differences are put into
#   the file test.diff.
#
#   Note that this script executes the "gt" command rather than gdv.  Be
#   sure to have gt properly set-up.  Note that it is assumed the gt is
#   set in the tc shell.  If c shell (or any other shell) is used, the gt
#   command executed in this script using the system function will need to
#   be modified appropriately.
#
#   By default, the script runs all jobs that have the form *.com.  If any
#   command line arguments are given, then the script runs those jobs
#   instead.
#
#   To run the entire set of test jobs in the current directory use the
#   command line entry: %>./gtest_submit.pl
#   
#   To run only test003.com and test006.com use the command line entry:
#   %>./gtest_submit.pl test003.com test006.com
#
#
#   Hrant P. Hratchian
#   Department of Chemistry
#   Indiana University
#   hhratchi@indiana.edu
#
#
#   Process command-line arguments.
#
    $gauss_arg = "gt";
    $found_gauss_arg = 0;
    foreach $temp (@ARGV){
      if($temp =~ /^-gt$/){
        $gauss_arg = "gt";
        $found_gauss_arg += 1;
      }elsif($temp =~ /^-gt1$/){
        $gauss_arg = "gt1";
        $found_gauss_arg += 1;
      }elsif($temp =~ /^-gt2$/){
        $gauss_arg = "gt2";
        $found_gauss_arg += 1;
      }elsif($temp =~ /^-gdv$/){
        $gauss_arg = "gdv";
        $found_gauss_arg += 1;
      }elsif($temp =~ /^-g09$/){
        $gauss_arg = "g09";
        $found_gauss_arg += 1;
      }elsif($temp =~ /^-(.*)$/){
        die "\n\nUnknown switch found on the command line: -$1\n\n";
      }else{
        push(@in_files,$temp);
      }
    }
    if($found_gauss_arg > 1){
      die "\n\nFound $found_gauss_arg Gaussian argument switches. Only one is allowed!\n\n";
    }
    if(! @in_files){
      @in_files = glob "*.com *.gjf";
    }
#
#   Run the jobs and diff the .log and .out.  Note that this diff uses our
#   gau-diff script.
#   
    foreach $current_job (@in_files){
      chomp($current_job);
      $current_job_short = $current_job;
      $current_job_short =~ s/\.(com|gjf)//;
      print "\nRunning $current_job...\n";
      print "\t\tCommand: gdvcode && $gauss_arg < $current_job >& $current_job_short.log\n";
      system "/bin/tcsh", "-i", "-c", "gdvcode && $gauss_arg < $current_job >& $current_job_short.log";
      system "gau-diff $current_job_short.log $current_job_short.out > $current_job_short.diff";
      print "   Done with $current_job\n";
    }
#
#   Now, go through the *.diff files and compile a list of jobs where
#   differences exist.  Then remove the diff files.
#   
    foreach $diff_file (@in_files){
      $diff_file =~ s/\.com//;
      $diff_file .= ".diff";
      open DIFFFILE,"< $diff_file";
      $temp = undef;
      while(<DIFFFILE>){
        chomp;
        $temp .= $_;
      }
      close DIFFFILE;
      if($temp=~/^\s*$/){
        unlink "$diff_file";
      }else{
        $current_job = $diff_file;
        $current_job =~ s/\.diff//;
        push(@jobs_with_diffs,$current_job);
      }
    }
#
#   Print out a list of jobs that have differences between *.log and *.out.
#   If none exist, then print a message indicating that no differences were
#   found.
#   
    if(@jobs_with_diffs > 0){
      print "\n\nHere are the files with differences:\n";
      foreach $temp (@jobs_with_diffs){
        print "   $temp\n";
      }
    }else{
      print "\n\nNo differences found in the tests run.\n\n";
    }
#
#   Let the user know that the testing is completed.
#
    print "\n\nTesting complete.\n";
