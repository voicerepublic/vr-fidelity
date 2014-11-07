      __ _     _      _ _ _
     / _(_) __| | ___| (_) |_ _   _
    | |_| |/ _` |/ _ \ | | __| | | |
    |  _| | (_| |  __/ | | |_| |_| |
    |_| |_|\__,_|\___|_|_|\__|\__, |
                              |___/
Welcome to Fidelity
===================

Fidelity will run audio strategies comprised of a plethora of other
audio tools.


## Run Tests

    rspec spec


## Debugging

When running fidelity from the commandline, prepend this to enable
full stack traces on errors:

    DEBUG=1 fidelity ...


## Installation

Add this line to your application's Gemfile:

    gem 'fidelity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fidelity


## Usage

### CLI

    fidelity run <manifestfile>

    fidelity analyze <manifestfile>


### Code

    Fidelity::ChainRunner.new(path).run(logger)

While

* `path` - a path to manifest file
* `logger` - optional, if given should be an instance of Logger


## The Gory Details

The manifest file should contain the following:

    ---
    :id: <id>
    :chain:
      - precursor
      - kluuu_merge
      - m4a
      - ogg
      - mp3
      - ...
    :talk_start: <timestamp>
    :talk_stop: <timestamp>
    :cut_conf:
      - start: <offset>
        end: <offset>
      - start: <offset>
        end: <offset>
      - ...

Where...

* Timestamps are down to seconds (not milliseconds!).
* Offsets are down to milliseconds and are relative to the beginning.
* `cut_conf` may be nil, an empty Array or omited entirely
* `chain` is a list of strategy names


## Available Strategies

* [precursor](lib/fidelity/strategy/precursor.rb)
* [normalize](lib/fidelity/strategy/normalize.rb)
* [kluuu_merge](lib/fidelity/strategy/kluuu_merge.rb)
* [user_merge](lib/fidelity/strategy/user_merge.rb)
* [normalize_users](lib/fidelity/strategy/normalize_users.rb)
* [talk_merge](lib/fidelity/strategy/talk_merge.rb)
* [trim](lib/fidelity/strategy/trim.rb)
* [cut](lib/fidelity/strategy/cut.rb)
* [m4a](lib/fidelity/strategy/m4a.rb)
* [mp3](lib/fidelity/strategy/mp3.rb)
* [ogg](lib/fidelity/strategy/ogg.rb)
* [move_clean](lib/fidelity/strategy/move_clean.rb)
* [jinglize](lib/fidelity/strategy/jinglize.rb)
* [auphonic](lib/fidelity/strategy/auphonic.rb)


## TODO

* further improve debugging and logging
* use [slop](/leejarvis/slop) or [docopt](/docopt/docopt.rb)
