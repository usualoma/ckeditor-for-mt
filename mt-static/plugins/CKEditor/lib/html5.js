(function() {

var html5elements = [
	{
		element : 'time',
		label: 'Time',
		attributes : { }
	}
];

var overrided_style_class = false;
function override_style_class() {
	if (overrided_style_class) {
		return;
	}
	overrided_style_class = true;

	var blockElements	= {section:1,header:1,footer:1,nav:1,article:1,aside:1,figure:1,dialog:1,hgroup:1,time:1,meter:1,menu:1,command:1,keygen:1,output:1,progress:1,details:1,datagrid:1,datalist:1};
	var objectElements	= {audio:1,video:1};
	var original_style_class = CKEDITOR.style;
	CKEDITOR.style = function() {
		original_style_class.apply(this, arguments);
		if (blockElements[this.element]) {
			this.type = CKEDITOR.STYLE_BLOCK;
		}
		else if (objectElements[this.element]) {
			this.type = CKEDITOR.STYLE_OBJECT;
		}
	}
	CKEDITOR.style.prototype    = original_style_class.prototype;
	CKEDITOR.style.getStyleText = original_style_class.getStyleText;
}

CKEDITOR.on('instanceCreated', function(obj) {
	var config = obj.editor.config;

	if (! config.format_tags) {
		config['format_tags'] = 'p;h1;h2;h3;h4;h5;h6;pre;address;div';
	}
	for (var i = 0, len = html5elements.length; i < len; i++) {
		var element = html5elements[i];
		var tag = element['tag'] || element['element'];
		config['format_tags'] += ';' + tag;
		config['format_' + tag] = element;
	}

	override_style_class();
});

CKEDITOR.on('instanceReady', function(obj) {
	var f = obj.editor.lang.format;
	for (var i = 0, len = html5elements.length; i < len; i++) {
		var element = html5elements[i];
		var tag = element['tag'] || element['element'];
		var key = 'tag_' + tag;
		if (! f[key]) {
			f[key] = element['label'];
		}
	}
});

})();
