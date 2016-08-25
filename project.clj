(defproject vrbo "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "https://github.com/munen/voicerepublic_dev"
  :license {:name "proprietary"
            :url "http://voicerepublic.com"}

  :dependencies [[org.clojure/clojure "1.8.0" :scope "provided"]
                 [org.clojure/clojurescript "1.7.228" :scope "provided"]
                 [reagent "0.5.1"]
                 [reagent-forms "0.5.15"]
                 [reagent-utils "0.1.7"]
                 [secretary "1.2.3"]
                 [org.clojure/core.incubator "0.1.3"]
                 [cljs-ajax "0.5.4"]
                 [cljsjs/moment "2.10.6-4"]
                 [cljsjs/selectize "0.12.1-1"]
                 [com.rpl/specter "0.12.0"]]

  :plugins [[lein-cljsbuild "1.1.1"]]

  :min-lein-version "2.5.0"

  :clean-targets ^{:protect false}
  [:target-path
   [:cljsbuild :builds :app :compiler :output-dir]
   [:cljsbuild :builds :app :compiler :output-to]]

  :resource-paths ["public"]

  :cljsbuild {:builds {:app {:source-paths ["src"] ;; app -> dev
                             :figwheel {:on-jsload vrbo.core/fig-reload}
                             :compiler {:main vrbo.core
                                        :output-to "public/js/app.js"
                                        :output-dir "public/js/out"
                                        :source-map-timestamp true
                                        :asset-path   "/js/out"
                                        :optimizations :none
                                        :pretty-print  true}}

                       :min {:source-paths ["src"] ;; min -> prod
                             :compiler {:main vrbo.core
                                        :output-to "public/js/app.js"
                                        ;;:optimizations :advanced}}}}
                                        :optimizations :whitespace}}}}

  :figwheel { :http-server-root "public"
              :server-port 3449 ;; default
              :nrepl-port 7002
              :nrepl-middleware ["cemerick.piggieback/wrap-cljs-repl"]
              :css-dirs ["public/css"]}

  :profiles { :dev { :dependencies [[prone "1.0.2"]
                                    [lein-doo "0.1.6"]
                                    [pjstadig/humane-test-output "0.7.1"]
                                    [lein-figwheel "0.5.0-6"]
                                    [org.clojure/tools.nrepl "0.2.12"]
                                    [com.cemerick/piggieback "0.2.1"]]

                    :plugins [[lein-figwheel "0.5.0-6"]
                              [lein-doo "0.1.6"]]

                    :doo {:build "test"}

                    :injections [(require 'pjstadig.humane-test-output)
                                 (pjstadig.humane-test-output/activate!)]}})
