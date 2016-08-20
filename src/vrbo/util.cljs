(ns vrng.util
  (:require
   [reagent.core :as reagent :refer [atom]]
   [clojure.string :as str]
   cljsjs.moment
   cljsjs.moment.locale.de))

;; ------------------------------
;; STATE

(defonce state
  (atom (js->clj (.-initialSnapshot js/window) :keywordize-keys true)))

(defn reset-state! [data]
  (reset! state data))

;; ------------------------------
;; TRANSLATIONS

(defonce translations
  (atom (js->clj (.-translations js/window))))

(defn t [& key]
  (let [keys (flatten (map #(clojure.string/split % ".") key))]
    (reduce get @translations keys)))

;; ------------------------------
;; TIMES

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


;; ------------------------------
;; TIMER

(defn inc-now [a-map]
  (update-in a-map [:now] inc))

(defn start-timer [a-atom]
  (js/setInterval #(swap! a-atom inc-now) 1000))

;; ------------------------------
;; MESSAGEING

(defn setup-faye [channel handler]
  (print "Subscribe" channel "...")
  (.subscribe js/fayeClient channel
              #(handler (js->clj %  :keywordize-keys true))))

;; ------------------------------
;; GA

(defn track-event [arguments]
  (if (exists? js/_gaq)
    (let [args (str/split arguments #" ")]
      (.push js/_gaq (clj->js (cons "_trackEvent" args))))
    (print "track:" arguments)))
