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


## Installation

Add this line to your application's Gemfile:

    gem 'fidelity'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fidelity


## Usage

Fidelity operates on the current working directory. It will read the
`metadata.yml` file.


### CLI

    fidelity <strategy> [strategy ...]

Where `strategy` is one of

* precursor
* normalize
* kluuu_merge
* user_merge
* normalize_users
* talk_merge
* trim
* cut
* m4a
* mp3
* ogg
* move_clean
* jinglize
* auphonic


### Code

    Fidelity::Exec.run(strategies, logger)

While

* `strategies` - an Array of names
* `logger` - optional, if given should be an instance of Logger


## The Gory Details

Fidelity expects a file `metadata.yml`. This file should contain the
following:

    ---
    id: <id>
    talk_start: <timestamp>
    talk_stop: <timestamp>
    cut_conf:
      - start: <offset>
        end: <offset>
      - start: <offset>
        end: <offset>
      - ...

Timestamps are down to seconds (not milliseconds!). Offsets are down
to milliseconds and are relative to the beginning.
