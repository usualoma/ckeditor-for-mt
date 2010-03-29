#!/usr/bin/perl

use Test::More;

use File::Spec;
use File::Basename;

BEGIN { require File::Spec->catfile(dirname(__FILE__), 'mt.pm'); }

my $mt   = MT->instance;
my $blog = MT::Blog->load;
my $entry = MT::Entry->load({blog_id => $blog->id});
my $tmpl = MT::Template->new;
my $ctx  = $tmpl->context;
$ctx->stash('blog', $blog);
$ctx->stash('entry', $entry);

my $plugin = $mt->component('CKEditor');
my $system_config = $plugin->get_config_hash('system');
$system_config->{'theme_content_css_type'} = 'content';
$plugin->set_config_value('theme_content_css_type', 'content', 'system');

$tmpl->text('<mt:CKEditorJavaScript />');
print($tmpl->output);


done_testing;
