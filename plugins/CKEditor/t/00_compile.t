#!/usr/bin/perl

use Test::More;

use File::Spec;
use File::Basename;

BEGIN { require File::Spec->catfile(dirname(__FILE__), 'mt.pm'); }

use_ok('CKEditor::App');
use_ok('CKEditor::L10N::en_us');
use_ok('CKEditor::Field');
use_ok('CKEditor::L10N::ja');
use_ok('CKEditor::L10N');
use_ok('CKEditor::Template::ContextHandlers');

done_testing;
