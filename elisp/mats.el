(require 'ox)
(require 'seq)

;; ================================================================================
;; Org utility functions
;; ================================================================================

(defun get-current-level (element)
  "Get the level to which ELEMENT belongs"
  (let ((headline (org-element-lineage element '(headline) t)))
    (if headline
        (org-element-property :level headline) 0)))

(defun get-affiliated (element)
  (buffer-substring (org-element-property :begin element)
                    (org-element-property :post-affiliated element)))

(defun get-post-blank (element)
  (org-element-property :post-blank element))

(defun delete-comments (doc)
  "Remove comments, comment blocks, and commented trees from Org document tree DOC"
  (org-element-map doc '(comment comment-block) 'org-element-extract-element)
  (org-element-map doc 'headline
    (lambda (hl)
      (and (org-element-property :commentedp hl)
           (org-element-extract-element hl)))))

;; Property drawers
;; --------------------------------------------------------------------------------
(defun make-node-property (key value)
  "Return a node property"
  (org-element-create
       'node-property
       (list :key key :value value)))

(defun make-property-drawer (&rest nodes)
  "Return a property drawer with property nodes NODES"
  (apply 'org-element-create
         'property-drawer nil nodes))

;; Headlines
;; --------------------------------------------------------------------------------
(defun make-headline (title level &rest children)
  "Return a headline with the given TITLE and LEVEL"
  (apply 'org-element-create
         'headline (list :title title :level level)
         children))

(defun make-headline-unnumbered (title level &rest children)
  "Return an unnumbered headline with the given TITLE and LEVEL"
  (make-headline
   title level
   (make-property-drawer
    (make-node-property "UNNUMBERED" t))
   children))


;; Paragraphs
;; --------------------------------------------------------------------------------
(defun make-paragraph (contents &optional post-blank)
  "Return a paragraph with the given CONTENTS"
  (let ((props (and post-blank (list :post-blank post-blank))))
    (apply 'org-element-create
           'paragraph props contents)))


;; Links
;; --------------------------------------------------------------------------------
(defun make-link (type path)
  "Return a link"
  (org-element-create 'link (list :type type :path path)))


(defun make-par-link (type path &optional affiliated post-blank)
  "Return a paragraph with a link"
  (let ((link (make-link type path))
        (contents))
    (setq contents (if affiliated (list affiliated link) link))
    (make-paragraph contents post-blank)))

;; Keywords
;; --------------------------------------------------------------------------------
(defun make-keyword (key value)
  (org-element-create 'keyword (list :key key :value value)))


(defun make-latex-keyword (value)
  (make-paragraph (list (make-keyword "LATEX" value))))



;; ================================================================================
;; MATS keywords
;; ================================================================================

(defun mats-keyword-p (element)
  "Returns t if ELEMENT is a MATS keyword"
  (and (eq (org-element-type element) 'keyword)
       (string= (org-element-property :key element) "MATS")))

(defvar mats-keyword-regex
  "[[:blank:]]*\\([^[:blank:]]+\\)\\(?:[[:blank:]]+\\(.*\\)\\)?[[:blank:]]*\\'")

(defun parse-mats-keywords (doc)
  "Add mats-type and mats-value properties to a mats-keyword"
  (org-element-map doc 'keyword
    (lambda (keyword)
      (let ((type)
            (text)
            (value))
        (when (mats-keyword-p keyword)
          (setq text (org-element-property :value keyword))
          (when (string-match mats-keyword-regex text)
            (setq keyword
                  (org-element-put-property keyword :mats-type (match-string 1 text)))
            (setq keyword
                  (org-element-put-property keyword :mats-value (match-string 2 text)))))))))

(defun process-mats-keywords (doc)
  "Get the different parts of a MATS keyword and call the appropriate handler"
  (parse-mats-keywords doc)
  (org-element-map doc 'keyword
    (lambda (keyword)
      (let ((type)
            (text)
            (value))
        (when (mats-keyword-p keyword)
          (setq type (org-element-property :mats-type keyword))
          (setq value (org-element-property :mats-value keyword))
          (cond ((string= type "col") (handle-col keyword))
                ((string= type "fig") (handle-fig keyword))
                ((string= type "figcol") (handle-figcol keyword))
                ((string= type "bib") (handle-bib keyword))
                ((string= type "pagebreak") (handle-pagebreak keyword))
                (t nil)))))))

;; Bibliography
;; --------------------------------------------------------------------------------
(defun handle-bib (keyword)
  "Handle bibliography blocks"
  (org-element-set-element
   keyword
   ;; Create a new top-level headline with properties
   (org-element-create
    'headline
    (list :level 1
          :post-blank (get-post-blank keyword))
    (org-element-create
     'property-drawer nil
     (org-element-create
      'node-property
      (list :key "BEAMER_env" :value "fullframe"))
     (org-element-create
      'node-property
      (list :key "UNNUMBERED" :value "t"))))))

;; Page breaks
;; --------------------------------------------------------------------------------
(defun handle-pagebreak (keyword)
  "Handle page breaks in handouts"
  (let ((headline))
    (setq headline
          (make-headline "Page break" (get-current-level keyword)
           (make-property-drawer
            (make-node-property "BEAMER_env" "ignoreheading"))
           (make-latex-keyword "\\mode<article>{\\clearpage{}}")))
    (org-element-set-element
     keyword (org-element-put-property headline
                                       :post-blank (get-post-blank keyword)))))

;; Columns
;; --------------------------------------------------------------------------------
(defvar mats-col-regex
  "\\`[[:blank:]]*\\(?:\\([0-9.]+\\)[[:blank:]]*\\)?\\'")

(defun make-col (level width post-blank)
  (org-element-create
   'headline
   (list :level level
         :post-blank post-blank)
   (org-element-create 'property-drawer nil
                       (org-element-create
                        'node-property
                        (list :key "BEAMER_col" :value (format "%g" width))))))

(defun handle-col (keyword)
  "Handle column"
  (let ((width)
        (value (org-element-property :mats-value keyword)))
    (when (string-match mats-col-regex value)
      (setq width (string-to-number (or (match-string 1 value) "0.5")))
      (org-element-set-element
       keyword
       (make-col (+ (get-current-level keyword) 1)
                 width
                 (get-post-blank keyword))))))

;; Figures
;; --------------------------------------------------------------------------------
(defun fig-file-path (value lang)
  (if (string-match "\\*" value)
      (replace-match (or lang "\\LANG") nil t value)
    value))

(defun handle-fig (keyword)
  (let ((value (org-element-property :mats-value keyword)))
    (org-element-set-element
     keyword
     (make-par-link "file"
                    (fig-file-path value nil)
                    (get-affiliated keyword)
                    (get-post-blank keyword)))))


;; Figure + column
;; --------------------------------------------------------------------------------
(defun handle-figcol (keyword)
  (let ((args)
        (path)
        (width)
        (level)
        (new)
        (value (org-element-property :mats-value keyword)))
    (setq args (split-string value))
    (setq path (fig-file-path (pop args) nil))
    (setq width (string-to-number (or (pop args) "0.5")))
    (setq level (+ (get-current-level keyword) 1))
    (setq new (make-col level width 1))
    (org-element-adopt-elements
        new (make-par-link "file"
                           path
                           (get-affiliated keyword) 1))
    (org-element-insert-before new keyword)
    (org-element-set-element
     keyword (make-col level (- 1 width) (get-post-blank keyword)))))

;; ================================================================================
;; Install driver
;; ================================================================================

(defun prepare-buffer ()
  "Remove comments and substitute MATS keywords"
  (let ((doc (org-element-parse-buffer)))
    (delete-comments doc)
    (process-mats-keywords doc)
    (org-element-interpret-data doc)))

(defun mats-preprocess (backend)
  "Replace buffer contents after substitute MATS keywords"
  (let ((new (prepare-buffer)))
    (erase-buffer)
    (insert new)))

(add-hook 'org-export-before-parsing-hook 'mats-preprocess)
