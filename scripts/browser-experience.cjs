/* Browser UI smoke test for actual experience HTML; game data is solved from public clues. */
const assert=require('node:assert/strict');
const path=require('node:path');
const { pathToFileURL }=require('node:url');
const { chromium }=require('playwright-core');
function solve(p) {
  const n=p.rows.length,names=[...new Set(p.regions.join(''))].sort();
  const domain=names.map(name=>{
    const cells=[];for(let r=0;r<n;r++)for(let c=0;c<n;c++)if(p.regions[r][c]===name)cells.push([r,c]);
    const rows=[...new Set(cells.map(([r])=>r))].sort((a,b)=>a-b);
    return Array.from({length:rows.length+1},(_,i)=>cells.filter(([r])=>rows.indexOf(r)>=i));
  });
  const solutions=[];
  function rec(i,seen,rs,cs){
    if(i===domain.length){
      if(rs.every((v,r)=>v===p.rows[r])&&cs.every((v,c)=>v===p.cols[c]))solutions.push(new Set(seen));
      return;
    }
    for(const wet of domain[i]){
      const a=rs.slice(),b=cs.slice();
      for(const [r,c] of wet){a[r]++;b[c]++;}
      if(a.some((v,r)=>v>p.rows[r])||b.some((v,c)=>v>p.cols[c]))continue;
      rec(i+1,[...seen,...wet.map(([r,c])=>r*n+c)],a,b);
    }
  }
  rec(0,[],Array(n).fill(0),Array(n).fill(0));
  assert.equal(solutions.length,1,p.id+' not unique');
  return solutions[0];
}
(async()=>{
 const browser=await chromium.launch({headless:true,channel:'chrome',args:['--no-sandbox']});
 const page=await browser.newPage({viewport:{width:375,height:820},isMobile:true,hasTouch:true});
 const errors=[];page.on('pageerror',e=>errors.push(String(e)));
 const html=path.resolve(__dirname,'../prototype/experience/index.html');
 await page.goto(pathToFileURL(html).href);
 const exercises=await page.evaluate(()=>window.__pukupukuTest.exercises);
 assert.equal(exercises.length,9);
 for(let index=0;index<exercises.length;index++){
  const p=exercises[index],solution=solve(p),n=p.rows.length;
  const cells=page.locator('.cell');
  assert.equal(await cells.count(),n*n);
  if(index===0){
   await page.locator('#hintBtn').click();
   assert.match(await page.locator('#hint').innerText(),/見る場所/);
   await page.locator('#hintBtn').click();
   assert.match(await page.locator('#hint').innerText(),/理由/);
   await page.locator('#hintBtn').click();
   assert.match(await page.locator('#hint').innerText(),/結論/);
   await page.locator('#dry').click();await cells.nth(0).click();
   await page.locator('#undo').click();
   assert.match(await cells.nth(0).innerText(),/·/);
  }
  for(const width of [320,375,402]){
   await page.setViewportSize({width,height:820});
   const scroll=await page.evaluate(()=>document.documentElement.scrollWidth);
   assert.ok(scroll<=width+1,'horizontal overflow: '+p.id+' '+width+' '+scroll);
  }
  for(let k=0;k<n*n;k++){
   await page.locator(solution.has(k)?'#water':'#dry').click();
   await cells.nth(k).click();
  }
  assert.match(await page.locator('#status').innerText(),/クリア/,p.id);
  if(index===7){
   const names=await page.locator('#choice button').allInnerTexts();
   assert.deepEqual(names,['もう1問','今日はここまで']);
  }
  if(index<8)await page.locator('#continue').click();
  console.log('BROWSER PASS',p.id,n+'x'+n);
 }
 assert.equal(await page.locator('#finish').isVisible(),true);
 assert.deepEqual(errors,[]);
 await page.reload();
 assert.match(await page.locator('#status').innerText(),/クリア/);
 await browser.close();
 console.log('PASS: nine puzzles, hints, undo, save/reload, optional sixth, widths 320/375/402');
})().catch(error=>{console.error(error);process.exit(1)});
