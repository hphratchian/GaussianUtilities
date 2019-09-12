#!/usr/bin/perl
#
#   This script is used to produce a set of *.arc files from a set of log
#   files.
#
#
#   Most Recent Modification Date: 4/21/2010
#                   Hrant P. Hratchian,
#                   Gaussian, Inc.
#                   Wallingford, CT 06492
#                   hrant@gaussian.com
#
#
    use lib "/mf/hrant/bin/";
    use lib "/home/hrant/bin/";
    use lib "/Users/hhratchian/bin/";
    use lib "/home/hhratchian/bin";
    use GaussLib;
#
#   Get the atom number and names of the files we need to look at.
#
    chomp((@gaussian_files)=@ARGV);
    if(!@gaussian_files){@gaussian_files=glob"*.log"};
#
#   Get the normal termination flags.
#
    foreach $file_name (@gaussian_files){
      chomp($file_name);
      @archives = ();
      ($normal_term,$Maximum_Force,$RMS_Force,$Maximum_Displacement,
        $RMS_Displacement,$oniom_energy,$zpe_correction_logfile,
        $thermal_correction_enthalpy,$thermal_correction_gibbs,$temperature,
        $pressure,@archives) = get_gauss_log_data($file_name);
      $num_archives = @archives;
      print "Found $num_archives archive(s) in file $file_name.\n";
      $ii = @archives;
      for ($i = 0;$i<@archives;$i++){
        $arc_file_name = "$file_name.$ii.arc";
        print "Writing out file $file_name.$ii.arc\n";
        open ARCFILE,"> $arc_file_name";
        print ARCFILE " Enter l9999.exe\n";
        print ARCFILE " Unable to Open any file for archive entry.\n";
        print ARCFILE "$archives[$i]\n\n";
        print ARCFILE " Normal termination of Gaussian";
        close ARCFILE;
        $ii = $ii-1;
      }
    }
