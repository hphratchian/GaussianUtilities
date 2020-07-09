#!/usr/bin/perl
#
#   This script is used to move all *.gjf files in the working directory to
#   *.com.
#
#   Hrant P. Hratchian
#   Gaussian, Inc.
#   Wallingford, CT 06492
#   hrant@gaussian.com
#
#
    @gjf_files=glob"*.gjf";
    foreach(@gjf_files){
      chomp;
      $com_file = $_;
      $com_file =~ s/\.gjf/\.com/;
      print "Moving $_ to $com_file.\n";
      `mv $_ $com_file`;
    }
