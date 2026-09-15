;;; Copyright (c) 2026 Chez Naijamn
;;;
;;; Permission is hereby granted, free of charge, to any person
;;; obtaining a copy of this software and associated documentation
;;; files (the "Software"), to deal in the Software without
;;; restriction, including without limitation the rights to use, copy,
;;; modify, merge, publish, distribute, sublicense, and/or sell copies
;;; of the Software, and to permit persons to whom the Software is
;;; furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be
;;; included in all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;;; NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
;;; HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
;;; WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

(in-package #:srt-change-time)

(defun to-msec (h m s msec)
  (+ (* h 3600000)
     (* m 60000)
     (* s 1000)
     msec))

(defun to-time (msec)
  (when (< msec 0)
    (setf msec 0)) ; これでいいのか？
  (let* ((h    (floor msec 3600000))
         (msec (mod msec 3600000))
         (m    (floor msec 60000))
         (msec (mod msec 60000))
         (s    (floor msec 1000))
         (ms2  (mod msec 1000)))
    (format nil "~2,'0d:~2,'0d:~2,'0d,~3,'0d"
            h m s ms2)))

(defun update-srt-line (line millisecond)
  (cl-ppcre:register-groups-bind
      (sh sm ss sms
       eh em es ems)
      ("^([0-9]{2}):([0-9]{2}):([0-9]{2}),([0-9]{3}) --> ([0-9]{2}):([0-9]{2}):([0-9]{2}),([0-9]{3})$"
       line)
    (let* ((start (+ (to-msec (parse-integer sh)
                              (parse-integer sm)
                              (parse-integer ss)
                              (parse-integer sms))
                     millisecond))
           (end   (+ (to-msec (parse-integer eh)
                              (parse-integer em)
                              (parse-integer es)
                              (parse-integer ems))
                     millisecond)))
      (return-from update-srt-line
        (format nil "~a --> ~a"
                (to-time start)
                (to-time end)))))
  line)

(defun update-srt (srt-file millisecond)
  (with-open-file (in srt-file
                      :direction :input
                      :external-format '(:utf-8 :newline :crlf))
    (with-output-to-string (out)
      (loop for line = (read-line in nil)
            while line
            do (format out "~a~%"
                       (update-srt-line line millisecond))))))
