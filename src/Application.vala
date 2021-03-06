/*
* Copyright (c) 2017 David Hewitt (https://github.com/davidmhewitt)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: David Hewitt <davidmhewitt@gmail.com>
*/

public class Torrential.Application : Granite.Application {
    private MainWindow? window = null;

    construct {
        flags |= ApplicationFlags.HANDLES_OPEN;
        application_id = "com.github.davidmhewitt.torrential";

        program_name = "Torrential";
        app_years = "2017";

        build_version = "1.0.0";
        app_icon = "com.github.davidmhewitt.torrential";
        main_url = "https://github.com/davidmhewitt/torrential";
        bug_url = "https://github.com/davidmhewitt/torrential/issues";
        help_url = "https://github.com/davidmhewitt/torrential/issues";
        //translate_url = "https://l10n.elementary.io/projects/desktop/granite";

        about_documenters = { null };
        about_artists = {
            "David Hewitt <davidmhewitt@gmail.com>",
            "Sam Hewitt <sam@snwh.org>"
        };
        about_authors = {
            "David Hewitt <davidmhewitt@gmail.com>",
        };

        about_comments = "A simple torrent client";
        about_translators = _("translator-credits");
        about_license_type = Gtk.License.GPL_2_0;

        if (AppInfo.get_default_for_uri_scheme ("magnet") == null) {
            var appinfo = new DesktopAppInfo (app_launcher);
            try {
                appinfo.set_as_default_for_type ("x-scheme-handler/magnet");
            } catch (Error e) {
                warning ("Unable to set self as default for magnet links: %s", e.message);
            }
        }

        if (AppInfo.get_default_for_type ("application/x-bittorrent", false) == null) {
            var appinfo = new DesktopAppInfo (app_launcher);
            try {
                appinfo.set_as_default_for_type ("application/x-bittorrent");
            } catch (Error e) {
                warning ("Unable to set self as default for torrent files: %s", e.message);
            }
        }
    }

    public override void open (File[] files, string hint) {
        if (files[0].has_uri_scheme ("magnet")) {
            var magnet = files[0].get_uri ();
            magnet = magnet.replace ("magnet:///?", "magnet:?");
            activate ();
            if (window != null) {
                window.add_magnet (magnet);
            }
            return;
        }

        var uris = new SList<string> ();
        foreach (var file in files) {
            uris.append (file.get_uri ());
        }

        activate ();
        if (window != null) {
            window.add_files (uris);
        }
    }

    public override void activate () {
        if (window == null) {
            window = new MainWindow (this);
            window.show_about.connect ((window) => {
                show_about (window);
            });

            add_window (window);
        }
        window.present ();
        window.present_with_time ((uint32)GLib.get_monotonic_time ());
    }
}

int main (string[] args) {
    var app = new Torrential.Application ();
    var ret_val = app.run (args);
    // Ensure we free the static instance of our application or else destructors won't be called
    // and libtransmission won't be shut down cleanly
    Granite.app = null;
    return ret_val;
}
