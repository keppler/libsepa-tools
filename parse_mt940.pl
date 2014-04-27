#!/usr/bin/perl
#  _ _ _
# | (_) |__ ___ ___ _ __  __ _   SEPA library · www.libsepa.com
# | | | '_ (_-</ -_) '_ \/ _` |  Copyright (c) 2013-2014 Keppler IT GmbH.
# |_|_|_.__/__/\___| .__/\__,_|_____________________________________________
#                  |_|
# parse_mt940.pl
# Parse MT940 account statements into a MySQL database
# http://github.com/keppler/libsepa-tools

use strict;
use warnings;
use DBI;
use SEPA 2.0;
use Data::Dumper;

# Configuration
my %CONFIG = (
  DBHOST   => 'localhost',
  DBNAME   => 'SEPA',
  DBUSER   => 'sepa',
  DBPASS   => 'BaNkInG',
  LIBSEPA_USER  => "YOUR NAME",         # libsepa license user
  LIBSEPA_CODE  => "YOUR LICENSE CODE", # libsepa license code
);

# un-comment and edit the following lines to activate your license:
if (defined($CONFIG{LIBSEPA_USER})) {
  SEPA::init(SEPA_INIT_LICUSER, $CONFIG{LIBSEPA_USER}) or die "SEPA::init(user) failed";
  SEPA::init(SEPA_INIT_LICCODE, $CONFIG{LIBSEPA_CODE}) or die "SEPA::init(license) failed";
}

if ($#ARGV != 0) {
  die "Usage: $0 <MT940-File>\n";
}

my $filename = $ARGV[0];

open(my $fh, "< $filename") or die "$0: Can't open $filename: $!\n";

my ($dbh);
# try to connect to the database
unless ($dbh = DBI->connect("DBI:mysql:$CONFIG{'DBNAME'}:$CONFIG{'DBHOST'}", $CONFIG{'DBUSER'}, $CONFIG{'DBPASS'})) {
  die "Database logon failed: $DBI::errstr\n";
}
$dbh->do("SET NAMES 'utf8'");

my $parser = new SEPA::StatementParser();
$parser->load(SEPA::StatementParser::SEPA_STMT_FORMAT_MT940, $filename);

close($fh);

my $stmts = $parser->getStatements();
my $count_parsed = 0;
my $count_added = 0;

foreach my $stmt (@$stmts) {
  my ($mybank, $myaccount) = $$stmt{account}=~/^([^\/]*)\/0*(.*)$/;
#  print "BANK=$mybank, ACCOUNT=$myaccount\n";

  TRANSACTION:
  foreach my $tx (@{$$stmt{tx}}) {
    my ($sql, $sth, $row);
    my %data = (
        'STMT_VALUTA'     => $$tx{valuta},    # value date
        'STMT_BOOKED'     => $$tx{booked} eq '1900-01-00' ? undef : $$tx{booked}, # book date (entry date)
        'STMT_MYBANK'     => $mybank,         # bank code or BIC of own account
        'STMT_MYACCOUNT'  => $myaccount,      # account number or IBAN of own account
        'STMT_AMOUNT'     => $$tx{amount},    # amount
        'STMT_CODE'       => $$tx{code},      # transaction type
        'STMT_REF'        => $$tx{ref},       # reference for the account owner 
        'STMT_BANKREF'    => $$tx{bankref},   # bank reference
        'STMT_GVC'        => $$tx{gvc},       # business code (payment type)
        'STMT_BANK'       => $$tx{bank},      # counterparty bank code or BIC
        'STMT_ACCOUNT'    => $$tx{account},   # counterparty account number or IBAN
        'STMT_NAME'       => $$tx{name},      # counterparty name
        'STMT_PURPOSE'    => $$tx{purpose},   # purpose
        'STMT_EREF'       => $$tx{eref},      # SEPA end-to-end reference
        'STMT_KREF'       => $$tx{kref},      # SEPA customer reference
        'STMT_MREF'       => $$tx{mref},      # SEPA mandate reference (direct debit only)
        'STMT_CRED'       => $$tx{cred},      # creditor ID (direct debit only)
        'STMT_DEBT'       => $$tx{dest},      # originators identification code
        'STMT_COAM'       => $$tx{coam},      # compensation amount (direct debit chargeback)
        'STMT_OAMT'       => $$tx{oamt},      # original amount (direct debit chargeback)
        'STMT_SVWZ'       => $$tx{svwz},      # SEPA purpose
        'STMT_ABWA'       => $$tx{abwa},      # differing debtor
        'STMT_ABWE'       => $$tx{abwe},      # differing creditor
      );
    $count_parsed++;
#    print Dumper(\%data);

    # check if record already exists:
    $sql = "SELECT STMT_ID FROM STATEMENTS WHERE "
        . join(' AND ', map { defined($data{$_}) ? "$_=" . $dbh->quote($data{$_}) : "$_ IS NULL" } keys %data);
#    print "SQL: $sql\n";
    unless (($sth = $dbh->prepare($sql)) && $sth->execute) {
      die "Error while querying database: $DBI::errstr\n";
    }
    if ($row = $sth->fetchrow_hashref) {
      # statement already in database
      $sth->finish;
      next TRANSACTION;
    }

    $sth->finish;
    print "SQL: $sql\n";

    # insert into database
    $sql = "INSERT INTO STATEMENTS (" . join(', ', keys %data) . ") VALUES ("
        . join(', ', map { defined($data{$_}) ? $dbh->quote($data{$_}) : 'NULL' } keys %data) . ")";
    print "SQL: $sql\n\n";
    unless ($dbh->do($sql)) {
      die "Error while adding record: $DBI::errstr\n";
    }
    $count_added++;
  }
}

print "OK, $count_parsed transactions parsed, $count_added transactions added.\n";

# <EOF>_____________________________________________________________________
