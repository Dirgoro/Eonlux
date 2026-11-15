// Perfil de baixo consumo de RAM para o Firefox ESR no EonluxOS 1.0 (hardware legado 2 GB)
pref("browser.tabs.unloadOnLowMemory", true);
pref("fission.autostart", false);
pref("dom.ipc.processCount", 2);

// Cache em memória limitado (64 MB) e cache em disco desativado para poupar I/O e espaço
pref("browser.cache.disk.enable", false);
pref("browser.cache.memory.enable", true);
pref("browser.cache.memory.capacity", 65536);
pref("browser.sessionhistory.max_total_viewers", 1);

// Desativa pré-carregamento especulativo de rede e DNS
pref("network.prefetch-next", false);
pref("network.dns.disablePrefetch", true);
pref("network.http.speculative-parallel-limit", 0);

// Desativa telemetria, Pocket e animações pesadas
pref("toolkit.telemetry.enabled", false);
pref("toolkit.telemetry.unified", false);
pref("datareporting.healthreport.uploadEnabled", false);
pref("extensions.pocket.enabled", false);
pref("toolkit.cosmeticAnimations.enabled", false);
