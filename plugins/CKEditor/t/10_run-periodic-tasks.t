#!/usr/bin/perl

use Test::More;

use File::Spec;
use File::Basename;

BEGIN { require File::Spec->catfile(dirname(__FILE__), 'mt.pm'); }

my $mt = MT->instance;
my $author = MT::Author->load;
my $blog = MT::Blog->load;

print($blog->id . "\n\n");

my $entry = MT::Entry->new;
$entry->set_values({
	blog_id   => $blog->id,
	author_id => $author->id,
	status    => MT::Entry::FUTURE,
	title     => 'testtest',
	text      => 'texttext',
});

$entry->save;

system(
	"chdir $ENV{MT_HOME}; " .
	File::Spec->catfile($ENV{MT_HOME}, 'tools', 'run-periodic-tasks')
);

$entry->remove;

done_testing;
