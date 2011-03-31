(function() {

var html5elements = [
	{
		element : 'time',
		label: 'Time',
		attributes : { }
	}
];

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
