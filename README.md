# EonluxOS 1.0

Distribuição Linux leve, responsiva e otimizada para hardware legado (`amd64`), baseada no **Debian Trixie (Debian 13)** com ambiente gráfico **XFCE** e compilação automatizada via **Debian Live-Build** no GitHub Actions.

## Especificações Implementadas

### Fase 1 (`feat/phase-01-base-system`)
- **Base:** Debian 13 (Trixie) `amd64` sem pacotes recomendados (`--apt-recommends false`).
- **Boot Híbrido:** Suporte simultâneo a **BIOS Legacy (Syslinux/Isolinux)** e **UEFI (GRUB-EFI)**.
- **Ambiente Gráfico:** XFCE puro com compositor desativado por padrão (`xfwm4`) e ajuste dinâmico de vídeo (`eonluxos-display-quirks`).
- **Servidor de Exibição e Sessão:** Xorg + LightDM (`logind-check-graphical=false`) + `user-setup` + `mate-polkit`.
- **Áudio:** Pilha nativa **PipeWire** (`pipewire-audio`, `pipewire-pulse`, `wireplumber`).
- **Navegador Live:** Firefox ESR (`pt-BR`).
- **Localização:** `pt_BR.UTF-8`, teclado `br`, fuso horário `America/Sao_Paulo`.

### Fase 2 (`feat/phase-02-legacy-tuning`)
- **ZRAM (`zstd`):** Swap comprimida em memória configurada a 50% da RAM física com prioridade máxima (`100`).
- **Prevenção Ativa contra Travamentos (`earlyoom`):** Encerramento preventivo de abas/processos pesados antes do esgotamento total da memória, protegendo `Xorg`, `lightdm` e `xfwm4`.
- **Kernel & Memória Virtual (`sysctl`):** `vm.swappiness=100`, `vm.page-cluster=0`, `vm.vfs_cache_pressure=50`, limites reduzidos de dirty pages e `kernel.nmi_watchdog=0`.
- **Armazenamento SSD:** Regra `udev` aplicando `mq-deadline` em SSDs SATA/eMMC, `none` em NVMe e `fstrim.timer` semanal.
- **Firefox ESR Enxuto:** Desativação de isolamento multi-processo pesado (`fission.autostart=false`), limite de 2 processos de conteúdo, cache em memória restrito a 64 MB e descarregamento automático de abas inativas.
