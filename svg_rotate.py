#!/usr/local/svg/bin/python

import argparse
import svgutils

parser = argparse.ArgumentParser(description="Rotate 90d svg")
parser.add_argument('--input',       required=True, help='input file')
parser.add_argument('--output',       required=True, help='input file')
args = parser.parse_args()

svg = svgutils.transform.fromfile(args.input)
originalSVG = svgutils.compose.SVG(args.input)
originalSVG.rotate(90)
originalSVG.move(svg.height, 1)
figure = svgutils.compose.Figure(svg.height, float(svg.width) + 2, originalSVG)
figure.save(args.output)
