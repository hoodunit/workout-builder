#!/usr/bin/env bash
set -e
git stash save wip
git branch -D gh-pages
git checkout -b gh-pages
npm run clean && npm run build:prod
git add dist --force
git mv dist/* ./
git rm README.md
git commit -m "Auto-add generated sources and tweak for GitHub Pages"
git push origin gh-pages:gh-pages --force
git checkout main
