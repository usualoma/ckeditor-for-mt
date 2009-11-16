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
	'FormatSettingDefault' => 'Default',

    'ThemeAdvancedFontSizesExample' => 'eg. Big text=30px,Small text=small,My Text Size=.mytextsize',
    'ThemeAdvancedFontsNote' => '',

	'Config example contents.' => <<__EOC__,
config.pasteFromWordRemoveStyle = true;
config.coreStyles_bold = { element : 'b' };
config.coreStyles_italic = { element : 'i' };

// When Enter is pressed, insert a tag <br />. 
config.enterMode = CKEDITOR.ENTER_BR;
// When Shift+Enter is pressed, create new tags <p></p>. 
config.shiftEnterMode = CKEDITOR.ENTER_P;

// "href" and "src" are converted into the relative path. 
config.rewrite_urls = true;

if (CKEditorBlogID == 1) {
    config.toolbar = &#x5b;
        &#x5b;'Bold','Italic','Underline','Strike','-','Subscript','Superscript'&#x5d;
    &#x5d;;
}
if (CKEditorBlogThemeID = 'professional_blog') {
    config.toolbar = &#x5b;
        &#x5b;'Bold','Italic','Underline','Strike','-','Subscript','Superscript'&#x5d;
    &#x5d;;
}
if (CKEditorObjectType = 'entry') {
	// Editing entry.
}
if (CKEditorObjectType = 'page') {
	// Editing page.
}
__EOC__
	'Arial/Arial, Helvetica, sans-serif;Times New Roman/Times New Roman, Times, serif;Verdana' => <<__EOC__,
Arial/Arial, Helvetica, sans-serif
Times New Roman/Times New Roman, Times, serif
Verdana
__EOC__
);

1;
