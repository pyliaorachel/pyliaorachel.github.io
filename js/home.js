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
	$('[data-toggle="popover"]').popover();

	$('.cv .timeline-description .back-side').addClass('isHidden');
	$('.cv .timeline-description .front-side').addClass('isShown');
	$('.cv .timeline-description').addClass('isFront');
	$('.cv .timeline-circle').click(function(){
		const desc = $(this).closest('.timeline-block').find('.timeline-description');
		const backSide = desc.find('.back-side');
		const frontSide = desc.find('.front-side');

		desc.toggleClass('isFront isBack');
		backSide.toggleClass('isShown isHidden');
		frontSide.toggleClass('isHidden isShown');

	});
});