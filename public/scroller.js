old_offset = -600;

function scroll() {
  if(old_offset >= 0) {// scrolling
    window.scrollBy(0,1)
    if((new_offset = $(window).scrollTop()) == old_offset) // wir sind unten
      old_offset = -600;
    else
      old_offset = new_offset
    
  } else {
    if(old_offset == -300) {
      window.scrollTo(0, 0)
    }
    old_offset++;
  }
}
window.setInterval(scroll, 2)