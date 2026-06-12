#!/bin/sh

set -e

while read line; do
    srepo="$(echo "$line" | cut -d' ' -f1)"
    reponame="$(echo "$srepo" |  sed 's@.*/@@')"
    srepodir="git/$reponame"
    wrepodir="web/$reponame"

    [ -d "$srepodir" ] || git clone --mirror "$srepo" "$srepodir"

    env -C "$wrepodir" stagit "$(readlink -f "$srepodir")"
    cp style.css logo.png "$wrepodir"

    for drepo in $(echo "$line" | cut -d' ' -f2-); do
        git -C "$srepodir" push --mirror "$drepo"
    done
done < mirrorlist

stagit-index git/* > web/index.html
cp style.css logo.png web
