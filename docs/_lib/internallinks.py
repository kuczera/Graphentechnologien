#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Pandoc filter to convert divs with class to LaTeX
environments  of the same name.
"""
import sys
from urllib.parse import urlparse

from pandocfilters import toJSONFilter, Link

def internallinks(key, value, format, meta):
    if key == 'Link':
        [attrs, contents, [url, title]] = value
        o = urlparse(url)
        if not o.scheme and not o.netloc and o.fragment:
            url = '#' + o.fragment
            return Link(attrs, contents, (url, title))

if __name__ == "__main__":
    toJSONFilter(internallinks)
