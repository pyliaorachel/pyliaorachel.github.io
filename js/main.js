$(document).ready(function(){
	// header
	$('#nav-links>li').click(function(){
		$('#nav-links>li.active').removeClass('active');
		$(this).addClass('active');
	});
});