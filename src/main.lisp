(defpackage cl-weather-lib
  (:use :cl
   :cl-json)
  (:export
   #:current-temp
   #:high-temp
   #:low-temp
   #:humidity
   #:make-weather-client
   #:current-weather))

(in-package :cl-weather-lib)


(defun assoc-value (item object)
  "Given an OBJECT a-list return the VALUE from (KEY . VALUE), where (EQUAL ITEM KEY)."
  (cdr (assoc item object)))


(defclass weather-client ()
  ((api-key
    :initarg :api-key
    :accessor api-key
    :documentation "The API key used to authenticate with OpenWeatherAPI." )))


(defun make-weather-client (api-key)
  "Creates an OpenWeather API client with the API-KEY for authentication."
  (make-instance 'weather-client :api-key api-key))


;; The weather class is used to map the JSON response from the API to a
;; Lisp Object so it's easier to access the information
(defclass weather ()
  ((current-temp :initarg :curtemp :accessor current-temp)
   (high-temp :initarg :hitemp :accessor high-temp)
   (low-temp :initarg :lowtemp :accessor low-temp)
   (humidity :initarg :humidity :accessor humidity)))


(defun convertK->unit (unit)
  "Returns functions to convert from Kelvin to the unit specified."
  (case unit
    (:F (lambda (temp) (+ 32 (/ (* 9 (funcall (convertK->unit :C) temp) 5)))))
    (:C (lambda (temp) (- temp 273.15)))
    (t (lambda (temp) temp))))


;; Handles mapping the API resposne into a weather instance
;; before creating the instance each temperature value is
;; converted to the specified unit
(defun parse-weather-response (unit response)
  (let* ((data (json:decode-json-from-string response))
         (main (assoc-value :main data))
         (k->unit (convertK->unit unit))
         (ctemp (funcall k->unit (assoc-value :temp main)))
         (htemp (funcall k->unit (assoc-value :temp--max main)))
         (ltemp (funcall k->unit (assoc-value :temp--min main)))
         (humidity (assoc-value :humidity main)))
    (make-instance 'weather
                   :curtemp ctemp
                   :hitemp htemp
                   :lowtemp ltemp
                   :humidity humidity)))


(defun make-api-request (url)
  (multiple-value-bind (body code)
      (dex:get url)
    (case code
          (200 (acons :status  :ok (acons :current-temp body nil)))
          (t  (acons :status :error (acons :reason body nil))))))


(defun current-weather (client location &optional (unit :F))
  "Makes the API call with the CLIENT to get the current weather at the LOCATION."
  (let ((url "http://api.openweathermap.org/data/2.5/weather?")
        (param-string (format nil "q=~A&appid=~A" location (api-key client))))
    (let ((res (make-api-request (format nil "~A~A" url param-string))))
      (case (assoc-value :status res)
        (:ok (parse-weather-response unit (cdr (assoc :current-temp res))))
        (:error res)))))
