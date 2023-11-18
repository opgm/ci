for branch in staging; do
  git fetch opgm $branch
  git branch -D $branch || :
  git switch -c $branch opgm/$branch
  cat release_alert.md RELEASES.md > RELEASES.md.tmp
  mv RELEASES.md.tmp RELEASES.md
  git add RELEASES.md
  git commit -am "Update release alert" --author="OPGM CI Automated"
  git push -f -u opgm $branch --no-verify
done
