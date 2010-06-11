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

	foreach my $k ('wrapper', 'jquery', 'css') {
		if (! defined($args->{$k})) {
			$args->{$k} = 1;
		}
	}

	my $blog = $ctx->stash('blog')
		or return '';
	my $blog_id = $blog->id;

	require MT::Util;
	my ($static_url, $script_url);
	my $version = MT::Util::encode_url(MT->VERSION);
	my $result = '';

	if ($args->{'css'}) {
		$static_url ||= $ctx->invoke_handler('StaticWebPath', $args);
		$result .= <<__SCRIPT__
<style type="text/css">
.mt-dialog {
	-moz-box-shadow: 0 3px 10px #2B2B2B;
	background: none repeat scroll 0 0 #FFFFFC;
	border: 1px solid #9EA1A3;
	display: none;
	left: 50%;
	margin-left: -340px;
	position: fixed;
	top: 30px;
	width: 680px;
	z-index: 3001;
}
.mt-dialog-overlay {
	background-color: #9EA1A3;
	display: none;
	height: 100%;
	left: 0;
	min-width: 950px;
	opacity: 0.5;
	filter: alpha(opacity=30);
	position: absolute;
	top: 0;
	width: 100%;
	z-index: 3000;
}
.mt-dialog span {
	display: none;
}
.mt-dialog img {
	left: 50%;
	margin: -33px 0 0 -33px;
	position: absolute;
	top: 50%;
}
body {
	position:relative;
	height: 100%;
}
body.has-dialog {
	overflow: hidden;
}
</style>
__SCRIPT__
	}

	if ($args->{'jquery'}) {
		$static_url ||= $ctx->invoke_handler('StaticWebPath', $args);
		$result .= <<__SCRIPT__
		<script type="text/javascript" src="${static_url}jquery/jquery.min.js?v=${version}"></script>
__SCRIPT__
	}

	if ($args->{'wrapper'}) {
		$static_url ||= $ctx->invoke_handler('StaticWebPath', $args);
		$script_url ||=
			$ctx->invoke_handler('AdminCGIPath', $args)
			. $ctx->invoke_handler('AdminScript', $args);
		$result .= <<__SCRIPT__
<script type="text/javascript" src="${static_url}jquery/jquery.bgiframe.min.js?v=${version}"></script>
<script type="text/javascript" src="${static_url}jquery/jquery.exfixed.js?v=${version}"></script>
<script type="text/javascript" src="${static_url}jquery/jquery.mt.min.js?v=${version}"></script>
<input type="hidden" name="blog-id" id="blog-id" value="$blog_id" />
<script type="text/javascript">
ScriptURI = '$script_url';
StaticURI = '$static_url';

if (typeof(app) === 'undefined') {
	app = {};
}
if (typeof(app.insertHTML) === 'undefined') {
	app.insertHTML = function(value, id) {
		CKEDITOR.instances[id].insertHtml(value);
	}
}
</script>
__SCRIPT__
	}

	require CKEditor::App;
	$result . &CKEditor::App::js_include({
		'wrapper' => $args->{'wrapper'},
		'ctx'     => $ctx,
	});
}

1;
