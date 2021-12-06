from pathlib import Path
from subprocess import run
import re

root = Path("./pack/plugins/start")
for p in root.iterdir():
    r = run("git remote -v", shell=True, cwd=p, capture_output=True)
    host = re.search(r'https://\S+', r.stdout.decode("utf8")).group()
    r = run("git status", shell=True, cwd=p, capture_output=True)
    branch = re.search(r'On branch (\S+)', r.stdout.decode("utf8")).group(1)
    run(["git", "submodule", "add", "-b", branch, host, str(p)], shell=True)
