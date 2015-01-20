#!/bin/sh

sox -n 1.wav rate -L 8k synth 5 sine 1000-100 tremolo 5
