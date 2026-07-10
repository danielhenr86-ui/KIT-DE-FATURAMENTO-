// Alpha Cartas de Crédito — Service Worker
// Versão: atualizar quando mudar o HTML para forçar recache nos dispositivos
const CACHE_NAME = 'alpha-pedido-v1';

// Arquivos que serão cacheados para funcionamento offline
const ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png'
];

// Instalar: cachear todos os assets
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(ASSETS))
      .then(() => self.skipWaiting())
  );
});

// Ativar: limpar caches antigos de versões anteriores
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

// Fetch: servir do cache se disponível, senão buscar na rede
self.addEventListener('fetch', event => {
  // Requisições externas (fontes Google, ViaCEP) sempre vão para a rede
  if (!event.request.url.startsWith(self.location.origin)) {
    return;
  }
  event.respondWith(
    caches.match(event.request)
      .then(cached => cached || fetch(event.request))
  );
});
