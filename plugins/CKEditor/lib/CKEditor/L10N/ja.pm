# Copyright (c) 2009 ToI-Planning <office@toi-planning.net> All rights reserved.
# For licensing, see LICENSE-Plugin.html

package CKEditor::L10N::ja;

use strict;
use base 'CKEditor::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (
	'toi-planning' => 'ToI企画',
	'Enable to edit field by CKEditor' => 'フィールドをCKEditorで編集可能にします。',
	'Setting for fields which edited by CKEditor.' => 'CKEditorで編集するフィールドの設定',
	'Setting for editor&#039;s button.' => 'エディターに表示するボタンの設定',
	'1st line&#039;s buttons.' => '1行目のボタン',
	'2nd line&#039;s buttons.' => '2行目のボタン',
	'3rd line&#039;s buttons.' => '3行目のボタン',
	'4th line&#039;s buttons.' => '4行目のボタン',
	'5th line&#039;s buttons.' => '5行目のボタン',
	'Reference' => '詳しい解説',
	'CustomFields' => 'カスタムフィールド',
	'Eneble for body.' => '「本文」と「続き」',
	'Eneble for excerpt.' => '「概要」',

	'Buttons set.' => 'ボタンのセット',
	'Full' => 'フル',
	'Normal' => '標準',
	'Table' => 'テーブル',
	'Simple' => 'シンプル',
	'Custom' => 'カスタム',
	'Config example' => '設定例',
	'Buttons' => '',

    'Default font size.' => 'デフォルトのフォントサイズ',
    'Available font sizes.' => '選択可能なフォントサイズ',
    'Default font.' => 'デフォルトのフォント',

	'This is system-wide field.\nYou can change this value at system-wide plugin configuration page.' =>
	'システム全体で使われるフィールドです。\nこのフィールドに関する設定の変更はシステム全体のプラグインの設定ページから行ってください。',

	'Setting for fonts.' => 'フォントの設定',
	'Font settings.' => '',
	'FontSettingDefault' => 'デフォルト',
	'Available font sizes.' => '指定可能なフォントサイズ',
	'Available fonts.' => '指定可能なフォント',

	'Setting for formats.' => 'フォーマットの設定',
	'Format settings.' => '',
	'FormatSettingDefault' => 'デフォルト',
	'Available format types.' => '指定可能なフォーマット',

	'Setting for contnt.css.' => '編集領域に関する設定',
	'content.css settings.' => '',
	'ContentCSSDefault' => 'デフォルト',
	'ContentCSSURL' => 'URLを指定する',
	'ContentCSSContent' => 'CSSを編集する',
	'Url of &#034;content.css&#034;' => 'URL',
	'Contents of content.css' => 'CSS',

    'ThemeAdvancedFontSizesExample' => '例) 小さなフォント/80%;大きなフォント/120%',
    'ThemeAdvancedFontsNote' => '注) "選択肢/CSSのfont-family" の形式で1行に1つずつ記載してください。',
	'Settings for editor&#039;s buttons, fonts and more.' =>
	'エディターのボタンやフォントなどの設定',

	'Other settings.', => 'その他の設定',
	'Other setting types.', => '',
	'OtherSettingDefault', => 'デフォルト',
	'Configuration values.' => '設定値',

	'Config example contents.' => <<__EOC__,
// Wordから貼り付けをした際にスタイルを除去する
config.pasteFromWordRemoveStyle = true;
// 「太字」ボタンを押した際に「b」要素を設定する。
config.coreStyles_bold = { element : 'b' };
// 「斜体」ボタンを押した際に「i」要素を設定する。
config.coreStyles_italic = { element : 'i' };

// Enterを押した場合に<br />を挿入する
config.enterMode = CKEDITOR.ENTER_BR;
// Shift+Enterを押した場合に<p>を作成する
config.shiftEnterMode = CKEDITOR.ENTER_P;

// 「href」や「src」を相対パスに変換する。
config.rewrite_urls = true;

// ブログ毎に表示するボタンを変更する
if (CKEditorBlogID == 1) {
    config.toolbar = &#x5b;
        &#x5b;'Bold','Italic','Underline','Strike','-','Subscript','Superscript'&#x5d;
    &#x5d;;
}
// テーマ毎に表示するボタンを変更する
if (CKEditorBlogThemeID = 'professional_blog') {
    config.toolbar = &#x5b;
        &#x5b;'Bold','Italic','Underline','Strike','-','Subscript','Superscript'&#x5d;
    &#x5d;;
}
// ブログ記事の編集の場合だけ設定を変更する
if (CKEditorObjectType = 'entry') {
	// Editing entry.
}
// ページの編集の場合だけ設定を変更する
if (CKEditorObjectType = 'page') {
	// Editing page.
}
__EOC__


	'12 Pixels/12px;Big/2.3em;30 Percent More/130%;Bigger/larger;Very Small/x-small' => '80%/80%;90%/90%;100%/100%;110%/110%;120%/120%;130%/130%;140%/140%;150%/150%;160%/160%;170%/170%;180%/180%;190%/190%;200%/200%',
	'Arial/Arial, Helvetica, sans-serif;Times New Roman/Times New Roman, Times, serif;Verdana' => <<__EOC__,
MSゴシック/MS Gothic, Osaka-Mono, monospace
MS Pゴシック/MS PGothic, Osaka, sans-serif
MS UI Gothic/MS UI Gothic, Meiryo, Meiryo UI, Osaka, sans-serif
MS P明朝/MS PMincho, Saimincho, serif
Arial/Arial, Helvetica, sans-serif
Comic Sans MS/Comic Sans MS, cursive
Courier New/Courier New, Courier, monospace
Georgia/Georgia, serif
Lucida Sans Unicode/Lucida Sans Unicode, Lucida Grande, sans-serif
Tahoma/Tahoma, Geneva, sans-serif
Times New Roman/Times New Roman, Times, serif
Trebuchet MS/Trebuchet MS, Helvetica, sans-serif
Verdana/Verdana, Geneva, sans-serif
__EOC__
);
