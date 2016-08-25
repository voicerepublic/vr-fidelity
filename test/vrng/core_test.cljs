(ns vrng.core-test
  (:require [cljs.test :refer-macros [is are deftest testing use-fixtures]]
            [reagent.core :as r :refer [atom]]
            [vrng.core :as c]))

;; setup

(defn setup-talks []
  (reset! c/state {:talks {1 {:id 1 :state "archived"}
                           2 {:id 2 :state "prelive"
                              :starts_at "2015-10-14T16:21:00.000+02:00"}
                           3 {:id 3 :state "prelive"
                              :starts_at "2015-10-14T17:21:00.000+02:00"}}}))

(defn setup-translations []
  (reset! c/translations {"days" "Tage"
                        "state" {"offline" "Aus"}}))

;; utils/helpers

(deftest test-next-talk
  (testing "should select next talk"
    (setup-talks)
    (is (= 2 (:id (c/next-talk))))))

(deftest test-talks-by-state
  (testing "should filter talks by state"
    (setup-talks)
    (is (= 2 (count (c/talks-by-state "prelive"))))
    (is (= 1 (count (c/talks-by-state "archived"))))))

(deftest test-translations
  (testing "should provide translations"
    (setup-translations)
    (is (= "Tage" (c/t "days")))
    (is (= "Aus" (c/t "state" "offline")))
    (is (= "Aus" (c/t "state.offline")))))




;;(deftest test-my-update-in
;;  (testing "should nicely update"
;;    (let [input {:list [{:key "blub", :value "foo"}]}
;;          my-update-in (fn [in key value] in)]
;;      (is (= {:list [{:key "blub", :value "bar"}]}
;;             (my-update-in input "blub" "bar"))))))
