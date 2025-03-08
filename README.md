# Dream Journal

Um app para registrar e entender seus sonhos. Criei isso porque sempre achei fascinante como os sonhos podem revelar tanto sobre nós mesmos.

## O que ele faz

- Permite registrar seus sonhos com detalhes
- Oferece interpretações que ajudam a refletir sobre os significados possíveis
- Guarda seus sonhos para você revisitar quando quiser
- Funciona tanto no celular quanto no computador

## Como configurar

### Para o Worker do Cloudflare

1. Crie um Worker no Cloudflare
2. Cole o código do arquivo `cloudflare-worker.js` 
3. Configure a chave da API Gemini nas variáveis de ambiente
4. Publique!

### Para o app

1. Clone o repositório
2. Crie um arquivo `.env` com seu endpoint do Cloudflare
3. Rode `flutter pub get`
4. Inicie com `flutter run`

## Como usar

É simples! Abra o app, clique no "+" para adicionar um sonho, descreva o que aconteceu, e peça uma interpretação. A ideia é ajudar você a refletir sobre os símbolos e temas que aparecem nos seus sonhos.

## Nota

Este app é só uma ferramenta para reflexão e diversão. As interpretações são inspiradas em conceitos de psicologia e filosofia, mas servem apenas como ponto de partida para suas próprias descobertas.

---

Feito com ☕ e curiosidade sobre o que acontece quando fechamos os olhos.
