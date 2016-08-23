(ns vrbo.dashboard
  (:require
   [vrbo.util :as u :refer [to-millis]]
   ;;[vrng.sporktrum :as spork]
   [reagent.core :as reagent :refer [atom]]
   [reagent.session :as session]
   ;;[secretary.core :as secretary :include-macros true]
   [ajax.core :refer [PUT]]
   [clojure.string :as str]
   ;;[cljsjs.selectize]
   cljsjs.moment
   goog.string.format
   goog.string)
  (:require-macros [cljs.core :refer [exists?]]))

;; ------------------------------
;; state

(defonce state (atom {:line-mapping {}}))

;; ------------------------------
;; demo data

(defn populate-with-demo-data []
  (swap! state assoc :lines
         {"sophie-glaser1"
          {:key         "sophie-glaser1"
           :instance-id "i-065618ba"
           :client-type "butt"
           :listener-count 1
           :venue-state "offline"
           :client-heartbeat (js/moment)
           :server-heartbeat (js/moment)
           :talks
           [{:slug  "a"
             :starts-at (.subtract (js/moment) 2 "hours")
             :ends-at (.subtract (js/moment) 1 "hours")
             :title "Anglo-American Cyclopedia 1917 edition"}
            {:slug  "b"
             :starts-at (.add (js/moment) 1 "hours")
             :ends-at (.add (js/moment) 2 "hours")
             :title "A First Encyclopaedia of Tlön"}
            {:slug  "c"
             :starts-at (.add (js/moment) 3 "hours")
             :ends-at (.add (js/moment) 4 "hours")
             :title "History of a Land called Uqbar by Silas Haslam"}]}

          "sophie-glaser2"
          {:key         "sophie-glaser2"
           :instance-id "i-065618bb"
           :client-type "darkice"
           :listener-count 2
           :venue-state "available"
           :client-heartbeat (js/moment)
           :server-heartbeat (js/moment)
           :talks
           [{:slug  "a"
             :starts-at (.subtract (js/moment) 2 "hours")
             :ends-at (.subtract (js/moment) 1.5 "hours")
             :title "Anglo-American Cyclopedia 1917 edition"}
            {:slug  "b"
             :starts-at (.subtract (js/moment) 3 "hours")
             :ends-at (.subtract (js/moment) 2.5 "hours")
             :title "A First Encyclopaedia of Tlön"}
            {:slug  "c"
             :starts-at (.subtract (js/moment) 4 "hours")
             :ends-at (.subtract (js/moment) 3.5 "hours")
             :title "History of a Land called Uqbar by Silas Haslam"}]}

          "sophie-glaser3"
          {:key         "sophie-glaser3 akljshdkjashd a"
           :instance-id "i-065618bc"
           :client-type "streamboxx"
           :client-name "Aristoteles"
           :client-state "streaming"
           :listener-count 6
           :venue-state "awaiting_stream"
           :client-heartbeat (js/moment)
           :server-heartbeat (js/moment)
           :talks
           [{:slug  "a"
             :starts-at (.subtract (js/moment) 2 "hours")
             :ends-at (.subtract (js/moment) 1 "hours")
             :title "Anglo-American Cyclopedia 1917 edition"}
            {:slug  "b"
             :starts-at (.subtract (js/moment) 4 "hours")
             :ends-at (.subtract (js/moment) 3 "hours")
             :title "A First Encyclopaedia of Tlön"}
            {:slug  "c"
             :starts-at (.subtract (js/moment) 6 "hours")
             :ends-at (.subtract (js/moment) 5 "hours")
             :title "History of a Land called Uqbar by Silas Haslam"}]}
          })
  (swap! state assoc :line-mapping
         {"sophie-glaser1" "sophie-glaser1"
          "sophie-glaser2" "sophie-glaser2"
          "sophie-glaser3" "sophie-glaser3"}))

(populate-with-demo-data)

;; ------------------------------
;; data helpers

(defn now []
  (@state :now))

(defn progress [t0 t1 td]
  (* (/ 100 td) (- t1 t0)))

(defn server-heartbeat-progress [line]
  (goog.string.format
   "%.2f%%"
   (max 0 (- 100 (progress (line :server-heartbeat) (js/moment) 4000)))))

(defn client-heartbeat-progress [line]
  (goog.string.format
   "%.2f%%"
   (max 0 (- 100 (progress (line :client-heartbeat) (js/moment) 5000)))))

(defn list-of-lines []
  ;; TODO do sorting
  (doall (map #((@state :lines) %)
              (distinct (vals (@state :line-mapping))))))


(defn window-start []
  (.subtract (js/moment) 4 "hours"))

(defn window-end []
  (.add (js/moment) 4 "hours"))

(defn window-size []
  (- (window-end) (window-start)))

(defn time-position
  ([time] (time-position time ""))
  ([time suffix]
   (let [diff (- time (window-start))]
     (str (goog.string.format "%.3f" (* (/ 100 (window-size)) diff)) suffix))))

(defn duration-width
  ([duration] (duration-width duration ""))
  ([duration suffix]
   (str (goog.string.format "%.3f" (* (/ 100 (window-size)) duration)) suffix)))

(defn window-hour0 []
  (.startOf (window-start) "hour"))

(defn marker-times []
  (map #(.add (window-hour0) % "hours") (range 0 9)))

(defn markers []
  (map #(hash-map :time %
                  :label (.format % "hh:mm")
                  :pos (time-position % "%")) (marker-times)))

(defn talk-width [talk]
  (let [duration (- (talk :ends-at) (talk :starts-at))]
    ;;(prn (/ duration (* 1000 60 60)))
    ;;(prn (/ (window-size) (* 1000 60 60)))
    (duration-width duration "%")))



;; ------------------------------
;; components

(defn now-comp []
  [:div#current-time-holder
   [:div#current-time-badge
    (.format (now) "hh:mm:ss")]])

(defn line-comp [line]
  ^{:key (line :key)}
  [:div.venue-tab.clearfix
    ;;Left side
    [:div.play-button-holder
      [:button.play-button
        [:img {:src "assets/sound_on.svg"}]]]
    ;; right side
    [:div.info-box
     [:div.venue-info [:span.venue-name (line :key)][:span.venue-state.float-right {:class (line :talk-state)} (line :venue-state)]]
     ;; TODO PHIL: accommodate client-state, client-name here, and accommodate addition of state-based css class for state:
     [:div.device-info
      [:span.device-type (line :client-type)]
      (if (line :client-name) [:span.device-name (line :client-name)])
      (if (line :client-state) [:span.device-state (line :client-state)])
      [:span.device-heartbeat-holder.float-right [:span.device-heartbeat {:style {:width (client-heartbeat-progress line)}}]]]
    [:div.server-info
      [:span.server-id (line :instance-id)]
      [:span.listener-count [:img.listener-icon {:src "assets/person.svg"}] (line :listener-count)]
      [:span.server-heartbeat-holder.float-right [:span.server-heartbeat {:style {:width (server-heartbeat-progress line)}}]]]
     ; [:p.state-badges
     ;  [:span.device-type (line :device)]
     ;  [:span.device-type {:class (line :talk-state)} (line :talk-state)]
     ;  [:span.device-type (server-heartbeat-progress line)]]
      ]])

(defn lines-comp []
  [:div#venue-column
   (doall (map line-comp (list-of-lines)))])

(defn talk-comp [talk]
  ^{:key (talk :slug)}
  [:div.time-slot-holder
   {:style {:margin-left (time-position (talk :starts-at) "%")}}
   [:p.time-slot-title (talk :title)]
   [:div.time-slot-fill]
   [:div.time-slot {:style {:width (talk-width talk)}}]])

(defn timeline-comp [line]
  ^{:key (line :key)}
  [:div.venue-timeslot-row
   ;;[:div.point-in-time {:style {:margin-left "350px"}}]
   (if (some? (line :talks))
     (doall (map talk-comp (line :talks))))])

(defn timelines-comp []
  [:div.venue-timeslots
   (doall (map timeline-comp (list-of-lines)))])

(defn marker-comp [marker]
  ^{:key (marker :label)}
  [:div.marker {:style {:margin-left (marker :pos)}} (marker :label)])

(defn markers-comp []
  [:div.markers
   (doall (map marker-comp (markers)))])

(defn main-comp []
  [:main
   [:div#time-grid.ui-draggable.ui-draggable-handle
    {:style {:left "400px" :top "0px"}}
    [markers-comp]
    [timelines-comp]
    [:div#current-time-line]
    [now-comp]]
   [:div#dashboard
    [lines-comp]]])

;; -------------------------
;; briefings (initial data)

;; ------------------------------
;; helpers

(defn line-lookup [key]
  (let [line-key ((@state :line-mapping) key)]
    (if-not line-key
      (do
        (swap! state assoc-in [:line-mapping key] key)
        (swap! state assoc-in [:lines key :key] key)))
    (or line-key key)))

;; -------------------------
;; message handlers

(defn server-heartbeat-handler [heartbeat]
  (let [now (js/moment)
        key (heartbeat :token)
        line-key (line-lookup key)]
    (swap! state assoc-in [:lines line-key :server-heartbeat] now)))

(defn client-heartbeat-handler [heartbeat]
  (let [now (js/moment)
        key (heartbeat :identifier)
        line-key (line-lookup key)]
    (swap! state assoc-in [:lines line-key :client-heartbeat] now)))

(defn client-report-handler [data]
  (let [key (data :identifier)
        path [:client-report key]]
    (swap! state assoc-in path data)))

(defn server-stats-handler [data]
  (let [key (data :slug)
        path [:server-stats key]]
    (swap! state assoc-in path data)))

(defn venues-handler [data]
  (let [key ((data :venue) :slug)
        path [:venue key]]
    (swap! state assoc-in path data)))

(defn talks-handler [data]
  (let [key ((data :talk) :slug)
        path [:talk key]]
    (swap! state assoc-in path data)))

(defn client-event-handler [data]
  (let [key (data :identifier)
        path [:client-event key]]
    (swap! state assoc-in path data)))

(defn connections-handler [data]
  (let [key (data :slug)
        path [:connection key]]
    (swap! state assoc-in path (data :event))))

;; -------------------------
;; init helpers

(def fps 30)
(def interval (/ 1000 fps))

(defonce then (atom (.now js/Date)))
(swap! state assoc :now (js/moment))

(defn update-loop []
  (js/requestAnimationFrame update-loop)
  (let [now (.now js/Date)
        delta (- now @then)]
    (when (> delta interval)
      (swap! state assoc :now (js/moment))
      (reset! then (- now (mod delta interval))))))


(defn subscribe [channel handler]
  (.subscribe js/fayeClient channel
              #(handler (js->clj %  :keywordize-keys true))))

(defn mount-root []
  (reagent/render [main-comp] (.getElementById js/document "livedashboard")))

;; -------------------------
;; initialize

(defn init! []
  (mount-root))

(update-loop)

(subscribe "/report"            client-report-handler)
(subscribe "/heartbeat"         client-heartbeat-handler)
(subscribe "/admin/stats"       server-stats-handler)
(subscribe "/admin/venues"      venues-handler)
(subscribe "/admin/talks"       talks-handler)
(subscribe "/admin/connections" connections-handler)
(subscribe "/server/heartbeat"  server-heartbeat-handler)
(subscribe "/event/devices"     client-event-handler)
