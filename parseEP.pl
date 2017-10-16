#!/usr/bin/env perl
use strict; use warnings;

# useage
# ./parseEP.pl /Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic/10370/20120918/Raw/EPrime/CogEmo4*.txt
# 
# past, use iconv
#  iconv -f utf16 -t ascii CogEmo4_ER_A_Run1-10370-1.txt | ./parseEP.pl 
# instead we do unecoding here
#  use open IN=>':encoding(utf-16)', OUT=> ':encoding(us-ascii)';

# what events do we care about
my @events=qw/Procedure BlockListP ITI ITI9 SoundOut1 Wait2 Wait3 Wait4 Word cue1 gap1 goodx/;
# what values do we care about
my @valuekeys=qw/OnsetTime Duration note/;



# MAIN
print join("\t",qw/subj datetime run trial event part value/),"\n";
readep($_) for (@ARGV); 

# FUNCTION(S)
sub readep {
  my $filename = shift;
  open(my $fh, '<:encoding(UTF-16)', $filename) or
   die "cannot open '$filename'";

  my %masterinfo;
  my @all=();
  my $trial=0;
  my $level=0;
  my $starttime=0;
  while(<$fh>){
    chomp; s/\n|\r//g;
    # grab header info
    $masterinfo{$1}=$2 if(/^(Experiment|SessionDate|SessionTime|Subject): (.*)/);
  
    # where are we in the output file
    if(/Level: (\d+)/){$level=$1}
    elsif(/LogFrame End/){$level=0};
  
    
    # use level and start to count trials, also in BlockP
    if($level==3 && /LogFrame Start/){++$trial}; 
  
    # line matches info we care about
    if(/\.OnsetTime|Procedure|BlockListP.Sample|Word|Duration:/){
        # parse line
        s/^\W*//;s/.Sample//; 
        my ($field,$value)=split(/:/);
        my ($event,$part)=split/\./,$field;
        $part="note" if(!$part);
  
        # set and normalize by starttime
        $starttime=$value if("$trial$event$part" eq "0ITI10OnsetTime");
        $value=$value-$starttime if ($part =~ /OnsetTime/);
  
        $all[$trial]->{$event}->{$part} = $value;
        #print "[$trial]-> $a[0]-> $a[1] = $b[1]\n";
        my $datetime="$masterinfo{SessionDate} $masterinfo{SessionTime}";
        print join("\t",$masterinfo{Subject},$datetime,$masterinfo{Experiment},$trial,$event,$part,$value),"\n" if $trial >0;
     }
  }
  close $fh;
  # print_out(@all)
}

# print out -- not used
sub print_out {
   my @all=@_;
   print join("\t","trial","event",@valuekeys),"\n";
   print "$#all\n";
   for my $i (0..$#all-1){
      my $t = $all[$i];
      for my $ek (@events){ 
         #my @vals=map {$_||""} @{$t->{$ek}->{@valuekeys}};
         #print join("\t",$i,$ek,":",@vals), "\n";
         print join("\t",$i,$ek);
         for my $vk (@valuekeys){
            print("\t",($t->{$ek}->{$vk})||"");
         }
         print "\n";
      }
   }
}
