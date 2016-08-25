(ns vrng.runner
    (:require [doo.runner :refer-macros [doo-tests]]
              [vrng.core-test]))
;;              [vrng.util-test]))

(doo-tests 'vrng.core-test)
;;           'vrng.util-test)
