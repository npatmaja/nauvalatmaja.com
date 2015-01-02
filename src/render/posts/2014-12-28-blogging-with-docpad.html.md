---
layout: post
title: "Blogging with Docpad"
date: 2014-12-28 17:31
comments: true
tags: blog, docpad, node.js
---

It has been a long time since I planned to have a dedicated blog for 
writing about some more _"meaningful"_ stuff instead of just
my rumbling I posted on my [trash bin](http://noval78.wordpress.com). 
After looking out what blogging platforms available, I finally decided 
to use [GitHub pages](https://pages.github.com/) 
to host my posts. However, as it uses [Jekyll](https://github.com/jekyll/jekyll)
as its engine, many people suggested to install Jekyll in my local machine, which
was a no-show for me. So I tried to built it 
manually without installing Jekyll locally, which was proven to be a 
hard thing to do. Later, I had to postponed the project
due to some higher priority activities until recent time.

As I am now re-learning javascript and node.js, I searched about static 
blogging with node.js to pick this blog project up once again, with a resolution 
to make it online. And that was how I came accross
[docpad](http://docpad.org), a dinamyc static site generator built 
using node.js. Similar to Jekyll, it can render markdown files to 
bunch of static htmls. Surprisingly, to build a blog using docpad wasn't hard 
thing to do. There were skeletons that you can choose
to bootstrap your blog when you first run `docpad run`.

![docpad skeletons][skeletons]

After creating the skeleton, next thing that is needed to do is to 
customize blog's appearance. Since I am bad at web design, I searched 
for blogs built using 
docpad whom source hosted on github. Fortunately, I found
[Erv Walter's blog](http://www.ewal.net) which satisfied my 
requirements for being simple and clean. So I cloned the blog's repository
and adapted it to the skeleton I used and did some minor changes, 
and _voila_ here it is. Lastly, I
used [GitHub pages plugin](https://docpad.org/plugin/ghpages)
to [push the blog to github](http://seethroughtrees.github.io/posts/github-pages-with-docpad/).

[skeletons]: /images/docpad-run-skeleton.png