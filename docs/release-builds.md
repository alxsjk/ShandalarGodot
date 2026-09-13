# Cross-platform release packages

Release packaging does not change the duel layout or rules. Godot 4.7.2
can cross-export all four targets; verify the official template archive's
checksum and extract only the needed templates. Set local custom-template
paths in the ignored `export_presets.cfg`, using the example as a guide.
The macOS export is universal; Windows and Linux target x86-64.

Use the debug export template for desktop releases, as documented in
CONTRIBUTING.md. Web uses the non-threaded release template. No test-profile
feature may be enabled during export. Run each command with GNU timeout
(gtimeout on macOS), close stdin, and write output to its own log file.
Inspect the exit status and log for export errors.

```sh
godot --headless --path . --export-debug 'Windows 64' /path/to/windows64/Shandalar.exe
godot --headless --path . --export-debug 'Linux 64' /path/to/linux64/Shandalar.x86_64
godot --headless --path . --export-debug macOS /path/to/macos/Shandalar.app
godot --headless --path . --export-release Web /path/to/web/index.html
```

Check macOS signing after export and after unpacking its ZIP. Run all
available native boot/duel checks and test the web export through a local
HTTP server in a browser. Isolate test profiles; remove any temporary
`override.cfg` before signing or packaging. Clearly disclose targets that
could only be cross-exported and not natively tested. A PCK smoke test
on another OS does not establish native binary compatibility.

Once the source revision is committed, package each verified export:

```sh
python3 tools/package_release.py --platform windows64 \
  --input /path/to/windows64 --out /path/to/release-downloads \
  --skin-zip /path/to/original_skin.zip --commit FULL_COMMIT_HASH
```

Repeat with `linux64`, `macos` and `web`. The version comes only from
`project.godot`. The packager never exports, uploads, overwrites an existing
package, copies the whole build directory, or builds a card pack. It streams
the approved files into two ZIPs, checks their integrity, preserves launcher
permissions and app signatures, and writes no UID/GID or extended metadata.
All packages carry tools under `tools/`, a README and per-file SHA256SUMS.
Only `-with-skin` includes `skin/original_skin.zip`; no package carries card
pictures. Validate the supplied skin with `tools/skin_catalogue.py --check`.

The public release consists of eight game ZIPs, the same `original_skin.zip`
as a separate download, and `SHA256SUMS` covering those nine assets. Publish
only this explicit list, never a wildcard over the build or local-art folder.
Create the release as a draft, upload and verify all assets against local
checksums, then publish. Keep personal paths and author details out of
notes, binaries, archives, tags and commits; use the configured pseudonym
and GitHub noreply address. Publication is always a separate, explicit
owner request, not the automatic tail of a local build.
