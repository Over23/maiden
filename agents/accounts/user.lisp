#|
 This file is a part of Colleen
 (c) 2016 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.colleen.agents.accounts)

(defclass user ()
  ((name :initarg :name :accessor name)
   (identities :initform () :accessor identities)
   (data :initarg :data :accessor data))
  (:default-initargs
   :name (error "NAME required.")
   :data (make-hash-table)))

(ubiquitous:define-ubiquitous-writer user (user)
  `(,(name user)
    (:identities ,(identities user))
    (:data ,(data user))))

(ubiquitous:define-ubiquitous-reader user (form)
  (let ((name (first form))
        (identities (cdr (assoc :identities (cdr form))))
        (data (cdr (assoc :data (cdr form)))))
    (make-instance 'user :name name :identities identities :data data)))
