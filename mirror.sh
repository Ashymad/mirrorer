#!/bin/sh

set -e

while read line; do
    srepo="$(echo "$line" | cut -d' ' -f1)"
    reponame="$(echo "$srepo" |  sed 's@.*/@@')"
    owner="$(echo "$srepo" | sed 's@.*/\(.*\)/.*@\1@')"
    srepodir="$PWD/git/$reponame"
    wrepodir="$PWD/web/$reponame"

    [ -d "$srepodir" ] || git clone --mirror "$srepo" "$srepodir"

    for drepo in $(echo "$line" | cut -d' ' -f2-); do
        git -C "$srepodir" push --mirror "$drepo"
    done

    echo "$owner" > "$srepodir/owner"
    echo "$srepo" > "$srepodir/url"
    echo ":)" > "$srepodir/description"

    mkdir -p "$wrepodir"
    cp style.css logo.png "$wrepodir"
    ( cd "$wrepodir"; stagit "$srepodir"; )
done < mirrorlist

cp style.css logo.png web
stagit-index git/* > web/index.html
