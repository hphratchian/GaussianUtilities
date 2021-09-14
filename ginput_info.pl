#!/usr/bin/perl
#
#   This script is used to get information out of a Gaussian input file (or
#   a list of Gaussian input files).  To execute the script use the
#   command:
#
#       %>./ginput_info.pl [options] file_1 [file_2] ... [file_n]
#   
#   Filenames must include extensions.  Also, globs work.
#
#   No options are required.  The available options include:
#
#       -0      Report the Link0 commands from the input file(s).
#       -r      Report the route line from the input file(s).
#       -t      Report the title line from the input file(s).
#   
#   By default, NO OPTIONS ARE TURNED ON!
#
#
#   Hrant P. Hratchian
#   Department of Chemistry & Chemical Biology
#   University of California, Merced
#   hhratchian@ucmerced.edu
#
#
#
#   Load arrays and variables based on invocation arguments.
#
    foreach $temp (@ARGV){
      chomp($temp);
      if($temp =~ /^-/){
        if($temp =~ /^-0$/){
          $get_link0 = 1;
        }elsif($temp =~ /^-r$/){
          $get_route = 1;
        }elsif($temp =~ /^-t$/){
          $get_title = 1;
        }else{
          die "Unknown option: $temp\n\n";
        }
      }else{
        push(@filelist,$temp);
      }
    }
#
#   Go through the input files and load hashes with information.  The
#   hashes used are:
#
#       %link0      This is the Link0 block.
#       %route      This is the route line.
#       %title      This is the title line.
#
#   To keep track of where we are in the input file, the variable
#   $position_flag is set to various values as we move through the Gaussian
#   input file.  The values of this variable are...
#
#       $position_flag = 0      Before the route line AND Link0 commands
#                               have NOT been found.
#       $position_flag = 1      Before the route line AND Link0 commands
#                               have been found.
#       $position_flag = 2      At the route line.
#       $position_flag = 3      After the route line.
#       $position_flag = 4      At the title line.
#       $position_flag = 5      After the title line.
#
    foreach $temp_file (@filelist){
      $current_infile = `interpolate_input $temp_file`;
      @infile = 0;
      @infile = split /\n/,"$current_infile";
      $position_flag = 0;
      foreach(@infile){
        chomp;
#
#       Set $position_flag.  We save loading the hashes for later, except
#       that if we get to the route line without finding any Link0 commands
#       then we set this file's Link0 hash to "NONE".
#
        if($position_flag==0 && /^\s*%/){
          $position_flag = 1
        }elsif($position_flag==0 && /^\s*#/){
          $position_flag = 2;
          $link0{$temp_file} .= "\t**NONE**\n";
        }elsif($position_flag==1 && /^\s*#/){
          $position_flag = 2;
        }elsif($position_flag==2 && /^\s*$/){
          $position_flag = 3;
        }elsif($position_flag==3 && /\S/){
          $position_flag = 4;
        }elsif($position_flag==4 && /^\s*$/){
          $position_flag = 5;
        }
        if(/^\s*--link1--\s*$/i){
          $position_flag = 0;
          $link0{$temp_file} .= "\n\t--Link1--\n\n";
          $route{$temp_file} .= "\n\t--Link1--\n\n";
          $title{$temp_file} .= "\n\t--Link1--\n\n";
        }
#
#       Now, load the hashes.
        $_ =~ s/(\S?)\s*$/$1/;
        if($position_flag==1){
          $link0{$temp_file} .= "\t$_\n";
        }elsif($position_flag==2){
          $route{$temp_file} .= "\t$_\n";
        }elsif($position_flag==4){
          $title{$temp_file} .= "\t$_\n";
        }
      }
    }
#
#   Now that all of the data from the input files has been read in, print
#   the requested data.
#
    if($get_link0){
      print "\nLINK0 LINES FROM FILES\n\n";
      foreach $temp_file (@filelist){
        chomp($link0{$temp_file});
        print "$temp_file\n$link0{$temp_file}\n\n";
      }
    }
    if($get_route){
      print "\nROUTE LINES FROM FILES\n\n";
      foreach $temp_file (@filelist){
        chomp($route{$temp_file});
        print "$temp_file\n$route{$temp_file}\n\n";
      }
    }
    if($get_title){
      print "\nTITLE LINES FROM FILES\n\n";
      foreach $temp_file (@filelist){
        chomp($title{$temp_file});
        print "$temp_file\n$title{$temp_file}\n\n";
      }
    }
