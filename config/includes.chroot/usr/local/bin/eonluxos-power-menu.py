#!/usr/bin/env python3
"""EonluxOS 1.0 Core - Tela personalizada de Desligar, Reiniciar e Sair usuario."""

import os
import shutil
import subprocess
import sys

import gi

gi.require_version("Gtk", "3.0")
gi.require_version("Gdk", "3.0")
from gi.repository import Gdk, GdkPixbuf, Gtk


CSS_STYLE = b"""
window#eonlux-power-window {
    background-color: #060C1C;
    border: 1.5px solid #137FEC;
    border-radius: 16px;
}

box#main-container {
    background-color: transparent;
    padding: 22px 26px 20px 26px;
}

label#header-title {
    color: #FFFFFF;
    font-family: "Noto Sans", sans-serif;
    font-size: 15pt;
    font-weight: bold;
}

label#header-subtitle {
    color: #94A3B8;
    font-family: "Noto Sans", sans-serif;
    font-size: 9.5pt;
}

button.action-card {
    background-color: rgba(15, 28, 56, 0.85);
    background-image: none;
    border: 1px solid rgba(56, 189, 248, 0.25);
    border-radius: 12px;
    padding: 16px 12px;
    min-width: 136px;
    min-height: 104px;
    box-shadow: none;
    transition: all 150ms ease-in-out;
}

button.action-card:hover,
button.action-card:focus {
    background-color: rgba(19, 127, 236, 0.28);
    border: 1.5px solid #38BDF8;
}

button.action-card.shutdown-card:hover,
button.action-card.shutdown-card:focus {
    background-color: rgba(220, 38, 38, 0.24);
    border: 1.5px solid #F87171;
}

label.card-title {
    color: #F8FAFC;
    font-family: "Noto Sans", sans-serif;
    font-size: 10.5pt;
    font-weight: bold;
}

label.card-desc {
    color: #94A3B8;
    font-family: "Noto Sans", sans-serif;
    font-size: 8pt;
}

button#cancel-btn {
    background-color: rgba(30, 41, 59, 0.65);
    background-image: none;
    border: 1px solid rgba(148, 163, 184, 0.30);
    border-radius: 8px;
    color: #CBD5E1;
    font-family: "Noto Sans", sans-serif;
    font-size: 9pt;
    padding: 6px 20px;
    min-height: 0;
    box-shadow: none;
}

button#cancel-btn:hover {
    background-color: rgba(51, 65, 85, 0.90);
    border-color: #38BDF8;
    color: #FFFFFF;
}
"""


def run_session_action(action: str) -> None:
    """Executa a acao selecionada com fallback seguro."""
    real_xfce_logout = (
        "/usr/bin/xfce4-session-logout.real"
        if os.path.exists("/usr/bin/xfce4-session-logout.real")
        else shutil.which("xfce4-session-logout")
    )

    if action == "shutdown":
        if real_xfce_logout:
            subprocess.Popen([real_xfce_logout, "--halt", "--fast"])
        else:
            subprocess.Popen(["systemctl", "poweroff"])
    elif action == "reboot":
        if real_xfce_logout:
            subprocess.Popen([real_xfce_logout, "--reboot", "--fast"])
        else:
            subprocess.Popen(["systemctl", "reboot"])
    elif action == "logout":
        if real_xfce_logout:
            subprocess.Popen([real_xfce_logout, "--logout", "--fast"])
        else:
            session_id = os.environ.get("XDG_SESSION_ID", "")
            if session_id:
                subprocess.Popen(["loginctl", "terminate-session", session_id])
            else:
                subprocess.Popen(["xfce4-session-logout", "--logout"])


class EonluxPowerWindow(Gtk.Window):
    def __init__(self) -> None:
        super().__init__(title="Encerrar EonluxOS")
        self.set_name("eonlux-power-window")
        self.set_decorated(False)
        self.set_resizable(False)
        self.set_position(Gtk.WindowPosition.CENTER_ALWAYS)
        self.set_keep_above(True)
        self.set_skip_taskbar_hint(True)
        self.set_type_hint(Gdk.WindowTypeHint.DIALOG)
        self.set_default_size(510, 275)

        screen = self.get_screen()
        visual = screen.get_rgba_visual()
        if visual is not None and screen.is_composited():
            self.set_visual(visual)
        self.set_app_paintable(True)

        self.connect("key-press-event", self._on_key_press)
        self.connect("destroy", Gtk.main_quit)

        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=16)
        main_box.set_name("main-container")
        self.add(main_box)

        # Cabecalho com logotipo oficial e titulo
        header_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        header_box.set_halign(Gtk.Align.CENTER)

        logo_widget = self._load_logo()
        if logo_widget:
            header_box.pack_start(logo_widget, False, False, 0)

        title_lbl = Gtk.Label(label="O que você deseja fazer?")
        title_lbl.set_name("header-title")
        header_box.pack_start(title_lbl, False, False, 0)

        sub_lbl = Gtk.Label(label="EonluxOS 1.0 Core • Escolha uma opção para finalizar a sessão atual")
        sub_lbl.set_name("header-subtitle")
        header_box.pack_start(sub_lbl, False, False, 0)

        main_box.pack_start(header_box, False, False, 0)

        # Grade com as 3 opcoes principais
        actions_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=14)
        actions_box.set_halign(Gtk.Align.CENTER)

        btn_shutdown = self._create_action_button(
            icon_name="system-shutdown",
            title="Desligar",
            subtitle="Encerrar o computador",
            action="shutdown",
            extra_class="shutdown-card",
        )
        btn_reboot = self._create_action_button(
            icon_name="system-reboot",
            title="Reiniciar",
            subtitle="Iniciar novamente",
            action="reboot",
        )
        btn_logout = self._create_action_button(
            icon_name="system-log-out",
            title="Sair usuário",
            subtitle="Encerrar sessão atual",
            action="logout",
        )

        actions_box.pack_start(btn_shutdown, True, True, 0)
        actions_box.pack_start(btn_reboot, True, True, 0)
        actions_box.pack_start(btn_logout, True, True, 0)

        main_box.pack_start(actions_box, True, True, 2)

        # Rodape com botao Cancelar
        footer_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        footer_box.set_halign(Gtk.Align.CENTER)

        cancel_btn = Gtk.Button(label="Cancelar (Esc)")
        cancel_btn.set_name("cancel-btn")
        cancel_btn.connect("clicked", lambda *_: Gtk.main_quit())
        footer_box.pack_start(cancel_btn, False, False, 0)

        main_box.pack_start(footer_box, False, False, 0)

        self.show_all()
        btn_shutdown.grab_focus()

    def _load_logo(self):
        candidates = [
            "/usr/share/icons/hicolor/48x48/apps/eonluxos-logo.png",
            "/usr/share/pixmaps/eonluxos-logo.png",
            "/usr/share/icons/hicolor/scalable/apps/eonluxos-logo.svg",
        ]
        for path in candidates:
            if os.path.exists(path):
                try:
                    pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(path, 42, 42, True)
                    return Gtk.Image.new_from_pixbuf(pixbuf)
                except Exception:
                    pass
        img = Gtk.Image.new_from_icon_name("system-shutdown", Gtk.IconSize.DIALOG)
        img.set_pixel_size(42)
        return img

    def _create_action_button(
        self,
        icon_name: str,
        title: str,
        subtitle: str,
        action: str,
        extra_class: str = "",
    ) -> Gtk.Button:
        btn = Gtk.Button()
        ctx = btn.get_style_context()
        ctx.add_class("action-card")
        if extra_class:
            ctx.add_class(extra_class)

        inner = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        inner.set_valign(Gtk.Align.CENTER)
        inner.set_halign(Gtk.Align.CENTER)

        icon = Gtk.Image.new_from_icon_name(icon_name, Gtk.IconSize.DIALOG)
        icon.set_pixel_size(34)
        inner.pack_start(icon, False, False, 2)

        lbl_title = Gtk.Label(label=title)
        lbl_title.get_style_context().add_class("card-title")
        inner.pack_start(lbl_title, False, False, 0)

        lbl_desc = Gtk.Label(label=subtitle)
        lbl_desc.get_style_context().add_class("card-desc")
        inner.pack_start(lbl_desc, False, False, 0)

        btn.add(inner)
        btn.connect("clicked", self._on_action_clicked, action)
        return btn

    def _on_action_clicked(self, _widget, action: str) -> None:
        self.hide()
        while Gtk.events_pending():
            Gtk.main_iteration()
        run_session_action(action)
        Gtk.main_quit()

    def _on_key_press(self, _widget, event) -> bool:
        if event.keyval == Gdk.KEY_Escape:
            Gtk.main_quit()
            return True
        return False


def main() -> int:
    settings = Gtk.Settings.get_default()
    if settings is not None:
        settings.set_property("gtk-theme-name", "Adwaita-dark")
        settings.set_property("gtk-icon-theme-name", "Papirus-Dark")
        settings.set_property("gtk-application-prefer-dark-theme", True)

    provider = Gtk.CssProvider()
    provider.load_from_data(CSS_STYLE)
    Gtk.StyleContext.add_provider_for_screen(
        Gdk.Screen.get_default(),
        provider,
        Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
    )

    win = EonluxPowerWindow()
    win.present()
    Gtk.main()
    return 0


if __name__ == "__main__":
    sys.exit(main())
