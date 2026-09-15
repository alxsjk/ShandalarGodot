"""Offline regression tests for the public release package boundary."""
import hashlib
from pathlib import Path
import stat
import tempfile
import unittest
import zipfile

import package_release as pack


class PackageReleaseTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / "source"
        self.folder = Path(self.temp.name) / "export"
        self.out = Path(self.temp.name) / "packages"
        self.folder.mkdir()
        self.skin = Path(self.temp.name) / "original_skin.zip"
        with zipfile.ZipFile(self.skin, "w") as archive:
            archive.writestr("skin/frame.png", b"frame")
        for name in (*("tools/" + n for n in pack.TOOLS), "LICENSE",
                     "docs/setup.txt", "docs/skin-catalogue.txt",
                     "docs/releases/1.2.3.md", "DeckLab/README.md", "game/icon.png",
                     "docs/setup-web.txt"):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"fixture")
        (self.root / "project.godot").write_text('config/version="1.2.3"\n')

    def make_export(self, platform):
        names = {
            "linux64": ("Shandalar.x86_64", "Shandalar.pck"),
            "windows64": ("Shandalar.exe", "Shandalar.console.exe", "Shandalar.pck"),
            "web": ("index.html", "index.js", "index.wasm", "index.pck", "index.audio.worklet.js"),
            "macos": ("Shandalar.app/Contents/MacOS/Shandalar",
                      "Shandalar.app/Contents/Resources/Shandalar.pck",
                      "Shandalar.app/Contents/Info.plist",
                      "Shandalar.app/Contents/_CodeSignature/CodeResources"),
        }[platform]
        for name in names:
            path = self.folder / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"export bytes")
        (self.folder / "cardart.zip").write_bytes(b"private card pictures")
        (self.folder / "smoke.log").write_text("diagnostic log")
        return names

    def build(self, platform):
        return pack.package(self.folder, self.out, platform, self.skin,
                            "a" * 40, self.root)

    def test_all_platforms_two_packages_checksums_and_metadata(self):
        for platform in pack.PLATFORMS:
            with self.subTest(platform=platform):
                names = self.make_export(platform)
                for output, included in zip(self.build(platform), (False, True)):
                    with zipfile.ZipFile(output) as archive:
                        prefix = f"Shandalar-1.2.3-{platform}/"
                        entries = archive.namelist()
                        for name in names:
                            self.assertIn(prefix + name, entries)
                        self.assertEqual(prefix + "skin/original_skin.zip" in entries, included)
                        self.assertFalse(any("cardart.zip" in name or ".log" in name for name in entries))
                        for entry in archive.infolist():
                            self.assertEqual(entry.extra, b"")
                            self.assertFalse(stat.S_ISLNK(entry.external_attr >> 16))
                        for line in archive.read(prefix + "SHA256SUMS").decode().splitlines():
                            checksum, name = line.split("  ", 1)
                            self.assertEqual(hashlib.sha256(archive.read(prefix + name)).hexdigest(), checksum)
                        if platform in ("linux64", "macos"):
                            self.assertEqual(archive.getinfo(prefix + "run.sh").external_attr >> 16 & 0o777, 0o755)
                        if platform == "macos":
                            entry = archive.getinfo(prefix + "Shandalar.app/Contents/MacOS/Shandalar")
                            self.assertEqual(entry.external_attr >> 16 & 0o777, 0o755)

    def test_card_pack_and_traversal_are_refused(self):
        for name in ("skin/cardart/island.jpg", "skin/../secret", "/skin/frame.png", "skin\\frame.png"):
            with self.subTest(name=name):
                with zipfile.ZipFile(self.skin, "w") as archive:
                    archive.writestr(name, b"payload")
                with self.assertRaises(ValueError):
                    pack.check_skin(self.skin)

    def test_missing_payload_refuses_before_output(self):
        with self.assertRaises(ValueError):
            self.build("linux64")
        self.assertFalse(self.out.exists())

    def test_overwrite_is_refused(self):
        self.make_export("linux64")
        outputs = self.build("linux64")
        before = [pack.digest(p) for p in outputs]
        with self.assertRaises(ValueError):
            self.build("linux64")
        self.assertEqual(before, [pack.digest(p) for p in outputs])

    def test_override_inside_mac_app_is_refused(self):
        self.make_export("macos")
        (self.folder / "Shandalar.app/Contents/Resources/override.cfg").write_text("test profile")
        with self.assertRaises(ValueError):
            self.build("macos")

    def test_local_pack_inside_mac_app_is_refused(self):
        self.make_export("macos")
        path = self.folder / "Shandalar.app/Contents/Resources" / pack.LOCAL_PACK
        path.write_bytes(b"must remain a local construction artifact")
        with self.assertRaisesRegex(ValueError, "must not be released"):
            self.build("macos")

    def test_fallen_empires_pack_inside_mac_app_is_refused(self):
        self.make_export("macos")
        path = self.folder / "Shandalar.app/Contents/Resources/Pack-2-Fallen-Empires.zip"
        path.write_bytes(b"local only")
        with self.assertRaisesRegex(ValueError, "must not be released"):
            self.build("macos")

    def test_home_path_in_binary_is_refused(self):
        self.make_export("linux64")
        (self.folder / "Shandalar.x86_64").write_bytes(str(Path.home()).encode())
        with self.assertRaises(ValueError):
            self.build("linux64")

    def test_symlink_payload_is_refused(self):
        self.make_export("linux64")
        binary = self.folder / "Shandalar.x86_64"
        binary.unlink()
        binary.symlink_to(self.root / "LICENSE")
        with self.assertRaises(ValueError):
            self.build("linux64")


if __name__ == "__main__":
    unittest.main()
