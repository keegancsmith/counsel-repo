# counsel-repo

Jump to repository using [ivy](https://github.com/abo-abo/swiper).

![counsel-repo](https://user-images.githubusercontent.com/187831/45005364-bcfe9400-afa7-11e8-8d11-f8c3685d648b.gif)

## Installation

Make sure `counsel-repo.el` is in your `load-path` and then:

``` emacs-lisp
(require 'counsel-repo)
```

Additionally ensure `counsel-repo` is installed onto your `$PATH`:

``` shellsession
$ go get github.com/keegancsmith/counsel-repo
```

## Configuration

By default counsel-repo will search `~/src` (or `$SRCPATHS` if set) and will
open results in dired. An example configuration which opens results in `magit`
and searches both `~/src` and `~/go/src`:

``` emacs-lisp
(setq
 counsel-repo-srcpaths '("~/go/src" "~/src")
 counsel-repo-action #'magit-status)
```

## How it works

[counsel-repo.go](./counsel-repo.go) recursively searches for all paths
containing `.git/HEAD`, returning the paths sorted by the `HEAD` file
mtime. mtime of `HEAD` is used since it is a good indicator for how recently
the repository was used / updated.

The finder is written in Go for performance reasons. For example an equivalent
shell version on my laptop takes 1.29s vs 0.08s of counsel-repo:

``` shellsession
$ /usr/bin/time find ~/go/src ~/src -type d -exec /bin/test -d '{}/.git' \; -print -prune > /dev/null
        1.29 real         0.46 user         0.64 sys
$ /usr/bin/time counsel-repo ~/go/src ~/src > /dev/null
        0.08 real         0.01 user         0.05 sys
```

