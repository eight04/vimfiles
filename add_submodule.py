from pathlib import Path, PurePosixPath
from subprocess import run, CalledProcessError
import re

def posix_path(p):
    # https://github.com/git-for-windows/git/issues/3575
    return str(PurePosixPath(p))

root = Path("./pack/plugins/start")
for p in root.iterdir():
    r = run("git remote -v", shell=True, cwd=p, capture_output=True)
    host = re.search(r'https://\S+', r.stdout.decode("utf8")).group()
    r = run("git status", shell=True, cwd=p, capture_output=True)
    branch = re.search(r'On branch (\S+)', r.stdout.decode("utf8")).group(1)
    try:
        run(["git", "submodule", "status", posix_path(p)], shell=True, check=True)
    except CalledProcessError:
        run(["git", "submodule", "add", "-b", branch, host, str(p)], shell=True)
    else:
        run(["git", "submodule", "set-branch", "-b", branch, posix_path(p)], shell=True, check=True)
        run(["git", "submodule", "set-url", posix_path(p), host], shell=True, check=True)
