old_offset = -100;
resume_timer = null;
scroll_interval = null;
runs = 0;

function scroll() {
  if(old_offset >= 0) { // scrolling
    new_offset = old_offset + 1
    $("#container").css("top", "-"+new_offset)
    
    if(($("#container").height() - $(window).height() + 100) <= old_offset) // wir sind unten
      old_offset = -600
    else
      old_offset = new_offset
  } else { // done scrolling
    if(old_offset == -300) {
      runs++
      if(runs > 5)
        location.reload()
      $("#container").css("top", "0")
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
    resume_timer = window.setTimeout(start, 3000)
}

function start() {
  resume_timer = null;
  $("#container").css("position", "relative")
  if(!scroll_interval)
    scroll_interval = window.setInterval(scroll, 20)
}
start()