# Copyright (c) 2009 ToI-Planning <office@toi-planning.net> All rights reserved.
# For licensing, see LICENSE-Plugin.html

package CKEditor::Template::ContextHandlers;

use strict;

sub _hdlr_include_customized_fields {
    my($ctx, $args) = @_;

	require MT;
	my $app = MT->instance;
	my $blog = $app->blog;
	my $blog_id = $blog ? $blog->id : 0;

	my $plugin = $app->component('CKEditor');

	my @ckeditor_fields = @{
		$plugin->get_config_value('ckeditor_fields') || []
	};
	if ($blog_id) {
		push(@ckeditor_fields, @{ $plugin->get_config_value(
			'ckeditor_fields', 'blog:' . $blog_id
		) || [] });
	}

    eval { require CustomFields::Field; };
    if ($@) {
        $ctx->var('ckeditor_customized_fields', undef);
		return;
    }

	my @ids = (0);
	if ($blog_id) {
		push(@ids, $blog_id);
	}
	my (%customized_fields, %customized_fields_page);
	my @fields = CustomFields::Field->load({
		'blog_id' => \@ids,
		'type' => 'textarea',
	});
	foreach my $f (@fields) {
		my $hash = {};
        my $id = $f->id;
		$hash->{'key'} = $id;
		$hash->{'checked'} = grep( { $_ == $id } @ckeditor_fields);
		$hash->{'name'} = $f->name;
		$hash->{'blog_id'} = $f->blog_id;

		if ($f->obj_type eq 'entry') {
			$customized_fields{$id} = $hash;
		}
		elsif ($f->obj_type eq 'page') {
			$customized_fields_page{$id} = $hash;
		}
	}

    $ctx->var(
		'ckeditor_customized_fields',
		keys(%customized_fields) ? \%customized_fields : undef
	);
    $ctx->var(
		'ckeditor_customized_fields_page',
		keys(%customized_fields_page) ? \%customized_fields_page : undef
	);

    $ctx->var(
		'ckeditor_has_customized_fields',
		scalar(keys(%customized_fields))+scalar(keys(%customized_fields_page))
	);
}

sub _hdlr_javascript {
    my($ctx, $args) = @_;

	require CKEditor::App;
	&CKEditor::App::js_include({
		'wrapper' => defined($args->{'wrapper'}) ? $args->{'wrapper'} : undef,
	});
}

1;
