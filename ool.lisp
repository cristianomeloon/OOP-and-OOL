
;;;; -*- Mode: Lisp -*-
;;;; Melon Cristiano 899647
;;;; Teodori Alessandro 899894
;;;; ool.lisp

(defparameter *classes-specs* (make-hash-table))

(defun add-class-spec (name class-spec)
  (setf (gethash name *classes-specs*) class-spec))

(defun class-spec (name)
  (gethash name *classes-specs*))

;;; def-class consente di creare
;;; e inserire in memoria una classe
(defun def-class (class-name parents &rest part)
  (cond
    ((and (symbolp class-name) (listp parents) (null (is-class class-name)))
     (let ((fields (get-fields (assoc 'fields part) parents))
           (methods (get-methods (assoc 'methods part))))
       (add-class-spec class-name (list
                                   (cons 'name class-name)
                                   (cons 'parents parents)
                                   (cons 'fields fields)
                                   (cons 'methods methods))))
     class-name)
    (t (error
        "ERROR: class already present or class-name or parents not valid!"))))

;;; make consente di creare un'istanza di una classe
(defun make (class-name &rest parts)
  (cond
    ((is-class class-name)
     (if (verify-instance-fields parts class-name)
         (append (list 'oolinst)
                 (list :class class-name :fields parts))))
    (t (error "ERROR: given class not valid"))))

;;; is-class verifica che il nome della classe
;;; passata sia di una classe presente in memoria
(defun is-class (class-name)
  (and (symbolp class-name)
       (gethash class-name *classes-specs*)))

;;; is-insnace verifica che l'oggetto passato sia una
;;; istanza di una classe
(defun is-instance (value &optional (class-name T))
  (if (listp value)
      (cond ((and (equal (car value) 'OOLINST)
                  (equal class-name 'T)) T)
            ((and (equal (car value) 'OOLINST)
                  (equal (third value) class-name)) T)
            ((deep-member class-name (second (class-spec (third value)))) T)
            (t (error "ERROR: given value not an instance of the class")))
      (error "ERROR: given value can't be an instance, value is not a list")))

;;; field prende come argomenti una istanza e il nome
;;; di un campo dell'istanza e ne restituisce il valore
(defun field (instance field-name)
  (cond
    ((not (is-instance instance)) nil)
    ((not (symbolp field-name)) nil)
    (t (if (deep-member field-name (fifth instance))
           (find-field field-name (fifth instance))
           (car (list (field-class field-name (third instance))))))))

;;; field* estrae il valore da una classe percorrendo
;;; una catena di attributi
(defun field* (instance &rest field-name)
  (cond ((null field-name) (error "ERROR: list is empty!"))
        ((eq (length field-name) 1)
         (field instance (if (listp (car field-name))
                             (caar field-name) (car field-name))))
        (T (field* (field instance (if (listp (car field-name))
                                       (caar field-name) (car field-name)))
                   (cdr field-name)))))

;;; FUNZIONI AGGIUNTIVE

;;; get-fields restituisce una lista formattata
;;; con chiavi di fields
(defun get-fields (field-part parents)
  (cond
    ((null field-part) nil)
    (t (mapcar (lambda (field)
                 (let ((field-name (first field))
                       (field-value (second field))
                       (field-type (if (not (null (third field)))
                                       (third field)
                                       NIL)))
                   (if (or (null field-type) (type-check field-value
                                                         field-type))
                       (if (null (mapcar (lambda (parent-name)
                                           (verify-class-field field-name
                                                               field-value
                                                               parent-name))
                                         parents))
                           (list :name field-name
                                 :value field-value
                                 :type field-type))
                       (error "Type check failed for field ~a" field-name))))
               (cdr field-part)))))

;;; typecheck verifica il tipo di una field, controllando che il value sia
;;; uguale o sottotipo del tipo specificato nella field
(defun type-check (value expected-type)
  (cond ((null expected-type) t)
        (t (let ((actual-type (type-of value)))
             (first (list (subtypep actual-type expected-type)))))))

(defun get-methods (method-part)
  (cond
    ((null method-part) NIL)
    (t (mapcar (lambda (method)
                 (let ((method-name (first method))
                       (method-args (cadr method))
                       (method-body (cddr method)))
                   ;; Definisci la funzione metodo a livello globale
                   (eval `(defun ,method-name (this ,@method-args)
                            ,@method-body))
                   (list :name method-name
                         :body (append method-args
                                       method-body))))
               (cdr method-part)))))

;;; valid-method-structure verifica che la struttura
;;; di un metodo sia corretta
(defun valid-method-structure (method)
  (and (listp method)
       (= (length method) 2)
       (listp (second method))))

;;; verify-instance-fields verifica che i fields di
;;; una istanza siano gli stessi della classe istanziata
(defun verify-instance-fields (fields class-name)
  (cond ((null fields) t)
        (t (if (not (null (field-class
                           (first fields)
                           class-name)))
               (if (type-check (second fields)
                               (first
                                (list (class-field-type
                                       (first fields)
                                       class-name))))
                   (verify-instance-fields (nthcdr 2 fields)
                                           class-name)
                   (error "ERROR: type of ~a field not valid"
                          (first fields)))
               (error "ERROR: class doesn't have ~a field"
                      (first fields))))))

;;; come verify-instance-fields, ma per def-class,
;;; si assicura che i tipi dei campi non vadano in conflitto
;;; con i campi dei genitori, in aggiunta funziona con un solo
;;; field alla volta, per seguire il funzionamento di get-fields
(defun verify-class-field (field-name field-value class-name)
  (if (not (null (field-class field-name class-name)))
      (if (type-check field-value
                      (class-field-type field-name
                                        class-name))
          T
          (error "ERROR: type of ~a field non valid" field-name))
      T))

;;; deep-member verifica che un elemento passato
;;; sia contenuto all'interno di una lista passata
(defun deep-member (atom list)
  (cond ((null list) nil)
        ((eq atom (car list)) t)
        ((listp (car list))
         (or (deep-member atom (car list))
             (deep-member atom (cdr list))))
        (t (deep-member atom (cdr list)))))

;;; field-class ha la stessa funzione di field ma sulle classi
(defun field-class (field-name class-name)
  (let ((class-fields (rest (third (class-spec class-name)))))
    (if (deep-member field-name class-fields)
        (find-field field-name class-fields)
        (values-list
         (remove nil
                 (mapcar
                  (lambda (p) (field-class field-name p))
                  (second (class-spec class-name))))))))

;;; find-field prende come argomenti un field-name
;;; e una lista di fields in cui cercare quel campo
(defun find-field (field-name fields)
  (if (null fields)
      nil
      (if (listp (car fields))
          (if (equal field-name (second (car fields)))
              (fourth (car fields))
              (find-field field-name (cdr fields)))
          (if (equal field-name (first fields))
              (second fields)
              (find-field field-name (cddr fields))))))



;;; class-field-type funziona come field-class, ma richiama una variante di
;;; finde-field che restituisce solamente il type del dato field
(defun class-field-type (field-name class-name)
  (let ((class-fields (rest (third (class-spec class-name)))))
    (if (deep-member field-name class-fields)
        (find-field-type field-name class-fields)
        (values-list
         (remove nil
                 (mapcar
                  (lambda (p) (class-field-type field-name p))
                  (second (class-spec class-name))))))))

;;; find-field-type prende come argomenti un field-name e una lista
;;; di fields in cui cercare il dato field e restituirne il tipo
(defun find-field-type (field-name fields)
  (if (null fields)
      nil
      (if (listp (car fields))
          (if (equal field-name (second (car fields)))
              (sixth (car fields))
              (find-field-type field-name (cdr fields))))))

;;;; end of file -- ool.lisp
