"""LAN launcher isolation and owned-directory cleanup, without running Godot."""
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class LanSmokeLauncherTest(unittest.TestCase):
    def run_launcher(self, keep=False, import_fails=False):
        with tempfile.TemporaryDirectory() as scratch:
            folder = Path(scratch)
            parent = folder / 'existing runs'
            parent.mkdir()
            sentinel = parent / 'keep-me.txt'
            sentinel.write_text('unrelated user file')
            fake = folder / 'fake-godot'
            fake.write_text(f'#!{sys.executable}\n' + '''
import json, os, pathlib, sys
args = sys.argv[1:]
out = pathlib.Path(os.environ['FAKE_REPORT'])
if '--import' in args:
    (out / 'import.json').write_text(json.dumps(dict(os.environ)))
    sys.exit(int(os.environ.get('FAKE_IMPORT_FAIL', '0')))
role = args[args.index('--role') + 1]
project = pathlib.Path(args[args.index('--path') + 1])
(out / (role + '.json')).write_text(json.dumps({
    'project': str(project),
    'settings': (project / 'override.cfg').read_text(),
    'source': str((project / 'project.godot').resolve()),
    'features': os.environ.get('GODOT_EDITOR_CUSTOM_FEATURES'),
    'xdg': os.environ['XDG_DATA_HOME'],
}))
print('LAN ' + role + ' OK')
''')
            fake.chmod(0o755)
            env = dict(os.environ, GODOT=str(fake), LAN_SMOKE_DIR=str(parent),
                       FAKE_REPORT=str(folder), FAKE_IMPORT_FAIL=str(int(import_fails)),
                       SHANDALAR_TEST_DATA_HOME=str(folder / 'import-profile'),
                       GODOT_EDITOR_CUSTOM_FEATURES='shandalar_test')
            command = ['bash', str(ROOT / 'tools/lan_smoke.sh')]
            if keep:
                command.append('--keep')
            result = subprocess.run(command, cwd=ROOT, env=env, stdin=subprocess.DEVNULL,
                                    capture_output=True, text=True, timeout=30)
            self.assertEqual(sentinel.read_text(), 'unrelated user file')
            self.assertEqual(result.returncode, 1 if import_fails else 0,
                             result.stdout + result.stderr)
            imported = json.loads((folder / 'import.json').read_text())
            self.assertIn('shandalar_test', imported['GODOT_EDITOR_CUSTOM_FEATURES'])
            if import_fails:
                self.assertFalse((folder / 'host.json').exists())
            else:
                roles = [json.loads((folder / (role + '.json')).read_text())
                         for role in ('host', 'guest')]
                self.assertNotEqual(roles[0]['settings'], roles[1]['settings'])
                self.assertNotEqual(roles[0]['xdg'], roles[1]['xdg'])
                for role, record in zip(('host', 'guest'), roles):
                    self.assertIn('config/name="Shandalar LAN Smoke ', record['settings'])
                    self.assertIn(role + '"', record['settings'])
                    self.assertEqual(record['features'], '')
                    self.assertEqual(Path(record['source']), ROOT / 'project.godot')
                    self.assertEqual(Path(record['project']).exists(), keep)
            remaining = list(parent.iterdir())
            self.assertEqual(len(remaining), 2 if keep else 1)

    def test_roles_are_isolated_and_only_owned_child_is_removed(self):
        self.run_launcher()

    def test_keep_retains_mirrors_without_changing_source(self):
        self.run_launcher(keep=True)

    def test_failed_import_stops_before_launching_roles(self):
        self.run_launcher(import_fails=True)
