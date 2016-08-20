    __     __    _          ____                  _     _ _
    \ \   / /__ (_) ___ ___|  _ \ ___ _ __  _   _| |__ | (_) ___
     \ \ / / _ \| |/ __/ _ \ |_) / _ \ '_ \| | | | '_ \| | |/ __|
      \ V / (_) | | (_|  __/  _ <  __/ |_) | |_| | |_) | | | (__
       \_/ \___/|_|\___\___|_| \_\___| .__/ \__,_|_.__/|_|_|\___|
                                     |_|
     ____             _     ___   __  __ _
    | __ )  __ _  ___| | __/ _ \ / _|/ _(_) ___ ___
    |  _ \ / _` |/ __| |/ / | | | |_| |_| |/ __/ _ \
    | |_) | (_| | (__|   <| |_| |  _|  _| | (_|  __/
    |____/ \__,_|\___|_|\_\\___/|_| |_| |_|\___\___|


Welcome to VoiceRepublic BackOffice
===================================

This app provides the BackOffice interface to the VoiceRepublic
database. Therefore this app will not have any
migrations. VoiceRepublic Dev is the single repository to store and
run migrations from.


Data Migration/Seeds
--------------------

Run

    rake data:migrate:create_admin


Deployment Setup
----------------

`public/system/dragonfly` needs to by symlink to the same directory of
the main app.


Dashboard Notes
---------------

* /server/heartbeat
* /event/devices
