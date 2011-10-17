old_offset = -600;
resume_timer = null;
scroll_interval = null;

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

window.onmousemove = function() {
  if(scroll_interval) {
    window.clearInterval(scroll_interval)
    scroll_interval = null;
  }
  if(!resume_timer)
    resume_timer = window.setTimeout(start, 10000)
}

function start() {
  resume_timer = null;
  if(!scroll_interval)
    scroll_interval = window.setInterval(scroll, 2)
}

//window.setTimeout(start, 10000)