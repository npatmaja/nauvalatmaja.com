---
title: "Ways to Boost Coding Productivity"
date: "2015-04-09"
tags: [code, productivity, tips]
categories: [Productivity]
socialsharing: true
totop: true
---
As a someone who codes frequently, in daily basis in fact, I need an
environment that is able to boost my productivity when coding. Some
might argue that one could be productive in every given environment.
That is the ideal case, however live is not. Hence, productivity
tools and workflows are created.

During my coding adventure, I found some *ways* that help me
to boost up my productivity, which are listed below.

# Use *nix platform
It come across to me that I use shell (terminal) a lot when writing a program,
e.g., navigating through directories, executing commands, committing
to local and remote repositories etc. In that regards,
no better OS to provide that other than *nix (either OS X or linux).
Moreover, they are more stable, more secure and easier to configure rather
than Windows. The last part is a bit bias as I have not been using
Windows for several years now, maybe in the latest release Windows
are more configurable than the previous versions. Well, I'm a pragmatic
person, I use what works for me.

# Use your most comfortable editor
I use [*Sublime Text 3*](http://www.sublimetext.com/3) to code mostly
everything, except Java (I'm still using Eclipse for that).
*Sublime Text* is a powerful yet easy to use
text editor that provides a lot of functionalities. Moreover, it
has myriad of plugins to make developer's life easier and tons of
themes please the eyes, which is also a very important thing (to
me at the very least). If you miss
the efficient vim key bindings, use [vintageaus](https://github.com/guillermooo/Vintageous)
to emulate vim key bindings inside *Sublime Text*.
<!-- Read more -->

# Change to zsh
See
[Brendon Repp's presentation](http://www.slideshare.net/jaguardesignstudio/why-zsh-is-cooler-than-your-shell-16194692)
on why to [zsh](http://www.zsh.org/). I use [oh-my-zsh](http://ohmyz.sh/) to manage the zsh
configuration and all. To sugar its visual, I use the
[agnoster](https://github.com/robbyrussell/oh-my-zsh/wiki/Themes#agnoster) theme. Besides,
the theme directly tells me in what git branch I'm currently working on in an awesome way.
Hence no need to type `git status` to see the working branch. Combined with the right git
aliases, it feels like home when coding.

# Add aliases your shell
Having short aliases is always a good thing to reduce finger movements when typing in
a terminal regardless of what shell you are using. One of useful alias is
aliases to go the the frequently
visited directoris. So, instead of typing `cd ~/codes/learning/nodejs` it's simpler
to just type `learn-nodejs` right?!

# Adopt GitHub Flow and the supporting git aliases
I have been using [GitHub Flow](http://scottchacon.com/2011/08/31/github-flow.html)
for sometime in my recent projects and find it
is a really straight forward approach in managing the development-deployment
workflow when using git. Adding the
[GitHub flow aliases](http://haacked.com/archive/2014/07/28/github-flow-aliases/)
to your `~/.gitconfig` will be even more fun. Here's
[my `.gitconfig`'s aliases section](https://gist.github.com/npatmaja/d72daeb2ec0f21f1af2a)
that has some additional aliases beside the GitHub flow aliases.

# Have a To-do list
A to-do list is a really powerful tool to manage and prioritize your tasks. Sometimes
it is taken for granted but it does help to keep the focus on the tasks that
should be done, especially for an easily distracted person (just like myself).
No need for fancy tools to create a to-do list, any text editor will do. However,
[Evernote](https://evernote.com/) or OS X's Notes or other to-do list apps
will be better choice.

I don't claim the list above is the best way to increase your coding productivity
but it works for me and my current working environment. The list is not and will
never be the final one because achieving better productivity is a long live
adventure.
