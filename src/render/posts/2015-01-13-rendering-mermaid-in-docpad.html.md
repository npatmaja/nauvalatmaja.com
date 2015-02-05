---
layout: post
title: "Rendering Mermaid in Docpad"
date: 2015-01-13 10:23
comments: true
tags: [Mermaid, DocPad, Marked, docpad-plugin-marked]
---
I stumbled across [Mermaid](http://knsv.github.io/mermaid/) when I saw 
[@ronaldwidha retweeted a tweet about it](https://twitter.com/nikmd23/status/553224624130228225). 
Mermaid is a library for *writing* diagrams instead of draw 
them similar to [Marked](https://github.com/chjj/marked)
to markdown, awesome! So, I thought I could use this in my blog just in case I 
need to draw some flowcharts or sequence diagrams in the future.

DocPad uses Marked to render markdown to html via 
[docpad-plugin-marked](https://github.com/docpad/docpad-plugin-marked) 
but natively, it doesn't support 
Mermaid syntax. Fortunately, Marked provide 
[a way to override its renderer](https://github.com/chjj/marked#overriding-renderer-methods),
however, it is not yet supported in the current release of the docpad-plugin-marked,
and [someone created a ticket on this issue](https://github.com/docpad/docpad-plugin-marked/issues/11). 
So based on the 
explanation there, I forked the plugin and started to hack it down. 
To add the functionality itself was not that hard but to define a proper test
for the plugin was tougher than it looks, at least at first as I didn't quite 
understand how DocPad's plugin tester works. Thanks to [this awesome post](http://www.delarre.net/posts/unit-testing-docpad-plugins/), 
I could finally write and pass the test. The working version of my fork
can be found [at my GitHub](https://github.com/npatmaja/docpad-plugin-marked).

<!-- Read more -->

To use the forked plugin, change the dependency definition in `package.json`:

```json
"docpad-plugin-marked": "git+ssh://git@github.com:npatmaja/docpad-plugin-marked.git"
```
Next is to redefine the `code` renderer by putting the definition in the `docpad.coffee`

```
plugins:
  marked:
    markedRenderer:
      code: (code, lang) ->
        escape = (html, encode) ->
          pattern = if !encode then /&(?!#?\w+;)/g  else /&/g
          return html
            .replace(pattern, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;')
            .replace(/'/g, '&#39;')

        if code.match(/^sequenceDiagram/)|| code.match(/^graph/)
          return "<div class=\"mermaid\">\n#{code}\n</div>\n"
        else
          if @options.highlight
            out = @options.highlight code, lang
            if out != null && out != code
              escaped = true
              code = out

          if !lang
            return '<pre><code>' +
              (if escaped then code else escape(code, true)) +
              '\n</code></pre>'
          
          return '<pre><code class="' +
            this.options.langPrefix +
            escape(lang, true) +
            '">' +
            (if escaped then code else escape(code, true)) +
            '\n</code></pre>\n'
```
Lastly, I added Mermaid.js to blog's layout as mentioned on Mermaid's
documentation. Now all are set to their place, so whenever I put Mermaid 
syntax in a markdown's code block <code>```</code> the code will 
be transformed to svg image. 

Without further ado, below are a couple of examples of Mermaid diagram
definition and their respective rendered diagram. It's show time!

# Simple graph
```
%% remove comment to render the graph
graph TB 
  subgraph one 
    a1-->a2
  end
  subgraph two
    b1-->b2
  end
  subgraph three
    c1-->c2
  end
  c1-->a2
```

```
graph TB 
  subgraph one 
    a1-->a2
  end
  subgraph two
    b1-->b2
  end
  subgraph three
    c1-->c2
  end
  c1-->a2
```

# Sequence diagram
```
%% remove comment to render the diagram
sequenceDiagram
  Alice ->> Bob: Hello Bob, how are you?
  Bob-->>John: How about you John?
  Bob--x Alice: I am good thanks!
  Bob-x John: I am good thanks!
  Note right of John: Bob thinks a long<br/>long time, so long<br/>that the text does<br/>not fit on a row.

  Bob-->Alice: Checking with John...
  Alice->John: Yes... John, how are you?
```

```
sequenceDiagram
  Alice ->> Bob: Hello Bob, how are you?
  Bob-->>John: How about you John?
  Bob--x Alice: I am good thanks!
  Bob-x John: I am good thanks!
  Note right of John: Bob thinks a long<br/>long time, so long<br/>that the text does<br/>not fit on a row.

  Bob-->Alice: Checking with John...
  Alice->John: Yes... John, how are you?
```

## Side note
The CSS I use to style the diagram can be seen [here](https://raw.githubusercontent.com/npatmaja/nauvalatmaja.com/master/src/render/styles/mermaid.less). Happy diagramming!