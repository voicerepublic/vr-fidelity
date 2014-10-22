      __ _     _      _ _ _
     / _(_) __| | ___| (_) |_ _   _
    | |_| |/ _` |/ _ \ | | __| | | |
    |  _| | (_| |  __/ | | |_| |_| |
    |_| |_|\__,_|\___|_|_|\__|\__, |
                              |___/
Welcome to Fidelity
===================

Fidelity will run audio strategies comprised to a plethora of other
audio tools.


## Run Tests

    rspec spec


## Installation

Add this line to your application's Gemfile:

    gem 'fidelity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fidelity


## Usage

Fidelity operates on the current working directory. It will read the
`fidelity.yml` file.


### CLI

    fidelity precursor
    fidelity normalize
    fidelity kluuu_merge
    fidelity user_merge
    fidelity normalize_users
    fidelity talk_merge
    fidelity trim
    fidelity cut
    fidelity m4a
    fidelity mp3
    fidelity ogg
    fidelity move_clean
    fidelity jinglize
    fidelity auphonic


### Code

    Fidelity::Exec.run(args)