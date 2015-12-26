---
Description: ""
Tags: [docpad, hugo]
date: 2015-12-27T00:30:28+07:00
draft: true
socialsharing: true
title: "Moving to Hugo"
totop: true
---
# why
- Docpad was really slow, it took more than 5 secs to render all the post (less than 10) while Hugo only took around 50 ms.
- Better project structure
- Better documentation
- The templates are nice and easier to modify compared to docpad
- It's Golang!

# setup
## install
```
brew install hugo
```
## create new site
```
hugo new site /path/to/site
```
## pick your theme and make it yours

# GitHub Pages deployment
- Using git subtree like [like in the docs](https://gohugo.io/tutorials/github-pages-blog/) but it not really what I need
- the deployment flow wasnt defiate much from docpad, so I use that.

# beyond
## Automation
- use gnu make as the build tool
- automate everything:
  - create new post
  - build static sites
  - GitHub Pages deployment setup
  - Github Pages deployment
  - etc
