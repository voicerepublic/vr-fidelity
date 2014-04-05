Deployment Notes
================


ERROR rbenv: 1.9.3-p448 is not installed
----------------------------------------

    backend@voicerepublic-staging:~$ rbenv versions
    backend@voicerepublic-staging:~$ rbenv install 1.9.3-p448
    Downloading yaml-0.1.6.tar.gz...
    [...]
    backend@voicerepublic-staging:~$ rbenv versions
    1.9.3-p448
    backend@voicerepublic-staging:~$ rbenv global 1.9.3-p448
    backend@voicerepublic-staging:~$ rbenv versions
    * 1.9.3-p448 (set by /home/backend/.rbenv/version)
  

rbenv: bundle: command not found
--------------------------------

    backend@voicerepublic-staging:~$ gem install bundler
    Fetching: bundler-1.6.1.gem (100%)
    [...]


DEBUG [60fe565e]  database configuration does not specify adapter
-----------------------------------------------------------------

TODO