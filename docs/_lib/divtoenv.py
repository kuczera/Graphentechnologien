#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Pandoc filter to convert divs with class to LaTeX
environments  of the same name.
"""

from pandocfilters import toJSONFilter, RawBlock, Div

def latex(x):
    return RawBlock('latex', x)


def divtoenv(key, value, format, meta):
    if key == 'Div' and format == 'latex':
        [[ident, classes, kvs], contents] = value
        if classes:
            klass = classes[0]
            return([latex(r'\begin{{{}}}'.format(klass))] + contents +
                   [latex('\end{{{}}}'.format(klass))])

if __name__ == "__main__":
    toJSONFilter(divtoenv)
