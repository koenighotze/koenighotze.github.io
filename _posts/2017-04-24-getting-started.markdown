---
title:  "Getting started with Jekyll, Github pages..."
date:   2017-04-24 15:48:54 +0200
categories: jekyll githubpages
permalink: /gh-pages/getting-started-with-gh-pages.html
---
This post summarizes the steps needed to set up a site such as this.

* TOC
{:toc}

## Setup Github

Create a new repository following the convention `<USERNAME>.github.io` as the repository name. E.g.
in my case, this is the repository available at [https://github.com/koenighotze/koenighotze.github.io]().
Like this, a so-called organization site, every push to the `master` branch will be published to the site itself.

## Setup local Jekyll

Jekyll is used to both create an online presence and to create a local preview of the site.
See below for rendering locally.

The installation is explained at [Github's Jekyll Tutorial](https://help.github.com/articles/setting-up-your-github-pages-site-locally-with-jekyll/).

## Configure the site

As I wanted to use the theme `jekyll-theme-architect`, I needed to modify the `_config.yml` and fetch some files from the `minima` template.

### Modifying the Jekyll configuration

Replace

```ruby
theme: minima
```

with

```ruby
theme: jekyll-theme-architect
```

The other values of note might be `title` and `description`, which are rather obvious.

### Stealing from minima

Running this configuration will result in errors such as

``
Build Warning: Layout 'page' requested in about.md does not exist.
``

or

``
jekyll 3.4.3 | Error:  Could not locate the included file 'icon-github.html' in any of ["/Users/dschmitz/dev/koenighotze.github.io/_includes"]. Ensure it exists in one of those directories and, if it is a symlink, does not point outside your site source.
``

This is a result of missing `minima` files in the `jekyll-theme-architect` theme. The easiest solution - at least the one I came up with ;) - was to copy the missing files from `minima` to the local site:

```javascript
$ pushd ..
$ git clone git@github.com:jekyll/minima.git
$ popd
$ cp -rvf ../minima/_includes .
$ cp -rvf ../minima/_layouts .
$ rm _layouts/default.html
```

We copy the `_includes` and `_layouts` to our local, new site. But, as we do not want to mess with the default `jekyll-theme-architect` theme layout, we remove the `default.html`.

## Render locally

```javascript
$ bundle exec jekyll serve
```

The site is available at `http://127.0.0.1:4000/`. Any errors will be reported by Jekyll, so you can fix it locally before pushing to Github.

## Combining with Browser-Sync

Now install browser-sync and voila, live-reloading in your browser

```javascript
$ npm i -g browser-sync
$ browser-sync  start -p http://127.0.0.1:4000/
```
