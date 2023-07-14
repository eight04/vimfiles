"""
vpm.py - a simple package manager cli for Vim plugins, based on git submodules.
"""
import argparse
import re
import sys

from pathlib import Path, PurePosixPath
from subprocess import run

ROOT = Path("pack/plugins/start")

def get_plugin_name(url):
    return url.split('/')[-1].split('.')[0]

def posix_path(p):
    # https://github.com/git-for-windows/git/issues/3575
    return str(PurePosixPath(p))

class App:
    def __init__(self):
        parser = argparse.ArgumentParser()
        parser.add_argument('command', choices=['install', 'update', 'uninstall', 'list', 'outdated'])
        parser.add_argument('plugin', nargs='*', help='git url or plugin name (when update/uninstall)')
        args = parser.parse_args()
        getattr(self, args.command)(args.plugin)

    def install(self, plugins):
        if not plugins:
            run("git submodule update --init --recursive", shell=True)
            return

        for plugin in plugins:
            branch = None
            t = plugin.split("#")
            if len(t) == 2:
                plugin, branch = t
            name = get_plugin_name(plugin)
            # FIXME: depth=1 doesn't work with branch? failed to install coc.nvim
            cmd = ["git", "submodule", "add", "--force"] 
            if branch:
                cmd.append("-b")
                cmd.append(branch)
            cmd.extend([plugin, (f"{posix_path(ROOT)}/{name}")])
            run(cmd, shell=True)

    def update(self, plugins):
        if not plugins:
            plugins = [plugin.name for plugin in ROOT.iterdir()]

        for plugin in plugins:
            r = run("git status", shell=True, cwd=(f"{posix_path(ROOT)}/{plugin}"), capture_output=True, text=True)
            if "up to date" in r.stdout:
                continue
            print(plugin)
            if "HEAD detached" in r.stdout:
                # switch back to init branch?
                r = run(
                    f"git config -f .gitmodules submodule.\"{posix_path(ROOT)}/{plugin}\".branch",
                    shell=True,
                    cwd=f"{posix_path(ROOT)}/{plugin}",
                    capture_output=True,
                    text=True
                    )
                branch = r.stdout.strip()
                if not branch:
                    # siwtch to remote default?
                    r = run("git remote show origin", shell=True, cwd=(f"{posix_path(ROOT)}/{plugin}"), capture_output=True, text=True)
                    branch = re.search(r"HEAD branch: (.*)", r.stdout).group(1)
                run(["git", "checkout", branch], shell=True, cwd=(f"{posix_path(ROOT)}/{plugin}"))
            run("git pull", shell=True, cwd=(f"{posix_path(ROOT)}/{plugin}"))
            print("")

    def uninstall(self, plugins):
        for plugin in plugins:
            run(["git", "rm", "-f", (f"{posix_path(ROOT)}/{plugin}")], shell=True)

    def list(self, _):
        for plugin in ROOT.iterdir():
            print(plugin.name)

    def outdated(self, plugins):
        if not plugins:
            plugins = [plugin.name for plugin in ROOT.iterdir()]

        for plugin in plugins:
            r = run("git log ..@{u} --oneline --color=always", shell=True, cwd=(f"{posix_path(ROOT)}/{plugin}"), capture_output=True)
            if r.stdout:
                print(plugin)
                sys.stdout.buffer.write(r.stdout)
                print("")

            elif r.stderr:
                print(plugin)
                sys.stdout.buffer.write(r.stderr)
                print("")

App()

