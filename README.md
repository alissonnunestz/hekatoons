[Uploading hekatoons.md…]()
# hekatoons — biblioteca + leitor de mangá

## A ideia geral

O site tem duas partes separadas, e é importante pensar nelas separadamente:

- **Dados** — um array (`MANGAS`) guarda tudo sobre cada título: nome, capa, sinopse, lista de capítulos. Sempre no mesmo formato: `{id, titulo, capa, sinopse, capitulos: [...]}`.
- **Interface** — pega esses dados e desenha as três telas (biblioteca, página do mangá, leitor). Não sabe nada sobre de onde vieram os dados, só sabe "mangá X → desenhar card X / tela X".

Essa separação é o que te permite trocar o array fixo por uma API de verdade (puxando de um banco de dados) sem mexer uma linha na parte visual.

## Os arquivos

| Arquivo | O que é |
|---|---|
| `index.html` | Estrutura das 3 telas (biblioteca, mangá, leitor) |
| `style.css` | Todo o visual — cards, cores, tema escuro |
| `script.js` | O array `MANGAS` (os dados) + toda a lógica de navegação |
| `capas/` | Pasta onde entram as imagens de capa de cada mangá |

## Rodando

Não precisa instalar nada — é HTML/CSS/JS puro.

Baixe os três arquivos pra mesma pasta e abra o `index.html` no navegador (ou use a extensão **Live Server** no VS Code pra recarregar sozinho a cada alteração).

## Adicionando seu próprio mangá

Tudo fica dentro do array `MANGAS`, no topo do `script.js`. Copie um bloco desses e preencha:

```js
{
  id:'meu-manga',
  titulo:'Nome do Mangá',
  genero:'Ação / Aventura',
  badge:'Ação',
  atualizado:'há 2 dias',
  capa:'capas/minha-capa.jpg',   // ou '' pra usar o placeholder automático
  sinopse:'Resumo da história.',
  capitulos:[
    {num:1, titulo:'Nome do capítulo', data:'01 Jan 2026', paginas:6}
  ]
}
```

A partir daí ele já aparece na biblioteca, com busca e ordenação funcionando normalmente — sem mexer em mais nada.

## Como colocar a capa de cada mangá

Eu não consigo gerar a arte do seu mangá nem replicar a capa de um título real (ela é protegida por direito autoral — o que eu te mandar teria que ser algo genérico, não a arte de verdade), mas o caminho mais rápido pra colocar uma capa de verdade é:

1. Salve a imagem (sua própria arte, ou uma que você tem licença de usar) dentro da pasta `capas/`.
2. Dê um nome sem espaço nem acento: `sombra-de-ferro.jpg`.
3. Aponte o campo `capa` pro caminho relativo: `capa:'capas/sombra-de-ferro.jpg'`.
4. Se `capa` ficar vazio (`capa:''`), o card mostra sozinho um monograma com a inicial do título — então dá pra ir preenchendo aos poucos, sem quebrar os outros mangás.

## Bônus: trocando o array por uma API de verdade

Se um dia você quiser que os mangás venham de um banco de dados de verdade em vez do array fixo, a lógica muda pouco — só troca de onde `MANGAS` vem.

Back-end mínimo (Node + Express), servindo os mesmos dados:

```js
const express = require('express');
const app = express();
const MANGAS = require('./mangas.json');

app.get('/api/mangas', (req, res) => res.json(MANGAS));
app.listen(3000);
```

No `script.js`, em vez do array fixo, você buscaria os dados na API antes de desenhar a biblioteca:

```js
let MANGAS = [];

async function carregarMangas(){
  const resp = await fetch('/api/mangas');
  MANGAS = await resp.json();
  MANGAS.forEach((m,i)=>{ m.cor = PALETTE[i % PALETTE.length]; m.dot = DOTS[i % DOTS.length]; });
  renderLibrary();
}
carregarMangas();
```

Repare que é a mesma ideia de sempre: o resto do código (`renderLibrary`, `goManga`, `coverHTML`...) nem percebe a diferença — ele só sabe desenhar o que está dentro de `MANGAS`, não importa se veio de um array fixo ou de uma API.
