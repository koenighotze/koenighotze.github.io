---
title:  Commandline hack for using Devhints.io
date:   2018-02-16
tags: ["CLI", "Shell", "hack"]
---

After listening to episode 283 of [The Changelog Podcast](https://changelog.com/podcast/283), I decided that I want to use the awesome cheat sheet repository at [Devhints](https://devhints.io) on the command-line.

This is what I came up with: if you want to read the cheat sheet for React, just type

```bash
$ hint react
```

and, voila, the sheet appears.


{{< figure src="/assets/images/2018-02-16/tty.gif"  >}}

The shell script needs both `wget` and `mdless`, which you can install using your favorite package manager. The sheets are fetched from Devhints.IO's [Github repository](https://github.com/hazeorid/devhints.io).

Sheet files are cached in `$HOME/.hack` and can be refreshed using the `--refresh` command-line argument.

If you like the idea of cheat sheets in your terminal, you might also want to checkout [TLDR](https://github.com/tldr-pages/tldr), which explains tools using examples - basically, it just reverses the classic man pages ;)

Anyway...

Let me know if you have a better way or some idea for improving this tiny snippet:

{{< gist koenighotze 2ff36346a1c6baaacf95d154b5fa264b >}}