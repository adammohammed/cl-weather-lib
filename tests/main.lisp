(defpackage cl-weather-lib/tests/main
  (:use :cl
        :cl-weather-lib
        :rove))
(in-package :cl-weather-lib/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :cl-weather-lib)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
