#!/bin/sh

set -e

while read line; do
    srepo="$(echo "$line" | cut -d' ' -f1)"

    if [ -d "$srepo" ]; then
        srepourl="$(git -C "$srepo" remote get-url origin)"
    else
        srepourl="$srepo"
    fi

    reponame="$(echo "$srepourl" |  sed 's@.*/@@')"
    owner="$(echo "$srepourl" | sed 's@.*/\(.*\)/.*@\1@')"
    srepodir="$PWD/git/$reponame"
    wrepodir="$PWD/web/$reponame"

    if [ -d "$srepodir" ]; then
        git -C "$repodir" remote update
    else
        git clone --mirror "$srepo" "$srepodir"
    fi

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

cp favicon.png style.css logo.png web
stagit-index git/* > web/index.html
