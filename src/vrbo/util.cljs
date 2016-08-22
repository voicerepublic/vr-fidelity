(ns vrbo.util
  (:require
   [reagent.core :as reagent :refer [atom]]
   [clojure.string :as str]
   cljsjs.moment
   cljsjs.moment.locale.de))

;; ------------------------------
;; times

(def datetime-format "YYYY-MM-DD hh:mm:ss Z")

(defn to-millis [datetime]
  (.format (.moment js/window datetime datetime-format) "x"))

(defn from-now [datetime]
  (.fromNow (.moment js/window datetime "x")))

(defn to-dhms [millis]
  (let [base    (/ (Math/abs millis) 1000)
        minute  60
        hour    (* 60 minute)
        day     (* 24 hour)
        days    (int (/ base day))
        hours   (int (/ base hour))
        minutes (- (int (/ base minute)) (* hours minute))
        seconds (- (int base) (* hours hour) (* minutes minute))]
    [days hours minutes seconds]))

(defn percentage [current total]
  (min 100 (* current (/ 100 total))))

(.locale js/moment "en") ;; or "de", depending on user settings
