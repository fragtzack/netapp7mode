package Rpt;
#use SelfLoader;
# michael.s.denney@gmail.com
# Rpt provides methods for common needed functions such as:
# Preparing email body with html formating from array of arrays
# Sending email
# Writing CSV file from array of arrays
use strict;
use Mail::Sender;
use Spreadsheet::WriteExcel;
use Common;
use Data::Dumper;
#use POSIX;

use vars qw($VERSION);
use subs qw (determine_format);
$VERSION = '0.29';
##  HISTORY
## 0.03 Added .SB_HeadingYellow and .SB_Footer , commented out global common html variables
## 0.11 Added .SB_Note_Normal
## 0.13 Added MakeEmailNote,MakeEmailNoteLight method
## 0.15 Added MakeEmailFooter method
## 0.17 Notes and Footer now use Nas::Rpt methods
## 0.19 Conversion to Linux, no shared_conf
## 0.21 WriteEmail
## 0.22 remove of WriteEmail, additions of Mail::Sendmail
## 0.23 Write::Excel and method write_excel_file
## 0.24 add_email_attachment method;
## 0.26 write_excel_file now looks for format for row,col
## 0.28 undef_to_blank sub (makes array elements a space if undef)
## 0.29 removed reference to html header gif file
###################################################################
sub new{
###################################################################
    my ($class_name) = @_;
    #my ($class_name,$shared_conf) = @_;
    #say "##########################";
    #say "shared_conf=>".$shared_conf;
    #my %configs=read_config("$shared_conf");
    #while ( (my $key,my $val) = each %configs) { print "$key =>$val<=\n"; }
    my $self = {};
    $self->{html_max_field_size}  = '40';
    bless ($self, $class_name) if defined $self;
    $self->{_created} = 1;
    return $self;
}
###################################################################
sub daily_rpt_dir{
###################################################################
   my $self = shift;
   if (@_) { $self->{daily_rpt_dir} = shift }
   return $self->{daily_rpt_dir};
}
###################################################################
sub email_attachment{
###################################################################
   my $self = shift;
   if (@_) { 
       push @{$self->{email_attachment}},@_;
   }
   #my $aref=@{$self->{email_attachment}};
   return \@{$self->{email_attachment}};
}
###################################################################
sub email_from{
###################################################################
   my $self = shift;
   if (@_) { $self->{email_from} = shift }
   return $self->{email_from};
}
###################################################################
sub email{
###################################################################
   my $self = shift;
   if (@_) { $self->{email} .= shift } ##append, dont over write!
   return $self->{email};
}
###################################################################
sub hosts_file{
###################################################################
   my $self = shift;
   if (@_) { $self->{host_file} = shift }
   return $self->{hosts_file};
}
###################################################################
sub local_host_ip_file{
###################################################################
   my $self = shift;
   if (@_) { $self->{local_host_ip_file} = shift }
   return $self->{local_host_ip_file};
}
###################################################################
sub html_max_field_size{
###################################################################
   my $self = shift;
   if (@_) { $self->{html_max_field_size} = shift }
   return $self->{html_max_field_size};
}
###################################################################
sub email_subject{
###################################################################
   my $self = shift;
   if (@_) { $self->{email_subject} = shift }
   return $self->{email_subject};
}
###################################################################
sub email_to{
###################################################################
   my $self = shift;
   if (@_) { $self->{email_to} = shift }
   return $self->{email_to};
}
###################################################################
sub mailhost{
###################################################################
   my $self = shift;
   if (@_) { $self->{mailhost} = shift }
   return $self->{mailhost};
}
##############################################################################
### GLOBAL COMMON HTML VARIABLES
##############################################################################
#our $tablewidth = "85%";                 #Width of the table#
##my $tablewidth= (reverse sort { $a <=> $b } map { length($_) } @report)[0]; #longest element size
#our $bgcolor = "#FFF2E1";                #Background color of the table#
#our $cellspacing = "2";                  #Cellspacing#
##our $cellpadding = "1";                  #Cellpadding#
#our $border = "0";                       #Border of table#
#our $cellbgcolor1 = "#000080";           #Cell background color#
#our $cellbgcolor = "#ADD8E6";            #$cellbgcolor = "#E6E6FA";
##$cellbgcolor = "#87cefa";
#our $font = "Verdana, arial";            #Font type #
#our $fontsize = "-1";                    #Font size#
#our $tablealign = "left";                #Table alignment (use center, left or right)#
#our $cellalign = "top";                  #Cell alignment (use top or bottom, empty to use default)#
    #my $Source="<a href=$fs_log_dir\\$tmphost\\$Source_FS.csv>$tmphost\_$Source_DM:$Source_FS</a>";
##############################################################################
sub pad_array_of_arrays{
##############################################################################
##This sub takes 2 parameters: \@table_headers, \@table_body
##Pad array of arrays with "-" to make each line
##equal to the length of the table headers.
##Arrays is meant to be used with MakeEmailBody or
##where ever table data(array of arrays) needs to match up with headers
my @table_headers=@{$_[0]};
my @table_body=@{$_[1]} or die "table_body required";

               my $header_size=scalar @table_headers;
	       foreach my $aref (@table_body){
		       my $line_size=scalar @$aref;
	               my $diff_size=$header_size-$line_size;
		       #say "header_size=>$header_size line_size=>$line_size diff_size => $diff_size";
		       if ( $diff_size != 0 ) {
		           foreach (my $cnt=0;$cnt<$diff_size;$cnt++) {
			       push @$aref,"-";
                           }
	               }
               }
=cut
	       foreach my $aref (@table_body){
		       my $line_size=scalar @$aref;
	               my $diff_size=$header_size-$line_size;
	               say "header_size=>$header_size line_size=>$line_size diff_size => $diff_size";
		       say $_ foreach @$aref;
		       #for ($diff_size;$diff_size==0;$diff_size--) {
		       #push @$aref,"-";
		       #}
               }
=cut
    return(\@table_headers,\@table_body);
}
##############################################################################
sub MakeEmailNote {
##############################################################################
    my $self=shift;
    my @notes=@{$_[0]};
    my $emailbody.='<p class=SB_Note>';
    foreach (@notes) {
        $emailbody.="$_<br>\n";
    }
    $emailbody.="</p>\n";

    $self->email($emailbody);
    return($emailbody);
}
##############################################################################
sub MakeEmailFooter {
##############################################################################
    my $self=shift;
    my @footer=@{$_[0]};
    my $emailbody.='<p class=SB_Footer>';
    foreach (@footer) {
        $emailbody.="$_<br>\n";
    }
    $emailbody.="</p>\n";

    $self->email($emailbody);
    return($emailbody);
}
##############################################################################
sub MakeEmailNoteLight {
##############################################################################
    my $self=shift;
    my @notes=@{$_[0]};

    my $emailbody.='<p class=SB_Note_Light>';
    foreach (@notes) {
        $emailbody.="$_<br>\n";
    }
    $emailbody.="</p>\n";

    $self->email($emailbody);
    return($emailbody);
}
##############################################################################
sub MakeEmailStatusHeaders {
##############################################################################
    my $self=shift;
    my $report_color=shift;
    my @header_summary=@{$_[0]};

    unless (($report_color eq "Green")||($report_color eq "Red")||($report_color eq "Yellow")) {die "Nas::Rpt->MakeEmailStatusHeaders() must pass Red or Green or Yellow"};

    my $emailbody="<p class=SB_Heading$report_color>";
    foreach my $summary (@header_summary) {
        $emailbody.="$summary<br>\n";
    }
    #$emailbody.="<p class=SB_Heading$report_color>";
	#$emailbody.="<p class=SB_HeadingGreen> $summary<br>";
    #$emailbody.="<p class=<br>";

    $self->email($emailbody);
    return($emailbody);
}
##############################################################################
sub MakeEmailBodyHeaders {
##############################################################################
    my $self=shift;
    my $report_title=$_[0];
    my $report_title2=$_[1];
    my @header_summary=@{$_[2]};

    #say "report_title=>$report_title";
    #say "report_title2=>$report_title2";
    #say $_ foreach (@header_summary);
    #exit;
    my $emailbody=<<END;

<HTML>

<style>
<!--
.SB_Title	     	{ font-family: Arial; font-size: 16pt; color: #000066; font-weight:bold; vertical-align: middle}
.SB_Heading     	{ font-family: Arial; font-size: 12pt; color: #000066; font-weight:bold }
.SB_Heading_Array     	{ font-family: Arial; font-size: 10pt; color: #333333; }
.SB_HeadingRed     	{ font-family: Arial; font-size: 12pt; color: #990000; font-weight:bold }
.SB_HeadingGreen     	{ font-family: Arial; font-size: 12pt; color: #009900; font-weight:bold }
.SB_HeadingYellow     	{ font-family: Arial; font-size: 12pt; color: #AEB404; font-weight:bold }
.SB_NoteRed     	{ font-family: Arial; font-size: 8pt; color: #990000; font-weight:bold;}
.SB_Note        	{ font-family: Arial; font-size: 8pt; color: #333333; font-weight:normal;}
.SB_Note_Light        	{ font-family: Arial; font-size: 8pt; color: #333333; font-weight:150;margin-left: 95;text-indent: -95}
.SB_Footer         	{ font-family: Arial; font-size: 7pt; color: #333333; font-weight:100;margin-left: 30}


.SB_Table    		{
					border:1px solid #000066; font-size: 10pt;
					font-family: Arial;
					padding-right: 10;
					padding-left: 10;
					cellpadding: 1;
					border-color: #000066; }

.SB_TableHeading 	{
					font-family: Arial;
					font-size: 10pt;
					font-weight: bold;
					background-color: #000066;
					color: #FFFFFF;
					border-width: 0;
					padding-right: 10;
					padding-left: 10; }

.SB_TableRow1 		{
					font-size: 10pt;
					font-family: Arial;
					background-color: #8BC5E2;
					text-align: left;
					color: #000066;
					padding-right: 10;
					padding-left: 10; }

.SB_TableRow2 		{
					font-size: 10pt;
					font-family: Arial;
					background-color: #D5EAF5;
					text-align: left;
					color: #000066;
					padding-right: 10;
					padding-left: 10; }

.SB_TableRow3 		{
					font-size: 10pt;
					font-family: Arial;
					background-color: #FFFFFF;
					text-align: left;
					color: #000066;
					padding-right: 10;
					padding-left: 10; }

.SB_Table_sm   		{
					border:1px solid #000066; font-size: 8pt;
					font-family: Arial;
					cellpadding: 1;
					border-color: #000066; }

.SB_sTableHeading_sm 	{
					font-family: Arial;
					font-size: 8pt;
					font-weight: bold;
					background-color: #000066;
					color: #FFFFFF;
					border-width: 0; }

.SB_sTableRow1_sm	{
					font-size: 8pt;
					font-family: Arial;
					background-color: #8BC5E2;
					text-align: left;
					color: #000066;}

.SB_sTableRow2_sm	{
					font-size: 8pt;
					font-family: Arial;
					background-color: #D5EAF5;
					text-align: left;
					color: #000066; }

.SB_sTableRow3_sm	{
					font-size: 8pt;
					font-family: Arial;
					background-color: #FFFFFF;
					text-align: left;
					color: #000066; }



-->
</style><body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<p class=SB_Title>
  $report_title</p>
<p class=SB_Heading>$report_title2</p>
END
#<p class=SB_Heading>$report_title2<br>
#<p class=SB_Title><img border="0" src=http://storagereqs.bankofamerica.com/images/BAC.gif">

   $emailbody.="<p class=SB_Heading_Array>";
    foreach my $summary (@header_summary) {
        $emailbody.="$summary<br>\n";
	#$emailbody.="<p class=SB_HeadingGreen> $summary<br>";
    }
    $emailbody.="</p>\n";

    $self->email($emailbody);
    return($emailbody);
}
##############################################################################
sub MakeEmailBody {
##############################################################################
    my $self=shift;
    my @report_header=@{$_[0]};
    my @report_body=@{$_[1]} or die "Nas::Rpt::MakeEmailBody need to pass \@report_body $!";
    #say "in MakeEmailBody";
    ##NEed to to check of the report_body element lines are equal to the report_header elements size
    ##And pad if not equal
    my ($header_ref,$body_ref)=pad_array_of_arrays(\@report_header,\@report_body);
    @report_header=@$header_ref;
    @report_body=@$body_ref; 
    #####Below here is the header for the table 
    ##### 
    my $emailbody="<TABLE class=SB_Table><THEAD><TR>\n";
    foreach my $header (@report_header) {
	    #say "table header=>$header";
         $emailbody.="<TH class=SB_TableHeading>$header</TH>\n";
    }


    ######Below here is the body of the table
    ######
    $emailbody.=" </TR></THEAD><TBODY>\n";
    my $row_count=0;
    foreach my $aref (@report_body) {
	$row_count++;
        $emailbody.= "<TR>\n";
        my $field_count=0;
        foreach my $field (@$aref) {
            $field_count++;
	    #$field=substr($field,0,$html_max_field_size) if ($field_count == 2); ##STDERR comes in on field #2
	    #$field=substr($field,0,20) if ($field_count == 3); ##STDERR might spill to field #3
            next if ($field_count > scalar(@report_header)); 
            $emailbody.="<TD class=SB_TableRow$row_count nowrap>$field</TD>\n";
        }
        $emailbody.="</TR>\n";
        $row_count=0 if ($row_count == 3);
    }
        $emailbody.="</TBODY></TABLE>\n";
	#$emailbody.="</:></HTML>\n";
 $self->email($emailbody);
 return($emailbody);
}
##############################################################################
sub SendEmail {
##############################################################################
   my $self=shift;

   unless ($self->email_from){
      $self->email_from($Common::basename);
   }
   my $sender=Mail::Sender->new({
     smtp => 'mail.abiz.com',
     auth => 'LOGIN',
     authid => 'MickeyMouse',
     authpwd => 'FakePw',
     subject =>$self->email_subject,
     from =>$self->email_from,
     to =>$self->email_to,
     client => qx/hostname/,
     multipart => 'mixed',
     skip_bad_recipients => 1, 
     #debug => 'mail.out',
     on_errors => 'die'
   });
   $sender->OpenMultipart({
     ctype => 'text/html',
     encoding => 'quoted-printable',
   });
   $sender->Body;
   $sender->SendEnc($self->email);
   foreach (@{$self->email_attachment}){
      my $file_description=qx/basename $_/;
      $sender->Attach({
         description =>$_,
         ctype => 'application/octet-stream',
         encoding => 'Base64',
         disposition => "attachment; filename=$file_description",
         file =>$_
      });
   }
   $sender->Close;
} #end sub SendMail
###################################################################
sub undef_to_blank{
###################################################################
   ##converts any elements in array of arrays to a space if undef
   my $array = shift;
   foreach my $aref(@$array){
      foreach (@$aref){
         $_ = " " unless ($_);
      }
   }
   return $array;
}
##############################################################################
sub write_csv_file{
###############################################################################
    #say "in write csv";
    my $self=shift;
    my $csvfile=$_[0] or logit "csvfile must be passed $!";
    my @cheader=@{$_[1]} or logit "cheader must be passed $!";
    #print "cheader=>"; print "$_," foreach (@cheader);
    my $csv_report=$_[2] or logit "csv_report must be passed $!";
    ##Header for main CSV file:
    $csv_report=undef_to_blank($csv_report);
    unless (open (MAINCSV,">$csvfile")) {logit "failed to open $csvfile"; return(0,"failed to open $csvfile");};
    foreach (@cheader) {
	    #print "$_,";
        print MAINCSV "$_,";
    }
    #print "\n";
    print MAINCSV "\n";
    ############### Create CSV File contents using the array of arrays @csv_report
    ############### by print each element of the secondary array with a ,
    ############### and for each element of the main array print the linefeed
    foreach (@$csv_report) {
        foreach my $field (@$_) {
		#print "$field,";
           print MAINCSV "$field,";  
        }
	#print "\n";
        print MAINCSV "\n";
    }
    close MAINCSV;
}
##############################################################################
sub excel_formats{
###############################################################################
    my $workbook=shift;
    my %formats;
    
    ####  Add and define a format  ####
    my $format_head = $workbook->add_format(); # Add a format
    $format_head->set_bold();
    $format_head->set_color('white');
    $format_head->set_bg_color('grey');
    $format_head->set_align('center');
    $formats{format_head}=$format_head;
    my $format_row = $workbook->add_format(); # Add a format
    $format_row->set_color('black');
    $format_row->set_bg_color('silver');
    $format_row->set_align('center');
    $formats{format_row}=$format_row;
    my $default= $workbook->add_format(); # Add a format
    $default->set_color('black');
    $default->set_align('center');
    $formats{default}=$default;
    my $yellow_bg = $workbook->add_format(); #add a format
    $yellow_bg->set_bg_color('yellow');
    $yellow_bg->set_align('center');
    $formats{yellow_bg}=$yellow_bg;
    my $green_bg = $workbook->add_format(); #add a format
    $green_bg->set_bg_color('green');
    $green_bg->set_align('center');
    $formats{green_bg}=$green_bg;
    my $orange_bg = $workbook->add_format(); #add a format
    $workbook->set_custom_color(40, '#FFCC99' ); 
    $orange_bg->set_bg_color(40);
    $orange_bg->set_align('center');
    $formats{orange_bg}=$orange_bg;
    my $light_green_bg= $workbook->add_format(); #add a format
    $light_green_bg->set_bg_color(0x26);
    $light_green_bg->set_align('center');
    $formats{light_green_bg}=$light_green_bg;
    return \%formats;
}
##############################################################################
sub write_excel_file{
###############################################################################
    #say "in write_excel_file ";
    my $self=shift;
    my $excelfile=$_[0] or logit "excel file must be passed $!";
    my $header=$_[1] or logit "header array must be passed $!";
    my $excel_rpt=$_[2] or logit "array reference must be passed $!";
    my $FRZ_COL=$_[3]||'NA';
    my $input_formats=$_[4];

    #print Dumper(%$formats);exit;
    
    ###### Create a new Excel workbook #####
    my $workbook = Spreadsheet::WriteExcel->new($excelfile);
    # Add a worksheet
    my $worksheet = $workbook->add_worksheet();
    $worksheet->keep_leading_zeros;
    my $max_rows=scalar @$excel_rpt;
    my $max_cols=scalar @$header;
    $worksheet->autofilter(0,0,$max_rows,$max_cols);
    #$worksheet->add_write_handler(qr[\w],\&store_string_widths);
   #Freeze first row and first FRZ_COL columns\&store_string_widths);
    if ($FRZ_COL =~ /^\d+$/){
        $worksheet->freeze_panes(1,$FRZ_COL);
    }
    my $formats=excel_formats($workbook);
    
    my $row=0;my $col=0;
    #######Header for main Excel file #######
    foreach (@$header) {
        #print "$_ ";
        $worksheet->write($row,$col,$_,$$formats{format_head});
        $col++;
    }
    $row++;
    ######## Create Excel File contents using the array of arrays @excel_rpt
#print Dumper(@$excel_rpt);exit;
    foreach my $aref (@$excel_rpt) {
        $col=0;
        foreach my $field (@$aref) {
	    #print "$field,";
            if ($col < 0){
                #$worksheet->write($row,$col,$field,$format_row); 
                $worksheet->write_string($row,$col,$field,$$formats{default}); 
            } else{ 
                #$worksheet->write($row,$col,$field,$format1); 
                my $cel_format=determine_format($row,$col,$formats,$input_formats);
                   $worksheet->write_string($row,$col,$field,$cel_format); 
            }#else if ($col < 0)
            $col++;
        }
        $row++;
	#print "\n";
    }
    my %col_widths=determine_col_widths($header,$excel_rpt);
    foreach (keys %col_widths){
       #say "row=>$row col=>$_ width=>".$col_widths{$_};
       if ($$input_formats{'all'}{$_}{'width'}){
          #say "CHANGE TO=>".$$formats{'all'}{$_}{'width'};
          $col_widths{$_}=$$input_formats{'all'}{$_}{'width'};
       }
       $worksheet->set_column($_,$_,$col_widths{$_}) if $col_widths{$_};
    }
}
##############################################################################
sub determine_format{
##############################################################################

   my $row=shift;
   my $col=shift;
   my $formats=shift;
   my $f_inputs=shift;

    #$formats{light_green_bg}=$light_green_bg;
   if ($$f_inputs{$row}{'all'}{'bg_color'} ){
      #say "f_inputs row=>$row bg_color=>".$$f_inputs{$row}{'all'}{'bg_color'};
      if ($$formats{$$f_inputs{$row}{'all'}{'bg_color'}}){
         return $$formats{$$f_inputs{$row}{all}{bg_color}};
      }
   }#end if ($$formats{$row}
   return $$formats{default};
}
##############################################################################
sub determine_col_widths{
##############################################################################
    my $header=$_[0] or logit "WARN header array must be passed $!";
    my $excel_rpt=$_[1] or logit "WARN array reference must be passed $!";
    my %col_widths;
    my $col_cnt=0;
    foreach (@$header){
       #say "contents =$_";
       #say "considering col $col_cnt , width ".length $_;
       $col_widths{$col_cnt}=length($_);
       #say "length of col $col_cnt is $col_widths{$col_cnt}";
       $col_cnt++;
    }
    foreach my $line (@$excel_rpt){
       $col_cnt=0;
       foreach my $field (@$line){
          #say "considering col $col_cnt ,width ".length $field;
          $col_widths{$col_cnt}=length($field) if (length($field) > $col_widths{$col_cnt});
          #say "length of col $col_cnt is $col_widths{$col_cnt}";
          $col_cnt++;
       }
    }
    foreach my $cols (keys %col_widths){
       #say "considering col $cols =".$col_widths{$cols};
       $col_widths{$cols}=$col_widths{$cols} * 1.5;
    }
    return %col_widths;
}
1;
