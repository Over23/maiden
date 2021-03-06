#|
 This file is a part of Maiden
 (c) 2016 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.maiden)

(define-event passive-event ()
  ())

(define-event active-event ()
  ())

(define-event client-event ()
  ((client :initarg :client :reader client))
  (:default-initargs
   :client (error "CLIENT required.")))

(defmethod respond ((event client-event) &rest args &key (class (class-of event)) &allow-other-keys)
  (issue (apply #'make-instance class :client (client event) args)
         (event-loop event)))

(define-event instruction-event (active-event)
  ())

(defgeneric respond (event &rest args &key class &allow-other-keys)
  (:method ((event event) &rest args &key (class (class-of event)) &allow-other-keys)
    (issue (apply #'make-instance class args)
           (event-loop event))))

(define-event query-event (identified-event instruction-event)
  ())

(defmethod respond ((event query-event) &key payload)
  (issue (make-instance 'response-event :identifier (identifier event)
                                        :payload payload)
         (event-loop event)))

(define-event response-event (identified-event payload-event passive-event)
  ()
  (:default-initargs :identifier (error "IDENTIFIER required.")))

(define-event core-event ()
  ())

(define-event consumer-added (core-event passive-event)
  ((consumer :initarg :consumer))
  (:default-initargs
   :consumer (error "CONSUMER required.")))

(defmethod print-object ((event consumer-added) stream)
  (print-unreadable-object (event stream :type T :identity T)
    (format stream "~a" (slot-value event 'consumer))))

(define-event consumer-removed (core-event passive-event)
  ((consumer :initarg :consumer))
  (:default-initargs
   :consumer (error "CONSUMER required.")))

(defmethod print-object ((event consumer-removed) stream)
  (print-unreadable-object (event stream :type T :identity T)
    (format stream "~a" (slot-value event 'consumer))))

(define-event instruction-event (active-event)
  ())

(defgeneric execute-instruction (instruction &key))

(defmethod execute-instruction :before (instruction &rest args &key)
  (v:debug :maiden.event.instruction "Executing ~a with ~s" instruction args))

(define-event core-instruction-event (core-event instruction-event)
  ())

(define-event add-consumer (core-instruction-event)
  ((consumer-type :initarg :consumer-type :reader consumer-type)
   (name :initarg :name :reader name)
   (initargs :initarg :initargs :reader initargs))
  (:default-initargs
   :consumer-type (error "CONSUMER-TYPE required.")
   :name (error "NAME required.")
   :initargs ()))

(defmethod execute-instruction ((instruction add-consumer) &key core)
  (add-consumer (start (apply #'make-instance
                              (consumer-type instruction)
                              :name (name instruction)
                              (initargs instruction)))
                core))

(define-event remove-consumer (core-instruction-event)
  ((name :initarg :name :reader name)
   (stop :initarg :stop :reader stop))
  (:default-initargs
   :name (error "NAME required.")
   :stop T))

(defmethod execute-instruction ((instruction remove-consumer) &key core)
  (let ((consumer (consumer (name instruction) core)))
    (when (stop instruction) (stop consumer))
    (remove-consumer consumer core)))
