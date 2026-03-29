#!/usr/bin/env python3
"""Runs a command in a VTE terminal on the Wayland background layer."""

import sys

import gi
from gi.repository import Gdk, GLib, Gtk, GtkLayerShell, Vte

gi.require_version("Gdk", "3.0")
gi.require_version("Gtk", "3.0")
gi.require_version("Vte", "2.91")
gi.require_version("GtkLayerShell", "0.1")


windows = []


def make_window(monitor, cmd):
    win = Gtk.Window()
    GtkLayerShell.init_for_window(win)
    GtkLayerShell.set_monitor(win, monitor)
    GtkLayerShell.set_layer(win, GtkLayerShell.Layer.BACKGROUND)
    for edge in (
        GtkLayerShell.Edge.TOP,
        GtkLayerShell.Edge.BOTTOM,
        GtkLayerShell.Edge.LEFT,
        GtkLayerShell.Edge.RIGHT,
    ):
        GtkLayerShell.set_anchor(win, edge, True)
    GtkLayerShell.set_exclusive_zone(win, -1)

    term = Vte.Terminal()

    def rgba(hex_color):
        c = Gdk.RGBA()
        c.parse(hex_color)
        return c

    # Solarized dark palette (16 colors)
    palette = [
        rgba(h)
        for h in (
            "#073642",
            "#dc322f",
            "#859900",
            "#b58900",  # black, red, green, yellow
            "#268bd2",
            "#d33682",
            "#2aa198",
            "#eee8d5",  # blue, magenta, cyan, white
            "#002b36",
            "#cb4b16",
            "#586e75",
            "#657b83",  # brblack, brred, brgreen, bryellow
            "#839496",
            "#6c71c4",
            "#93a1a1",
            "#fdf6e3",  # brblue, brmagenta, brcyan, brwhite
        )
    ]
    term.set_colors(rgba("#839496"), rgba("#002b36"), palette)

    term.connect("child-exited", lambda *_: win.destroy())
    win.add(term)
    win.show_all()

    def spawn_once(*_):
        term.spawn_async(
            Vte.PtyFlags.DEFAULT,
            None,
            cmd,
            None,
            GLib.SpawnFlags.SEARCH_PATH,
            None,
            None,
            -1,
            None,
            None,
        )
        return False  # run only once

    # Defer spawn until the compositor has assigned the final size
    GLib.idle_add(spawn_once)
    windows.append(win)

    def on_destroy(*_):
        if win in windows:
            windows.remove(win)
        if not windows:
            Gtk.main_quit()

    win.connect("destroy", on_destroy)


def main():
    cmd = sys.argv[1:] or ["cbonsai", "-l", "-i", "-b", "1", "-L", "50"]

    display = Gdk.Display.get_default()

    seen_monitors = set()

    def add_monitors():
        for i in range(display.get_n_monitors()):
            mon = display.get_monitor(i)
            if mon not in seen_monitors:
                seen_monitors.add(mon)
                make_window(mon, cmd)

    display.connect("monitor-added", lambda _d, _m: add_monitors())

    # Defer initial enumeration to after the main loop starts
    GLib.idle_add(add_monitors)

    Gtk.main()


if __name__ == "__main__":
    main()
