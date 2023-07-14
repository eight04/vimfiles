"""
vpm.py - a simple package manager cli for Vim plugins, based on git submodules.
"""
import argparse

from pathlib import Path, PurePosixPath
from subprocess import run

ROOT = Path("./pack/plugins/start")

def get_plugin_name(url):
    return url.split('/')[-1].split('.')[0]

def posix_path(p):
    # https://github.com/git-for-windows/git/issues/3575
    return str(PurePosixPath(p))

class App:
    def __init__(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('command', choices=['install', 'update', 'uninstall', 'list'])
        parser.add_argument('plugin', nargs='*', help='git url or plugin name (when update/uninstall)')
        args = parser.parse_args()
        getattr(self, args.command)(args.plugin)

    def install(self, plugins):
        for plugin in plugins:
            branch = None
            t = plugin.split("#")
            if len(t) == 2:
                plugin, branch = t
            name = get_plugin_name(plugin)
            cmd = ["git", "submodule", "add", plugin, (f"{posix_path(ROOT)}/{name}")]
            if branch:
                cmd.append("-b")
                cmd.append(branch)
            run(cmd, shell=True)

    def update(self, plugins):
        raise NotImplementedError

    def uninstall(self, plugins):
        for plugin in plugins:
            run(["git", "rm", (f"{posix_path(ROOT)}/{plugin}")], shell=True)

    def list(self, _):
        for plugin in ROOT.iterdir():
            print(plugin.name)

App()

