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
OPT_ROOT = Path("pack/plugins/opt")
DEBUG = os.environ.get("DEBUG")

def is_repo_url(url):
    return re.match(r"^(https?|git|ssh|file)://", url) or re.match(r"^[\w-]+@[\w.-]+:", url)

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
            "--save", choices=["opt", "start"], help="save plugin to opt or start (default: start)", default="start"
        )
        parser.add_argument(
            "plugin", nargs="*", help="git url or plugin name (when update/uninstall)"
        )
        args = parser.parse_args()
        getattr(self, args.command)(args)

    def install(self, args):
        """
        # install plugins from git urls, e.g.
        vpm.py install [--save opt|start] [git_url1#branch1 git_url2#branch2 ...]
        # move existing plugins to opt or start, e.g.
        vpm.py install --save opt|start [plugin1 plugin2 ...]
        """
        plugins = args.plugin
        if not plugins:
            run("git submodule update --init --recursive", shell=True)
            return
        for plugin in plugins:
            branch = None
            if "#" in plugin:
                plugin, branch = plugin.split("#")
            else:
                try:
                    r = run(["git", "remote", "show", plugin], capture_output=True, text=True)
                    branch = re.search(r"HEAD branch: (.*)", r.stdout).group(1)
                except Exception:
                    branch = "master"
            name = get_plugin_name(plugin) if is_repo_url(plugin) else plugin
            start_path = f"{posix_path(ROOT)}/{name}"
            opt_path = f"{posix_path(OPT_ROOT)}/{name}"
            if args.save == "opt" and Path(start_path).exists():
                # move to opt if already exists in start
                run(["git", "mv", start_path, opt_path], shell=True)
            elif args.save == "start" and Path(opt_path).exists():
                # move to start if already exists in opt
                run(["git", "mv", opt_path, start_path], shell=True)
            else:
                # FIXME: depth=1 doesn't work with branch? failed to install coc.nvim
                target_path = opt_path if args.save == "opt" else start_path
                cmd = ["git", "submodule", "add", "--depth", "1", "--force",  "-b", branch, plugin, target_path]
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

    def update(self, args):
        return self.outdated(args, update=True)

    def uninstall(self, args):
        for plugin in args.plugin:
            run(["git", "rm", "-f", (f"{posix_path(ROOT)}/{plugin}")], shell=True)
            run(["git", "config", "--remove-section", f"submodule.\"{posix_path(ROOT)}/{plugin}\""], shell=True)
            # NOTE: this leaves some idx files that raises permission error?
            rmtree(f".git/modules/{posix_path(ROOT)}/{posix_path(plugin)}")
            rmtree(f"{posix_path(ROOT)}/{plugin}")

    def list(self, _):
        for plugin in ROOT.iterdir():
            print(plugin.name)

    def outdated(self, args, update=False):
        plugins = args.plugin
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
