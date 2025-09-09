/* Lightweight debug panel for PowerChart (console may be disabled) */
(function () {
  // Enable when: ?debug=1, #debug, data-debug="1" on this script tag, window.MP_DEBUG === true, or localStorage flag.
  var scriptEl = document.currentScript || (function(){
    var s=document.getElementsByTagName('script'); return s[s.length-1];
  })();

  function hasParam(re){ return re.test(location.search); }
  function hasHash(re){ return re.test(location.hash); }

  var enabled =
      hasParam(/\bdebug=1\b/i) ||
      hasHash(/#debug\b/i) ||
      (scriptEl && scriptEl.getAttribute('data-debug') === '1') ||
      (typeof window.MP_DEBUG !== 'undefined' && window.MP_DEBUG === true) ||
      localStorage.getItem('mpage_debug') === '1';

  // Build panel
  var panel = document.createElement('div');
  panel.id = 'mp-debug';
  panel.innerHTML =
    '<header><b>MPage Debug</b>' +
    '<div><button id="mpd-clear" title="Clear">Clear</button> ' +
    '<button id="mpd-hide" title="Hide">Hide</button></div></header>' +
    '<pre id="mp-debug-pre"></pre>';
  document.addEventListener('DOMContentLoaded', function(){ document.body.appendChild(panel); if(enabled) show(); });
  var out; function cache(){ out = out || document.getElementById('mp-debug-pre'); return out; }

  function show(){ panel.style.display='block'; }
  function hide(){ panel.style.display='none'; }
  function ts(){ var d=new Date(); return d.toISOString().replace('T',' ').replace('Z',''); }
  function safe(x){ try { return typeof x === 'string' ? x : JSON.stringify(x, null, 2); } catch(e){ return String(x); } }
  function write(prefix,args,isErr){
    var pre = cache(); if(!pre) return;
    var line = "["+ts()+"] "+prefix+" "+Array.prototype.map.call(args, safe).join(" ");
    pre.textContent += line + "\n";
    pre.scrollTop = pre.scrollHeight;
  }

  // Public API
  window.debug = {
    on:  function(){ localStorage.setItem('mpage_debug','1'); enabled=true; show(); },
    off: function(){ localStorage.removeItem('mpage_debug'); enabled=false; hide(); },
    clear:function(){ var pre=cache(); if(pre) pre.textContent=''; },
    log: function(){ if(enabled){ show(); write('LOG ', arguments, false); } },
    info:function(){ if(enabled){ show(); write('INFO', arguments, false); } },
    warn:function(){ if(enabled){ show(); write('WARN', arguments, false); } },
    error:function(){ if(enabled){ show(); write('ERR ', arguments, true ); } },
    json:function(label,obj){ if(enabled){ show(); write('JSON', [label, obj], false); } }
  };

  // Wire buttons after DOM ready
  document.addEventListener('DOMContentLoaded', function(){
    var btnH = document.getElementById('mpd-hide');
    var btnC = document.getElementById('mpd-clear');
    if(btnH) btnH.onclick = function(){ window.debug.off(); };
    if(btnC) btnC.onclick = function(){ window.debug.clear(); };
  });

  // Keyboard toggle Ctrl+Alt+D
  document.addEventListener('keydown', function(ev){
    if(ev.ctrlKey && ev.altKey && (ev.key==='d' || ev.key==='D')){
      enabled ? window.debug.off() : window.debug.on();
    }
  });

  // Mirror runtime errors into panel (without breaking host)
  window.addEventListener('error', function(e){
    window.debug.error('Uncaught', e.message, 'at', e.filename+':'+e.lineno+':'+e.colno);
  });

  // Mirror console.* if present; don’t crash if PowerChart stubs it
  var c = window.console || {};
  ['log','info','warn','error'].forEach(function(m){
    var orig = c[m] || function(){};
    window.console = window.console || {};
    window.console[m] = function(){
      try { if(enabled) window.debug[m].apply(null, arguments); } catch(_) {}
      try { orig.apply(c, arguments); } catch(_) {}
    };
  });

  // Initial visibility
  if (document.readyState === 'complete' || document.readyState === 'interactive') { if(enabled) show(); }
})();