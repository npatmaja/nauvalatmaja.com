---
Description: ""
Tags: [docpad, hugo]
Topics: ["web development"]
date: 2015-12-27T00:30:28+07:00
draft: false
socialsharing: true
title: "Moving to Hugo"
totop: true
---

Several weeks ago, my [Docpad][docpad] installation got screwed.
There was some errors when I tried to run it. My assumption
was because I just moved to Node.js 5.x, so I tried to upgrade
(or re-install it, maybe) it. Though the errors are gone, it
did not work as it used to be, it failed to build my blog
properly --- or I just forgotten how to use it, that's another
possibility.

Since I was looking for alternatives, I found [Hugo][hugo], a
static site generator created by [Steve Francia][spf13] using
[Go][golang]. The documentation was comprehensive enough to
get me started. Thanks to Hugo I got this blog up and running
again.

After digging a bit deeper into Hugo, Compared to Docpad,
Hugo came out on top. The first and foremost deciding factor
to me was speed. Docpad took more than 5 seconds to generate
my blog with just merely 7 posts in it, and (most) sometimes
it took longer than that.
It was quite unpleasant experience when I drafted
a blog post and want to preview it but need to wait that much
and to make it worse I did it quite often, conscious or
un-consciously. Amazingly, Hugo took only around 100ms to generate
my blog, that was 500 time faster, awesome!

So, if you have the same problem as mine or just want to try new
things, here's my __Hugo How To__.

# Setup the site
## Install Hugo and get it running
Hugo [is easy to install][hugo-install], you can download its
binary or install it via [Homebrew](http://brew.sh/) like I did
or if you feel a bit adventurous you might want to build it from
source, which might as well quite easy. To get Hugo runs actually
took quite minimal effort. The [quickstart](https://gohugo.io/overview/quickstart/) do a really
good job to explain the step by step.

One more thing I like about Hugo is it provides a better working
structure compared to Docpad. When creating a new site by running
`hugo new /path/to/site`, Hugo creates a working skeleton
structure comprises `archtypes`, `content`, `data`, `layouts`,
`static` and `themes`. Those directories are where we supposed
to put pre-configured _front matter_, blog contents (posts),
data, site layouts, static files and themes that we want to use.
The [Source Organization](https://gohugo.io/overview/source-directory/)
section elaborates on the directory structure deeper.

## Pick your theme and make it yours
Hugo comes up with quite a lot [ready to use themes](http://themes.gohugo.io/).
You can try all the themes by simply [clone all the themes](https://github.com/spf13/hugoThemes)
and run `hugo server -t <theme-name>`. The command tells Hugo
to load the specified theme and use it to render the site then
runs a HTTP server to serve the generated site. If no directory
given (using `-d` option), Hugo generates the site to your
machine's memory when running the `hugo server` command.

If none of the themes up to your liking, then you can
[customize them](https://gohugo.io/themes/customizing/)
quite easy. You don't need edit directly the theme you are using,
you only need to override the specific part to your liking
instead. The easiest way to do this is by copying the part that
you want to change from the themes directory to its respective
directory in your site, e.g.,

```sh
cp /themes/redlounge/layouts/index.html layouts/index.html
```

and start modifying it. The way Hugo determines the layout
is to find respective files in `layouts` then using defaults
`layouts/_defaults` if the desired file can't be found.
The search is then propagated to the used theme `themes/used-theme` if the file still not found.

For this blog, I choose [hugo-redlounge](https://github.com/tmaiaroto/hugo-redlounge)
as the base of my blog theme and customized it as you see now. Most of the customizations are related to styles, hence,
I use [SCSS](http://sass-lang.com/) to modularize my custom CSS.
I put all the SCSS files in a separate `src` directory and only
the resulting CSS is put in the `static` directory to be used.
Another way is to clone [Steve Francia's website](https://github.com/spf13/spf13.com), which looks
really awesome and start to customize it as you see fit.

## Migration
Migrating from Docpad to Hugo should be easy assuming the posts
are written in markdown format. In my case, I just needed to copy all posts into `content/post`. Copying the markdowns alone should be
enough to make Hugo renders them. However, you might want to
change the posts' [front matter](https://gohugo.io/content/front-matter)
to adhere Hugo's format. Next is to migrate all the static files
to directory `static`.

# Hosting on GitHub
There are several ways to deploy generated site to GitHub-Pages.
Using `git subtree` is one of them like shown in
[this tutorial](https://gohugo.io/tutorials/github-pages-blog/).
The cons of this method is that you also keep track the generated
site directory to your working repository. This is a problem for
me as I have quite slow internet connection so I need the
the repository to be as small as possible.

To solve the problem, I did is similar to what I did
previously to Docpad: make the generated site directory (default
is `public`) ignored then clone the existing [gh_pages](https://pages.github.com/)
(create one if necessary) to directory `public`. When deploying to GitHub, the sequence is: copy `public/.git`, `public/.gitignore`
somewhere else, generate the site, put back `.git` and
`.gitignore` to `public` then commit and push it.

```bash
# Do this only one time when setting up public dir.
# Assuming you are inside your working directory.
git clone git@github.com:user/user.github.io.git public
echo "public" >> .gitignore

# commit and push your repository
git commit -m "ignore public"
git push origin master

# Deployment sequence
# create temporary directory
mkdir tmp

# copy .git/ to temp
cp -r public/.git tmp/.git
cp public/.gitignore tmp/.gitignore

# clean out directory public and regenerate htmls
rm -rf public

# generate static htmls
hugo -t some_theme

# copy back the git files
cp -r tmp/.git public/.git
cp tmp/.gitignore public/.gitignore

# go to the out folder
pushd public > /dev/null

# create .nojekyll file
# https://github.com/blog/572-bypassing-jekyll-on-github-pages
touch .nojekyll

# add and push to github pages
git add -A
git commit -m "`date`"
git push -f origin master

# change back to root dir
popd > /dev/null

# remove temp directory
rm -rf tmp
```

# Automation
What I did next is to automate repetitive tasks such as deployment steps above, which is quite lengthy and prone to errors.
For this project
I decided to use [gnu][gnu] [make][make] as the build tool
---I used this
[bash script][deploy] when dealing with Docpad previously.
Besides deployment, I created tasks for [creating new post, generate static sites, clean the working directory And GitHub-Pages deployment setup][mymake].

{{< sectionsign >}}

Overall, Hugo is a nice tool to play with. It is very fast, customizable and easy to operate. There are a lot of Hugo's
features that yet to explore, e.g., shortcodes, taxonomies,
scratch, etc. Up to this point, I am a satisfied Hugo's user, but,
we'll see.

[docpad]: {{< relref "post/2014-12-28-blogging-with-docpad.html.md" >}}
[hugo]: https://gohugo.io/
[golang]: https://golang.org/
[spf13]: http://spf13.com/
[hugo-install]: https://gohugo.io/overview/installing/
[deploy]: https://gist.github.com/npatmaja/7f30c79c08cb315466dd#file-deploy
[gnu]: https://www.gnu.org/software/make/manual/make.html
[make]: https://en.wikipedia.org/wiki/Make_(software)
[mymake]: https://github.com/npatmaja/nauvalatmaja.com/blob/master/Makefile
