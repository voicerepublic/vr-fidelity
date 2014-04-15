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


Warning: unicorn_wrapper restart
--------------------------------
DEBUG [78ea7dd4]  pkill:
DEBUG [78ea7dd4]  killing pid 1231 failed
DEBUG [78ea7dd4]  : Operation not permitted

This error shows up in the log while deploying, since it tries to kill
processes it doesn't own. While this is not a problem, it is somewhat
irritating.