old_offset = $(window).scrollTop();
function scroll() {
  if(old_offset >= 0) {// scrolling
    window.scrollBy(0,1)
    if((new_offset = $(window).scrollTop()) == old_offset) // wir sind unten
      old_offset = -500;
    else
      old_offset = new_offset
    
  } else {
    if(old_offset == -200) {
      window.scrollTo(0, 0)
    }
    old_offset++;
  }
}
window.setInterval(scroll, 2)