//
// 全体の設定
//
// insやdelをブラウザで意図通りに表示させるためにDTDの調整が必要
CKEDITOR.dtd.del = CKEDITOR.dtd.strike;
CKEDITOR.dtd.ins = CKEDITOR.dtd.u;


//
// インスタンス毎の設定
//
CKEDITOR.on('instanceCreated', function(obj) {
	var config = obj.editor.config;

	// Enterを押した場合に<p>を作成する
	config.enterMode = CKEDITOR.ENTER_P;
	// Shift+Enterを押した場合に<br />を挿入する
	config.shiftEnterMode = CKEDITOR.ENTER_BR;

	config.fontSize_sizes='80%/80%;90%/90%;100%/100%;110%/110%;120%/120%;130%/130%;140%/140%;150%/150%;160%/160%;170%/170%;180%/180%;190%/190%;200%/200%';
	config.font_names='MSゴシック/MS Gothic, Osaka-Mono, monospace; MS Pゴシック/MS PGothic, Osaka, sans-serif; MS UI Gothic/MS UI Gothic, Meiryo, Meiryo UI, Osaka, sans-serif; MS P明朝/MS PMincho, Saimincho, serif; Arial/Arial, Helvetica, sans-serif;Comic Sans MS/Comic Sans MS, cursive;Courier New/Courier New, Courier, monospace;Georgia/Georgia, serif;Lucida Sans Unicode/Lucida Sans Unicode, Lucida Grande, sans-serif;Tahoma/Tahoma, Geneva, sans-serif;Times New Roman/Times New Roman, Times, serif;Trebuchet MS/Trebuchet MS, Helvetica, sans-serif;Verdana/Verdana, Geneva, sans-serif';

	// 「下線」ボタンで「ins」要素を挿入する
	config.coreStyles_underline = { element : 'ins' };
	// 「打ち消し」ボタンで「del」要素を挿入する
	config.coreStyles_strike = { element : 'del' };

	// デフォルトでスペルチェック(SCAYT) を無効にする
	config.scayt_autoStartup = false;
});
