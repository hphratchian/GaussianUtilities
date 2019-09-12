#
#   Perl Module to collect and manipulate data from Gaussian log files.
#
#   Functions provided by this module include:
#       get_gauss_log_data
#       gauss_archive_format_1
#       gauss_archive_section0
#       gauss_archive_input_file_data
#       gauss_archive_results_section_data
#       gauss_archive_get_dipole
#       gauss_archive_get_force
#       gauss_molspec2chargemultip
#       gauss_molspec2cart
#       gauss_molspec2atomicsymbols
#       gauss_distance_cart
#       gauss_angle_cart
#       gauss_archive_num_op_sections
#       gauss_input_file_check
#
#
#   For information regarding use and purpose of these functions, see the
#   comments at the start of each routine.
#
#
#
#   Most Recent Modification Date: 7/14/2008
#                   Hrant P. Hratchian,
#                   Dept. of Chemistry, Indiana University
#                   hhratchi@indiana.edu
#
#
    package GaussLib;
    require Exporter;
    @ISA = qw(Exporter);
    @EXPORT = qw(&get_gauss_log_data &gauss_archive_format_1 
      &gauss_archive_section0 &gauss_archive_input_file_data
      &gauss_archive_results_section_data &gauss_archive_get_dipole 
      &gauss_archive_get_force &gauss_molspec2chargemultip
      &gauss_molspec2cart &gauss_molspec2atomicsymbols
      &gauss_distance_cart &gauss_angle_cart &gauss_archive_num_op_sections
      &gauss_input_file_check);
    use strict;
    use Math::Trig;
#
    sub get_gauss_log_data{
#
#   This routine is used to retrieve data from a Gaussian log file.  The
#   only input argument is the name of the Gaussian log file, including its
#   extension.
#
#   On return, this routine gives the following data (in the order shown):
#       $normal_term    This is an integer flag that indicates the
#                       termination status of the Gaussian job.  This flag
#                       is set to 0 if normal termination is detected, 1 if
#                       the job failed, and 2 if the job terminated
#                       normally but no archive entry was found.
#       $Maximum_Force  This is the last max. force given in the Gaussian
#                       log file.
#       $RMS_Force      This is the last rms force given in the Gaussian
#                       log file.
#       $Maximum_Displacement
#                       This is the last max. displacement given in the
#                       Gaussian log file.
#       $RMS_Displacement
#                       This is the last rms displacement given in the
#                       Gaussian log file.
#       $oniom_energy   This is the last ONIOM energy given in the Gaussian
#                       log file.
#       $zpe_correction_logfile
#                       This is the last ZPE correction from the Gaussian
#                       log file.
#       $thermal_correction_enthalpy
#                       This is the last thermal correction to the enthalpy
#                       given in the Gaussian log file.
#       $thermal_correction_gibbs
#                       This is the last thermal correction to the Gibbs
#                       free energy given in the Gaussian log file.
#       $temperature    This is the last temperature given for
#                       thermochemical analysis in the Gaussian log file.
#       $pressure       This is the last pressure given for thermochemical
#                       analysis in the Gaussian log file.
#       @archives       This is an array of archive entries from the
#                       Gaussian log file.  The archive list is given from
#                       last to first.  So, if only the last archive is
#                       wanted, use $archives[0].  Each archive entry is
#                       stored in @archives as on long line.
#
#   
      use strict;
      if(@_ != 1){
        die "\nWrong number of parameters sent to Routine get_gauss_log_data_sub.\n\n";
      }
      my($log_file) = @_;
      chomp($log_file);
      my($in_archive,$line,$num_archives,$last_line,$normal_term,
        $Maximum_Force,$RMS_Force,$Maximum_Displacement,$RMS_Displacement,
        $oniom_energy,$zpe_correction_logfile,$thermal_correction_enthalpy,
        $thermal_correction_gibbs,$temperature,$pressure,$current_archive,
        @archives);
#
#     Open the log file.
#
      open LOGFILE,"$log_file";
#
#     Find the archive entry in the log file.  The variable $in_archive is
#     used to keep track of where we are in the file.  When $in_archive =
#     0, we are in a completely irrelevant section in the file.  When
#     $in_archive = 1, we have detected the start of the section where the
#     archive should be.  When $in_archive = 2, we are in the archive and
#     these lines are stored.  When $in_archive = 3, we have found a blank
#     line after an archive.
#
      $in_archive = 0;
      while(<LOGFILE>){
        if(/^\s*Maximum\s*Force\s*(\d*\.\d*)\s*(\d*\.\d*)\s*(YES||NO)/){
          $Maximum_Force = $1;
        }elsif(/^\s*RMS\s*Force\s*(\d*\.\d*)\s*(\d*\.\d*)\s*(YES||NO)/){
          $RMS_Force = $1;
        }elsif(/^\s*Maximum\s*Displacement\s*(\d*\.\d*)\s*(\d*\.\d*)\s*(YES||NO)/){
          $Maximum_Displacement = $1;
        }elsif(/^\s*RMS\s*Displacement\s*(\d*\.\d*)\s*(\d*\.\d*)\s*(YES||NO)/){
          $RMS_Displacement = $1;
        }elsif(/^\s*ONIOM: extrapolated energy =\s*(-?\d*\.\d*)/){
          $oniom_energy = $1;
        }elsif(/^\s*Zero-point correction=\s*(-?\d*\.\d*)\s*\(Hartree\/Particle\)/){
          $zpe_correction_logfile = $1;
        }elsif(/^\s*Thermal correction to Enthalpy=\s*(-?\d*\.\d*)/){
          $thermal_correction_enthalpy = $1;
        }elsif(/^\s*Thermal correction to Gibbs Free Energy=\s*(-?\d*\.\d*)/){
          $thermal_correction_gibbs = $1;
        }elsif(/^\s*Temperature\s*(\d*\.\d*)\s*Kelvin\.  Pressure\s*(\d*\.\d*)\s*Atm\./){
          $temperature = $1;
          $pressure = $2;
        }
        if(/Test job not archived\./ || /for archive entry\./){
          $in_archive = 1;
          $current_archive = "";
        }
        if($in_archive!=1 && /^\s*1\/\d+\//){
          $in_archive = 1;
          $current_archive = "";
        }
        if($in_archive==1 && /.*\\/){
          $in_archive = 2;
        }
        if($in_archive==2 && (/^\s*$/ || /The archive entry for this job was punched\./)){
          $in_archive = 3;
          $num_archives += 1;
          unshift(@archives,$current_archive);
        }
        if($in_archive==2){
          chomp($line = $_);
          $line =~ s/^ //;
          $current_archive .= $line;
        }
        if(/\S/){
          $last_line = $_;
        }
      }
#
#     Use $last_line to see if we the Gaussian job terminated without
#     error.  Then, properly set $normal_term.  This flag is set to 0 if
#     normal termination is detected, 1 if the job failed, and 2 if the job
#     terminated normally but no archive entry was found.
#
      if(!($last_line =~ /Normal termination of Gaussian/)){
        $normal_term = 1;
      }elsif($num_archives < 1){
        $normal_term = 2;
      }else{
        $normal_term = 0;
      }
#
#     Close the log file.
#
      close LOGFILE;
#
#     Return.
#
      return ($normal_term,$Maximum_Force,$RMS_Force,$Maximum_Displacement,
        $RMS_Displacement,$oniom_energy,$zpe_correction_logfile,
        $thermal_correction_enthalpy,$thermal_correction_gibbs,$temperature,
        $pressure,@archives);
    }


    sub gauss_archive_format_1{
#
#   This routine is used to reformat a Gaussian archive entry stored as one
#   long character string.  This single long character variable form is
#   sent as the ONLY input variable.  The output from this routine is a
#   single character string where all "\" characters are replaced by
#   new-line tags.  The final "@" in the archive is removed.  The returned
#   archive will have NO trailing new-line tags.
#
#
      use strict;
      my($output);
#
#     Do the work...
#
      if(@_ > 1){
        die "\n\nMore than one argument sent to Routine gauss_archive_format_1!\n\n";
      }
      ($output) = @_;
      $output =~ s/\\*@\n*$//;
      $output =~ s/\\/\n/g;
#
#     Return to the calling program.
#
      return ($output);
    }


    sub gauss_archive_section0{
#
#   This routine is used to parse section 0 data from a Gaussian archive
#   entry.  The only input data is the archive, which should be sent as a
#   single character variable, just as Routine get_gauss_log_data returns
#   the archive.  The only exception to that format is that only one
#   archive should be sent at a time to this routine.
#
#   As output, this routine returns the following information from the
#   archive sent:
#       sequence number;
#       site;
#       job type;
#       procedure;
#       basis set;
#       stoichiometry;
#       person;
#       date;
#       optional sections flag;
#
#
      use strict;
      my($archive_in);
      my(@archive_sections,$dummy,$seq,$site,$job_type,$procedure,
        $basis_set,$stoich,$person,$date,$op_sections);
#
#     Load $archive_in.
#
      if(@_ != 1){die "\n\nWrong number of arguments sent to Routine gauss_archive_section0!\n\n"};
      ($archive_in) = @_;
      chomp($archive_in);
#
#     Start by breaking up the archive into sections.  Then, parse section
#     0 into the necessary pieces.
#
      @archive_sections = split /\\\\/, $archive_in;
      ($dummy,$seq,$site,$job_type,$procedure,$basis_set,$stoich,$person,
        $date,$op_sections) = split /\\/, $archive_sections[0];
#
#     Return to the calling program.
#
      return ($seq,$site,$job_type,$procedure,$basis_set,$stoich,$person,
        $date,$op_sections);
    }


    sub gauss_archive_input_file_data{
#
#   This routine is used to parse the input file sections from a Gaussian archive
#   entry.  The only input data is the archive, which should be sent as a
#   single character variable, just as Routine get_gauss_log_data returns
#   the archive.  The only exception to that format is that only one
#   archive should be sent at a time to this routine.
#
#   As output, this routine returns the following information from the
#   archive sent:
#       route line;
#       title;
#       molecular specification (includes charge and multiplicity);
#       optional input sections (may include z-matrix variable definitions);
#
#   All returned quantities are scalars with new-line characters included
#   where appropriate.
#
#
      use strict;
      my($archive_in);
      my($i);
      my(@archive_sections,@temp,$i,$op_sections,$route,$title,$mol_spec,$op_input);
#
#     Load $archive_in.
#
      if(@_ != 1){die "\n\nWrong number of arguments sent to Routine gauss_archive_input_file_data!\n\n"};
      ($archive_in) = @_;
      chomp($archive_in);
#
#     Start by breaking up the archive into sections.  Then we grab the
#     optional sections flag from section 0 and the data needed from the
#     archive to re-build an input file.
#
      @archive_sections = split /\\\\/, $archive_in;
      @temp = split /\\/, $archive_sections[0];
      $op_sections = @temp[9];
      $route = $archive_sections[1];
      $title = $archive_sections[2];
      $mol_spec = $archive_sections[3];
      $mol_spec =~ s/\\/\n/g;
      for ($i=1;$i<=$op_sections;$i++){
        $op_input .= "\n"."$archive_sections[3+$i]";
      }
      if($op_input){$op_input =~ s/\\/\n/g}
#
#     Return to the calling program.
#
      return ($route,$title,$mol_spec,$op_input);
    }


    sub gauss_archive_results_section_data{
#
#   This routine is used to parse the results section from a Gaussian
#   archive entry.  The only input data is the archive, which should be
#   sent as a single character variable, just as Routine get_gauss_log_data
#   returns the archive.  The only exception to that format is that only
#   one archive should be sent at a time to this routine.
#
#   As output, this routine returns the following information from the
#   archive sent:
#       cisd_energy
#	ccsd_paren_t_energy
#	ccsd_energy
#	mp4sdtq_energy
#	mp4sdq_energy
#	mp4dq_energy
#	mp4d_energy
#	mp3_energy
#	mp2_energy
#	scf_energy
#	zpe_correction
#	thermal_correction_energy
#	point_group
#	ssquared
#
#   All returned quantities are scalars with new-line characters included
#   where appropriate.
#
#
      use strict;
      my($archive_in);
      my($i);
      my(@archive_sections,@temp,$i,$results_section_num,$results_temp,
        @results);
      my($cisd_energy,$ccsd_paren_t_energy,$ccsd_energy,$mp4sdtq_energy,
        $mp4sdq_energy,$mp4dq_energy,$mp4d_energy,$mp3_energy,$mp2_energy,
        $scf_energy,$zpe_correction,$thermal_correction_energy,$point_group,
        $ssquared);
#
#     Load $archive_in.
#
      if(@_ != 1){die "\n\nWrong number of arguments sent to Routine gauss_archive_results_section_data!\n\n"};
      ($archive_in) = @_;
      chomp($archive_in);
#
#     Start by breaking up the archive into sections.  Then we grab the
#     optional sections flag from section 0 and the results section.
#
      @archive_sections = split /\\\\/, $archive_in;
      @temp = split /\\/, $archive_sections[0];
      $results_section_num = gauss_archive_num_op_sections($temp[9]);
      $results_temp = $archive_sections[$results_section_num];
      @results = split /\\/, $results_temp;
      for ($i=0;$i<@results;$i++){
        if($results[$i] =~ /^CISD=(-?\d*.\d*)/){
          $cisd_energy = $1;
        }elsif($results[$i] =~ /^CCSD\(T\)=(-?\d*.\d*)/){
          $ccsd_paren_t_energy = $1;
        }elsif($results[$i] =~ /^CCSD=(-?\d*.\d*)/){
          $ccsd_energy = $1;
        }elsif($results[$i] =~ /^MP4SDTQ=(-?\d*.\d*)/){
          $mp4sdtq_energy = $1;
        }elsif($results[$i] =~ /^MP4SDQ=(-?\d*.\d*)/){
          $mp4sdq_energy = $1;
        }elsif($results[$i] =~ /^MP4DQ=(-?\d*.\d*)/){
          $mp4dq_energy = $1;
        }elsif($results[$i] =~ /^MP4D=(-?\d*.\d*)/){
          $mp4d_energy = $1;
        }elsif($results[$i] =~ /^MP3=(-?\d*.\d*)/){
          $mp3_energy = $1;
        }elsif($results[$i] =~ /^MP2=(-?\d*.\d*)/){
          $mp2_energy = $1;
        }elsif($results[$i] =~ /^HF=(-?\d*.\d*)/){
          $scf_energy = $1;
        }elsif($results[$i] =~ /^ZeroPoint=(-?\d*.\d*)/){
          $zpe_correction = $1;
        }elsif($results[$i] =~ /^Thermal=(-?\d*.\d*)/){
          $thermal_correction_energy = $1;
        }elsif($results[$i] =~ /^PG=(\S+)\s+(\S+)\s*$/){
          $point_group = $1;
#hph          $framework_group = $2;
        }elsif($results[$i] =~ /^S2=(\d*.\d*)$/){
          $ssquared = $1;
        }
      }
#
#     Return to the calling program.
#
      return ($cisd_energy,$ccsd_paren_t_energy,$ccsd_energy,$mp4sdtq_energy,
        $mp4sdq_energy,$mp4dq_energy,$mp4d_energy,$mp3_energy,$mp2_energy,
        $scf_energy,$zpe_correction,$thermal_correction_energy,
        $point_group,$ssquared);
    }


    sub gauss_archive_get_dipole{
#
#   This routine is used to get the dipole vector from a Gaussian archive.
#   The Gaussian archive is the only input sent to this routine.  The sent
#   archive should be sent in a variable that comes in the form provided by
#   routine gauss_archive_format_1.  The output from this routine is an
#   array that contains the x, y, and z components of the dipole moment.
#
#
      use strict;
      my($temp,@temp_array,$found);
      my(@dipole);
#
#     Do the work...
#
      if(@_ > 1){
        die "\n\nMore than one argument sent to Routine gauss_archive_get_dipole!\n\n";
      }
      ($temp) = @_;
      @temp_array = split /\n/, $temp;
      $found = 0;
      foreach(@temp_array){
        if(/^Dipole=(-?\d+\.\d*),(-?\d+\.\d*),(-?\d+\.\d*)\s*$/){
          $found += 1;
          @dipole[0] = $1;
          @dipole[1] = $2;
          @dipole[2] = $3;
        }
      }
      if($found != 1){die "\n\n$found dipoles have been found in the archive!\n\n"};
#
#     Return to the calling program.
#
      return (@dipole);
    }


    sub gauss_archive_get_force{
#
#   This routine is used to get the force vector from a Gaussian archive.
#   The Gaussian archive is the only input sent to this routine.  The sent
#   archive should be sent in a variable that comes in the form provided by
#   routine gauss_archive_format_1.  The output from this routine is an
#   array that contains the forces (in Cartesian coordinates).
#
#
      use strict;
      my($archive_in,@archive_sections,$force_section);
      my($force);
#
#     Do the work.  We assume that the force is always going to be the last
#     section of the archive.
#
      if(@_ > 1){
        die "\n\nMore than one argument sent to Routine gauss_archive_get_force!\n\n";
      }
      ($archive_in) = @_;
      @archive_sections = split /\n\n/, $archive_in;
      $force_section = @archive_sections-1;
      $force = $archive_sections[$force_section];
#
#     Return to the calling program.
#
      return ($force);
    }


    sub gauss_molspec2chargemultip{
#
#   This routine is used to take a Gaussian style molecular specification
#   deck (provided as one character scalar variable) and returns the charge
#   and multiplicity. The molecular specification deck sent to this routine
#   should include the charge and multiplicity on the first line. The next
#   deck from the archive/input should also be sent. If the molecular
#   specification is sent in z-matrix form then this second deck is used,
#   otherwise it ignored. The format should be the same as is used in
#   Gaussian.
#
#
      use strict;
      my($mol_spec,@temp);
      my($chargeMultip);
      my($charge,$multiplicity);
#
#     Load $mol_spec. After this block of code, the charge/multiplicity
#     line is removed.
#
      if(@_ != 1){die "\n\nWrong number of arguments send to Routine gauss_molspec2chargemultip!\n\n"}
      ($mol_spec) = @_;
      @temp = split /\n/, $mol_spec;
      $chargeMultip = $temp[0];
      ($charge,$multiplicity) = split /,/, $chargeMultip;
#
#     Return to the calling program.
#
      return ($charge,$multiplicity);
    }


    sub gauss_molspec2cart{
#
#   This routine is used to take a Gaussian style molecular specification
#   deck (provided as one character scalar variable) and returns an array
#   of Cartesian coordinates.  The molecular specification deck sent to
#   this routine should include the charge and multiplicity on the first
#   line. The next deck from the archive/input should also be sent.  If the
#   molecular specification is sent in z-matrix form then this second deck
#   is used, otherwise it ignored.  The format should be the same as is
#   used in Gaussian.
#
#
      use strict;
      my($mol_spec,$extra_deck,@temp);
      my($zmat_flag,$xyztemp);
      my(@cart);
#
#     Load $mol_spec.  After this block of code, the charge/multiplicity
#     line is removed.
#
      if(@_ != 2){die "\n\nWrong number of arguments send to Routine gauss_molspec2cart!\n\n"}
      ($mol_spec,$extra_deck) = @_;
      $mol_spec =~ s/^.*\n//;
      $mol_spec =~ s/\n*$//;
#
#     Load @cart.
#
      @temp = split /\n/, $mol_spec;
      if($temp[0] =~ /^.*[ ,](-?\d+\.\d*).*[ ,](-?\d+\.\d*).*[ ,](-?\d+\.\d*).*$/){
        $zmat_flag = 0;
      }else{
        $zmat_flag = 1;
      }
      if($zmat_flag){
        open ZMATFILE, "> junk123qaz.zmat";
        print ZMATFILE "# test\n\ntest\n\n0 1\n$mol_spec\n$extra_deck\n\n";
        close ZMATFILE;
        system "newzmat -izmat junk123qaz.zmat -oxyz";
        $xyztemp = `cat junk123qaz.xyz`;
        unlink "junk123qaz.zmat";
        unlink "junk123qaz.xyz";
        chomp($xyztemp);
        @temp = split /\n/, $xyztemp;
        foreach(@temp){
          if(/^.* (-?\d+\.\d*).* (-?\d+\.\d*).* (-?\d+\.\d*).*$/){
            push(@cart,($1,$2,$3));
          }else{
            die "Unable to find coordinates in Routine gauss_molspec2cart!\n\n";
          }
        }
      }else{
        foreach(@temp){
          if(/^.*[ ,](-?\d+\.\d*).*[ ,](-?\d+\.\d*).*[ ,](-?\d+\.\d*).*$/){
            push(@cart,($1,$2,$3));
          }else{
            die "Unable to find Cartesian coordinates in Routine gauss_molspec2cart!\n\n";
          }
        }
      }
#
#     Return to the calling program.
#
      return (@cart);
    }


    sub gauss_molspec2atomicsymbols{
#
#   This routine is used to take a Gaussian style molecular specification
#   deck (provided as one character scalar variable) and returns an array
#   of atomic symbols (or atomic numbers depending on the input). The
#   molecular specification deck sent to this routine should include the
#   charge and multiplicity on the first line. The next deck from the
#   archive/input should also be sent.
#
#
      use strict;
      my($mol_spec,$temp,@temp1,@temp2);
      my(@atomic_symbols);
#
#     Load $mol_spec.  After this block of code, the charge/multiplicity
#     line is removed.
#
      if(@_ != 1){die "\n\nWrong number of arguments send to Routine gauss_molspec2atomicsymbols!\n\n"}
      ($mol_spec) = @_;
      $mol_spec =~ s/^.*\n//;
      $mol_spec =~ s/\n*$//;
#
#     Load @atomic_symbols.
#
      $mol_spec =~ s/^\s+//g;
      $mol_spec =~ s/\s+$//g;
      @temp1 = split /\n/, $mol_spec;
      foreach $temp (@temp1){
        $temp =~ s/\s(\S)/,$1/g;
        @temp2 = split /,/, $temp;
        push(@atomic_symbols,$temp2[0]);
      }
#
#     Return to the calling program.
#
      return (@atomic_symbols);
    }


    sub gauss_distance_cart{
#
#   This routine is used to compute the distance between two atoms.  As
#   input, this routine takes the numbers of the two atomic centers and an
#   array of the Cartesian coordinates.  The Cartesian coordinates should
#   be given in the form returned by Routine gauss_molspec2cart.
#
#   The output of this routine is the distance.
#
#
      use strict;
      my($atom1,$atom2,@cart,@temp);
      my($distance);
#
#     Load things.
#
      ($atom1,$atom2,@cart) = @_;
#
#     Do the work.
#
      $temp[0] = $cart[3*$atom1-3]-$cart[3*$atom2-3];
      $temp[1] = $cart[3*$atom1-3+1]-$cart[3*$atom2-3+1];
      $temp[2] = $cart[3*$atom1-3+2]-$cart[3*$atom2-3+2];
      $distance = sqrt($temp[0]*$temp[0]+$temp[1]*$temp[1]+
        $temp[2]*$temp[2]);
#
#     Return to the calling program.
#
      return ($distance);
    }


    sub gauss_angle_cart{
#
#   This routine is used to compute the angle between three atoms.  As
#   input, this routine takes the numbers of the three atomic centers and
#   an array of the Cartesian coordinates.  The Cartesian coordinates
#   should be given in the form returned by Routine gauss_molspec2cart.
#
#   The output of this routine is the angle in degrees.
#
#
      use strict;
      my($atom1,$atom2,$atom3,@cart,@temp1,@temp2);
      my($distance1,$distance2,$cos_theta);
      my($theta);
#
#     Load things.
#
      ($atom1,$atom2,$atom3,@cart) = @_;
#
#     Do the work.
#
      $temp1[0] = $cart[3*$atom1-3]-$cart[3*$atom2-3];
      $temp1[1] = $cart[3*$atom1-3+1]-$cart[3*$atom2-3+1];
      $temp1[2] = $cart[3*$atom1-3+2]-$cart[3*$atom2-3+2];
      $temp2[0] = $cart[3*$atom3-3]-$cart[3*$atom2-3];
      $temp2[1] = $cart[3*$atom3-3+1]-$cart[3*$atom2-3+1];
      $temp2[2] = $cart[3*$atom3-3+2]-$cart[3*$atom2-3+2];
      $distance1 = sqrt($temp1[0]*$temp1[0]+$temp1[1]*$temp1[1]+
        $temp1[2]*$temp1[2]);
      $distance2 = sqrt($temp2[0]*$temp2[0]+$temp2[1]*$temp2[1]+
        $temp2[2]*$temp2[2]);
      $cos_theta = ($temp1[0]*$temp2[0]+$temp1[1]*$temp2[1]+
        $temp1[2]*$temp2[2])/($distance1*$distance2);
      $theta = acos($cos_theta);
      $theta = $theta*180/pi;
#
#     Return to the calling program.
#
      return ($theta);
    }


    sub gauss_archive_num_op_sections{
#
#   This routine is used to figure out the last section in the archive that
#   has input file info.  This is determined by the "optional section flag"
#   in Section 0.
#
#   The only input to this routine is the optional section flag value.
#
#   The only output from this routine is the last section in the archive
#   that will hold input file info.
#
#
      use strict;
      my($op_flag,$last_input_section);
      ($op_flag) = @_;
#
#     Do the work.
#
      if($op_flag==0){
        $last_input_section = 0;
      }elsif($op_flag==1){
        $last_input_section = 1;
      }elsif($op_flag==2){
        $last_input_section = 1;
      }elsif($op_flag==3){
        $last_input_section = 2;
      }elsif($op_flag==4){
        $last_input_section = 2;
      }elsif($op_flag==5){
        $last_input_section = 3;
      }else{
        die "\n\nInvalid option sections flag (=$op_flag)\n\n";
      }
      $last_input_section += 4;
      return ($last_input_section);
    }


    sub gauss_input_file_check{
#
#   This routine is used to read through a Gaussian input file and returns
#   a number of job parameters.
#
#   As INPUT, this routine takes the name of the Gaussian input file.
#
#   As OUTPUT, this routine returns (in this order):
#       1.  Requested memory amount;
#       2.  Requested memory units;
#       3.  Number of requested Linda workers;
#       4.  Number of requested shared procs;
#       5.  Name of the checkpoint file (the value returned by this
#           function always includes the extension ".chk");
#       6.  Name of the read-write file; and (the value returned by this
#           function always includes the extension ".rwf");
#       7.  List of at-files.
#
#   Note that the number of requested Linda workers is taken as the value
#   assigned in the Gaussian input file using "%nproclinda".  The
#   "%lindaworkers" is unknown to this routine.
#
      use strict;
      if(@_ != 1){
        die "\nWrong number of parameters sent to Routine gauss_input_file_check.\n\n";
      }
      my($infile) = @_;
      my($memsize,$memtype,$numlinda,$numproc,$chkfile,$rwffile,@AtFiles);
      my($temp,@chkfile_list);
#
#     Set defaults.
#
      $memsize = 128;
      $memtype = "MB";
      $numlinda = 0;
      $numproc = 1;
#
#     Open and read through the Gaussian input file to determine what job
#     requirements are specified.
#
      open (INFILE, "$infile");
      while (<INFILE>) {
        chomp;
        if (/^\s*\%mem\s*\=\s*(\d+)([a-zA-Z]*)\s*$/i){
          $memsize = $1;
          $memtype = $2;
          unless ($memtype =~ m/KB|KW|MB|MW|GB|GW/i) {
            $memtype="MW";
          }
        }
        if (/^\s*\%nproclinda\s*\=\s*(\d+)\s*$/i){
          $numlinda = $1;
          unless ($numlinda =~ m/\s*(\d*)\s*/) {
            die "Number of linda workers must be numeric!\n"}
        }
        if (/^\s*\%(nproc||nprocshared)\s*\=\s*(\d+)\s*$/i){
          $numproc = $2;
          unless ($numproc =~ m/\s*(\d*)\s*/) {
            die "Number of processors must be numeric!\n";  
          } 
        }
        if (/^\s*\%chk\s*\=\s*(\S*.chk)\s*$/i){
          push(@chkfile_list,$1);
        }elsif (/^\s*\%chk\s*\=\s*(\S*)\s*$/i){
          push(@chkfile_list,"$1.chk");
        }
        if (/^\s*\%oldchk\s*\=\s*(\S*.chk)\s*$/i){
          push(@chkfile_list,$1);
        }elsif (/^\s*\%oldchk\s*\=\s*(\S*)\s*$/i){
          push(@chkfile_list,"$1.chk");
        }
        if (/^\s*\%rwf\s*\=\s*(\S*.rwf)\s*$/i){
          $rwffile = $1;
        }elsif (/^\s*\%rwf\s*\=\s*(\S*)\s*$/i){
          $rwffile = "$1.rwf";
        }
        if (/^\s*\@(.*)\s*$/){
          $temp = $1;
          $temp =~ s/\/N\s*$//;
          push(@AtFiles,$temp);
          print "Found \@-file: $temp\n";
        }
      }
      close (INFILE);
#
#     Form ',' delimited lists from temparary lists formed above.
#
      $chkfile = join ",",@chkfile_list;
#
#     Return to the calling program.
#
      return ($memsize,$memtype,$numlinda,$numproc,$chkfile,$rwffile,@AtFiles);
    }


1;
