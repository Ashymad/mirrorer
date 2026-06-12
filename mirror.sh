#!/bin/sh

set -e

mkdir -p web git
cp style.css logo.png web

while read line; do
    srepo="$(echo "$line" | cut -d' ' -f1)"
    reponame="$(echo "$srepo" |  sed 's@.*/@@')"
    owner="$(echo "$srepo" | sed 's@.*/\(.*\)/.*@\1@')"
    srepodir="git/$reponame"
    wrepodir="web/$reponame"

    [ -d "$srepodir" ] || git clone --mirror "$srepo" "$srepodir"

    mkdir -p "$wrepodir"
    ln -sf ../style.css ../logo.png "$wrepodir"
    echo "$owner" > "$srepodir/owner"
    echo "$srepo" > "$srepodir/urls
    echo ":)" > "$srepodir/description"
    env -C "$wrepodir" stagit "$(readlink -f "$srepodir")"

    for drepo in $(echo "$line" | cut -d' ' -f2-); do
        git -C "$srepodir" push --mirror "$drepo"
    done
done < mirrorlist

stagit-index git/* > web/index.html
