#!/usr/bin/perl
#
#   This Perl script takes a Gaussian output file and extracts the archive
#   entry and other information.  Using USER specified column headings,
#   data is written out as a tab-delimited table.  The Gaussian output file
#   is given by the USER as an invocation argument.  Multiple files may be
#   specified as a list of files at the command line.
#
#   Currently, the "#p" option must be used when jobs are run for this
#   script to locate the archive entries.  This will be fixed in a future
#   version.
#
#   After the discussion that follows, a complete table of options/switches
#   is provided.
#
#   Most of the options below should be self-explanatory, so no detail
#   beyond the comments in the table below is given for most.  However,
#   further information regarding some capabilities is useful.
#
#   1. GENERAL USE
#       General use of this script is simple.  Consider the case where you
#       want the total energies from the jobs in a.log and b.log.  Use the
#       command:
#
#          %>Table_Gauss.pl -energy a.log b.log
#
#       Globs can also be used for the file list.  To get the energies from
#       all log files in the current directory, use:
#
#          %>Table_Gauss.pl -energy *.log
#
#       It is also possible to get multiple data tabulated from the same execution of
#       this script.  As an example, the following command will tabulate
#       the total energy, zero-point energy, and the E+ZPE values for all
#       log files in the current directory.
#
#          %>Table_Gauss.pl -energy -zpe -energy+zpe *.log
#
#
#   2. REACTION TABLE OPTIONS
#       The "-reaction_file" and "-reaction_units" switches are used to set
#       options related to reaction table printing.  Reaction tables are
#       used to generate a table of reaction energies and optionally
#       activation energies.  In order to have a reaction table printed,
#       you must use the -reaction_file switch.  The -reaction_units
#       switch is optional, and in the absence of the -reaction_file switch
#       is essentially ignored.
#
#       It is also important to note that any files given in the reaction
#       table entry definition file must ALSO be given in the command line
#       list of log files.  However, it is NOT necessary to use the -energy
#       switch.
#
#       The file defined by the -reaction_file switch consists of
#       definitions for each reaction that should be included in the
#       reaction table.  Reactants, products, and transition structures are
#       given in order separated by ":".  If activation energies are not
#       needed/available, then the transition structure is omitted from the
#       line.  As an example, consider the case where the reactant,
#       product, and transition structure are given by the files r.log,
#       p.log, and ts.log.  In this case the appropriate line in the
#       reaction table entries file is:
#
#          r.log:p.log:ts.log
#
#       If the activation energy is not needed, or available, then this
#       line is given by:
#
#          r.log:p.log
#
#       It is possible to have multiple reactant, product, or transition
#       structures.  In this case, the files are separated by a ",".  Let
#       the reactant side of the reaction be given by the files r.log and
#       h2o.log, the product side by p.log, and the transition structure by
#       ts.log.  The definition line that should be used is:
#
#          r.log,h2o.log:p.log:ts.log
#
#       If multiple reactions are being considered, each reaction goes on
#       its own line.  For example, consider reaction 1-3:
#
#          r-1.log,h2o.log.log:p-1.log:ts-1.log
#          r-2.log,h2o.log.log:p-2.log:ts-2.log
#          r-3.log,h2o.log.log:p-3.log:ts-3.log
#
#       Globs can also be used, which lets us write the previous example as
#       one line:
#
#          r-*.log,h2o.log.log:p-*.log:ts-*.log
#
#       Presently, only one glob may be used per section (section =
#       reactant, product, ts).  Therefore, the following line is NOT valid
#       and will result in an error:
#
#         r_a-*.log,r_b-*.log:p-*.log
#
#
#
#   3. VALID OPTIONS/SWITCHES
#       Valid column headings, which are assigned as options, include:
#
#   -----------------------------------------------------------------------
#   Option*              Table Heading
#   -----------------------------------------------------------------------
#   -date                Job date
#
#   -job_type            Job Type
#   -jobtype
#   -type
#
#   -model_chemistry     Model Chemistry
#   -model_chem
#   -modelchem
#
#   -hamiltonian         Hamiltonian
#
#   -basis_set           Basis Set
#   -basis
#
#   -stoichiometry       Stoichiometry
#   -formula
#
#   -charge              Charge
#
#   -multiplicity        Spin multiplicity
#   -multip
#
#   -energy(au)          Energy (au)
#   -energy
#   -e
#
#   -energy+zpe          E+ZPE (au)
#   -e+zpe
#   -ezpe
#
#   -energy+thermal      Electronic energy plus thermal correction (au)
#   -e+thermal
#
#   -energy+enthalpy     Electronic energy plus thermal enthalpies (au)
#   -e+enthalpy
#   -enthalpy
#
#   -energy+gibbs        Electronic energy plus thermal Gibbs FE (au)
#   -e+gibbs
#   -gibbs
#   -free_energy
#   -freeenergy
#   
#   -scf_energy          SCF Energy (au)
#   -scfenergy
#   -scf
#
#   -ssquared            <S^2>
#
#   -mp2_energy          MP2 Energy (au)
#   -mp2energy
#   -mp2
#
#   -mp3_energy          MP3 Energy (au)
#   -mp3energy
#   -mp3
#
#   -mp4_sdtq_energy     MP4(SDTQ) E (au)
#   -mp4_sdtqenergy
#   -mp4_sdtq
#   -mp4_energy
#   -mp4energy
#   -mp4
#
#   -mp4_sdq_energy      MP4(SDQ) E (au)
#   -mp4_sdqenergy
#   -mp4_sdq
#
#   -mp4_dq_energy       MP4(DQ) E (au)
#   -mp4_dqenergy
#   -mp4_dq
#
#   -mp4_d_energy        MP4(D) E (au)
#   -mp4_denergy
#   -mp4_d
#
#   -cisd_energy         CISD Energy (au)
#   -cisd
#
#   -ccsd_energy         CCSD Energy (au)
#   -ccsd
#
#   -ccsd_paren_t_energy CCSD(T) E (au)
#   -ccsd_paren_t
#
#   -force               Max Force, RMS Force, Max Disp, RMS Disp (The last
#                        set written in the Gaussian output file.)
#
#   -zpe                 ZPE (au)
#
#   -thermal_correction_energy    Thermal correction to the ENERGY (as
#   -thermal_energy      opposed to the ENTHALPY)
#   -thermalenergy
#   
#   -thermal_correction_enthalpy  Thermal correction to the ENTHALPY (as
#   -thermal_enthaply    opposed to the ENERGY)
#   -thermalenthalpy
#   
#   -thermal_correction_gibbs  Thermal correction to the ENTHALPY (as
#   -thermal_gibbs       opposed to the ENERGY)
#   -thermalgibbs
#   -thermal_free_energy
#   -thermalfreeenergy
#
#   -temperature         Temperature used in thermochemistry analysis (K)
#   -temp
#
#   -pressure            Pressure used in thermochemistry analysis (atm)
#   -press
#
#   -point_group         Molecular point group
#   -pointgroup
#   -pg
#
#   -reaction_file=A     Build a reaction profile table using the reactant,
#   -reactionfile=A      product, and transition-structure (optional)
#   -rxn_file=A          listings given in file 'A'.
#   -rxnfile=A
#   -reaction=A
#   -rxn=A
#
#   -reaction_units=A    The units of energy reported in the reaction table
#   -reactionunits=A     is given by the value of 'A'.  Valid entries
#   -rxnunits=A          include 'au', 'kcal/mol' (or 'kcalmol'), 'ev',
#                        and 'cm-1'.
#
#   -reaction_energy=A   The type of reaction energies to be reported in
#   -reactionenergy=A    the reaction table is given by the value of 'A'.
#   -rxnenergy=A         Valid options include 'electronic' (or 'scf'),
#   -rxne=A              'ezpe', 'thermal', 'gibbs'
#
#   -----------------------------------------------------------------------
#
#   * When multiple options yield the same outcome, they are listed in
#     successive rows.  Blank lines indicate a new (set of) keyword(s).
#     Also, all options are case-insensitive.
#
#
#   Most Recent Modification Date: 9/12/2019
#                   Hrant P. Hratchian,
#                   Department of Chemistry & Chemical Biology
#                   Center for Chemical Computation and Theory (ccCAT)
#                   University of California, Merced
#                   hhratchian@ucmerced.edu
#
#
#   Revision History:
#       9/26/2006   Added functionalities to include thermochemistry data
#                   in the table.
#
#       10/14/2006  Added the reaction table option.  The ability to use
#                   wildcards in the reaction definition file still needs
#                   to be added.
#
#       3/26/2007   Added glob capabilities to the reaction table option.
#                   Also, introductory instructions and comments have been
#                   significantly expanded.
#
#       4/10/2007   Integrated the use of my module GaussLib.
#
#       7/31/2007   Expanded the use of module GaussLib.  Some new hashes
#                   have also been added.  An additional option switch for
#                   printing point group designations has also been added.
#
#       4/13/2011   Added reaction_energy switch.
#
#       9/12/2019   Added s-squared, charge, and multiplicity.
#
#--------------------------------------------------------------------------
#
#
#   Set-up communication with modules.
#
    use lib "/mf/hrant/bin/";
    use lib "/home/hrant/bin/";
    use lib "/Users/hhratchian/bin/";
    use lib "/home/hhratchian/bin";
    use GaussLib;
#
#   Interpret command line arguments and fill the array @gaussian_files
#   with the list of the files the user wants us to analyze.
#
    foreach(@ARGV){
      chomp($_);
      if(/^-date$/i){
        push(@Table_Entries,"Date");
      }elsif(/^-(job_type||jobtype||type)$/i){
        push(@Table_Entries,"Job Type");
      }elsif(/^-(model_chemistry||model_chem||modelchem)$/i){
        push(@Table_Entries,"Model Chem");
      }elsif(/^-hamiltonian$/i){
        push(@Table_Entries,"Hamiltonian");
      }elsif(/^-(basis_set||basis)$/i){
        push(@Table_Entries,"Basis Set");
      }elsif(/^-(stoichiometry||formula)$/i){
        push(@Table_Entries,"Stoichiometry");
      }elsif(/^-(charge)$/i){
        push(@Table_Entries,"Charge");
      }elsif(/^-(multiplicity||multip)$/i){
        push(@Table_Entries,"Multip");
      }elsif(/^-(energy\(au\)||energy||e)$/i){
        push(@Table_Entries,"Energy (au)");
      }elsif(/^-(energy\+zpe||e\+zpe||ezpe)$/i){
        push(@Table_Entries,"E+ZPE (au)");
      }elsif(/^-(energy\+thermal||e\+thermal)$/i){
        push(@Table_Entries,"E+Thermal (au)");
      }elsif(/^-(energy\+enthalpy||e\+enthalpy||enthalpy)$/i){
        push(@Table_Entries,"Enthalpy (au)");
      }elsif(/^-(energy\+gibbs||e\+gibbs||gibbs||free_energy||freeenergy)$/i){
        push(@Table_Entries,"Gibbs FE (au)");
      }elsif(/^-(scf_energy||scfenergy||scf)$/i){
        push(@Table_Entries,"SCF Energy (au)");
      }elsif(/^-(ssquared||s2)$/i){
        push(@Table_Entries,"<S^2>");
      }elsif(/^-(mp2_energy||mp2energy||mp2)$/i){
        push(@Table_Entries,"MP2 Energy (au)");
      }elsif(/^-(mp3_energy||mp3energy||mp3)$/i){
        push(@Table_Entries,"MP3 Energy (au)");
      }elsif(/^-(mp4_sdtq_energy||mp4_sdtqenergy||mp4_sdtq||
        mp4_energy||mp4energy||mp4)$/i){
        push(@Table_Entries,"MP4(SDTQ) E (au)");
      }elsif(/^-(mp4_sdq_energy||mp4_sdqenergy||mp4_sdq)$/i){
        push(@Table_Entries,"MP4(SDQ) E (au)");
      }elsif(/^-(mp4_dq_energy||mp4_dqenergy||mp4_dq)$/i){
        push(@Table_Entries,"MP4(DQ) E (au)");
      }elsif(/^-(mp4_d_energy||mp4_denergy||mp4_d)$/i){
        push(@Table_Entries,"MP4(D) E (au)");
      }elsif(/^-(cisd_energy||cisd)$/i){
        push(@Table_Entries,"CISD Energy (au)");
      }elsif(/^-(ccsd_energy||ccsd)$/i){
        push(@Table_Entries,"CCSD Energy (au)");
      }elsif(/^-(ccsd_paren_t_energy||ccsd_paren_t)$/i){
        push(@Table_Entries,"CCSD(T) E (au)");
      }elsif(/^-(force)$/i){
        push(@Table_Entries,"Max Force");
        push(@Table_Entries,"RMS Force");
        push(@Table_Entries,"Max Disp");
        push(@Table_Entries,"RMS Disp");
      }elsif(/^-(zpe)$/i){
        push(@Table_Entries,"ZPE (au)");
      }elsif(/^-(thermal_correction_energy||thermal_energy||thermalenergy)$/i){
        push(@Table_Entries,"Thermal Corr to Energy (au)");
      }elsif(/^-(thermal_correction_enthalpy||thermal_enthalpy||thermalenthalpy)$/i){
        push(@Table_Entries,"Thermal Corr to Enthalpy (au)");
      }elsif(/^-(thermal_correction_gibbs||thermal_gibbs||thermalgibbs||thermal_free_energy||thermalfreeenergy)$/i){
        push(@Table_Entries,"Thermal Corr to Gibbs (au)");
      }elsif(/^-(temperature||temp)$/i){
        push(@Table_Entries,"Temp (K)");
      }elsif(/^-(pressure||press)$/i){
        push(@Table_Entries,"Pressure (atm)");
      }elsif(/^-(point_group||pointgroup||pg)$/i){
        push(@Table_Entries,"Point Group");
      }elsif(/^-(reaction_file||reactionfile||rxn_file||rxnfile||reaction||rxn)=(\S+)$/i){
        $reaction_table_file = $2;
        chomp($reaction_table_file);
        $do_reaction_table = 1;
      }elsif(/^-(reaction_units||reactionunits||rxn_units||rxnunits)=(\S+)$/i){
        $reaction_table_units = $2;
        chomp($reaction_table_units);
        $reaction_table_units =~ s/^(.*)$/\U$1/i;
      }elsif(/^-(reaction_energy||reactionenergy||rxnenergy||rxne)=(\S+)$/i){
        $reaction_table_energy_input = $2;
        chomp($reaction_table_energy_input);
        $reaction_table_energy_input =~ s/^(.*)$/\U$1/i;
      }elsif(/^-(.*)/){
        die "Unknown argument sent to Table_Gauss: $1\n\n";
      }else {
        push(@gaussian_files,$_);
      }
    }

#hph+
#    print "\n\nHere are the table entries...\n";
#    foreach $temp (@Table_Entries){
#      print "$temp\n";
#    }
#hph-

#
#   Load the reaction table entries.
#
    if($do_reaction_table){
      ($reaction_table_ts_present,@reaction_table_entries) = 
        &reaction_table_list_set_up_sub($reaction_table_file);
    }
#
#   Presently, the file names are always given in column 1 of the data
#   tables.  Here, we add "File Name" to the front of the array
#   @Table_Entries.
#
    unshift(@Table_Entries,"File Name");
#
#   Fill @archives, which contains the archive entry from each Gaussian
#   output file.  We process the archive entry for each file individually.
#   The current file's archive is stored in $current_archive.
#
#   In this section, we also pick up other data that we're interested in
#   that does NOT appear in the archive.
#
#   Information collected from the archive entries includes:
#
# ------------------------------------------------------------------------
#      Hash Name                   Information Stored
# ------------------------------------------------------------------------
#      %seq_num                    Archive sequence number
#      %site                       Site name where the job was run
#      %job_type                   Job Type (SP, Opt, Freq, etc.)
#      %hamiltonian                Hamiltonian (RHF, UHF, RB3LYP, etc.)
#      %basis_set                  Basis Set
#      %stoichiometry              Stoichiometry
#      %charge                     Charge
#      %multiplicity               Spin multiplicity
#      %person                     Username of the person that ran the job
#      %date                       Date that the job was run (10-SEPT-2005)
#      %route_section              Full job route section
#      %job_title                  Job title
#      %molecular_specification    Molecular specification data
#      %cisd_energy                CISD energy in Hartree
#      %ccsd_energy                CCSD energy in Hartree
#      %mp4sdtq_energy             MP4(SDTQ) energy in Hartree
#      %mp4sdq_energy              MP4(SDQ) energy in Hartree
#      %mp4dq_energy               MP4(DQ) energy in Hartree
#      %mp4d_energy                MP4(D) energy in Hartree
#      %mp3_energy                 MP3 energy in Hartree
#      %mp2_energy                 MP2 energy in Hartree
#      %scf_energy                 SCF energy in Hartree
#      %zpe_correction             Zero point energy correction
#      %thermal_correction_energy  Thermal correction to the ENERGY
#      %point_group                Molecular point group
#      %ssquared                   SCF <S^2>
# ------------------------------------------------------------------------
#
#
#   Other information loaded include:
#
# ------------------------------------------------------------------------
#      Hash Name                   Information Stored
# ------------------------------------------------------------------------
#      %oniom_energy               Extrapolated energy from ONIOM jobs
#      %Maximum_Force              Last entry of the max force
#      %RMS_Force                  Last entry of the rms force
#      %Maximum_Displacement       Last entry of the max displacement
#      %RMS_Displacement           Last entry of the rms displacement
#      %thermal_correction_enthalpy Thermal correction to the ENTHALPY
#      %thermal_correction_gibbs   Thermal correction to the Gibbs free
#                                  energy.
#      %temperature                Temperature used for thermochemistry
#      %pressure                   Pressure used for thermochemistry
# ------------------------------------------------------------------------
#
#
#   Based on the hashes loaded from the Gaussian output file we can build a
#   series of other hashes, which include:
#
# ------------------------------------------------------------------------
#      Hash Name                   Information Stored
# ------------------------------------------------------------------------
#      %model_chemistry            This is the model chemistry (ie,
#                                  HF/STO-3G).
#      %energy                     This is the internal energy.
#      %energy_plus_zpe            This is E0+ZPE.
#      %energy_plus_thermal        This is E0+E(tran)+E(rot)+E(vib).
#      %enthalpy_plus_thermal      This is H = E+RT.
#      %gibbs_free_energy          This is G = H-ST.
# ------------------------------------------------------------------------
#
#
    @temp = @gaussian_files;
    foreach(@temp){
      chomp($file_name = $_);
      ($normal_term,
        $Maximum_Force{$file_name},
        $RMS_Force{$file_name},
        $Maximum_Displacement{$file_name},
        $RMS_Displacement{$file_name},
        $oniom_energy{$file_name},
        $zpe_correction_logfile{$file_name},
        $thermal_correction_enthalpy{$file_name},
        $thermal_correction_gibbs{$file_name},
        $temperature{$file_name},
        $pressure{$file_name},
        $archives{$file_name}) = get_gauss_log_data($file_name);
      if($normal_term){die "\n$file_name did not terminate normally!\n\n"}
    }
#
#   Since the first few sections of the archive entry (which are separated
#   by two slashes each) always have certain kinds of data, we begin by
#   splitting the archive sections apart and then pulling some of the
#   initial information we want from these split sections.  In the next
#   section, we pull data that can be taken by directly searching through
#   the whole archive line (stored in %archives).  The key difference
#   between the data that we pull from the archive here and the data we
#   pull in the next section is that the information we get here is not
#   separated by headings.  Instead, we just know that it will occur in a
#   specific order.  The data we get from the archive in the next section
#   of this script all has headers that we can search for.
#
    foreach(@gaussian_files){
#
#     Get the basic job info and specifics.
#
      ($seq_num{$_},$site{$_},$job_type{$_},$hamiltonian{$_},$basis_set{$_},
        $stoichiometry{$_},$person{$_},$date{$_},$op_sections_flag) = 
        gauss_archive_section0($archives{$_});
      ($route_section{$_},$job_title{$_},$molecular_specification{$_},
        $op_input) = gauss_archive_input_file_data($archives{$_});
      ($charge{$_},$multiplicity{$_}) =
        gauss_molspec2chargemultip($molecular_specification{$_});
#
#     Now load values from the results section in the archive.
#
      ($cisd_energy{$_},$ccsd_paren_t_energy{$_},$ccsd_energy{$_},
        $mp4sdtq_energy{$_},$mp4sdq_energy{$_},$mp4dq_energy{$_},
        $mp4d_energy{$_},$mp3_energy{$_},$mp2_energy{$_},$scf_energy{$_},
        $zpe_correction_archive{$_},$thermal_correction_energy{$_},
        $point_group{$_},$ssquared{$_}) = 
        gauss_archive_results_section_data($archives{$_});
#
#     Based on a strange bit of code in Link 9999 the archive entry for the
#     zero point correction may be dropped if it is "too" small.  So, for
#     now we will use the zero point correction from the log file.
#
      $zpe_correction{$_} = $zpe_correction_logfile{$_};
    }
#
#   Using the hashes %hamiltonian and %basis_set load the hash
#   %model_chemistry.
#
    foreach(@gaussian_files){
      chomp;
      $model_chemistry{$_} = $hamiltonian{$_} . "/" . $basis_set{$_};
    }
#
#   Grab the correct energy value and load the hash %energy.
#
    foreach(@gaussian_files){
      chomp;
      $Current_File = $_;
      if(defined($oniom_energy{$Current_File})){
        $energy{$Current_File} = $oniom_energy{$Current_File};
      }elsif(defined($cisd_energy{$Current_File})){
        $energy{$Current_File} = $cisd_energy{$Current_File};
      }elsif(defined($ccsd_paren_t_energy{$Current_File})){
        $energy{$Current_File} = $ccsd_paren_t_energy{$Current_File};
      }elsif(defined($ccsd_energy{$Current_File})){
        $energy{$Current_File} = $ccsd_energy{$Current_File};
      }elsif(defined($mp4sdtq_energy{$Current_File})){
        $energy{$Current_File} = $mp4sdtq_energy{$Current_File}
      }elsif(defined($mp4sdq_energy{$Current_File})){
        $energy{$Current_File} = $mp4sdq_energy{$Current_File}
      }elsif(defined($mp4dq_energy{$Current_File})){
        $energy{$Current_File} = $mp4dq_energy{$Current_File}
      }elsif(defined($mp4d_energy{$Current_File})){
        $energy{$Current_File} = $mp4d_energy{$Current_File}
      }elsif(defined($mp3_energy{$Current_File})){
        $energy{$Current_File} = $mp3_energy{$Current_File}
      }elsif(defined($mp2_energy{$Current_File})){
        $energy{$Current_File} = $mp2_energy{$Current_File}
      }elsif(defined($scf_energy{$Current_File})){
        $energy{$Current_File} = $scf_energy{$Current_File}
      }
    }
#
#   Using the hashes we have filled, fill the hashes %energy_plus_zpe,
#   %energy_plus_thermal, %enthalpy_plus_thermal, and %gibbs_free_energy.
#
    foreach(@gaussian_files){
      chomp;
      $energy_plus_zpe{$_} = $energy{$_}+$zpe_correction{$_};
      $energy_plus_thermal{$_} = $energy{$_}+$thermal_correction_energy{$_};
      $enthalpy_plus_thermal{$_} = $energy{$_}+$thermal_correction_enthalpy{$_};
      $gibbs_free_energy{$_} = $energy{$_}+$thermal_correction_gibbs{$_};
    }
#
#   In order to ensure that the table columns provide enough space for text
#   entries, we need to know the length of the largest element in certain
#   columns.  These maximum lengths are determined and set in this section.
#   The variables that are set, and the column headings they are used for
#   are:
#         $File_Name_Length   ... This is the max length of the file
#                                 names.
#         $Job_Type_Length    ... This is the length of the job types.
#         $Model_Chem_Length  ... This is the length of the model
#                                 chemistry.
#         $Hamiltonian_Length ... This is the length of the Hamiltonian.
#         $Basis_Set_Length   ... This is the length of the basis sets.
#         $Stoichiometry_Length . This is the length of the stoichiometry.
#
    $Job_Type_Length = 8;
    $Model_Chem_Length = 10;
    $Hamiltonian_Length = 11;
    $Basis_Set_Length = 9;
    $Stoichiometry_Length = 13;
    foreach(@gaussian_files){
      chomp;
      $Current_File_Name_Length = length $_;
      if($Current_File_Name_Length > $File_Name_Length){
        $File_Name_Length = $Current_File_Name_Length;
      }
      $Current_Job_Type_Length = length $job_type{$_};
      if($Current_Job_Type_Length > $Job_Type_Length){
        $Job_Type_Length = $Current_Job_Type_Length;
      }
      $Current_Model_Chem_Length = length $model_chemistry{$_};
      if($Current_Model_Chem_Length > $Model_Chem_Length){
        $Model_Chem_Length = $Current_Model_Chem_Length;
      }
      $Current_Hamiltonian_Length = length $hamiltonian{$_};
      if($Current_Hamiltonian_Length > $Hamiltonian_Length){
        $Hamiltonian_Length = $Current_Hamiltonian_Length;
      }
      $Current_Basis_Set_Length = length $basis_set{$_};
      if($Current_Basis_Set_Length > $Basis_Set_Length){
        $Basis_Set_Length = $Current_Basis_Set_Length;
      }
      $Current_Stoichiometry_Length = length $stoichiometry{$_};
      if($Current_Stoichiometry_Length > $Stoichiometry_Length){
        $Stoichiometry_Length = $Current_Stoichiometry_Length;
      }
    }
#
    $File_Name_Length += 3;
    $Job_Type_Length += 3;
    $Model_Chem_Length += 3;
    $Hamiltonian_Length += 3;
    $Basis_Set_Length += 3;
    $Stoichiometry_Length += 3;
#
#   Print out a table of requested information.  We first have to build the
#   header and line-by-line formattings based on the data that has been
#   requested by the user.  We also build the table header (the column
#   titles).  We also set the length of numeric entries
#   ($Numeric_Entry_Length) and the number of decimal points ($Num_Decimal)
#   we want to use.
#
    $Numeric_Entry_Length       = 20;
    $Num_Decimal                =  6;
    $Numeric_Entry_Length_Short =  3;
    foreach(@Table_Entries){
      if(/^File Name$/){
        $Table_Header_Format .= "\t%-$File_Name_Length" . "s";
        $Table_Line_Format   .= "\t%-$File_Name_Length" . "s";
        if($File_Name_Length%8==0){
          $Table_Header_Length += $File_Name_Length;
        }else{
          $Table_Header_Length += $File_Name_Length + (8 - $File_Name_Length%8);
        }
      }elsif(/^Date$/){
        $Table_Header_Format .= "\t%-$Job_Type_Length" . "s";
        $Table_Line_Format   .= "\t%-$Job_Type_Length" . "s";
        if($Job_Type_Length%8==0){
          $Table_Header_Length += $Job_Type_Length;
        }else{
          $Table_Header_Length += $Job_Type_Length + (8 - $Job_Type_Length%8);
        }
      }elsif(/^Job Type$/){
        $Table_Header_Format .= "\t%-$Job_Type_Length" . "s";
        $Table_Line_Format   .= "\t%-$Job_Type_Length" . "s";
        if($Job_Type_Length%8==0){
          $Table_Header_Length += $Job_Type_Length;
        }else{
          $Table_Header_Length += $Job_Type_Length + (8 - $Job_Type_Length%8);
        }
      }elsif(/^Model Chem$/){
        $Table_Header_Format .= "\t%-$Model_Chem_Length" . "s";
        $Table_Line_Format   .= "\t%-$Model_Chem_Length" . "s";
        if($Model_Chem_Length%8==0){
          $Table_Header_Length += $Model_Chem_Length;
        }else{
          $Table_Header_Length += $Model_Chem_Length + (8 - $Model_Chem_Length%8);
        }
      }elsif(/^Hamiltonian$/){
        $Table_Header_Format .= "\t%-$Hamiltonian_Length" . "s";
        $Table_Line_Format   .= "\t%-$Hamiltonian_Length" . "s";
        if($Hamiltonian_Length%8==0){
          $Table_Header_Length += $Hamiltonian_Length;
        }else{
          $Table_Header_Length += $Hamiltonian_Length + (8 - $Hamiltonian_Length%8);
        }
      }elsif(/^Stoichiometry$/){
        $Table_Header_Format .= "\t%-$Stoichiometry_Length" . "s";
        $Table_Line_Format   .= "\t%-$Stoichiometry_Length" . "s";
        if($Stoichiometry_Length%8==0){
          $Table_Header_Length += $Stoichiometry_Length;
        }else{
          $Table_Header_Length += $Stoichiometry_Length + (8 - $Stoichiometry_Length%8);
        }
      }elsif(/^Charge$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length_Short" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length_Short" . "d";
        if($Numeric_Entry_Length_Short%8==0){
          $Table_Header_Length += $Numeric_Entry_Length_Short;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length_Short +
            (8 - $Numeric_Entry_Length_Short%8);
        }
      }elsif(/^Multip$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length_Short" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length_Short" . "d";
        if($Numeric_Entry_Length_Short%8==0){
          $Table_Header_Length += $Numeric_Entry_Length_Short;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length_Short +
            (8 - $Numeric_Entry_Length_Short%8);
        }
      }elsif(/^Basis Set$/){
        $Table_Header_Format .= "\t%-$Basis_Set_Length" . "s";
        $Table_Line_Format   .= "\t%-$Basis_Set_Length" . "s";
        if($Basis_Set_Length%8==0){
          $Table_Header_Length += $Basis_Set_Length;
        }else{
          $Table_Header_Length += $Basis_Set_Length + (8 - $Basis_Set_Length%8);
        }
      }elsif(/^Energy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^E\+ZPE \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^E\+Thermal \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Enthalpy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Gibbs FE \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^SCF Energy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^<S\^2>$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^MP2 Energy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^MP3 Energy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^MP4\(SDTQ\) E \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^MP4\(SDQ\) E \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^MP4\(DQ\) E \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^MP4\(D\) E \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^CISD Energy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^CCSD Energy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^CCSD\(T\) E \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Max Force$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^RMS Force$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Max Disp$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^RMS Disp$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^ZPE \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Thermal Corr to Energy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Thermal Corr to Enthalpy \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Thermal Corr to Gibbs \(au\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Temp \(K\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Pressure \(atm\)$/){
        $Table_Header_Format .= "\t%$Numeric_Entry_Length" . "s";
        $Table_Line_Format   .= "\t%$Numeric_Entry_Length.$Num_Decimal" . "f";
        if($Numeric_Entry_Length%8==0){
          $Table_Header_Length += $Numeric_Entry_Length;
        }else{
          $Table_Header_Length += $Numeric_Entry_Length + (8 - $Numeric_Entry_Length%8);
        }
      }elsif(/^Point Group$/){
        $Table_Header_Format .= "\t%-$Stoichiometry_Length" . "s";
        $Table_Line_Format   .= "\t%-$Stoichiometry_Length" . "s";
        if($Stoichiometry_Length%8==0){
          $Table_Header_Length += $Stoichiometry_Length;
        }else{
          $Table_Header_Length += $Stoichiometry_Length + (8 - $Stoichiometry_Length%8);
        }
      }
    }
    $Table_Header_Length += 8;
    @Table_Header = @Table_Entries;
    $Table_Header_Format =~ (s/^\t//);
    $Table_Line_Format =~ (s/^\t//);
    $Table_Header_Format = ("=" x $Table_Header_Length) . "\n" . $Table_Header_Format;
    $Table_Header_Format .= "\n" . ("=" x $Table_Header_Length) . "\n";
    printf "$Table_Header_Format",@Table_Header;
    foreach(@gaussian_files){
      chomp($Current_File=$_);
      foreach(@Table_Header){
        if(/^File Name$/){
          push(@Current_Table_Line,$Current_File);
        }elsif(/^Job Type$/){
          push(@Current_Table_Line,$job_type{$Current_File});
        }elsif(/^Date$/){
          push(@Current_Table_Line,$date{$Current_File});
        }elsif(/^Model Chem$/){
          push(@Current_Table_Line,$model_chemistry{$Current_File});
        }elsif(/^Hamiltonian$/){
          push(@Current_Table_Line,$hamiltonian{$Current_File});
        }elsif(/^Stoichiometry$/){
          push(@Current_Table_Line,$stoichiometry{$Current_File});
        }elsif(/^Charge$/){
          push(@Current_Table_Line,$charge{$Current_File});
        }elsif(/^Multip$/){
          push(@Current_Table_Line,$multiplicity{$Current_File});
        }elsif(/^Basis Set$/){
          push(@Current_Table_Line,$basis_set{$Current_File});
        }elsif(/^Energy \(au\)$/){
          push(@Current_Table_Line,$energy{$Current_File});
        }elsif(/^E\+ZPE \(au\)$/){
          push(@Current_Table_Line,$energy_plus_zpe{$Current_File});
        }elsif(/^E\+Thermal \(au\)$/){
          push(@Current_Table_Line,$energy_plus_thermal{$Current_File});
        }elsif(/^Enthalpy \(au\)$/){
          push(@Current_Table_Line,$enthalpy_plus_thermal{$Current_File});
        }elsif(/^Gibbs FE \(au\)$/){
          push(@Current_Table_Line,$gibbs_free_energy{$Current_File});
        }elsif(/^SCF Energy \(au\)$/){
          push(@Current_Table_Line,$scf_energy{$Current_File});
        }elsif(/^<S\^2>$/){
          push(@Current_Table_Line,$ssquared{$Current_File});
        }elsif(/^MP2 Energy \(au\)$/){
          push(@Current_Table_Line,$mp2_energy{$Current_File});
        }elsif(/^MP3 Energy \(au\)$/){
          push(@Current_Table_Line,$mp3_energy{$Current_File});
        }elsif(/^MP4\(SDTQ\) E \(au\)$/){
          push(@Current_Table_Line,$mp4sdtq_energy{$Current_File});
        }elsif(/^MP4\(SDQ\) E \(au\)$/){
          push(@Current_Table_Line,$mp4sdq_energy{$Current_File});
        }elsif(/^MP4\(DQ\) E \(au\)$/){
          push(@Current_Table_Line,$mp4dq_energy{$Current_File});
        }elsif(/^MP4\(D\) E \(au\)$/){
          push(@Current_Table_Line,$mp4d_energy{$Current_File});
        }elsif(/^CISD Energy \(au\)$/){
          push(@Current_Table_Line,$cisd_energy{$Current_File});
        }elsif(/^CCSD Energy \(au\)$/){
          push(@Current_Table_Line,$ccsd_energy{$Current_File});
        }elsif(/^CCSD\(T\) E \(au\)$/){
          push(@Current_Table_Line,$ccsd_paren_t_energy{$Current_File});
        }elsif(/^Max Force$/){
          push(@Current_Table_Line,$Maximum_Force{$Current_File});
        }elsif(/^RMS Force$/){
          push(@Current_Table_Line,$RMS_Force{$Current_File});
        }elsif(/^Max Disp$/){
          push(@Current_Table_Line,$Maximum_Displacement{$Current_File});
        }elsif(/^RMS Disp$/){
          push(@Current_Table_Line,$RMS_Displacement{$Current_File});
        }elsif(/^ZPE \(au\)$/){
          push(@Current_Table_Line,$zpe_correction{$Current_File});
        }elsif(/^Thermal Corr to Energy \(au\)$/){
          push(@Current_Table_Line,$thermal_correction_energy{$Current_File});
        }elsif(/^Thermal Corr to Enthalpy \(au\)$/){
          push(@Current_Table_Line,$thermal_correction_enthalpy{$Current_File});
        }elsif(/^Thermal Corr to Gibbs \(au\)$/){
          push(@Current_Table_Line,$thermal_correction_gibbs{$Current_File});
        }elsif(/^Temp \(K\)$/){
          push(@Current_Table_Line,$temperature{$Current_File});
        }elsif(/^Pressure \(atm\)$/){
          push(@Current_Table_Line,$pressure{$Current_File});
        }elsif(/^Point Group$/){
          push(@Current_Table_Line,$point_group{$Current_File});
        }
      }
      printf "$Table_Line_Format\n",@Current_Table_Line;
      $Len_Current_Table_Line = @Current_Table_Line;
      for ($i = 1;$i<=$Len_Current_Table_Line;$i++){
        $temp = shift(@Current_Table_Line);
      }
    }
    printf ("=" x $Table_Header_Length) . "\n";
    print "\n\n";
#
#   Now, if requested, print the reaction table.
#
    if($do_reaction_table){
#
#     The work here begins by building the arrays @reactant_energy,
#     @product_energy, and @ts_energy.  At this point, all energies are in
#     Hartree.
#
      if($reaction_table_energy_input =~ /^(ELECTRONIC||SCF)$/){
        $reaction_energy_type = "energy";
      }elsif($reaction_table_energy_input =~ /^EZPE$/){
        $reaction_energy_type = "energy_plus_zpe";
      }elsif($reaction_table_energy_input =~ /^THERMAL$/){
        $reaction_energy_type = "enthalpy_plus_thermal";
      }elsif($reaction_table_energy_input =~ /^GIBBS$/){
        $reaction_energy_type = "gibbs_free_energy";
      }else{
        $reaction_energy_type = "energy";
      }
      print "Reaction energy type = $reaction_energy_type\n\n";
      $reaction_entry_table_header_format = ("=" x 75)."\nReaction Table Entries\n".
        ("=" x 75)."\n";
      printf "$reaction_entry_table_header_format";
      $i = 0;
      for $current_reaction (@reaction_table_entries){
        ($current_reactant_list,$current_product_list,$current_ts_list) =
          split /:/, $current_reaction;
        $i += 1;
        print "$i\t$current_reactant_list:$current_product_list";
        if($current_ts_list =~ /--NOTS--/){
          print "\n";
        }else{
          print ":$current_ts_list\n";
        }
        @current_reactant_array = split /,/, $current_reactant_list;
        @current_product_array = split /,/, $current_product_list;
        @current_ts_array = split /,/, $current_ts_list;
        $current_reactant_energy = 0;
        for $current_reactant_file (@current_reactant_array){
          $current_reactant_energy += ${$reaction_energy_type}{$current_reactant_file};
          $current_reactant_energy_plus_zpe += $energy_plus_zpe{$current_reactant_file};
        }
        $current_product_energy = 0;
        for $current_product_file (@current_product_array){
          $current_product_energy += ${$reaction_energy_type}{$current_product_file};
          $current_product_energy_plus_zpe += $energy_plus_zpe{$current_product_file};
        }
        $current_ts_energy = 0;
        if($reaction_table_ts_present){
          for $current_ts_file (@current_ts_array){
            if($current_ts_file =~ /--NOTS--/){
              $current_ts_energy = $current_reactant_energy;
              $current_ts_energy_plus_zpe = $current_reactant_energy_plus_zpe;
            }else{
              $current_ts_energy += ${$reaction_energy_type}{$current_ts_file};
              $current_ts_energy_plus_zpe += $energy_plus_zpe{$current_ts_file};
            }
          }
        }
        push(@reactant_energy,$current_reactant_energy);
        push(@product_energy,$current_product_energy);
        if($reaction_table_ts_present){push(@ts_energy,$current_ts_energy)}
        push(@reactant_energy_plus_zpe,$current_reactant_energy_plus_zpe);
        push(@product_energy_plus_zpe,$current_product_energy_plus_zpe);
        if($reaction_table_ts_present_plus_zpe){push(@ts_energy,$current_ts_energy_plus_zpe)}
      }
      $reaction_entry_table_bottom_format = ("=" x 75)."\n\n";
      printf "$reaction_entry_table_bottom_format";
#
#     Set-up the unit conversion value.
#
      if($reaction_table_units){
        if($reaction_table_units =~ /^AU$/){
          $reaction_conversion = 1;
        }elsif($reaction_table_units =~ /^(KCAL\/MOL||KCALMOL)$/){
          $reaction_conversion = 627.509469;
        }elsif($reaction_table_units =~ /^(KJ\/MOL||KJMOL)$/){
          $reaction_conversion = 2625.500;
        }elsif($reaction_table_units =~ /^EV$/){
          $reaction_conversion = 27.2117;
        }elsif($reaction_table_units =~ /^CM-1$/){
          $reaction_conversion = 219474.63;
        }else{
          die "\nUnknown reaction units selected: $reaction_table_units.\n\n";
        }
      }else{
        $reaction_conversion = 1;
        $reaction_table_units = "AU";
      }
      $reaction_table_units = "($reaction_table_units)";
#
#     Print the reaction energy table.
#
      $reaction_table_header_format = ("=" x 75)."\nRxn No.\t\tRxn Energy$reaction_table_units";
      if($reaction_table_ts_present){
        $reaction_table_header_format .= "\tActivation Energy$reaction_table_units";
      }
      $reaction_table_header_format .= "\n".("=" x 75)."\n";
      $reaction_table_line_format = "%-7d\t\t%-20.6f";
      if($reaction_table_ts_present){
        $reaction_table_line_format .= "\t%-20.6f";
      }
      $reaction_table_line_format .= "\n";
      printf "$reaction_table_header_format";
      for ($i = 0;$i<@reactant_energy;$i++){
        $current_reaction_energy =
          ($product_energy[$i]-$reactant_energy[$i])*$reaction_conversion;
        if($reaction_table_ts_present){
          $current_activation_energy = ($ts_energy[$i]-$reactant_energy[$i])*$reaction_conversion;
          printf "$reaction_table_line_format", $i+1, $current_reaction_energy, $current_activation_energy;
        }else{
          printf "$reaction_table_line_format", $i+1, $current_reaction_energy;
        }
      }
      printf ("=" x 75) . "\n";
      print "\n\n";
    }


##########################################################################
#                                                                        #
#                              SUBROUTINES                               #
#                                                                        #
##########################################################################

    sub reaction_table_list_set_up_sub{
#
#   This routine is used to set-up a variable for reaction tables, which is
#   a single-line character that can be torned apart later to determine
#   which energies are used for the reactant, product, and optionally the
#   transition-structure for each reaction entry.
#
#   As INPUT, this routine requires the name of the reaction table data
#   file (usually $reaction_table_file).  In order to keep this routine
#   general for future use, this variable is passed here as an argument.
#   
      use strict;
      if(@_ != 1){
        die "\nWrong number of parameters sent to Routine reaction_table_list_set_up_sub.\n\n";
      }
      my($file_to_read) = @_;
      chomp($file_to_read);
      my($temp_line,$num_reactions,$reaction_table_ts_present,@temp_array,
        $reaction_table_entries_scalar,@reaction_table_entries);
      open REACTIONFILE,"$file_to_read";
#
#     Go through the reaction table entry file and build the array of
#     reactions.
#
      while(<REACTIONFILE>){
        chomp($temp_line = $_);
        $num_reactions += 1;
        @temp_array = ();
        @temp_array = split /:/, $temp_line;
        if(@temp_array==3){
          $reaction_table_ts_present = 1;
        }elsif(@temp_array==2){
          $temp_line .= ":--NOTS--";
        }else{
          die "\nReaction $num_reactions has an invalid number of species.\n\n";
        }
        $temp_line =~ s/\s//g;
        $temp_line = &reaction_table_list_glob_sub($temp_line);
        $reaction_table_entries_scalar .= "$temp_line\n";
      }
      close REACTIONFILE,"$file_to_read";
      $reaction_table_entries_scalar =~ s/\n$//;
      @reaction_table_entries = split /\n/, $reaction_table_entries_scalar;
#
#     Return.
#
      return ($reaction_table_ts_present, @reaction_table_entries);
    }


    sub reaction_table_list_glob_sub{
#
#   This routine is used to test a line read from a reaction table entry
#   definition file for globs.  As input, send the current line from the
#   reaction table entry defition file.  As output, this routine returns
#   this line just as it was sent if no globs are present.  If globs are
#   present, the globs are expanded into multiple lines which are delimited
#   by "\n".
#   
      use strict;
      if(@_ != 1){
        die "\nWrong number of parameters sent to Routine reaction_table_list_glob_sub.\n\n";
      }
      my($line_in) = @_;
      chomp($line_in);
      my($reactant,$product,$ts,$r_globs,$p_globs,$ts_globs,$tot_globs,
        $temp,$temp1,$temp2,@temp_array,$i,@glob_array,@r_array,@p_array,
        @ts_array,$line_out);
#
#     Begin by parsing $line_in into $reactant, $product, and $ts.
#
      ($reactant,$product,$ts) = split /:/, $line_in;
#
#     Go through $reactant, $product, and $ts and expand globs as
#     appropriate.
#
      $r_globs = 0;
      $p_globs = 0;
      $ts_globs = 0;
#
#     Take care of the reactant section.
      if($reactant =~ /\*/){
        @temp_array = ();
        @temp_array = split /,/, $reactant;
        foreach $temp (@temp_array){
          if($temp =~ /\*/){
            $r_globs += 1;
            if($r_globs>1){
              die "\n\nreactant section: $reactant\n  Only 1 glob allowed per section!\n\n";
            }
            @glob_array = ();
            @glob_array = glob"$temp";
          }
        }
        @r_array = ();
        foreach $temp (@glob_array){
          $temp1 = "";
          foreach $temp2 (@temp_array){
            if($temp2 =~ /\*/){
              $temp1 .= "$temp,";
            }else{
              $temp1 .= "$temp2,";
            }
          }
          $temp1 =~ s/,$//;
          push(@r_array,$temp1);
        }
      }
#
#     Take care of the product section.
      if($product =~ /\*/){
        @temp_array = ();
        @temp_array = split /,/, $product;
        foreach $temp (@temp_array){
          if($temp =~ /\*/){
            $p_globs += 1;
            if($p_globs>1){
              die "\n\nproduct section: $product\n  Only 1 glob allowed per section!\n\n";
            }
            @glob_array = ();
            @glob_array = glob"$temp";
          }
        }
        @p_array = ();
        foreach $temp (@glob_array){
          $temp1 = "";
          foreach $temp2 (@temp_array){
            if($temp2 =~ /\*/){
              $temp1 .= "$temp,";
            }else{
              $temp1 .= "$temp2,";
            }
          }
          $temp1 =~ s/,$//;
          push(@p_array,$temp1);
        }
      }
#
#     Take care of the ts section.
      if($ts =~ /\*/){
        @temp_array = ();
        @temp_array = split /,/, $ts;
        foreach $temp (@temp_array){
          if($temp =~ /\*/){
            $ts_globs += 1;
            if($ts_globs>1){
              die "\n\nts section: $ts\n  Only 1 glob allowed per section!\n\n";
            }
            @glob_array = ();
            @glob_array = glob"$temp";
          }
        }
        @ts_array = ();
        foreach $temp (@glob_array){
          $temp1 = "";
          foreach $temp2 (@temp_array){
            if($temp2 =~ /\*/){
              $temp1 .= "$temp,";
            }else{
              $temp1 .= "$temp2,";
            }
          }
          $temp1 =~ s/,$//;
          push(@ts_array,$temp1);
        }
      }
#
#     Check that globs done to the reactant, product, and/or ts all have
#     the same number of final entries.  Also, we need put the reactant,
#     product, and ts lists back together in the proper order before
#     leaving.
#
      $tot_globs = $r_globs+$p_globs+$ts_globs;
      if($tot_globs==0){
        $line_out = $line_in;
      }elsif($tot_globs==1){
        if($r_globs==1){
          foreach $temp (@r_array){
            $line_out .= "$temp:$product:$ts\n";
          }
        }elsif($p_globs==1){
          foreach $temp (@p_array){
            $line_out .= "$reactant:$temp:$ts\n";
          }
        }elsif($ts_globs==1){
          foreach $temp (@ts_array){
            $line_out .= "$reactant:$temp:$ts\n";
          }
        }else{
          die "\n\nError 1 in reaction_table_list_glob_sub!\n\n";
        }
      }elsif($tot_globs==2){
        if($r_globs==0){
          $temp = @p_array;
          $temp1 = @ts_array;
          if($temp!=$temp1){
            die "\n\nreaction_table_list_glob_sub: Product and TS arrays are NOT the same length!\n\n";
          }
          for ($i=0;$i<$temp;$i++){
            $line_out .= "$reactant:$p_array[$i]:$ts_array[$i]\n";
          }
        }elsif($p_globs==0){
          $temp = @r_array;
          $temp1 = @ts_array;
          if($temp!=$temp1){
            die "\n\nreaction_table_list_glob_sub: Reactant and TS arrays are NOT the same length!\n\n";
          }
          for ($i=0;$i<$temp;$i++){
            $line_out .= "$r_array[$i]:$product:$ts_array[$i]\n";
          }
        }elsif($ts_globs==0){
          $temp = @r_array;
          $temp1 = @p_array;
          if($temp!=$temp1){
            die "\n\nreaction_table_list_glob_sub: Reactant and Product arrays are NOT the same length!\n\n";
          }
          for ($i=0;$i<$temp;$i++){
            $line_out .= "$r_array[$i]:$p_array[$i]:$ts\n";
          }
        }else{
          die "\n\nError 2 in reaction_table_list_glob_sub!\n\n";
        }
      }elsif($tot_globs==3){
        $temp = @r_array;
        $temp1 = @p_array;
        $temp2 = @ts_array;
        if(($temp!=$temp1)||($temp!=$temp2)){
          die "\n\nreaction_table_list_glob_sub: Reactant, Product, and TS arrays are NOT the same length!\n\n";
        }
        for ($i=0;$i<$temp;$i++){
          $line_out .= "$r_array[$i]:$p_array[$i]:$ts_array[$i]\n";
        }
      }else{
        die "\n\nError 3 in reaction_table_list_glob_sub!\n\n";
      }
#
#     Remove the new-line character at the end of $line_out.
#
      $line_out =~ s/\n\s*$//;
#
#     Return $line_out.
#
      return ($line_out);
    }
