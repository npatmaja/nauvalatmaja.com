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
After a while, I decided to use [GitHub pages](https://pages.github.com/) 
to host my posts. However, the problem is, I don't want to install 
[Jekyll](https://github.com/jekyll/jekyll) in my machine so I tried to do built it 
manually without installing Jekyll locally, which was proven to be a 
hard thing to do at the. Since I had other 
higher priorities, the project was abandoned till recently.

As I am now re-learning javascript and node.js, I searched about static 
blogging with node.js to pick this blog project up, with a resolution 
to make it online. And that was how I came accross
[docpad](http://docpad.org), a dinamyc static site generator built 
using node.js. Similar to Jekyll, it can render markdown files to 
bunch of static htmls. To build a blog using docpad wasn't hard 
thing to do. There were skeletons that you can choose
to bootstrap your blog when you first run `docpad run`.

![docpad skeletons][skeletons]

Since I am really bad at web design, I searched for blogs built using 
docpad and its source hosted on github. Then, I found
[Erv Walter's blog](http://www.ewal.net) which satisfied my 
requirements: simple and clean. So I cloned the blog's repository
and adapted it to the skeleton I used and did some minor changes, 
and _voila_ here it is. Lastly, I
used [GitHub pages plugin](https://docpad.org/plugin/ghpages)
to [push the blog to github](http://seethroughtrees.github.io/posts/github-pages-with-docpad/).

[skeletons]: /images/docpad-run-skeleton.png