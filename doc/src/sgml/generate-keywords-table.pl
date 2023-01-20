#!/usr/bin/perl
#
# Generate the keywords table for the documentation's SQL Key Words appendix
#
# Copyright (c) 2019-2023, PostgreSQL Global Development Group

use strict;
use warnings;

my @sql_versions = reverse sort ('1992', '2011', '2016');

my $srcdir = $ARGV[0];

my %keywords;
my %as_keywords;

# read SQL-spec keywords

foreach my $ver (@sql_versions)
{
	foreach my $res ('reserved', 'nonreserved')
	{
		foreach my $file (glob "$srcdir/keywords/sql${ver}*-${res}.txt")
		{
			open my $fh, '<', $file or die;

			while (<$fh>)
			{
				chomp;
				$keywords{$_}{$ver}{$res} = 1;
			}

			close $fh;
		}
	}
}

# read PostgreSQL keywords

open my $fh, '<', "$srcdir/../../../src/include/parser/kwlist.h" or die;

while (<$fh>)
{
	if (/^PG_KEYWORD\("(\w+)", \w+, (\w+)_KEYWORD\, (\w+)\)/)
	{
		$keywords{ uc $1 }{'pg'}{ lc $2 } = 1;
		$as_keywords{ uc $1 } = 1 if $3 eq 'AS_LABEL';
	}
}

close $fh;

# print output

print "<!-- autogenerated, do not edit -->\n";

print <<END;
<table id="keywords-table">
 <title><acronym>SQL</acronym> Key Words</title>

 <tgroup cols="5">
  <colspec colname="col1" colwidth="5*"/>
  <colspec colname="col2" colwidth="3*"/>
  <colspec colname="col3" colwidth="2*"/>
  <colspec colname="col4" colwidth="2*"/>
  <colspec colname="col5" colwidth="2*"/>
  <thead>
   <row>
    <entry>Key Word</entry>
    <entry><productname>PostgreSQL</productname></entry>
END

foreach my $ver (@sql_versions)
{
	my $s = ($ver eq '1992' ? 'SQL-92' : "SQL:$ver");
	print "    <entry>$s</entry>\n";
}

print <<END;
   </row>
  </thead>

  <tbody>
END

foreach my $word (sort keys %keywords)
{
	# Insert zwsp's into very long keywords, so that they can be broken
	# into multiple lines in PDF format (or narrow HTML windows).
	my $printword = $word;
	$printword =~ s/_/_&zwsp;/g if (length($printword) > 20);

	print "   <row>\n";
	print "    <entry><token>$printword</token></entry>\n";

	print "    <entry>";
	if ($keywords{$word}{pg}{'unreserved'})
	{
		print "non-reserved";
	}
	elsif ($keywords{$word}{pg}{'col_name'})
	{
		print "non-reserved (cannot be function or type)";
	}
	elsif ($keywords{$word}{pg}{'type_func_name'})
	{
		print "reserved (can be function or type)";
	}
	elsif ($keywords{$word}{pg}{'reserved'})
	{
		print "reserved";
	}
	if ($as_keywords{$word})
	{
		print ", requires <literal>AS</literal>";
	}
	print "</entry>\n";

	foreach my $ver (@sql_versions)
	{
		print "    <entry>";
		if ($keywords{$word}{$ver}{'reserved'})
		{
			print "reserved";
		}
		elsif ($keywords{$word}{$ver}{'nonreserved'})
		{
			print "non-reserved";
		}
		print "</entry>\n";
	}
	print "   </row>\n";
}

print <<END;
  </tbody>
 </tgroup>
</table>
END
