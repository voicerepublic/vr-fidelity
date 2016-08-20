(ns vrbo.dashboard
  (:require
   ;;[vrng.util :as u :refer [t state to-millis track-event]]
   ;;[vrng.sporktrum :as spork]
   [reagent.core :as reagent :refer [atom]]
   [reagent.session :as session]
   ;;[secretary.core :as secretary :include-macros true]
   [ajax.core :refer [PUT]]
   [clojure.string :as str]
   ;;[cljsjs.selectize]
   goog.string.format
   goog.string)
  (:require-macros [cljs.core :refer [exists?]]))

(defn main-comp []
  [:main
   [:div#time-grid.ui-draggable.ui-draggable-handle
    {:style {:left "400px" :top "0px"}}
    [:div.marker "10:00"]
    [:div.marker.half]
    [:div.marker "11:00"]
    [:div.marker.half]
    [:div.marker "12:00"]
    [:div.marker.half]
    [:div.marker "13:00"]
    [:div.marker.half]
    [:div.marker "14:00"]
    [:div.marker.half]
    [:div.venue-timeslots
     [:div.venue-timeslot-row
      [:div.point-in-time {:style {:margin-left "450px"}}]
      [:div.time-slot-holder
       {:style {:margin-left "400px"}}
       [:p.time-slot-title "This is a talky talk"]
       [:div.time-slot-fill]
       [:div.time-slot]]]
     [:div.venue-timeslot-row
      [:div.time-slot-holder
       {:style {:margin-left "800px"}}
       [:p.time-slot-title "This is really awesome"]
       [:div.time-slot]]]
     [:div.venue-timeslot-row
      [:div.time-slot-holder
       {:style {:margin-left "200px"}}
       [:p.time-slot-title "Funny Porcelain Handpuppet"]
       [:div.time-slot-fill]
       [:div.time-slot]
       [:div.time-slot-holder
        {:style {:margin-left "400px"}}
        [:p.time-slot-title "Gagnly Steel Kerchiefs"]
        [:div.time-slot-fill {:style {:width "102px"}}]
        [:div.time-slot]]]]]
    [:div#current-time-line]
    [:div#current-time-holder [:div#current-time-badge "11:46:05"]]]
   [:div#dashboard
    [:div#venue-column
     [:div.venue-tab
      [:div.top-row.clearfix
       [:div.play-button-holder
        [:button.play-button
         [:svg [:use {:xlink:href "#icon-sound_on"}]]]]
       [:div.venue-info
        [:p.name-id "sophie-glaser " [:span "  i-065618ba"]]
        [:p.state-badges
         [:span.device-type "butt"]
         [:span.server-state.connected "connected"]
         [:span.device-type.live "live"]]]]
      [:div.bottom-row.clearfix
       [:p.small-6.columns.float-left.no-pad
        [:span.small-2.float-left.columns.server-status.no-pad.connected]
        [:span.small-10.float-right.columns.server-heartbeat.no-pad.connected]]
       [:p.small-6.columns.float-right.no-pad
        [:span.small-2.float-left.columns.connection-status.no-pad.connected]
        [:span.small-10.float-right.columns.box-heartbeat.no-pad.false]]]]
     [:div.venue-tab
      [:div.top-row.clearfix
       [:div.play-button-holder
        [:button.play-button
         [:svg [:use {:xlink:href "#icon-sound_on"}]]]]
       [:div.venue-info
        [:p.name-id "leipziger-buchmesse " [:span "  i-8dhskjh3"]]
        [:p.state-badges
         [:span.device-type "gandor"]
         [:span.server-state.connected "connected"]
         [:span.device-type.live "live"]]]]
      [:div.bottom-row.clearfix
       [:p.small-6.columns.float-left.no-pad
        [:span.small-2.float-left.columns.server-status.no-pad.connected]
        [:span.small-10.float-right.columns.server-heartbeat.no-pad.connected]]
       [:p.small-6.columns.float-right.no-pad
        [:span.small-2.float-left.columns.connection-status.no-pad.connected]
        [:span.small-10.float-right.columns.box-heartbeat.no-pad.true]]]]
     [:div.venue-tab
      [:div.top-row.clearfix
       [:div.play-button-holder
        [:button.play-button
         [:svg [:use {:xlink:href "#icon-sound_on"}]]]]
       [:div.venue-info
        [:p.name-id "voice-republic-testing " [:span "  i-e0f2bd5c"]]
        [:p.state-badges
         [:span.device-type "kant"]
         [:span.server-state.awaiting-stream "awaiting-stream"]
         [:span.device-type.offline "offline"]]]]
      [:div.bottom-row.clearfix
       [:p.small-6.columns.float-left.no-pad
        [:span.small-2.float-left.columns.server-status.no-pad.awaiting-stream]
        [:span.small-10.float-right.columns.server-heartbeat.no-pad.awaiting-stream]]
       [:p.small-6.columns.float-right.no-pad
        [:span.small-2.float-left.columns.connection-status.no-pad.awaiting-stream]
        [:span.small-10.float-right.columns.box-heartbeat.no-pad.true]]]]]]]
  )
;; -------------------------
;; Initialize

;; (defn inc-now [state-map]
;;   (update-in state-map [:now] inc))
;;
;; (defn start-timer []
;;   (let [intervalId (js/setInterval #(swap! state inc-now) 1000)]
;;     (swap! page-state assoc :intervalId intervalId)))
;;
;; (defn venue-channel []
;;   (:channel (venue)))
;;
;; (defn schedule-check-availability []
;;   (if (= (venue-state) "offline")
;;     (js/setTimeout request-availability-action (max 0 (time-to-available)))))

;; (defn setup-faye [callback]
;;   (print "Subscribe" (venue-channel))
;;   (let [subscription
;;         (.subscribe js/fayeClient (venue-channel)
;;                     #(venue-message-handler (js->clj %  :keywordize-keys true)))]
;;     (.then subscription callback)))

(defn mount-root []
  (reagent/render [main-comp] (.getElementById js/document "livedashboard")))

(defn init! []
  ;; (start-timer)
  ;; (setup-faye schedule-check-availability)
  (mount-root))
