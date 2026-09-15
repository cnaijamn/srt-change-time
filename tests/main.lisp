(defpackage srt-change-time/tests/main
  (:use :cl
        :srt-change-time
        :rove))
(in-package :srt-change-time/tests/main)

;; NOTE: To run this test file, execute `(asdf:test-system :srt-change-time)' in your Lisp.

(deftest test-target-1
  (testing "should (= 1 1) to be true"
    (ok (= 1 1))))
