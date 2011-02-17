CKEDITOR.config.skin = 'movabletype';
CKEDITOR.config.resize_minWidth = 500;
if (CKEditorMTVersion < 5) {
	CKEDITOR.config.resize_dir = 'vertical';
}
CKEDITOR.config.templates = 'movabletype';
CKEDITOR.config.templates_files = [
	StaticURI + '/plugins/CKEditor/template/config.js'
];
CKEDITOR.config.stylesCombo_stylesSet = 'movabletype:' + StaticURI + '/plugins/CKEditor/style/config.js';
CKEDITOR.config.baseFloatZIndex = 3000;
