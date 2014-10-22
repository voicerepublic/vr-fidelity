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

    fidelity run <metadatafile>


### Code

    Fidelity::Exec.run(path, logger)

While

* `path` - a path to metadata file
* `logger` - optional, if given should be an instance of Logger


## The Gory Details

Fidelity expects a file `metadata.yml` in the current working
directory. This file should contain the following:

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
* `cut_conf` may be nil or an empty Array.
* `chain` is a list of strategy names


## Available Strategies

* [precursor](lib/fidelity/strategy/precursor.rb)
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
