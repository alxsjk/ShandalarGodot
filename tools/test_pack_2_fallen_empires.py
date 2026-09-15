"""Offline checks for the dedicated Fallen Empires construction tool."""
import tempfile
import unittest
import warnings
from unittest.mock import patch
import zipfile
from pathlib import Path

import pack_2_fallen_empires as pack
import pack_1_dotp_complete as first

class PackTwoTests(unittest.TestCase):
    def test_full_checklist_and_independent_names(self):
        manifest, catalog, cards, _ = pack.assembled()
        names = {row['name'] for row in cards}
        self.assertEqual(len(names), 102)
        self.assertEqual(len(pack.read_json(pack.SOURCE / 'cards.json')), 187)
        self.assertEqual(set(catalog['sets']), {'fem'})
        self.assertEqual(set(catalog['sets']['fem']['names']), names)
        self.assertFalse(names & {name for _, name in first.assigned_pairs()})
        self.assertEqual(manifest['id'], 'pack-2')
        self.assertEqual(len(pack.art_targets(Path('unused'))), 204)

    def test_deterministic_art_archive_and_no_scripts(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            for path, _, _ in pack.art_targets(root / 'art'):
                path.parent.mkdir(parents=True, exist_ok=True)
                path.write_bytes(b'\xff\xd8test\xff\xd9')
            out = root / pack.FILE_NAME
            again = root / 'again' / pack.FILE_NAME
            pack.build(out, root / 'art')
            pack.build(again, root / 'art')
            self.assertEqual(out.read_bytes(), again.read_bytes())
            self.assertEqual(pack.verify(out)['checksums']['artwork']['files'], 408)
            with zipfile.ZipFile(out) as archive:
                self.assertEqual(len(archive.namelist()), 412)
                self.assertFalse(any(name.endswith('.gd') for name in archive.namelist()))

    def test_metadata_only_is_not_a_player_pack(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / pack.FILE_NAME
            pack.build(out, include_art=False)
            pack.verify(out, require_art=False)
            with self.assertRaises(ValueError):
                pack.verify(out)

    def test_extra_and_duplicate_entries_are_refused(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / pack.FILE_NAME
            pack.build(out, include_art=False)
            with zipfile.ZipFile(out, 'a') as archive:
                archive.writestr('injected.gd', 'extends Node')
            with self.assertRaisesRegex(ValueError, 'unexpected'):
                pack.verify(out, require_art=False)
            pack.build(out, include_art=False)
            with warnings.catch_warnings():
                warnings.simplefilter('ignore', UserWarning)
                with zipfile.ZipFile(out, 'a') as archive:
                    archive.writestr(pack.PREFIX + 'README.txt', 'duplicate')
            with self.assertRaisesRegex(ValueError, 'duplicate'):
                pack.verify(out, require_art=False)

    def test_failed_verification_does_not_replace_previous_pack(self):
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp) / pack.FILE_NAME
            pack.build(out, include_art=False)
            before = out.read_bytes()
            with patch.object(pack, 'verify', side_effect=ValueError('test failure')):
                with self.assertRaises(ValueError):
                    pack.build(out, include_art=False)
            self.assertEqual(out.read_bytes(), before)
            self.assertEqual(list(out.parent.iterdir()), [out])

if __name__ == '__main__':
    unittest.main()
