#!/usr/bin/env python3

import argparse
import re
import os
import os.path


class Matcher:
    """A regexp and a handler in case of match"""

    def __init__(self, pat, handler):
        self.pat = re.compile(pat)
        self.handler = handler

    def process(self, text):
        m = self.pat.match(text)
        if m:
            return self.handler(m)
        return None


def always_none(m):
    """Always return None"""
    return None


def first_group(m):
    """Returns the first group of the match"""
    return m.group(1)


tex_matcher = Matcher('^INPUT (.+)$', first_group)


def scan_tex_file(tex):
    deps = set()
    with open(tex) as f:
        for l in f:
            path = tex_matcher.process(l)
            if path and os.path.isabs(path):
                deps.add(os.path.realpath(path))
    return deps


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('file', help='input file')
    parser.add_argument("-o", "--out", help="output file")
    parser.add_argument("-t", "--target", help="target file")

    args = parser.parse_args()
    input_file = args.file
    output_file = args.out
    target_file = args.target

    proj_dir = os.path.realpath(os.getcwd())
    deps = {('.' + d[len(proj_dir):])
            for d in scan_tex_file(input_file)
            if d.startswith(proj_dir)}

    with open(output_file, 'w') as f:
        f.write('{}: \\\n'.format(target_file))
        f.write('\t{}'.format(' \\\n\t'.join(deps)))
        f.write('\n\n')
        f.write(''.join([d + ':\n' for d in deps]))
