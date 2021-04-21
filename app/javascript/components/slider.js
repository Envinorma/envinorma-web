import Glide from '@glidejs/glide'

document.addEventListener("DOMContentLoaded", function () {
  if (document.querySelector('.glide') != null) {
    const leftArrowClasses = document.querySelector('.glide__arrow--left').classList;
    const rightArrowClasses = document.querySelector('.glide__arrow--right').classList;

    var numberOfArretes = document.querySelectorAll('.glide__slide').length
    var slidesPerView =  4
    var peekBefore = 0
    var peekAfter = 100

    if (numberOfArretes <= 4) {
      slidesPerView = numberOfArretes;
      rightArrowClasses.add('invisible');

      peekAfter = 0
    }

    leftArrowClasses.add('invisible');

    const glide = new Glide('.glide', {
      type: 'slider',
      startAt: 0,
      perView: slidesPerView,
      rewind: false,
      peek: { before: peekBefore, after: peekAfter }
    });

    glide.on('run.after', function(){
      const currentSlideIndex = glide.index;
      if(currentSlideIndex == 0 ) {
        leftArrowClasses.add('invisible')
      } else {
        leftArrowClasses.remove('invisible')
      }

      if(currentSlideIndex == (numberOfArretes - Math.trunc(glide.settings.perView)) ) {
        rightArrowClasses.add('invisible')
      } else {
        rightArrowClasses.remove('invisible')
      }
    });

    glide.mount();
  }
});
