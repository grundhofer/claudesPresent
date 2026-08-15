#!/bin/zsh
# Invariant probe for index.html, run in EN/DE x light/dark.
# Prints one PASS/FAIL line per check; exits non-zero if any check fails.
SP="${TMPDIR:-/tmp}/claudespresent-probe"; mkdir -p "$SP"
SRC="$(cd "$(dirname "$0")/.." && pwd)/index.html"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
fail=0

for theme in light dark; do
  for lang in en de; do
    TMP="$SP/probe-run-$theme-$lang.html"
    cp "$SRC" "$TMP"
    cat >> "$TMP" <<EOF
<script>
setTimeout(function(){
  var R=[];
  function chk(n,c){ R.push((c?"PASS":"FAIL")+" [$theme/$lang] "+n); }
  document.documentElement.setAttribute('data-theme','$theme');
  var art=document.getElementById('note-006-art');
  if ('$lang'==='de') art.querySelector('[data-set-lang="de"]').click();

  var c=document.getElementById('rotateCanvas');
  chk('canvas sized', c.width>400 && c.height>150);
  var d=c.getContext('2d').getImageData(0,0,c.width,c.height).data;
  var painted=0; for(var i=3;i<d.length;i+=4) if(d[i]!==0) painted++;
  chk('instrument paints', painted>5000);

  chk('article lang follows switch', art.getAttribute('lang')==='$lang');
  chk('lang hook is a function', typeof window.__rotateSetLang==='function');

  var vis=[].slice.call(art.querySelectorAll('[data-lang]')).filter(function(e){return !e.hasAttribute('hidden');});
  chk('only one language visible', vis.every(function(e){return e.getAttribute('data-lang')==='$lang';}));

  chk('instruct localised', document.getElementById('rotateInstruct').textContent.indexOf(
      '$lang'==='de' ? 'Präg' : 'Memorise')===0);
  document.getElementById('rotateReady').click();
  chk('pick label localised', document.getElementById('rotatePickLbl').textContent.indexOf(
      '$lang'==='de' ? 'Welche' : 'Pick')===0);
  chk('buttons are chips', ['rotateReady','rotateAbsolute','rotateRelative','rotateReset']
      .every(function(id){return document.getElementById(id).classList.contains('chip');}));

  chk('toc lists note 006', !!document.querySelector('.toc a[href="#note-006"]'));
  chk('note 006 anchor exists', !!document.getElementById('note-006'));
  chk('exactly one drop cap per language', ['en','de'].every(function(L){
        return art.querySelectorAll('.body > div[data-lang="'+L+'"] p.open').length===1; }));
  chk('kicker declares english', art.querySelector('.kicker').getAttribute('lang')==='en');
  chk('no stale "still running" text', art.textContent.indexOf('still running')<0
      && art.textContent.indexOf('läuft noch')<0);

  // The retracted claims may appear ONLY inside the "kept honest" apparatus, never in the prose.
  var prose='';
  [].slice.call(art.querySelectorAll('.body > div[data-lang]')).forEach(function(dv){ prose+=dv.textContent; });
  chk('no fabricated red wall in prose', prose.indexOf('rote Wand')<0);
  chk('no windowless-truck claim in prose', prose.indexOf('Lastwagen ohne Fenster')<0);
  chk('humboldt misquote not in prose', prose.indexOf('um die Nation, welcher')<0);
  chk('retractions are recorded somewhere', art.textContent.indexOf('rote Wand')>0);
  chk('kant 1768 present', art.textContent.indexOf('Weltgegenden')>0);
  chk('german closing quotes', !/„[^„“]{0,400}?"/.test(art.innerHTML));

  // Garden-wide typography, not just this note. The ASCII closing quote sat in
  // notes 001/002/004 for weeks precisely because the only check that would
  // have caught it was scoped to note 006. Read textContent, not innerHTML:
  // attribute values are full of ASCII quotes and would fire falsely.
  // Strip script/style before reading the page's text. document.body.textContent
  // includes the text of <script> elements — and this probe appends itself to the
  // page, so a check for a literal string would otherwise find its own needle and
  // report on itself rather than on the garden.
  var pageText = (function(){
    var c = document.body.cloneNode(true);
    [].slice.call(c.querySelectorAll('script,style')).forEach(function(n){ n.parentNode.removeChild(n); });
    return c.textContent;
  })();
  chk('german double quotes close garden-wide', !/„[^„“]{0,400}?"/.test(pageText));
  // The negative lookahead spares the apostrophe in a possessive inside a
  // quotation ("Olbers's"), which is not a closing mark.
  chk('german single quotes close garden-wide', !/‚[^‚‘]{0,200}?'(?![A-Za-zÄÖÜäöüß])/.test(pageText));

  // Note 006 was written by a guest (DeepSeek), and for nine days nothing a
  // reader could see said so. These checks exist so that can't silently recur.
  chk('guest credited in the kicker', art.querySelector('.kicker').textContent.toLowerCase().indexOf('deepseek') > 0);
  var visText = [].slice.call(art.querySelectorAll('[data-lang]'))
      .filter(function(e){ return !e.hasAttribute('hidden'); })
      .map(function(e){ return e.textContent; }).join(' ');
  chk('guest credited in the visible language', visText.indexOf('DeepSeek') > 0);
  chk('colophon no longer claims every note is Claude', pageText.indexOf('Every note is written by a fresh session') < 0);
  chk('colophon records the guest exception', pageText.indexOf('note 006 was planted by') > 0);

  document.title='PROBE::'+R.join('::');
}, 1200);
</script>
EOF
    out=$("$CHROME" --headless=new --disable-gpu --virtual-time-budget=6000 --dump-dom "file://$TMP" 2>/dev/null \
          | grep -o '<title>PROBE::[^<]*</title>' | sed 's/<title>PROBE:://; s/<\/title>//')
    if [[ -z "$out" ]]; then echo "FAIL [$theme/$lang] probe did not run"; fail=1; continue; fi
    echo "$out" | tr ':' '\n' | grep -v '^$'
    echo "$out" | grep -q FAIL && fail=1
  done
done
echo "---"
[[ $fail -eq 0 ]] && echo "ALL CHECKS PASS" || echo "SOME CHECKS FAILED"
exit $fail
