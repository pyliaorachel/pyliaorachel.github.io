$(document).ready(function(){
	// cv
	$('.cv .description').hide();
	$('.cv .cv-circle').click(function(){
		$('.cv .cv-circle').toggleClass('isClosed');
		if ($('.cv .cv-circle').hasClass('isClosed')) {
			$('.cv .description').slideUp('slow');
			$('.cv .title-text').slideDown('slow');
		} else {
			$('.cv .description').slideDown('slow');
			$('.cv .title-text').slideUp('slow');
		}
	});
});