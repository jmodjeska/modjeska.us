function external_links_in_new_windows_loop() {
  if (!document.links) { document.links = document.getElementsByTagName('a'); }
  var change_link = false;
  var force = '';
  var ignore = '';
  for (var t=0; t<document.links.length; t++) {
    var all_links = document.links[t];
    change_link = false;
    if(document.links[t].hasAttribute('onClick') == false) {
      if(all_links.href.search(/^http/) != -1 && all_links.href.search('modjeska.us') == -1 && all_links.href.search(/^#/) == -1) { change_link = true; }
      if(force != '' && all_links.href.search(force) != -1) { change_link = true; }
      if(ignore != '' && all_links.href.search(ignore) != -1) { change_link = false; }
      if(change_link == true) {
        document.links[t].setAttribute('onClick', 'javascript:window.open(\'' + all_links.href.replace(/'/g, '') + '\', \'_blank\', \'noopener\'); return false;');
        document.links[t].removeAttribute('target');
      }
    }
  }
}
function external_links_in_new_windows_load(func)
{
  var oldonload = window.onload;
  if (typeof window.onload != 'function'){ window.onload = func; } else {
    window.onload = function(){
      oldonload();
      func();
    }
  }
}
external_links_in_new_windows_load(external_links_in_new_windows_loop);
