# The DocPad Configuration File
# It is simply a CoffeeScript Object which is parsed by CSON
cheerio = require('cheerio')
url = require('url')
docpadConfig =

  # Template Data
  # =============
  # These are variables that will be accessible via our templates
  # To access one of these within our templates, refer to the FAQ: https://github.com/bevry/docpad/wiki/FAQ

  templateData:

    # Specify some site properties
    site:
      # The production url of our website
      url: "http://nauvalatmaja.com"

      cleanUrl: "www.nauvalatmaja.com"

      # Here are some old site urls that you would like to redirect from
      oldUrls: [
        
      ]

      # The default title of our website
      title: "nauval atmaja"

      # The website description (for SEO)
      description: """
        Nauval Atmaja's personal notes on software development and all that
        """

      # The website keywords (for SEO) separated by commas
      keywords: """
        software, engineering, software engineering, architecture, software architecture, programming, thought, javascript, node.js,
        ruby on rails, java, HTML, code, hack, tips, trick, *nix, OSX
        """

      # The website author's name
      author: "Nauval Atmaja"

      # The website author's email
      email: "nauval.atmaja@gmail.com"

      # Your company's name
      copyright: () ->
        "© Nauval Atmaja 2014 - #{(new Date).getFullYear()}"



    # Helper Functions
    # ----------------

    # Get the prepared site/document title
    # Often we would like to specify particular formatting to our page's title
    # we can apply that formatting here
    getPreparedTitle: ->
      # if we have a document title, then we should use that and suffix the site's title onto it
      if @document.title
        "#{@document.title} | #{@site.title}"
      # if our document does not have it's own title, then we should just use the site's title
      else
        @site.title

    # Get the prepared site/document description
    getPreparedDescription: ->
      # if we have a document description, then we should use that, otherwise use the site's description
      @document.description or @site.description

    # Get the prepared site/document keywords
    getPreparedKeywords: ->
      # Merge the document keywords with the site keywords
      @site.keywords.concat(@document.keywords or []).join(', ')

    getPageUrlWithHostname: ->
      "#{@site.url}#{@document.url}"

    getIdForDocument: (document) ->
      hostname = url.parse(@site.url).hostname
      date = document.date.toISOString().split('T')[0]
      path = document.url
      "tag:#{hostname},#{date},#{path}"

    fixLinks: (content) ->
      baseUrl = @site.url
      regex = /^(http|https|ftp|mailto):/

      $ = cheerio.load(content)
      $('img').each ->
        $img = $(@)
        src = $img.attr('src')
        $img.attr('src', baseUrl + src) unless regex.test(src)
      $('a').each ->
        $a = $(@)
        href = $a.attr('href')
        $a.attr('href', baseUrl + href) unless regex.test(href)
      $.html()

    moment: require('moment')

    # Discus.com settings
    disqusShortName: 'nauvalatmaja'

    # Google+ settings
    googlePlusId: '112846605467404730226'

    twitter: "https://twitter.com/novalpas"

    github: "https://github.com/npatmaja"

    linkedin: "https://id.linkedin.com/in/nauvalatmaja/"

    getTagUrl: (tag) ->
      slug = tag.toLowerCase().replace(/[^a-z0-9]/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '')
      "/tags/#{slug}/"

    getCuttedContent: (content) ->
      i = content.search('<!-- Read more -->')
      if i >= 0
        content[0..i-1]
      else
        content

    hasReadMore: (content) ->
      content.search('<!-- Read more -->') >= 0

  # Collections
  # ===========
  # These are special collections that our website makes available to us

  collections:
    # For instance, this one will fetch in all documents that have pageOrder set within their meta data
    pages: (database) ->
      database.findAllLive({pageOrder: $exists: true}, [pageOrder:1,title:1])

    # This one, will fetch in all documents that will be outputted to the posts directory
    # posts: (database) ->
    #   database.findAllLive({relativeOutDirPath:'posts'},[date:-1])
    posts: ->
      @getCollection('documents').findAllLive({relativeDirPath: 'posts'}, [date: -1])

    cleanurls: ->
      @getCollection('html').findAllLive(skipCleanUrls: $ne: true)

  environments:
    development:
      collections:
        posts: ->
          @getCollection('documents').findAllLive({relativeDirPath: {'$in' : ['posts', 'drafts']}}, [relativeDirPath: 1,  date: -1])

  # DocPad Events
  # =============

  # Here we can define handlers for events that DocPad fires
  # You can find a full listing of events on the DocPad Wiki
  events:

    # Server Extend
    # Used to add our own custom routes to the server before the docpad routes are added
    serverExtend: (opts) ->
      # Extract the server from the options
      {server} = opts
      docpad = @docpad

      # As we are now running in an event,
      # ensure we are using the latest copy of the docpad configuraiton
      # and fetch our urls from it
      latestConfig = docpad.getConfig()
      oldUrls = latestConfig.templateData.site.oldUrls or []
      newUrl = latestConfig.templateData.site.url

      # Redirect any requests accessing one of our sites oldUrls to the new site url
      server.use (req,res,next) ->
        if req.headers.host in oldUrls
          res.redirect 301, newUrl+req.url
        else
          next()

  plugins:
    tags:
      findCollectionName: 'posts'
      extension: '.html'
      injectDocumentHelper: (document) ->
        document.setMeta(
          layout: 'tags'
        )
    dateurls:
      cleanurl: true
      trailingSlashes: true
      keepOriginalUrls: false
      collectionName: 'posts'
      dateIncludesTime: true
    paged:
      cleanurl: true
      startingPageNumber: 2
    cleanurls:
      trailingSlashes: true
      collectionName: 'cleanurls'
    highlightjs:
        replaceTab: 2
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

# Export our DocPad Configuration
module.exports = docpadConfig
