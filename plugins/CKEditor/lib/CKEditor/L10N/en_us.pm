# Copyright (c) 2009 ToI-Planning <office@toi-planning.net> All rights reserved.
# For licensing, see LICENSE-Plugin.html

package CKEditor::L10N::en_us;

use strict;

use base 'CKEditor::L10N';
use vars qw( %Lexicon );
%Lexicon = (
	'FontSettingDefault' => 'Default',
	'ContentCSSDefault' => 'Default',
	'ContentCSSURL' => 'URL',
	'ContentCSSContent' => 'CSS',
	'OtherSettingDefault' => 'Default',

    'ThemeAdvancedFontSizesExample' => 'eg. Big text=30px,Small text=small,My Text Size=.mytextsize',
    'ThemeAdvancedFontsNote' => '',

	'Config example contents.' => <<__EOC__,
CKEDITOR.config.config.pasteFromWordRemoveStyle = true;
CKEDITOR.config.coreStyles_bold = { element : 'b' };
CKEDITOR.config.coreStyles_italic = { element : 'i' };
if (CKEditorBlogID == 1) {
    CKEDITOR.config.toolbar = [
        ['Bold','Italic','Underline','Strike','-','Subscript','Superscript']
    ];
}
if (CKEditorBlogThemeID = 'professional_blog') {
    CKEDITOR.config.toolbar = [
        ['Bold','Italic','Underline','Strike','-','Subscript','Superscript']
    ];
}
if (CKEditorObjectType = 'entry') {
	// Editing entry.
}
if (CKEditorObjectType = 'page') {
	// Editing page.
}
__EOC__
);

1;
