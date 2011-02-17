# Copyright (c) 2009 ToI-Planning <office@toi-planning.net> All rights reserved.
# For licensing, see LICENSE-Plugin.html

package CKEditor::Field;
use strict;
use warnings;

use MT::Object;
use base qw( MT::Object );

__PACKAGE__->install_properties({
	column_defs => {
		'id' => 'integer not null auto_increment',

		'entry_id' => 'integer not null',
		'blog_id' => 'integer not null',
		'author_id' => 'integer not null',
		'field' => 'string(255)',

		'height' => 'integer not null',
	},
	audit => 1,
	indexes => {
		blog_field => {
			columns => [ 'blog_id', 'field' ],
		}
	},
	datasource => 'ckeditor_field',
	primary_key => 'id',

    child_of => [ 'MT::Blog', 'MT::Entry', 'MT::Author' ],
});

sub parents {
    my $obj = shift;
    {
		entry_id => MT->model('entry'),
        template_id => MT->model('template'),
    };
}

1;
