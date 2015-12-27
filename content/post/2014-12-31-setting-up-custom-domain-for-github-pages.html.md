---
title: "Setting Up Custom Domain for GitHub Pages"
date: 2014-12-31
tags: ["GitHub Pages", "custom domain", NameCheap, CloudFlare]
categories: [Web]
socialsharing: true
totop: true
---
It has been a couple days since [nauvalatmaja.com][link:nauval] is online,
and to be honest the process was not as hard as I had imagined. Kudos to
[David Ensinger][link:david] who has written in details on
how he [set up his custom domain for his GitHub pages][link:set-up-namecheap] and
[tweak it to get faster by using cloudflare][link:set-up-cloudflare]. All
the needed information to do this can be found there.

I purchased this this domain name at [NameCheap][link:namecheap], as suggested by David's post,
with just a bit more than five bucks for a year. Then, I used the free plan of [CloudFlare][link:cloudflare]
for the DNSs, which I think it is sufficient for my need, and set up the DNS records using `CNAME`
on the CloudFlare panel to point to my GitHub Pages address. Lastly,
[I add a `CNAME` file in the root directory of my GitHub Pages repository to redirect it][link:gh-custom-domain].
And that's it, practically the process is done after you transfer the DNS from NameCheap to
CloudFlare, you may need to wait for a while to make the changes take effect.

It took me less than three hours, more or less, to make my custom domain
accessible. Frankly, I spent more hours thinking the custom domain name I
should use than did the actual setup. I am quite happy with the
setup, hosting static pages on GitHub is right decision. It is simple, easy
and particularly fast, well it's static html pages anyway.

[link:nauval]: http://nauvalatmaja.com/
[link:david]: http://davidensinger.com/
[link:set-up-namecheap]: http://davidensinger.com/2013/03/setting-the-dns-for-github-pages-on-namecheap/
[link:set-up-cloudflare]: http://davidensinger.com/2014/04/transferring-the-dns-from-namecheap-to-cloudflare-for-github-pages/
[link:namecheap]: https://www.namecheap.com/
[link:cloudflare]: https://cloudflare.com
[link:gh-custom-domain]: https://help.github.com/articles/setting-up-a-custom-domain-with-github-pages/
