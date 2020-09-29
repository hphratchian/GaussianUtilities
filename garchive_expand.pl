#!/usr/bin/perl
#
#   This script is used to extract and expand an archive entry in one or
#   more Gaussian output files.  The Gaussian log files to extract archives
#   from are given as command line arguments.
#
#
#   Most Recent Modification Date: 4/10/2007
#                   Hrant P. Hratchian,
#                   Dept. of Chemistry, Indiana University
#                   hhratchi@indiana.edu
#
#
    use lib "/Users/hhratchian/bin/";
    use GaussLib;
#
#   Get the names of the files we need to look at.
#
    chomp(@gaussian_files=@ARGV);
#
#   Get the archive and then re-format and print.
#
    foreach $file (@gaussian_files){
      print "\n-------------------------\nFile: $file\n";
      ($normal_term,$Maximum_Force,$RMS_Force,$Maximum_Displacement,
        $RMS_Displacement,$oniom_energy,$cpe_correction_logfile,
        $thermal_correction_enthalpy,$thermal_correction_gibbs,$temperature,
        $pressure,$archive) = get_gauss_log_data($file);
      if($normal_term){die "\n$file did not terminate normally!\n\n"}
      $archive = gauss_archive_format_1($archive); 
      print "$archive\n-------------------------\n";
    }
