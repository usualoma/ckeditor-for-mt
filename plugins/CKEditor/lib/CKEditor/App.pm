# Copyright (c) 2009 ToI-Planning <office@toi-planning.net> All rights reserved.
# For licensing, see LICENSE-Plugin.html

package CKEditor::App;
use strict;
use File::Basename;
use CKEditor::Field;
use MT::Util qw( encode_js );

sub plugin_data_post_save {
	my ($cb, $obj, $original) = @_;
	my $plugin = MT->component('CKEditor');
	my $app = MT->instance;

	if (lc($app->param('plugin_sig')) ne $plugin->id) {
		return;
	}

	require MT::Blog;
	my $blog_id = $app->param('blog_id') || 0;

	my @ids = $app->param('ckeditor_field_ids');
	$plugin->set_config_value(
		'ckeditor_fields', \@ids, $blog_id ? ('blog:' . $blog_id) : undef
	);
}

sub ckeditor_plugins {
	my $static_file_path = shift;
	my $dir = File::Spec->catfile(
		$static_file_path, 'plugins', 'CKEditor',
		'ckeditor', 'plugins'
	);

	my @ignores = ('dialog', 'dialogui', 'domiterator', 'editingblock', 'fakeobjects', 'floatpanel', 'htmlwriter', 'iframedialog', 'listblock', 'menu', 'menubutton', 'panel', 'panelbutton', 'richcombo', 'selection', 'styles', 'uicolor');

	opendir(my $dh, $dir);
	my @plugins = grep({
		my $e = $_;
		$e !~ m/^\./ && ! grep($_ eq $e, @ignores)
	} readdir($dh));
	closedir($dh);
	@plugins;
}

sub ckeditor_defaults {
	my $static_file_path = shift;
	my $dir = File::Spec->catfile(
		$static_file_path, 'plugins', 'CKEditor',
		'lib', 'default'
	);
	opendir(my $dh, $dir);
	my @defaults = grep($_ =~ m/\.js$/, readdir($dh));
	closedir($dh);
	@defaults;
}

sub js_include {
	my $param = shift || {};
	if (! defined($param->{'wrapper'})) {
		$param->{'wrapper'} = 1;
	}

	my $app = MT->instance;
	my $plugin = $app->component('CKEditor');
	my $hash = $plugin->get_config_hash('system') || {};

	my $static_url = $app->config('StaticWebPath');
	$static_url =~ s/\/?$//;
	my $static_file_path = $app->static_file_path;

	my $buttons = '';
	if ($hash->{'theme_advanced_buttons_set'} eq 'custom') {
		$buttons .= <<__EOB__;
config.toolbar_MTCustom = @{[ $hash->{'theme_advanced_buttons'} ]};
__EOB__
	}
	$buttons .=
		"config.toolbar = 'MT"
		. ucfirst($hash->{'theme_advanced_buttons_set'})
		. "';";

	my $plugins =
		"config.plugins = '"
		. join(',', &ckeditor_plugins($static_file_path))
		. "';";
	my $defaults = join('', map({
		<<__EOS__
<script type="text/javascript" src="$static_url/plugins/CKEditor/lib/default/$_"></script>
__EOS__
	}  &ckeditor_defaults($static_file_path)));

	my $font_settings = '';
	if ($hash->{'theme_advanced_font_setting'} eq 'custom') {
        my $fonts = $hash->{'theme_advanced_fonts'};
        $fonts = join(';', grep(!/^\s*$/, split(/;?\s*(\n|\r)/, $fonts)));
		$font_settings = <<__EOH__;
config.fontSize_sizes = '@{[ $hash->{'theme_advanced_font_sizes'} ]}';
config.font_names = '$fonts';
__EOH__
	}

	my $format_settings = '';
	if ($hash->{'theme_advanced_format_setting'} eq 'custom') {
        my $types = $hash->{'theme_advanced_format_types'};
		$format_settings = "config.format_tags = '$types';";
	}

	my $css_settings = '';
	if ($hash->{'theme_content_css_type'} eq 'url') {
		$css_settings = <<__EOH__;
config.contentsCss = '@{[ $hash->{'theme_content_css_url'} ]}';
__EOH__
	}
	elsif ($hash->{'theme_content_css_type'} eq 'content') {
		my $cfg = $app->config;
		my $ctx = $param->{'ctx'};
		my $uri = ($ctx ?
			(
				$ctx->invoke_handler('AdminCGIPath') .
				$ctx->invoke_handler('AdminScript')
			) :
			($app->can('app_uri') ?
				$app->app_uri :
				($cfg->AdminCGIPath || $cfg->CGIPath)
			)
		) . '?__mode=ckeditor_content_css';

		$css_settings = <<__EOH__;
config.contentsCss = '$uri';
__EOH__
	}

	my $other_config = '';
	if (
		($hash->{'ckeditor_config_type'} eq 'custom')
		&& (my $v = $hash->{'ckeditor_config_value'})
	) {
		$other_config = "$v;";
	}

	my ($blog, $type, $lang);

	if ($app->can('user') && $app->user) {
		$blog = $app->blog;
		$type = $app->param('_type');
		$lang = $app->user->preferred_language;
	}

	if (my $ctx = $param->{'ctx'}) {
		$blog = $ctx->stash('blog');
		if (my $entry = $ctx->stash('entry')) {
			$type = $entry->class;
		}
		$lang = $blog->language;
	}

	unless ($blog && $type && $lang) {
		return '';
	}

	my $l10n = File::Spec->catfile(
		$static_file_path, 'plugins', 'CKEditor',
		'lib', 'default', 'l10n', $lang . '.js'
	);
	if (-e $l10n) {
		$l10n = '<script type="text/javascript" src="'.$static_url.'/plugins/CKEditor/lib/default/l10n/'.$lang.'.js"></script>';
	}
	else {
		$l10n = '';
	}

	if (-e File::Spec->catfile(
			$static_file_path, 'plugins', 'CKEditor', 'ckeditor',
			'lang', $lang . '.js'
	)) {
		$lang = "config.language = '$lang';";
	}
	elsif (
		($lang =~ m/(.*?)(-.*)/)
		&& (-e File::Spec->catfile(
			$static_file_path, 'plugins', 'CKEditor', 'ckeditor',
			'lang', $1 . '.js'
		)
	)) {
		$lang = "config.language = '$lang';";
	}
	else {
		$lang = '';
	}

	if ($param->{'wrapper'}) {
        my $compat_mt4_instance_created = ($MT::VERSION < 5) ? <<__EOS__ : '';
        if (navigator.appVersion.indexOf('MSIE') == -1) {
            var dialog_container = getByID('dialog-container');
            if (dialog_container) {
                dialog_container.className = '';
                dialog_container.style.zIndex = 3000;
            }
        }
__EOS__

		<<__EOH__;
<style type="text/css">
#cke_contents_editor-content-textarea iframe,
#cke_contents_editor-content-textarea textarea
{
	top: auto;
	position: static;
}
</style>
<script type="text/javascript">
var CKEditorMTVersion = '@{[ $MT::VERSION ]}';
</script>
<script type="text/javascript" src="$static_url/plugins/CKEditor/ckeditor/ckeditor.js"></script>
$defaults
$l10n
<script type="text/javascript">
var CKEditorBlogID = @{[ $blog->id ]};
var CKEditorBlogThemeID = '@{[ $blog->can('theme_id') ? $blog->theme_id : '' ]}';
var CKEditorBlogTemplateSet = '@{[ encode_js($blog->can('template_set') ? $blog->template_set : '') ]}';
var CKEditorObjectType = '@{[ $type ]}';
(function() {
	if (typeof(Editor) !== 'undefined') {
		var editor_textarea_focus = Editor.Textarea.prototype.focus;
		function focus() {
			if (
				(! this.element.disabled)
				&& (this.element.style.display != 'none')
			) {
				editor_textarea_focus.call(this);
			}
		}
		Editor.Textarea = new Class(Editor.Textarea, {
			focus: focus,
			placement: null
		});
	}

	CKEDITOR.on('instanceCreated', function(__obj) {
		$compat_mt4_instance_created

		var editor = __obj.editor;
		var config = editor.config;

		$plugins
		$buttons
		$font_settings
		$format_settings
		$css_settings
		$other_config
		$lang

		config.resize_event = true;
		editor.on('resizeComplete', function() {
			var container = editor.getResizable();
			var height = getByID('ckeditor_' + editor.name + '_height');
			if (height) {
				height.value = container.\$.offsetHeight
			}
		});
	});
})();
</script>
__EOH__
	}
	else {
		<<__EOH__;
<script type="text/javascript" src="$static_url/plugins/CKEditor/ckeditor/ckeditor.js"></script>
$defaults
__EOH__
	}
}

sub param_edit_entry {
	my ($cb, $app, $param, $tmpl) = @_;
	my $plugin = MT->component('CKEditor');
	my $blog = $app->blog or return;
	my $blog_id = $blog->id;
	my @ids = ();

	$param->{'js_include'} ||= '';
	$param->{'js_include'} .= &js_include;

	my $system_hash = $plugin->get_config_hash() || {};
	my $hash = $plugin->get_config_hash('blog:' . $blog_id) || {};

	if ($hash->{'ckeditor_for_excerpt'}) {
		push(@ids, 'excerpt');
	}

    eval { require CustomFields::Field; };
    if (! $@) {
		my @field_ids = (
			@{ $hash->{'ckeditor_fields'} || [] },
			@{ $system_hash->{'ckeditor_fields'} || [] }
		);
		if (@field_ids) {
			my @fields = CustomFields::Field->load({
				'blog_id' => [ 0, $blog_id ],
				'obj_type' => $app->param('_type'),
				'type' => 'textarea',
				'id' => \@field_ids,
			});
			foreach my $f (@fields) {
				push(@ids, 'customfield_' . $f->basename);
			}
		}
	}

	if (@ids) {
		my $ids = "'" . join("','", @ids) . "'";
		my $script = <<__EOH__;
<script type="text/javascript">
(function() {

	function insertHTML(html, field) {
		if (field) {
			field = field.replace('___ckeditorfield___', 'customfield');
		}

		/* At this context field is not ignored. we have a few editor */
		if (
			(! field)
			|| (field == 'editor-content-textarea')
			|| ((! CKEDITOR) || (! CKEDITOR.instances[field]))
		) {
			this.fixHTML(this.editor.insertHTML(html));
		}
		else {
			var editor = CKEDITOR.instances[field];
			editor.insertHtml(html)
		}
	}

	App.singletonConstructor =
	MT.App = new Class( MT.App, {
		insertHTML: insertHTML,
		placement: null
	} );
	if (window.app) {
		window.app.insertHTML = insertHTML;
	}

	var ids = [$ids];
	for (var i = 0; i < ids.length; i++) {
		var id = 'editor-content-textarea';
	 	var opt = {
			on: {
				key: function(ev) {
					window.app.setDirty();
				}
			}
		};

		var height = getByID('ckeditor_' + ids[i] + '_height');
		if (height && height.value && height.value > 0) {
			opt['height'] = height.value;
		}

		var input = getByID(ids[i]);
		if (
			input && input.parentNode &&
			input.parentNode.className == 'textarea-wrapper'
		) {
			var input_parent = input.parentNode;
			input_parent.parentNode.appendChild(input);
			input_parent.parentNode.removeChild(input_parent);
		}

		CKEDITOR.replace(ids[i], opt);
	}
})();
</script>
__EOH__
		my $footer = $tmpl->getElementById('footer_include');
		my $node = $tmpl->createTextNode($script);
		$tmpl->insertBefore($node, $footer);
	}

	my @fields = CKEditor::Field->load(
		{ 'blog_id' => $blog_id },
		{ sort => [
			{ column => 'entry_id', desc => 'desc' },
			{ column => 'author_id', desc => 'desc' },
		] }
	);
	my %fields;
	$fields{$_->field} ||= $_ for @fields;

	my $heights = join('', map({
		my $id = 'ckeditor_'.$_.'_height';
		my $value = $fields{$_} ? $fields{$_}->height : '';
		<<__EOI__
<input type="hidden" id="$id" name="$id" value="$value" />
__EOI__
	} @ids, 'editor-content-textarea'));

	{
		my $field = $tmpl->getElementById('content_fields');
		my $node = $tmpl->createTextNode($heights);
		$tmpl->insertAfter($node, $field);
	}
}

sub entry_post_save {
	my ($cb, $obj, $original) = @_;
	my $plugin = MT->component('CKEditor');
	my $app = MT->instance;

	return if ! $app->can('param');

	my $blog = $app->blog
		or return;
	my $user = $app->user
		or return;
	my $blog_id = $blog->id;

	my $vars = $app->param->Vars;

	my @fields = CKEditor::Field->load(
		{ 'blog_id' => $blog_id },
		{ sort => [
			{ column => 'entry_id', desc => 'desc' },
			{ column => 'author_id', desc => 'desc' },
		] }
	);
	my %fields;
	$fields{$_->entry_id}{$_->author_id}{$_->field} = $_ for @fields;

	foreach my $k (%$vars) {
		next unless $vars->{$k};
		if ($k =~ m/^ckeditor_(.*)_height$/) {
			my $v = $vars->{$k};
			foreach my $k (
				[$obj->id, $user->id],
				[0, $user->id],
				[0, 0]
			) {
				my ($k1, $k2) = @$k;
				$fields{$k1}{$k2}{$1} ||= new CKEditor::Field;
				$fields{$k1}{$k2}{$1}->set_values({
					'blog_id' => $blog_id,
					'entry_id' => $k1,
					'author_id' => $k2,
					'field' => $1,
					'height' => $v,
				});
				$fields{$k1}{$k2}{$1}->save;
			}
		}
	}
}


sub init_request {
	my ($app) = @_;
	my $plugin = MT->component('CKEditor');
	
	return if !($app->can('param'));

	my $blog_id = $app->param('blog_id') or return;

	if ($plugin->get_config_value('ckeditor_for_body', 'blog:' . $blog_id)) {
		$app->config('RichTextEditor', 'CKEditor');

		if ($MT::VERSION < 5) {
			$plugin->{registry}{richtext_editors}{ckeditor}{template} =
				'ckeditor_compat_mt4.tmpl'
		}
		$plugin->{registry}->{richtext_editors}->{archetype} =
			$plugin->{registry}->{richtext_editors}->{ckeditor};
	}
}

sub content_css {
    my $app = shift;
	my $plugin = $app->component('CKEditor');

	$app->{cgi_headers}{'Content-Type'} = 'text/css; charset=UTF-8';
	$plugin->get_config_value('theme_content_css_content');
}

1;
