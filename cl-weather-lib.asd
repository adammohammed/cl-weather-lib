(defsystem "cl-weather-lib"
  :version "0.1.0"
  :author "Adam Mohammed"
  :license ""
  :depends-on ("dexador" "cl-json")
  :components ((:module "src"
                :components
                ((:file "main"))))
  :description ""
  :in-order-to ((test-op (test-op "cl-weather-lib/tests"))))

(defsystem "cl-weather-lib/tests"
  :author "Adam Mohammed"
  :license ""
  :depends-on ("cl-weather-lib"
               "rove")
  :components ((:module "tests"
                :components
                ((:file "main"))))
  :description "Test system for cl-weather-lib"
  :perform (test-op (op c) (symbol-call :rove :run c)))
