### Serpent Bricks Demo

[![License](https://img.shields.io/badge/License-ZLib-blue.svg)](https://opensource.org/licenses/ZLib)

Simple [Serpent](https://github.com/lispysnake/serpent) demonstration employing the age-old premise of 'break the bricks'. Highly similar to
[serpent-demo-paddle]((https://github.com/lispysnake/serpent-demo-paddle)), but significantly less boring.

### Building

To get the dependencies on Solus, issue the following command:

    sudo eopkg it -c system.devel sdl2-image-devel sdl2-devel mesalib-devel ldc dub dmd

As with Serpent, you will **currently** need to have `serpent-support` checked out and built locally.
We're going to address this to allow linking to dynamic bgfx, etc, to make this step much easier.

Make sure you have all modules cloned recursively:

    git submodule update --init --recursive

    ./scripts/build.sh

## Running

    ./bin/serpent-demo-bricks
