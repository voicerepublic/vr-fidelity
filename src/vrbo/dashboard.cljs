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
   goog.string
   [com.rpl.specter :as s :refer [NIL->VECTOR END keypath]])
  (:require-macros [cljs.core :refer [exists?]]
                   [com.rpl.specter.macros :as sm :refer [select-one transform setval]]))


;; ------------------------------
;; state

(defonce state (atom {:line-mapping {}}))

;; ------------------------------
;; data helpers

(defn now []
  (@state :now))

(defn parse-time [string]
  (js/moment string "YYYY-MM-DD HH:mm:ss Z"))

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
  ;; TODO do some sorting
  (doall (map #((@state :lines) %)
              (distinct (vals (@state :line-mapping))))))

(defn window-start []
  (.subtract (js/moment) 4 "hours"))

(defn window-end []
  (.add (js/moment) 4 "hours"))

(defn window-size []
  (- (window-end) (window-start)))

;; TODO resolve code duplication in the following 2 functions
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
                  :label (.format % "HH:mm")
                  :pos (time-position % "%")) (marker-times)))

(defn talk-width [talk]
  (let [duration (- (parse-time (talk :ends_at)) (parse-time (talk :starts_at)))]
    (duration-width duration "%")))

;; ------------------------------
;; data helpers

(defn client-type [line]
  (or (line :client_name)
      (get-in @state [:devices (line :device_id) :type])))

(defn client-name [line]
  (get-in @state [:devices (line :device_id) :name]))

(defn client-state [line]
  (get-in @state [:devices (line :device_id) :state]))

;; ------------------------------
;; components

(defn now-comp []
  [:div#current-time-holder
   [:div#current-time-badge
    (.format (now) "HH:mm:ss")]])

(defn line-comp [line]
  ^{:key (line :key)}
  [:div.venue-tab.clearfix
   [:div.play-button-holder ; --- left side
    [:button.play-button
     [:img {:src "assets/sound_on.svg"}]]]
   [:div.info-box ; --- right side
    [:div.venue-info
     [:span.venue-name {:title (str (line :client-report))} (line :key)]
     [:span.venue-state.float-right {:class (line :talk-state)} (line :state)]
     ]
    [:div.device-info
     [:span.device-type {:class (client-type line)} (client-type line)]
     (if (line :device_id)
       [:span.device-name (client-name line)])
     (if (line :device_id)
       [:span.device-state {:class (client-state line)} (client-state line)])
     [:span.device-heartbeat-holder.float-right
      [:span.device-heartbeat {:style {:width (client-heartbeat-progress line)}}]
      ]]
    [:div.server-info
     [:span.server-id (or (line :instance_id) "n/a")]
     [:span.listener-count
      [:img.listener-icon {:src "assets/person.svg"}]
      (select-one [:stats :listener_count] line) "/"
      (select-one [:stats :listener_peak] line) " "
      (goog.string.format "(%d kb/sbr)" (/ (select-one [:stats :bitrate] line) 1024))
      ]
     [:span.server-heartbeat-holder.float-right
      [:span.server-heartbeat {:style {:width (server-heartbeat-progress line)}}]
      ]]]])

(defn lines-comp []
  [:div#venue-column
   (doall (map line-comp (list-of-lines)))])

(defn talk-comp [talk]
  ^{:key (talk :id)}
  [:div.time-slot-holder
   {:style {:margin-left (time-position (parse-time (talk :starts_at)) "%")}}
   [:p.time-slot-title {:style {:width (talk-width talk)}}
    [:a {:href (talk :url)} (talk :title)]]
   [:p.talk-state {:class (talk :state)} (talk :state)]
   [:div.time-slot-fill]
   [:div.time-slot {:style {:width (talk-width talk)}}]])

(defn point-comp [event]
  ^{:key (event :time)}
  [:div.point-in-time
   {:class (event :event)
    :title (event :event)
    :style {:margin-left (time-position (event :time) "%")}}])

(defn timeline-comp [line]
  ^{:key (line :key)}
  [:div.venue-timeslot-row
   (if-not (empty? (line :events))
     (doall (map point-comp (line :events))))
   (if (some? (line :talks))
     (doall (map talk-comp (line :talks))))])

(defn timelines-comp []
  [:div.venue-timeslots
   (doall (map timeline-comp (list-of-lines)))
   ])

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
    [lines-comp]
    ]])

;; ------------------------------
;; helpers

(defn line-lookup [key]
  (let [line-key ((@state :line-mapping) key)]
    (if-not line-key
      (do
        (swap! state assoc-in [:line-mapping key] key)
        (swap! state assoc-in [:lines key :key] key)))
    (or line-key key)))

(defn dbg [name obj]
  (print name)
  (.log js/console (clj->js obj)))

;; -------------------------
;; briefings (initial data)

;; TODO fill lines data from with briefings
;(defn jsx->clj [x]
;  (into {} (for [k (.keys js/Object x)] [k (aget x k)])))

(swap! state assoc-in [:device-mapping] (js->clj (.. js/window -mappings -devices)))

;;(dbg "device-mapping" (:device-mapping @state))

(defn merge-into-state [key data]
  (let [line-key (line-lookup key)]
    (swap! state update-in [:lines line-key] merge (assoc data :key line-key))))

;; -------------------------
;; message handlers

(defn server-heartbeat-handler [heartbeat]
  ;;(dbg "SERVER HEARTBEAT IN" heartbeat)
  (let [now (js/moment)
        key (heartbeat :token)]
    (merge-into-state key {:server-heartbeat now}))
  ;;(dbg "SERVER HEARTBEAT OUT" @state)
  )

(defn client-heartbeat-handler [heartbeat]
  ;;(dbg "CLIENT HEARTBEAT" heartbeat)
  (let [now (js/moment)
        key (heartbeat :identifier)]
    (merge-into-state key {:client-heartbeat now}))
  ;;(dbg "CLIENT HEARTBEAT OUT" @state)
  )

(defn client-report-handler [data]
  ;;(dbg "CLIENT REPORT" data)
  (let [key (data :identifier)]
    (merge-into-state key {:client-report data})))

(defn server-stats-handler [data]
  ;;(dbg "SERVER STATS IN" data)
  (let [key (data :slug)]
    (merge-into-state key {:stats (data :stats)}))
  ;;(dbg "SERVER STATS OUT" @state)
  )

(defn venues-handler [data]
  ;;(dbg "VENUE IN" data)
  (let [venue     (data :venue)
        slug      (venue :slug)
        token     (venue :client_token)
        device-id (venue :device_id)
        device    ((@state :device-mapping) (str device-id))] ; identifier
    (swap! state assoc-in [:line-mapping device] slug)
    (swap! state assoc-in [:line-mapping token] slug)
    (merge-into-state slug venue)
    )
  (dbg "VENUE OUT" @state)
  )

(defn devices-handler [data]
  ;;(dbg "DEVICE" data)
  (swap! state assoc-in [:device-index :by-identifier (data :identifier)] (data :id))
  (swap! state assoc-in [:devices (data :id)] data))

;;(defn talks-handler [data]
;;  (dbg "TALK" data)
;;  (let [key ((data :talk) :slug)
;;        path [:talk key]]
;;    (swap! state assoc-in path data)))

(defn client-event-handler [data]
  (dbg "CLIENT EVENT IN" data)
  (let [key (data :identifier)
        line-key (line-lookup key)
        new (assoc data :time (js/moment))
        nav [:lines (keypath line-key) :events NIL->VECTOR END]]
    (swap! state #(setval nav [new] %)))
  (dbg "CLIENT EVENT OUT" @state)
  )

(defn connections-handler [data]
  (dbg "CONNECTION EVENT IN" data)
  (let [key (data :slug)
        path [:connection key]]
    (swap! state assoc-in path (data :event)))
  (dbg "CONNECTION EVENT OUT" data)
  )

;; ------------------------------
;; update loop at exactly 30fps

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

(update-loop)

;; -------------------------
;; init helpers

(defn subscribe [channel handler]
  (.subscribe js/fayeClient channel
              #(handler (js->clj %  :keywordize-keys true))))

(defn mount-root []
  (reagent/render [main-comp] (.getElementById js/document "livedashboard")))

;; -------------------------
;; initialize

(defn init! []
  (mount-root))

(subscribe "/report"            client-report-handler)
(subscribe "/heartbeat"         client-heartbeat-handler)
(subscribe "/admin/stats"       server-stats-handler)
(subscribe "/admin/venues"      venues-handler)
;;(subscribe "/admin/talks"       talks-handler)
(subscribe "/admin/connections" connections-handler)
(subscribe "/server/heartbeat"  server-heartbeat-handler)
(subscribe "/event/devices"     client-event-handler)
(subscribe "/admin/devices"     devices-handler)
