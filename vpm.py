"""
vpm.py - a simple package manager cli for Vim plugins, based on git submodules.

NOTE: Some plugins requires additional setup after installation, e.g.

- coc.nvim: `npm ci` in the plugin directory.
- fzf: `fzf#install()`
"""
import argparse
import re
import sys
import shutil
import traceback
import os

from pathlib import Path, PurePosixPath
from subprocess import run as run_raw

ROOT = Path("pack/plugins/start")
DEBUG = os.environ.get("DEBUG")

def run(cmd, **kwargs):
    if DEBUG:
        print("> " + (" ".join(cmd) if isinstance(cmd, list) else cmd))
    return run_raw(cmd, **kwargs)

def rmtree(p):
    try:
        shutil.rmtree(p)
    except FileNotFoundError:
        pass
    except PermissionError:
        # https://stackoverflow.com/questions/76546956/permissionerror-winerror-5-access-is-denied-team-sortifie-git-git-object
        # try to remove read-only attribute and retry
        def onexc(func, path, exc_info):
            os.chmod(path, 0o666)
            func(path)
        try:
            shutil.rmtree(p, onexc=onexc)
        except Exception:
            traceback.print_exc()

def get_plugin_name(url):
    m = re.search(r"([^/\\]+)\.git", url)
    return m.group(1)

def posix_path(p):
    # https://github.com/git-for-windows/git/issues/3575
    return str(PurePosixPath(p))

class App:
    def __init__(self):
        parser = argparse.ArgumentParser()
        parser.add_argument(
            "command", choices=["install", "update", "uninstall", "list", "outdated"]
        )
        parser.add_argument(
            "plugin", nargs="*", help="git url or plugin name (when update/uninstall)"
        )
        args = parser.parse_args()
        getattr(self, args.command)(args.plugin)

    def install(self, plugins):
        if not plugins:
            run("git submodule update --init --recursive", shell=True)
            return

        for plugin in plugins:
            branch = None
            if "#" in plugin:
                plugin, branch = plugin.split("#")
            else:
                r = run(["git", "remote", "show", plugin], capture_output=True, text=True)
                branch = re.search(r"HEAD branch: (.*)", r.stdout).group(1)
            name = get_plugin_name(plugin)
            # FIXME: depth=1 doesn't work with branch? failed to install coc.nvim
            cmd = ["git", "submodule", "add", "--depth", "1", "--force",  "-b", branch, plugin, f"{posix_path(ROOT)}/{name}"]
            run(cmd, shell=True)

        print("To rebuild help tags, run\n:helptags ALL")

    def get_remote_branch(self, plugin):
        # check submodule config
        r = run(
            f'git config -f .gitmodules submodule."{posix_path(ROOT)}/{plugin}".branch',
            shell=True,
            capture_output=True,
            text=True,
        )
        branch = r.stdout.strip()
        if not branch:
            # use remote default
            r = run(
                "git remote show origin",
                shell=True,
                cwd=(f"{posix_path(ROOT)}/{plugin}"),
                capture_output=True,
                text=True,
            )
            branch = re.search(r"HEAD branch: (.*)", r.stdout).group(1)
        return branch

    def update(self, plugins):
        return self.outdated(plugins, update=True)

    def uninstall(self, plugins):
        for plugin in plugins:
            run(["git", "rm", "-f", (f"{posix_path(ROOT)}/{plugin}")], shell=True)
            run(["git", "config", "--remove-section", f"submodule.\"{posix_path(ROOT)}/{plugin}\""], shell=True)
            # NOTE: this leaves some idx files that raises permission error?
            rmtree(f".git/modules/{posix_path(ROOT)}/{posix_path(plugin)}")
            rmtree(f"{posix_path(ROOT)}/{plugin}")

    def list(self, _):
        for plugin in ROOT.iterdir():
            print(plugin.name)

    def outdated(self, plugins, update=False):
        if not plugins:
            plugins = [plugin.name for plugin in ROOT.iterdir()]

        for plugin in plugins:
            print(f"checking {plugin}")
            branch = self.get_remote_branch(plugin)
            run(
                "git fetch",
                shell=True,
                cwd=(f"{posix_path(ROOT)}/{plugin}"),
                # capture_output=True,
            )
            if not update:
                r = run(
                    f"git log HEAD...origin/{branch} --oneline --color=always",
                    shell=True,
                    cwd=(f"{posix_path(ROOT)}/{plugin}"),
                    capture_output=True,
                )
                if r.stdout:
                    print(plugin)
                    sys.stdout.buffer.write(r.stdout)
                elif r.stderr:
                    print(plugin)
                    sys.stdout.buffer.write(r.stderr)
            else:
                run(
                    f"git checkout origin/{branch}",
                    shell=True,
                    cwd=(f"{posix_path(ROOT)}/{plugin}"),
                )

            print("")

App()
