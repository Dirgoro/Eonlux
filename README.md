# EonluxOS 1.0

Distribuição Linux leve, responsiva e otimizada para hardware legado (`amd64`), baseada no **Debian Trixie (Debian 13)** com ambiente gráfico **XFCE** e compilação automatizada via **Debian Live-Build** no GitHub Actions.

## Especificações Implementadas

### Fase 1 (`feat/phase-01-base-system`)
- **Base:** Debian 13 (Trixie) `amd64` sem pacotes recomendados (`--apt-recommends false`).
- **Boot Híbrido:** Suporte simultâneo a **BIOS Legacy (Syslinux/Isolinux)** e **UEFI (GRUB-EFI)**.
- **Ambiente Gráfico:** XFCE puro com compositor desativado por padrão (`xfwm4`) e painel superior único de 32px.
- **Áudio:** Pilha nativa **PipeWire** (`pipewire-audio`, `pipewire-pulse`, `wireplumber`).

### Fase 2 (`feat/phase-02-legacy-tuning`)
- **ZRAM (`lz4`):** Swap comprimida em memória configurada a 50% da RAM física com prioridade máxima (`100`).
- **Prevenção contra OOM (`earlyoom`):** Proteção ativa para evitar travamentos totais em máquinas com 2 GB de RAM.
- **Otimizações de Sistema:** Ajustes de kernel (`sysctl`), escalonadores de I/O para SSD (`mq-deadline`) e limitação de caches.

### Fase 3 (`feat/phase-03-visual-layout`)
- **Identidade Visual Dark Slate:** Papel de parede personalizado do Eonlux Core, tema escuro `Adwaita-dark` e fontes otimizadas.
- **Dock Plank:** Barra de atalhos inferior limpa e integrada para acesso rápido a aplicativos.
- **Plymouth Splash Customizado:** Animação de carregamento de boot com o logotipo oficial e barra de progresso.
