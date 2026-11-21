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

  // ---- note 007: the missing fundamental ----
  var a7=document.getElementById('note-007-art');
  if ('$lang'==='de') a7.querySelector('[data-set-lang="de"]').click();
  var c7=document.getElementById('toneCanvas');
  chk('007 canvas sized', c7.width>400 && c7.height>200);
  var d7=c7.getContext('2d').getImageData(0,0,c7.width,c7.height).data;
  var p7=0; for(var i7=3;i7<d7.length;i7+=4) if(d7[i7]!==0) p7++;
  chk('007 instrument paints', p7>5000);
  chk('007 lang hook is a function', typeof window.__toneSetLang==='function');
  chk('007 article lang follows switch', a7.getAttribute('lang')==='$lang');
  var v7=[].slice.call(a7.querySelectorAll('[data-lang]')).filter(function(e){return !e.hasAttribute('hidden');});
  chk('007 only one language visible', v7.every(function(e){return e.getAttribute('data-lang')==='$lang';}));
  chk('007 exactly one drop cap per language', ['en','de'].every(function(L){
        return a7.querySelectorAll('.body > div[data-lang="'+L+'"] p.open').length===1; }));
  chk('007 kicker declares english', a7.querySelector('.kicker').getAttribute('lang')==='en');
  chk('toc lists note 007', !!document.querySelector('.toc a[href="#note-007"]'));
  chk('007 labels localised', document.getElementById('toneLblHarm').textContent===('$lang'==='de'?'Teiltöne':'harmonics'));
  chk('007 chip names localised', document.getElementById('toneH1').getAttribute('aria-label').indexOf('$lang'==='de'?'Teilton 1':'harmonic 1')===0);
  // Sound must never start by itself: a second after load, nobody has pressed anything.
  var pb=document.getElementById('tonePlay');
  chk('007 silent until pressed', pb.getAttribute('aria-pressed')==='false');
  var lo=function(){return document.getElementById('toneLow').textContent;};
  var rp=function(){return document.getElementById('toneRep').textContent;};
  var h=function(k){document.getElementById('toneH'+k).click();};
  chk('007 full tone reads 200/200', lo()==='200 Hz' && rp()==='200 Hz');
  h(1);
  chk('007 without x1 lowest 400 repeats 200', lo()==='400 Hz' && rp()==='200 Hz'
      && document.getElementById('toneH1').getAttribute('aria-pressed')==='false');
  h(3); h(5); h(7); h(8);   // leaves 2, 4, 6
  chk('007 x2 x4 x6 repeats at 400', lo()==='400 Hz' && rp()==='400 Hz');
  h(1); h(3); h(5); h(7); h(8);
  chk('007 restored to full tone', lo()==='200 Hz' && rp()==='200 Hz');
  pb.click();
  chk('007 listen button toggles and relabels', pb.getAttribute('aria-pressed')==='true'
      && pb.textContent===('$lang'==='de'?'stopp':'stop'));
  pb.click();
  chk('007 stop returns to listen', pb.getAttribute('aria-pressed')==='false'
      && pb.textContent===('$lang'==='de'?'anhören':'listen'));

  // Every note is wired exactly once. A duplicated block (a splice run twice) re-wires the
  // same handlers silently and passes every other check; this is the only place it shows.
  // The needle is assembled at runtime, or the probe would count its own source.
  var scriptSrc=[].slice.call(document.scripts).map(function(s){return s.textContent;}).join('\n');
  chk('every note wired exactly once', ['001','002','003','004','005','006','007','008','009','010'].every(function(n){
        return scriptSrc.split('wire("note '+n+'"').length-1===1; }));

  // ---- note 008: a day away ----
  var a8=document.getElementById('note-008-art');
  if ('$lang'==='de') a8.querySelector('[data-set-lang="de"]').click();
  var c8=document.getElementById('dayCanvas');
  chk('008 canvas sized', c8.width>400 && c8.height>200);
  var d8=c8.getContext('2d').getImageData(0,0,c8.width,c8.height).data;
  var p8=0; for(var i8=3;i8<d8.length;i8+=4) if(d8[i8]!==0) p8++;
  chk('008 instrument paints', p8>3000);
  chk('008 lang hook is a function', typeof window.__daySetLang==='function');
  chk('008 article lang follows switch', a8.getAttribute('lang')==='$lang');
  var v8=[].slice.call(a8.querySelectorAll('[data-lang]')).filter(function(e){return !e.hasAttribute('hidden');});
  chk('008 only one language visible', v8.every(function(e){return e.getAttribute('data-lang')==='$lang';}));
  chk('008 exactly one drop cap per language', ['en','de'].every(function(L){
        return a8.querySelectorAll('.body > div[data-lang="'+L+'"] p.open').length===1; }));
  chk('008 kicker declares english', a8.querySelector('.kicker').getAttribute('lang')==='en');
  chk('toc lists note 008', !!document.querySelector('.toc a[href="#note-008"]'));
  chk('008 labels localised', document.getElementById('dayLblWhen').textContent===('$lang'==='de'?'wann':'when'));
  chk('008 chip names localised', document.getElementById('dayGeoX').getAttribute('aria-label').indexOf('$lang'==='de'?'18. November':'18 November')===0);
  chk('008 no scaffolding left', !/Scaffold|Gerüst|CAPTION-|pending research/.test(a8.textContent));
  chk('008 starts live', document.getElementById('dayNow').getAttribute('aria-pressed')==='true');
  // The ephemeris against JPL Horizons values it was never fitted to (noon UTC, quantity 21).
  var sl=document.getElementById('daySlider');
  var dn=function(){return document.getElementById('dayDown').textContent;};
  var gt=function(id){return document.getElementById(id).textContent;};
  var at=function(i){ sl.value=String(i); sl.dispatchEvent(new Event('input')); };
  at(4545);  chk('008 1990-02-14 reads 5 h 36 min 35 s', dn()==='5 h 36 min 35 s');
  at(12773); chk('008 2012-08-25 reads 16 h 49 min 53 s', dn()==='16 h 49 min 53 s');
  at(16871); chk('008 2023-11-14 reads 22 h 30 min 34 s', dn()==='22 h 30 min 34 s');
  at(24741); chk('008 2045-06-01 reads 32 h 54 min 25 s', dn()==='32 h 54 min 25 s');
  chk('008 slider releases the live chip', document.getElementById('dayNow').getAttribute('aria-pressed')==='false');
  // The three crossings: each chip must land its own readout on exactly one day, and only that one.
  var ex=function(id){return document.getElementById(id).classList.contains('exact');};
  document.getElementById('dayUpX').click();
  chk('008 17 nov — a signal sent needs 24 h exactly', gt('dayUp')==='24 h 00 min 00 s' && ex('dayUp') && !ex('dayDown'));
  document.getElementById('dayGeoX').click();
  chk('008 18 nov — distance now is 24 h exactly', gt('dayGeo').indexOf('24 h 00 min 00 s')===0 && ex('dayGeo'));
  chk('008 chips follow the choice', document.getElementById('dayGeoX').getAttribute('aria-pressed')==='true'
      && document.getElementById('dayNow').getAttribute('aria-pressed')==='false'
      && document.getElementById('dayUpX').getAttribute('aria-pressed')==='false');
  chk('008 18 nov — the prose\'s 23 h 59 min 55 s and 24 h 00 min 05 s', gt('dayDown')==='23 h 59 min 55 s' && gt('dayUp')==='24 h 00 min 05 s');
  document.getElementById('dayDownX').click();
  chk('008 19 nov — light arriving has travelled 24 h exactly', dn()==='24 h 00 min 00 s' && ex('dayDown') && !ex('dayUp'));
  document.getElementById('dayApr').click();
  chk('008 apr 2027 comes back to 24 h 01 min 24 s', dn()==='24 h 01 min 24 s');
  document.getElementById('dayNow').click();
  chk('008 now chip returns to live', document.getElementById('dayNow').getAttribute('aria-pressed')==='true'
      && document.getElementById('dayApr').getAttribute('aria-pressed')==='false');

  // 008's postscript (2026-11-20): dated, after the closing section, in the visible language only.
  var psv=document.getElementById('day-after-$lang'), pso=document.getElementById('day-after-'+('$lang'==='en'?'de':'en'));
  var cl8=[].slice.call(a8.querySelectorAll('h3')).filter(function(h){
        return /Nothing happens out there|Dort draußen passiert nichts/.test(h.textContent) && !h.closest('[hidden]'); })[0];
  chk('008 postscript visible in its language only', !!psv && !!pso && a8.contains(psv) && a8.contains(pso)
      && !psv.closest('[hidden]') && !!pso.closest('[hidden]'));
  chk('008 postscript follows the closing section', !!cl8 && !!psv
      && !!(cl8.compareDocumentPosition(psv) & Node.DOCUMENT_POSITION_FOLLOWING));
  chk('008 postscript dated', !!psv && psv.nextElementSibling.textContent===('$lang'==='de'?'20. November 2026':'Added 20 November 2026'));
  chk('008 kicker names the postscript', /postscript 20 nov 2026/.test(a8.querySelector('.kicker').textContent));
  // ---- note 009: the mouse-to-elephant curve ----
  var a9=document.getElementById('note-009-art');
  if ('$lang'==='de') a9.querySelector('[data-set-lang="de"]').click();
  var c9=document.getElementById('bmrCanvas');
  chk('009 canvas sized', c9.width>400 && c9.height>200);
  var px9=function(){ var d=c9.getContext('2d').getImageData(0,0,c9.width,c9.height).data, n=0;
        for(var i=3;i<d.length;i+=4) if(d[i]!==0) n++; return n; };
  chk('009 instrument paints', px9()>5000);
  chk('009 lang hook is a function', typeof window.__bmrSetLang==='function');
  chk('009 article lang follows switch', a9.getAttribute('lang')==='$lang');
  var v9=[].slice.call(a9.querySelectorAll('[data-lang]')).filter(function(e){return !e.hasAttribute('hidden');});
  chk('009 only one language visible', v9.every(function(e){return e.getAttribute('data-lang')==='$lang';}));
  chk('009 exactly one drop cap per language', ['en','de'].every(function(L){
        return a9.querySelectorAll('.body > div[data-lang="'+L+'"] p.open').length===1; }));
  chk('009 kicker declares english', a9.querySelector('.kicker').getAttribute('lang')==='en');
  chk('toc lists note 009', !!document.querySelector('.toc a[href="#note-009"]'));
  chk('009 labels localised', document.getElementById('bmrLblWho').textContent===('$lang'==='de'?'Tiere':'animals'));
  chk('009 chip names localised', document.getElementById('bmrLarge').getAttribute('aria-label').indexOf('$lang'==='de'?'nur die Arten ab':'only the species of one')===0);
  // The figures below are least-squares fits to the 626 species of Savage et al. 2004, computed
  // independently from the published table (Python, 2026-11-20). The prose quotes them, so each
  // is checked twice: the instrument must compute it, and the visible prose must say it.
  var g9=function(id){return document.getElementById(id).textContent;};
  var L9=function(v){return '$lang'==='de'? v.replace(/\./g,','): v;};
  var prose9=''; [].slice.call(a9.querySelectorAll('.body > div[data-lang="$lang"]')).forEach(function(d){ prose9+=d.textContent; });
  chk('009 opens on all 626 at 3/4', g9('bmrN')==='626' && g9('bmrDrawn')==='3/4'
      && document.getElementById('bmrThreeQuarters').getAttribute('aria-pressed')==='true');
  chk('009 all 626 fit 0.71 ± 0.01', g9('bmrFit')===L9('0.71 ± 0.01'));
  chk('009 all 626 miss 1.50 at 3/4', g9('bmrMiss')===L9('×1.50'));
  document.getElementById('bmrTwoThirds').click();
  chk('009 all 626 miss 1.50 at 2/3', g9('bmrDrawn')==='2/3' && g9('bmrMiss')===L9('×1.50'));
  document.getElementById('bmrBest').click();
  chk('009 all 626 miss 1.48 at best fit', g9('bmrMiss')===L9('×1.48'));
  document.getElementById('bmrSmall').click();
  chk('009 under 1 kg 477 fit 0.66 ± 0.02', g9('bmrN')==='477' && g9('bmrFit')===L9('0.66 ± 0.02'));
  document.getElementById('bmrLarge').click();
  chk('009 over 1 kg 149 fit 0.84 ± 0.04', g9('bmrN')==='149' && g9('bmrFit')===L9('0.84 ± 0.04'));
  chk('009 best fit follows the animals', g9('bmrDrawn')===L9('0.836'));
  document.getElementById('bmrPerKg').click();
  chk('009 per kilogram repaints, readouts unchanged', px9()>5000 && g9('bmrFit')===L9('0.84 ± 0.04'));
  var sl9=document.getElementById('bmrSlider'); sl9.value='0.9'; sl9.dispatchEvent(new Event('input'));
  chk('009 slider sets the line and releases the chips', g9('bmrDrawn')===L9('0.900')
      && ['bmrTwoThirds','bmrThreeQuarters','bmrBest'].every(function(id){return document.getElementById(id).getAttribute('aria-pressed')==='false';}));
  document.getElementById('bmrAll').click(); document.getElementById('bmrPerAnimal').click(); document.getElementById('bmrThreeQuarters').click();
  chk('009 prose quotes the instrument', ['0.71','0.66','0.84','1.48','1.50','626','477','149','0.836','0.834'].every(function(v){
        return prose9.indexOf(L9(v))>=0 || a9.querySelector('.sources div[data-lang="$lang"]').textContent.indexOf(L9(v))>=0; }));
  chk('009 no scaffolding left', !/INTERACTIVE|@@M[XY]@@|<!--/.test(a9.textContent));

  // ---- note 010: the next tram ----
  // The readouts are computed from Terada's 38 tram times (1922); the prose quotes them.
  try {
  var a10=document.getElementById('note-010-art');
  if ('$lang'==='de') a10.querySelector('[data-set-lang="de"]').click();
  var c10=document.getElementById('tramCanvas');
  function px10(){ var d=c10.getContext('2d').getImageData(0,0,c10.width,c10.height).data, n=0;
    for(var i=3;i<d.length;i+=4) if(d[i]!==0) n++; return n; }
  chk('010 canvas sized', c10.width>400 && c10.height>=190);
  chk('010 instrument paints', px10()>5000);
  chk('010 lang hook is a function', typeof window.__tramSetLang==='function');
  chk('010 article lang follows switch', a10.getAttribute('lang')==='$lang');
  var v10=[].slice.call(a10.querySelectorAll('[data-lang]')).filter(function(e){return !e.hasAttribute('hidden');});
  chk('010 only one language visible', v10.every(function(e){return e.getAttribute('data-lang')==='$lang';}));
  chk('010 exactly one drop cap per language', ['en','de'].every(function(L){
        return a10.querySelectorAll('.body > div[data-lang="'+L+'"] p.open').length===1; }));
  chk('010 kicker declares english', a10.querySelector('.kicker').getAttribute('lang')==='en');
  chk('toc lists note 010', !!document.querySelector('.toc a[href="#note-010"]'));
  chk('010 labels localised', document.getElementById('tramLblTrams').textContent===('$lang'==='de'?'Bahnen':'trams'));
  chk('010 control names localised', document.getElementById('tramDrop').getAttribute('aria-label').indexOf('$lang'==='de'?'ein Fahrgast kommt':'a passenger arrives')===0
      && document.getElementById('tramCanvas').getAttribute('aria-label').indexOf('$lang'==='de'?'Zwei Reihen':'Two rows')===0);
  function g10(id){ return document.getElementById(id).textContent; }
  function L10(v){ return '$lang'==='de' ? v.replace('.',',') : v; }
  function r10(gap,met,wait,ratio){ return g10('tramGap')===gap && g10('tramMet')===met && g10('tramWait')===wait && g10('tramRatio')===L10(ratio); }
  chk('010 opens on 1922 with 2m05 3m10 1m35 x1.52', document.getElementById('tram1922').getAttribute('aria-pressed')==='true'
      && r10('2 min 5 s','3 min 10 s','1 min 35 s','×1.52'));
  document.getElementById('tramTimetable').click();
  chk('010 timetable gives 2m05 2m05 1m03 x1.00', r10('2 min 5 s','2 min 5 s','1 min 3 s','×1.00'));
  document.getElementById('tramRandom').click();
  chk('010 random gives 2m05 4m10 2m05 x2.00', r10('2 min 5 s','4 min 10 s','2 min 5 s','×2.00'));
  document.getElementById('tram1922').click();
  for (var k10=0;k10<6;k10++) document.getElementById('tramDrop').click();
  chk('010 passengers leave the readouts alone', r10('2 min 5 s','3 min 10 s','1 min 35 s','×1.52') && px10()>5000);
  var prose10=''; [].slice.call(a10.querySelectorAll('.body > div[data-lang="$lang"]')).forEach(function(dv){ prose10+=dv.textContent; });
  var need10 = '$lang'==='de'
    ? ['2 Minuten 5 Sekunden','3 Minuten 10','63 Sekunden','sondern 95','42 Sekunden','106','167','171','sechsunddreißig','einundzwanzig','sieben Minuten','40,5','65,8','147','anderthalbmal']
    : ['2 minutes 5 seconds','3 minutes 10','63 seconds','but 95','42 seconds','106','167','171','thirty-six','twenty-one','seven minutes','40.5','65.8','147','one and a half times'];
  chk('010 prose quotes the instrument', need10.every(function(v){ return prose10.indexOf(v)>=0; }));
  chk('010 no sibling miscount in prose', prose10.indexOf('siblings')<0 && prose10.indexOf('Geschwister')<0);
  chk('010 translator named rightly', a10.textContent.indexOf('Takayuki Hiraoka')>0 && a10.textContent.indexOf('Takehisa')<0);
  chk('010 no scaffolding left', !/INTERACTIVE|<!--|\*\*/.test(a10.textContent));
  } catch (e10) { chk('010 section threw - '+String(e10.message).replace(/:/g,' '), false); }

  // A markdown rule spliced in as prose shows up on the page as a literal "---" (008 carried two, 2026-11-14 to -20).
  chk('no stray markdown rule in any note', [].slice.call(document.querySelectorAll('main article.note p')).every(function(p){
        return p.textContent.trim()!=='---'; }));

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
