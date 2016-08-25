(ns ^:figwheel-no-load vrng.dev
  (:require [vrng.core :as core]
            [figwheel.client :as figwheel :include-macros true]))

(enable-console-print!)

(figwheel/watch-and-reload
  :websocket-url "ws://localhost:3449/figwheel-ws"
  :jsload-callback core/mount-roots)

(core/init!)
