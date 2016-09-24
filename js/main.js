$(document).ready(function(){
	var path = window.location.pathname.split('/')[1];
	if (path == '')
		path = 'home';
	const activeNavElementStr = '.nav-' + path;
	$(activeNavElementStr).addClass('active');

	// header
	$('#nav-links>li').click(function(){
		$('#nav-links>li.active').removeClass('active');
		$(this).addClass('active');
	});
});