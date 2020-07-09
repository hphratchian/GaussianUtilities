#!/usr/bin/perl
#
#   This script is used to move all *.com files in the working directory to
#   *.gjf.
#
#   Hrant P. Hratchian
#   Gaussian, Inc.
#   Wallingford, CT 06492
#   hrant@gaussian.com
#
#
    @com_files=glob"*.com";
    foreach(@com_files){
      chomp;
      $gjf_file = $_;
      $gjf_file =~ s/\.com/\.gjf/;
      print "Moving $_ to $gjf_file.\n";
      `mv $_ $gjf_file`;
    }
