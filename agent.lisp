#|
 This file is a part of Colleen
 (c) 2016 Shirakumo http://tymoon.eu (shinmera@tymoon.eu)
 Author: Nicolas Hafner <shinmera@tymoon.eu>
|#

(in-package #:org.shirakumo.colleen)

(define-consumer agent () ())

(defmethod initialize-instance :after ((agent agent) &key)
  (unless (name agent)
    (setf (name agent) (class-name (class-of agent)))))

(defmethod matches ((a agent) (b agent))
  (eql (class-of a) (class-of b)))

(defmethod add-consumer ((agent agent) (core core))
  (let ((existing (find agent (consumers core) :test #'matches)))
    (when existing
      (cerror "Add it anyway." 'agent-already-exists-error :agent agent :existing-agent existing)))
  (call-next-method))