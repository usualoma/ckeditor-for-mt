# Copyright (c) 2009 ToI-Planning <office@toi-planning.net> All rights reserved.
# For licensing, see LICENSE-Plugin.html

package CKEditor::App;
use strict;
use File::Basename;

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
CKEDITOR.config.toolbar_MTCustom = @{[ $hash->{'theme_advanced_buttons'} ]};
__EOB__
	}
	$buttons .=
		"CKEDITOR.config.toolbar = 'MT"
		. ucfirst($hash->{'theme_advanced_buttons_set'})
		. "';";

	my $plugins =
		"CKEDITOR.config.plugins = '"
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
//CKEDITOR.config.fontSize_defaultLabel = '@{[ $hash->{'theme_advanced_font_sizes_default'} ]}';
//CKEDITOR.config.font_defaultLabel = '@{[ $hash->{'theme_advanced_font_sizes_default'} ]}';
CKEDITOR.config.fontSize_sizes = '@{[ $hash->{'theme_advanced_font_sizes'} ]}';
CKEDITOR.config.font_names = '$fonts';
__EOH__
	}

	my $format_settings = '';
	if ($hash->{'theme_advanced_format_setting'} eq 'custom') {
        my $types = $hash->{'theme_advanced_format_types'};
		$format_settings = "CKEDITOR.config.format_tags = '$types';";
	}

	my $css_settings = '';
	if ($hash->{'theme_content_css_type'} eq 'url') {
		$css_settings = <<__EOH__;
config.contentsCss = '@{[ $hash->{'theme_content_css_url'} ]}';
__EOH__
	}
	elsif ($hash->{'theme_content_css_type'} eq 'content') {
		my $uri = $app->app_uri . '?__mode=ckeditor_content_css';
		$css_settings = <<__EOH__;
CKEDITOR.config.contentsCss = '$uri';
__EOH__
	}

	my $other_config = '';
	if (
		($hash->{'ckeditor_config_type'} eq 'custom')
		&& (my $v = $hash->{'ckeditor_config_value'})
	) {
		$other_config = $v;
	}

	if ($app->can('user')) {
		my $blog = $app->blog;
		my $lang = $app->user->preferred_language;
		if (-e File::Spec->catfile(
				$static_file_path, 'plugins', 'CKEditor', 'ckeditor',
				'lang', $lang . '.js'
		)) {
			$lang = "CKEDITOR.config.language = '$lang';";
		}
		elsif (
			($lang =~ m/(.*?)(-.*)/)
			&& (-e File::Spec->catfile(
				$static_file_path, 'plugins', 'CKEditor', 'ckeditor',
				'lang', $1 . '.js'
			)
		)) {
			$lang = "CKEDITOR.config.language = '$lang';";
		}
		else {
			$lang = '';
		}

		if ($param->{'wrapper'}) {
		<<__EOH__;
<style type="text/css">
#cke_contents_editor-content-textarea iframe,
#cke_contents_editor-content-textarea textarea
{
	top: auto;
	position: static;
}
</style>
<script type="text/javascript" src="$static_url/plugins/CKEditor/ckeditor/ckeditor.js"></script>
$defaults
<script type="text/javascript">
var CKEditorBlogID = @{[ $blog->id ]};
var CKEditorBlogThemeID = '@{[ $blog->theme_id ]}';
(function() {
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

	$plugins
	$buttons
	$font_settings
	$format_settings
	$css_settings
	$other_config
	$lang
})();
</script>
<script type="text/javascript" src="$static_url/plugins/CKEditor/config.js"></script>
__EOH__
		}
		else {
		<<__EOH__;
<script type="text/javascript" src="$static_url/plugins/CKEditor/ckeditor/ckeditor.js"></script>
$defaults
<script type="text/javascript" src="$static_url/plugins/CKEditor/config.js"></script>
__EOH__
		}
	}
}

sub param_edit_entry {
	my ($cb, $app, $param, $tmpl) = @_;

	$param->{'js_include'} ||= '';
	$param->{'js_include'} .= &js_include;
}

sub source_edit_entry {
	my ($cb, $app, $tmpl) = @_;
	my $plugin = MT->component('CKEditor');
	my $blog_id = $app->param('blog_id') or return;
	my @ids = ();

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
		CKEDITOR.replace(ids[i]);
	}
})();
</script>
__EOH__

		#$$tmpl .= $script;
		my $replace = '<mt:?include[^>]*name="include/footer.tmpl"[^>]*>';
		$$tmpl =~ s#$replace#$script$&#i;
	}

}

sub init_request {
	my ($app) = @_;
	my $plugin = MT->component('CKEditor');
	
	return if !($app->can('param'));

	my $blog_id = $app->param('blog_id') or return;

	if ($plugin->get_config_value('ckeditor_for_body', 'blog:' . $blog_id)) {
		$app->config('RichTextEditor', 'CKEditor');

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