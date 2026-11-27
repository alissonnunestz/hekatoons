// ---- dados de exemplo (num site real isso viria de uma API/banco de dados) ----
const PALETTE = [['#7a2e2e','#241012'],['#2e4a6b','#101a24'],['#3c6b4a','#0f1c13'],['#6b4a2e','#1c130c']];
const DOTS = ['#ef6356','#4f8fe0','#4caf6d','#d98a3d'];
const MANGAS = [
  {id:'17-21', titulo:'17-21', genero:'Drama / Fantasia', badge:'drama', atualizado:'há 4 dias',capa:'capas/number1.jpg',
   sinopse:'A strange world where aliens have taken over the human world, and only two humans are left which are apparently disguising themselves as mere chickens.',
   capitulos:[{num:1,titulo:'O Despertar',data:'03 Jan 2026',paginas:6}]},
  {id:'jardim-eletrico', titulo:'Jardim Elétrico', genero:'Ficção Científica', badge:'Sci-fi', atualizado:'há 6 horas',
   sinopse:'Em uma cidade onde as plantas foram substituídas por circuitos vivos, um jardineiro clandestino cultiva a última semente orgânica do planeta.',
   capitulos:[{num:1,titulo:'Raiz de Cobre',data:'05 Fev 2026',paginas:5},{num:2,titulo:'Floração',data:'12 Fev 2026',paginas:6}]},
  {id:'veu-de-tinta', titulo:'Véu de Tinta', genero:'Mistério', badge:'Mistério', atualizado:'há 2 dias',
   sinopse:'Uma detetive que só enxerga pistas quando desenhadas à mão investiga uma série de crimes cometidos por alguém que apaga a própria existência dos registros.',
   capitulos:[{num:1,titulo:'Primeira Página',data:'20 Jan 2026',paginas:7},{num:2,titulo:'Borrão',data:'27 Jan 2026',paginas:6},{num:3,titulo:'Rascunho',data:'03 Fev 2026',paginas:8},{num:4,titulo:'A Folha em Branco',data:'10 Fev 2026',paginas:7}]},
  {id:'ultimo-trem', titulo:'Último Trem', genero:'Drama', badge:'Drama', atualizado:'há 1 semana',
   sinopse:'Dois irmãos afastados pela vida se reencontram no último vagão de um trem noturno que, segundo os passageiros mais antigos, nunca chega ao seu destino.',
   capitulos:[{num:1,titulo:'Plataforma 9',data:'01 Mar 2026',paginas:6},{num:2,titulo:'Vagão-Restaurante',data:'08 Mar 2026',paginas:7}]},
];
MANGAS.forEach((m,i)=>{ m.cor = PALETTE[i % PALETTE.length]; m.dot = DOTS[i % DOTS.length]; });

// ---- estado da aplicação ----
let state = { view:'library', query:'', sort:'recentes', mangaId:null, chapIndex:0, page:0 };

function setQuery(v){ state.query = v; renderLibrary(); }

function setSort(s){
  state.sort = s;
  document.querySelectorAll('.tab').forEach(t=>t.classList.toggle('active', t.dataset.sort===s));
  renderLibrary();
}
document.getElementById('tabs').addEventListener('click', e=>{
  const btn = e.target.closest('.tab'); if(btn) setSort(btn.dataset.sort);
});

function findManga(id){ return MANGAS.find(m=>m.id===id); }

// se o mangá tiver uma imagem de capa (m.capa), mostra ela; senão, usa o monograma de placeholder
function coverHTML(m){
  if(m.capa){ return `<img class="cover-img" src="${m.capa}" alt="Capa de ${m.titulo}">`; }
  return `<span class="mono">${m.titulo.charAt(0)}</span>`;
}

function showView(name){
  state.view = name;
  document.querySelectorAll('.view').forEach(v=>v.classList.remove('active'));
  document.getElementById('view-'+name).classList.add('active');
  window.scrollTo(0,0);
}

// ---- biblioteca ----
function sortedFiltered(){
  const q = state.query.trim().toLowerCase();
  let list = MANGAS.filter(m=>m.titulo.toLowerCase().includes(q));
  if(state.sort==='az') list = [...list].sort((a,b)=>a.titulo.localeCompare(b.titulo,'pt'));
  else if(state.sort==='capitulos') list = [...list].sort((a,b)=>b.capitulos.length-a.capitulos.length);
  return list;
}

function renderLibrary(){
  const grid = document.getElementById('grid');
  const list = sortedFiltered();
  document.getElementById('empty').style.display = list.length? 'none':'block';
  grid.innerHTML = list.map(m=>{
    const lastCh = m.capitulos[m.capitulos.length-1].num;
    return `
    <div class="card" tabindex="0" onclick="goManga('${m.id}')" onkeydown="if(event.key==='Enter')goManga('${m.id}')">
      <div class="cover" style="--c1:${m.cor[0]};--c2:${m.cor[1]}">
        <span class="badge" style="--dot:${m.dot}"><i></i>${m.badge}</span>
        ${coverHTML(m)}
      </div>
      <div class="card-body">
        <div class="card-meta"><span>Cap. ${lastCh}</span><span>${m.atualizado}</span></div>
        <div class="card-title">${m.titulo}</div>
      </div>
    </div>`;
  }).join('');
}

function goLibrary(){ showView('library'); }

// ---- detalhe do mangá ----
function goManga(id){
  state.mangaId = id;
  const m = findManga(id);
  document.getElementById('manga-body').innerHTML = `
    <div class="detail">
      <div class="cover" style="--c1:${m.cor[0]};--c2:${m.cor[1]}">${coverHTML(m)}</div>
      <div>
        <h2 class="display">${m.titulo}</h2>
        <div class="genero">${m.genero}</div>
        <p class="sinopse">${m.sinopse}</p>
      </div>
    </div>
    <div class="chapters">
      ${m.capitulos.map((c,i)=>`
        <button class="chap-row" onclick="openReader(${i},0)">
          <span class="chap-num display">${c.num}</span>
          <span class="chap-info"><strong>${c.titulo}</strong><small>${c.data}</small></span>
          <span class="chap-pages">${c.paginas} pág.</span>
        </button>`).join('')}
    </div>`;
  showView('manga');
}

// ---- leitor ----
function openReader(chapIndex, page){
  state.chapIndex = chapIndex; state.page = page;
  renderReader();
  showView('reader');
}

function renderReader(){
  const m = findManga(state.mangaId);
  const c = m.capitulos[state.chapIndex];
  document.getElementById('reader-chap-label').textContent = `${m.titulo} · Cap. ${c.num} — ${c.titulo}`;
  document.getElementById('page-el').style.setProperty('--c1', m.cor[0]);
  document.getElementById('page-num').textContent = state.page + 1;
  document.getElementById('page-txt').textContent = `Página ilustrativa do capítulo "${c.titulo}" — aqui entraria a imagem real da página.`;
  document.getElementById('page-count').textContent = `${state.page+1} / ${c.paginas}`;
  document.getElementById('prev-btn').disabled = (state.page===0 && state.chapIndex===0);
  document.getElementById('next-btn').disabled = (state.page===c.paginas-1 && state.chapIndex===m.capitulos.length-1);
}

document.getElementById('prev-btn').onclick = ()=>{
  const m = findManga(state.mangaId);
  if(state.page>0){ state.page--; }
  else if(state.chapIndex>0){ state.chapIndex--; state.page = m.capitulos[state.chapIndex].paginas-1; }
  renderReader();
};
document.getElementById('next-btn').onclick = ()=>{
  const m = findManga(state.mangaId);
  const c = m.capitulos[state.chapIndex];
  if(state.page < c.paginas-1){ state.page++; }
  else if(state.chapIndex < m.capitulos.length-1){ state.chapIndex++; state.page = 0; }
  renderReader();
};
document.getElementById('reader-back').onclick = ()=> showView('manga');

document.addEventListener('keydown', e=>{
  if(state.view!=='reader') return;
  if(e.key==='ArrowRight') document.getElementById('next-btn').click();
  if(e.key==='ArrowLeft') document.getElementById('prev-btn').click();
});

renderLibrary();
