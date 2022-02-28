#!/usr/bin/env python3

import argparse
import os
import sys
from datetime import date

import ghapi
from ghapi.actions import github_token


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--owner', required=True)
    parser.add_argument('--path', required=True)
    parser.add_argument('--tag', required=True)

    return parser.parse_args()


def main():
    args = parse_arguments()
    tag = args.tag

    try:
        api = ghapi.core.GhApi(owner=args.owner,
                               repo='arc-gnu-toolchain',
                               token=github_token())


        rel = api.create_release(tag_name=tag,
                                 name=f'GNU Toolchain for ARC Processors, {tag}',
                                 body='**Automated Release**\n'
                                      f'{tag}-release',
                                 prerelease=True)

        for dirs, _, files in os.walk(args.path):
            for file in files:
                asset = os.path.join(dirs, file)
                api.upload_file(rel, asset)

    except Exception as ex:
        sys.exit(ex)


if __name__ == "__main__":
    main()
