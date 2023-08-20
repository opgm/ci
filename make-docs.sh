COMMIT=$(git rev-parse master) gomplate < opgm_readme.t.md > README.md
git commit -am "Update docs"
