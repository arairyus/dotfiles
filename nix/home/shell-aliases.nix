{
  code = "/Applications/Zed.app/Contents/MacOS/cli";
  python = "python3";
  pip = "pip3";
  tg = "terragrunt";
  tf = "terraform";
  tfdoc = "terraform-docs";
  tfplan = "terraform plan | awk '/Cost Estimation:/{exit} {print}'";
  tfscan = "terrascan";
  docker = "podman";
  docker-compose = "podman compose";
  dk = "podman";
  ll = "ls -la";
  la = "ls -al";
  k = "kubectl";
  kx = "kubectx";
  copilot = builtins.concatStringsSep " " [
    "copilot"
    # read-only shell commands
    "--allow-tool='shell(ls)'"
    "--allow-tool='shell(cat)'"
    "--allow-tool='shell(head)'"
    "--allow-tool='shell(tail)'"
    "--allow-tool='shell(grep)'"
    "--allow-tool='shell(find)'"
    "--allow-tool='shell(wc)'"
    "--allow-tool='write'"
    # git read-only ops (write ops like push/commit/merge will prompt)
    "--allow-tool='shell(git status)'"
    "--allow-tool='shell(git log)'"
    "--allow-tool='shell(git diff)'"
    "--allow-tool='shell(git show)'"
    "--allow-tool='shell(git branch)'"
    "--allow-tool='shell(git fetch)'"
    "--allow-tool='shell(git remote)'"
    "--allow-tool='shell(git tag)'"
    "--allow-tool='shell(git stash)'"
    "--allow-tool='shell(git rev-parse)'"
    "--allow-tool='shell(git ls-files)'"
    "--allow-tool='shell(git blame)'"
    "--allow-tool='shell(git config)'"
    "--allow-tool='shell(git shortlog)'"
    # gh read-only ops (create/merge/close/comment will prompt)
    "--allow-tool='shell(gh pr list)'"
    "--allow-tool='shell(gh pr view)'"
    "--allow-tool='shell(gh pr diff)'"
    "--allow-tool='shell(gh pr status)'"
    "--allow-tool='shell(gh pr checks)'"
    "--allow-tool='shell(gh issue list)'"
    "--allow-tool='shell(gh issue view)'"
    "--allow-tool='shell(gh issue status)'"
    "--allow-tool='shell(gh repo view)'"
    "--allow-tool='shell(gh repo list)'"
    "--allow-tool='shell(gh run list)'"
    "--allow-tool='shell(gh run view)'"
  ];
}
