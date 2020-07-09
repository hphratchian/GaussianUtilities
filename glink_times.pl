#!/usr/bin/perl
#
#
#   Load the arguments and GAUSSIAN log file name from the command line.
#
    $verbose = 0;
    foreach (@ARGV){
      if(/^-v/){
        $verbose = 1;
      }elsif(/^-c/){
        $cume = 1;
      }elsif(/^-t/){
        $verbose = -1;
      }elsif(/^-(.*)/){
        die "\n\nUnknown argument sent to glink_times: $1\n\n";
      }else{
        $gfile_name = $_;
        $num_gfiles += 1;
      }
    }
    if($num_gfiles != 1){die "\nWrong number of GAUSSIAN log files given!\n\n"}
#
#   Get timing info from the Gaussian log file.  This is accomplished by
#   calling Routine get_glink_times_sub, followed by split operations to
#   tear apart and load the stings returned from the routine into lists and
#   hashes.
#
    ($links_found_temp,$link_cpu_times_temp,$link_wall_times_temp,
      $links_tot_cpu_time_temp,$links_cpu_time_verbose_temp,
      $links_tot_wall_time_temp,$links_wall_time_verbose_temp,
      $links_num_entries_temp,$cume_data) = &get_glink_times_sub($gfile_name);
    @links_found = split /,/,$links_found_temp;
    @temp_array = split /,/,$link_cpu_times_temp;
    %link_cpu_times = @temp_array;
    @temp_array = split /,/,$link_wall_times_temp;
    %link_wall_times = @temp_array;
    @links_tot_cpu_time = split /,/,$links_tot_cpu_time_temp;
    @links_cpu_time_verbose = split /,/,$links_cpu_time_verbose_temp;
    @links_tot_wall_time = split /,/,$links_tot_wall_time_temp;
    @links_wall_time_verbose = split /,/,$links_wall_time_verbose_temp;
    @links_num_entries = split /,/,$links_num_entries_temp;

#hph
    if($cume){
      print "Hrant, here is the cume data...\n$cume_data\n\n";
    }
#hph

#
#   Compute the total cpu and wall times so that we can report percent job
#   times for each link below.
#
    for ($i=0;$i<@links_found;$i++){
      $job_cpu_time += $links_tot_cpu_time[$i];
      $job_wall_time += $links_tot_wall_time[$i];
    }
#
#   Print the timings table with number of times and total time spent in
#   each link.
#
    $table_boarder_format_1 = ("="x60)."\n";
    $table_boarder_format_2 = "\t".("-"x50)."\n";
    $table_boarder_format_3 = "\t".("_"x50)."\n";
    $table_header_format_1 = "\t\t\t   CPU TIME\t    WALL TIME\n";
    $table_header_format_2 = "\tLink\tRuns\t  sec\t   %\t   sec\t   %\n";
    $table_line_format_1 = "\t%4d\t%4d\t%5.1f\t%6.2f\t%5.0f\t%6.2f\n";
    $table_line_format_2 = "\t\t\t%5.1f\t%6.2f\t%5.0f\t%6.2f\n";
    if($verbose >= 0 ){
      print "\n";
      printf "$table_boarder_format_1";
      printf "$table_header_format_1";
      printf "$table_header_format_2";
      printf "$table_boarder_format_1";
      for ($i=0;$i<@links_found;$i++){
        $link_percent_cpu_time = 100.*$links_tot_cpu_time[$i]/$job_cpu_time;
        $link_percent_wall_time = 100.*$links_tot_wall_time[$i]/$job_wall_time;
        printf "$table_line_format_1",$links_found[$i],$links_num_entries[$i],
          $links_tot_cpu_time[$i],$link_percent_cpu_time,
          $links_tot_wall_time[$i],$link_percent_wall_time;
        if($verbose){
          @temp_array_cpu = split /;/,$links_cpu_time_verbose[$i];
          @temp_array_wall = split /;/,$links_wall_time_verbose[$i];
          for ($j=0;$j<@temp_array_cpu;$j++){
            $link_percent_cpu_temp = 100.*$temp_array_cpu[$j]/$job_cpu_time;
            $link_percent_wall_temp = 100.*$temp_array_wall[$j]/$job_wall_time;
            printf "$table_line_format_2",$temp_array_cpu[$j],$link_percent_cpu_temp,
              $temp_array_wall[$j],$link_percent_wall_temp;
          }
          if($i<(@links_found-1)){printf "$table_boarder_format_2"}
        }
      }
      printf "$table_boarder_format_1";
      print "\n";
    }
#
    printf "$table_boarder_format_3";
    printf "\t\t\tTOTAL JOB CPU TIME\n";
    printf "$table_boarder_format_3";
    printf "\t\t\tSECONDS = %12.1f\n",$job_cpu_time;
    if($verbose >= 0){
      printf "\t\t\tMINUTES = %12.1f\n",$job_cpu_time/60;
      printf "\t\t\t  HOURS = %12.1f\n",$job_cpu_time/3600;
      printf "\t\t\t   DAYS = %12.1f\n\n",$job_cpu_time/86400;
    }
#
    printf "$table_boarder_format_3";
    printf "\t\t\tTOTAL JOB WALL TIME\n";
    printf "$table_boarder_format_3";
    printf "\t\t\tSECONDS = %12.1f\n",$job_wall_time;
    if($verbose >= 0){
      printf "\t\t\tMINUTES = %12.1f\n",$job_wall_time/60;
      printf "\t\t\t  HOURS = %12.1f\n",$job_wall_time/3600;
      printf "\t\t\t   DAYS = %12.1f\n\n",$job_wall_time/86400;
    }

##########################################################################
#                                                                        #
#                              SUBROUTINES                               #
#                                                                        #
##########################################################################

    sub get_glink_times_sub{
#
#   This routine is used to get cpu and wall-clock times in each link of a
#   Gaussian job.
#
#   The INPUT to this subroutine is the name of the Gaussian output file,
#   which must have been run using the #p option.
#
#   On OUTPUT, this routine gives a series of strings that are joined
#   strings and unwound hashes.  The elements of each array/hash are
#   delimited by ",".  Joined arrays end with the name "_list" and unwound
#   hashes end with the name "_hash".  The returned strings are:
#       $links_found_list
#       $link_cpu_times_hash
#
      use Time::Local;
      use strict;
      if(@_ != 1){
        die "\nWrong number of parameters sent to Routine get_glink_times_sub.\n\n";
      }
      my($gfile_name) = @_;
      chomp($gfile_name);
      my($i,$temp,$temp1,@temp_array,$link_num,$link_cpu,@links_found_tmp,
        @links_found,%link_cpu_times,$links,$month,$month_num,$day,$hour,
        $min,$sec,$year,$current_epoch,$link_wall,%link_wall_times,
        @temp_cpu_array,@temp_wall_array,$num_entries,@links_num_entries,
        $tot_cpu_time,$tot_wall_time,$cpu_time_verbose,$wall_time_verbose,
        @links_tot_cpu_time,@links_cpu_time_verbose,@links_tot_wall_time,
        @links_wall_time_verbose,$cume_cpu_time,$cume_wall_time);
      my($links_found_list,$link_cpu_times_hash,$link_wall_times_hash,
        $links_tot_cpu_time_list,$links_cpu_time_verbose_list,
        $links_tot_wall_time_list,$links_wall_time_verbose_list,
        $links_num_entries_list,$cume_data);
#
#   Open the log file and read through it to build the hash table of cpu
#   times, link by link.  After we read through the file, we build an array
#   that has the links found sorted by their numbers.
#
      open GFILE,"< $gfile_name";
      while(<GFILE>){
        chomp;
        if(/^\s*Leave Link\s+(\d+)\s+at\s+\S+\s+(\S+)\s+(\d+)\s(\d+):(\d+):(\d+)\s+(\d+),.+cpu:\s*(\S+)\s+elap:\s*\d+\.\d+\s*$/){
          $link_num = $1;
          $month = $2;
          $day = $3;
          $hour = $4;
          $min = $5;
          $sec = $6;
          $year = $7;
          $link_cpu = $8;
          $month_num = &gauss_month_sub($month);
          if($current_epoch){
            $temp = $current_epoch;
            $current_epoch = timelocal($sec,$min,$hour,$day,$month_num,$year);
            $link_wall = $current_epoch-$temp;
          }else{
            $current_epoch = timelocal($sec,$min,$hour,$day,$month_num,$year);
            $link_wall = 0;
          }
          if($link_cpu_times{$link_num}){
            $link_cpu_times{$link_num} .= ";$link_cpu";
            $link_wall_times{$link_num} .= ";$link_wall";
          }else{
            $link_cpu_times{$link_num} = "$link_cpu";
            $link_wall_times{$link_num} = "$link_wall";
            $links_found_tmp[$link_num] += 1;
          }
          $cume_cpu_time += $link_cpu;
          $cume_wall_time += $link_wall;
          if($cume_data){
            $cume_data = "$cume_data"."\n$link_num,$link_cpu,$link_wall,$cume_cpu_time,$cume_wall_time";
          }else{
            $cume_data = "$link_num,$link_cpu,$link_wall,$cume_cpu_time,$cume_wall_time";
          }
        }
      }
      close GFILE;
      for ($i=0;$i<@links_found_tmp;$i++){
        if($links_found_tmp[$i]){push(@links_found,$i)}
      }
#
#     Set-up the arrays that are useful for actually printing a summary of
#     the link-by-link timing data collected above.
#
      foreach $temp (@links_found){
        @temp_cpu_array = split /;/,$link_cpu_times{$temp};
        @temp_wall_array = split /;/,$link_wall_times{$temp};
        $num_entries = @temp_cpu_array;
        push(@links_num_entries,$num_entries);
        $tot_cpu_time = 0;
        $tot_wall_time = 0;
        $cpu_time_verbose = "";
        foreach $temp1 (@temp_cpu_array){
          $tot_cpu_time += $temp1;
          if($cpu_time_verbose){
            $cpu_time_verbose .= ";"."$temp1";
          }else{
            $cpu_time_verbose .= "$temp1";
          }
        }
        $wall_time_verbose = "";
        foreach $temp1 (@temp_wall_array){
          $tot_wall_time += $temp1;
          if($wall_time_verbose){
            $wall_time_verbose .= ";"."$temp1";
          }else{
            $wall_time_verbose .= "$temp1";
          }
        }
        push(@links_tot_cpu_time,$tot_cpu_time);
        push(@links_cpu_time_verbose,$cpu_time_verbose);
        push(@links_tot_wall_time,$tot_wall_time);
        push(@links_wall_time_verbose,$wall_time_verbose);
      }
#
#     Prepare the set of output strings for return to the calling program.
#
      $links_found_list = join ",",@links_found;
      @temp_array = %link_cpu_times;
      $link_cpu_times_hash = join ",",@temp_array;
      @temp_array = %link_wall_times;
      $link_wall_times_hash = join ",",@temp_array;
      $links_tot_cpu_time_list = join ",",@links_tot_cpu_time;
      $links_cpu_time_verbose_list = join ",",@links_cpu_time_verbose;
      $links_tot_wall_time_list = join ",",@links_tot_wall_time;
      $links_wall_time_verbose_list = join ",",@links_wall_time_verbose;
      $links_num_entries_list = join ",",@links_num_entries;
#
#     Return.
#
      return ($links_found_list,$link_cpu_times_hash,$link_wall_times_hash,
        $links_tot_cpu_time_list,$links_cpu_time_verbose_list,
        $links_tot_wall_time_list,$links_wall_time_verbose_list,
        $links_num_entries_list,$cume_data);
    }


    sub gauss_month_sub{
#
#   This routine is used to convert a month label used in date stamps by
#   GAUSSIAN in its output files to a number acceptable for using the
#   routine timelocal.
#
      use strict;
      if(@_ != 1){
        die "\nWrong number of parameters sent to Routine gauss_month_sub.\n\n";
      }
      my($in_month) = @_;
      chomp($in_month);
      my($out_month);
      if($in_month eq "Jan"){
        $out_month = 0;
      }elsif($in_month eq "Feb"){
        $out_month = 1;
      }elsif($in_month eq "Mar"){
        $out_month = 2;
      }elsif($in_month eq "Apr"){
        $out_month = 3;
      }elsif($in_month eq "May"){
        $out_month = 4;
      }elsif($in_month eq "Jun"){
        $out_month = 5;
      }elsif($in_month eq "Jul"){
        $out_month = 6;
      }elsif($in_month eq "Aug"){
        $out_month = 7;
      }elsif($in_month eq "Sep"){
        $out_month = 8;
      }elsif($in_month eq "Oct"){
        $out_month = 9;
      }elsif($in_month eq "Nov"){
        $out_month = 10;
      }elsif($in_month eq "Dec"){
        $out_month = 11;
      }else{
        die "\n\nInvalid in_month - $in_month - to gauss_month_sub.\n\n";
      }
      return ($out_month);
    }
