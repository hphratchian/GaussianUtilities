#!/usr/bin/perl
#
#   This Perl script takes one or more GAUSSIAN optimization jobs and
#   extracts the convergence data from each step, including the change in
#   the SCF energy. (NOTE: The script currently grabs only the SCF energy,
#   which may not be the true value of the potential surface. The tables
#   for each step, together with the step number, change in SCF energy from
#   the previous step, and the number of imaginary frequencies if a
#   frequency job step is present are give as output.
#
#   To run this script use...
#       %>./Gauss_Opt_Convergence.pl [filename]
#
#
#   Most Recent Modification Date: 9/20/2006
#                   Hrant P. Hratchian,
#                   Dept. of Chemistry, Indiana University
#                   hhratchi@indiana.edu
#
#   Revision History:
#       2/2/2010    Added capability to handle multiple files given at the
#                   command line in one execution.
#       9/20/2006   Add delta-E column to the data table.  We still need to
#                   add functionality for cases where the model chemistry
#                   is not HF or DFT.  In those cases the delta-E column
#                   will report incorrect data.
#
#
#--------------------------------------------------------------------------
#
#
#   Start by filling @file_list and looking for option switches from the
#   invocation argument.
#
    $precision_flag = 9;
    foreach $temp (@ARGV){
      chomp($temp);
      if($temp =~ /^-(.*)$/){
        if($temp =~ /^-(lowprecision|lowprec|lowp|lp)$/i){
          $precision_flag = 0;
        }elsif($temp =~ /^-(highprecision|highprec|highp|hp)$/i){
          $precision_flag = 9;
        }else{
          die "\n\nUnknown switch found: $temp\n\n";
        }
      }else{
        push(@file_list,$temp);
      }
    }
    $Number_of_files = @file_list;
    print "\nCompiling Opt/Freq report for $Number_of_files files.\n\n";
#
#   Based on the precision flag, set-up the table print formatting.
#
    if($precision_flag==0){
      $table_print_format1 = "%4.0f     %8.4f(%3s)    %8.4f(%3s)    ".
        "%8.4f(%3s)    %8.4f(%3s)\n";
      $table_print_format = "%4.0f     %8.4f(%3s)    %8.4f(%3s)    ".
        "%8.4f(%3s)    %8.4f(%3s)    %10.5f\n";
    }elsif($precision_flag==9){
      $table_print_format1 = "%4.0f     %8.6f(%3s)    %8.6f(%3s)    ".
        "%8.6f(%3s)    %8.6f(%3s)\n";
      $table_print_format = "%4.0f     %8.6f(%3s)    %8.6f(%3s)    ".
        "%8.6f(%3s)    %8.6f(%3s)    %10.8f\n";
    }else{
      die "\n\nInvalid precision flag: $precision_flag\n\n";
    }
#
#   Loop over each file (loaded into $File_Name) and report.
#
    $Dashed_Line = ("-" x 92);
    foreach $File_Name (@file_list){
      chomp($File_Name);
#
#     Open the file ($File_Name) and then search through it for each
#     optimization cycle to grab the convergence tables. The variable
#     $Flag is used to keep track of where we are in the output file. When
#     we are outside of L103 output sections, $Flag is 0. When we enter
#     the L103 output section, $Flag is set to 1. If a frequency job has
#     been detected (such as in an OPT FREQ job), we pick up (and later
#     report) the number of imaginary frequencies.
      open FILE,"$File_Name";
      $Flag = 0;
      $Found_Freq = 0;
      @SCF_Energy = ();
      @Step_Number = ();
      @Max_Force = ();
      @Max_Force_Converged = ();
      @RMS_Force = ();
      @RMS_Force_Converged = ();
      @Max_Displacement = ();
      @Max_Displacement_Converged = ();
      @RMS_Displacement = ();
      @RMS_Displacement_Converged = ();
      $Num_Imag_Freq = 0;
      while(<FILE>){
        if($Flag==0 && /^\s*SCF Done:.*=\s*(-?\d*\.\w*-?\w*)\s.*$/){
          push(@SCF_Energy,$1)
        }elsif($Flag==0 && /^\s*(Grad){18}/){
          $Flag = 1;
        }elsif($Flag==1 && /^\s*Step number\s*(\d*)\s*out of a maximum of/){
          push(@Step_Number,$1);
        }elsif($Flag==1 && /^\s*Maximum Force\s*(\d*\.\d*)\s*(\d*\.\d*)\s*([YESNO]*)/){
          push(@Max_Force,$1);
          push(@Max_Force_Threshold,$2);
          push(@Max_Force_Converged,$3);
        }elsif($Flag==1 && /^\s*RMS     Force\s*(\d*\.\d*)\s*(\d*\.\d*)\s*([YESNO]*)/){
          push(@RMS_Force,$1);
          push(@RMS_Force_Threshold,$2);
          push(@RMS_Force_Converged,$3);
        }elsif($Flag==1 && /^\s*Maximum Displacement\s*(\d*\.\d*)\s*(\d*\.\d*)\s*([YESNO]*)/){
          push(@Max_Displacement,$1);
          push(@Max_Displacement_Threshold,$2);
          push(@Max_Displacement_Converged,$3);
        }elsif($Flag==1 && /^\s*RMS     Displacement\s*(\d*\.\d*)\s*(\d*\.\d*)\s*([YESNO]*)/){
          push(@RMS_Displacement,$1);
          push(@RMS_Displacement_Threshold,$2);
          push(@RMS_Displacement_Converged,$3);
        }elsif($Flag==1 && /^\s*(Grad){18}/){
          $Flag = 0;
        }elsif(/^\s*\**\s*(\d*)\s*imaginary frequencies \(negative Signs\)/){
          $Num_Imag_Freq = $1;
        }elsif($Flag==0 && /^\s*Frequencies --/){
          $Found_Freq = 1;
          if(!$Num_Imag_Freq){
            $Num_Imag_Freq = 0;
          }
        }
      }
#
#     Begin printing results for file $File_Name.
      print "Opt/Freq report for file $File_Name:\n";
#
#     Print optimization convergence data.
      if(@Step_Number > 0){
        $Job_Step = 0;
        print "$Dashed_Line\n";
        print "Step #     Max Force        RMS Force        Max Disp",
          "         RMS Disp        Delta-E (au)\n";
        print "$Dashed_Line\n";
        for($i = 0; $i <= @Step_Number-1; $i++){
          if($i==0 | $Step_Number[$i]==1){
            $Job_Step += 1;
            $Ref_Energy = $SCF_Energy[$i];
            print "$Dashed_Line\n"; 
            printf "   Job Step: %-4d\n",$Job_Step;
            printf "   Max Force Threshold         = %8.6f\n",$Max_Force_Threshold[$i];
            printf "   RMS Force Threshold         = %8.6f\n",$RMS_Force_Threshold[$i];
            printf "   Max Displacement Threshold  = %8.6f\n",$Max_Displacement_Threshold[$i];
            printf "   RMS Displacement Threshold  = %8.6f\n",$RMS_Displacement_Threshold[$i];
            printf "   Initial SCF Energy (au) = %-16.9f\n",$SCF_Energy[$i];
            print "$Dashed_Line\n"; 
            printf "$table_print_format1",$Step_Number[$i],$Max_Force[$i],
              $Max_Force_Converged[$i],$RMS_Force[$i],
              $RMS_Force_Converged[$i],$Max_Displacement[$i],
              $Max_Displacement_Converged[$i],$RMS_Displacement[$i],
              $RMS_Displacement_Converged[$i];
          }else{
            printf "$table_print_format",$Step_Number[$i],$Max_Force[$i],
              $Max_Force_Converged[$i],$RMS_Force[$i],
              $RMS_Force_Converged[$i],$Max_Displacement[$i],
              $Max_Displacement_Converged[$i],$RMS_Displacement[$i],
              $RMS_Displacement_Converged[$i],
              $SCF_Energy[$i]-$SCF_Energy[$i-1];
          }
        }
        print "$Dashed_Line\n";
      }else{
        print "   NO OPT SECTION FOUND!\n";
      }
      print "\n";
      print "   Number of job steps: $Job_Step\n";
      print "   Total number (for all job steps) of optimization cycles: $i\n";
#
#     Print the number of imaginary frequencies found.
      if($Found_Freq){
        if($Num_Imag_Freq == 1){
          print "   $Num_Imag_Freq imaginary frequency.\n\n";
        }else{
          print "   $Num_Imag_Freq imaginary frequencies.\n\n";
        }
      }else{
        print "   No FREQ job detected.\n";
      }
      print "\n\n";
    }
