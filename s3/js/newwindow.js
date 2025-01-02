function external_links_in_new_windows_loop() {
  if (!document.links) {
    document.links = document.getElementsByTagName('a');
  }
  var change_link = false;
  var force = '';
  var ignore = '';

  for (var t=0; t<document.links.length; t++) {
    var all_links = document.links[t];
    change_link = false;

    if(document.links[t].hasAttribute('onClick') == false) {
      // forced if the address starts with http (or also https), but does not link to the current domain
      if(all_links.href.search(/^http/) != -1 && all_links.href.search('modjeska.us') == -1 && all_links.href.search(/^#/) == -1) {
        // console.log('Changed ' + all_links.href);
        change_link = true;
      }

      if(force != '' && all_links.href.search(force) != -1) {
        // forced
        // console.log('force ' + all_links.href);
        change_link = true;
      }

      if(ignore != '' && all_links.href.search(ignore) != -1) {
        // console.log('ignore ' + all_links.href);
        // ignored
        change_link = false;
      }

      if(change_link == true) {
        // console.log('Changed ' + all_links.href);
        document.links[t].setAttribute('onClick', 'javascript:window.open(\'' + all_links.href.replace(/'/g, '') + '\', \'_blank\', \'noopener\'); return false;');
        document.links[t].removeAttribute('target');
      }
    }
  }
}

// Load
function external_links_in_new_windows_load(func)
{
  var oldonload = window.onload;
  if (typeof window.onload != 'function'){
    window.onload = func;
  } else {
    window.onload = function(){
      oldonload();
      func();
    }
  }
}

external_links_in_new_windows_load(external_links_in_new_windows_loop);
