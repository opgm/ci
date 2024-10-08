declare -a submodules=("panda" "msgq_repo" "opendbc_repo" "rednose_repo" "tinygrad_repo" "teleoprtc_repo")

function unsubmodule() {
  for submodule in $submodules; do
    mv $submodule .tmp
    git submodule deinit -f $submodule
    git rm -f $submodule
    mv .tmp $submodule
    rm -rf $submodule/.git
    rm -rf $submodule/.github
    git add $submodule
  done
  git rm -f .gitmodules
}
