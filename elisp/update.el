(defun update-math ()
  (interactive)
  (let (indent-string)
    (save-excursion
      (point-min)
      (while (re-search-forward "\\\\\\[.*?\\\\\\]" nil t)
        (setq indent-string (buffer-substring-no-properties (line-beginning-position) (match-beginning 0)))
        (replace-match (format "#+begin_export latex
%s\\&
%s#+end_export" indent-string indent-string))))))




(setq fig-files-list
      '(("unit-2A-figs" .
         ("fig-t10-xy" "fig-t10-rp1" "fig-t10-rp1b" "fig-t10-rp3"
           "fig-t10-rp5" "fig-t10-rp6" "fig-t10-rp7" "fig-t10-rp8"
           "fig-t10-rp10" "fig-t10-rp11" "fig-t10-rac1" "fig-t10-orp2"
           "fig-t10-orp3"))
       ("unit-2B-figs" .
         ("fig-t11-ci02" "fig-t11-ci03" "fig-t11-ci04" "fig-t11-ci05"
           "fig-t11-ci06" "fig-t11-tr01" "fig-t11-map01" "fig-t11-rms01"
           "fig-t11-rms02" "fig-t11-rms03" "fig-t11-nreg01" "fig-t11-nreg02"
           "fig-t1a1-nreg03" "fig-t11-nreg04" "fig-t11-fu01" "fig-t11-map02"
           "fig-t11-map03" "fig-t11-fu02"))
       ("unit-2C-figs" .
         ("fig-t12-eq01" "fig-t12-eq01a" "fig-t12-eq02" "fig-t12-eq02a"
           "fig-t12-eq03" "fig-t12-ej01" "fig-t12-eq10" "fig-t12-eq11"
           "fig-t12-ej02"))
       ("unit-3A-figs" .
         ("fig-t15-crc2" "fig-t15-crc3" "fig-t15-crc" "fig-t15-eng"
           "fig-t15-cpc2" "fig-t15-cpc3" "fig-t15-cpc" "fig-t15-dem"))
       ("unit-3B-figs" .
         ("fig-t16-eres20" "fig-t16-eres22" "fig-t16-eres02" "fig-t16-eres03"
           "fig-t16-eres04" "fig-t16-eres10" "fig-t16-eres11" "fig-t16-eres12"
           "fig-t16-eres05a" "fig-t16-eres05" "fig-t16-eres06"))
       ("unit-4A-figs" .
         ("fig-t21-ciri01" "fig-t21-ciri02" "fig-t21-ciri03" "fig-t21-ciri04"
           "fig-t21-ciri05" "fig-t21-ciri06" "fig-t21-ciri07" "fig-t21-cisv01"))
       ("unit-5A-figs" .
         ("fig-t25-cp01" "fig-t25-cp03" "fig-t25-cp06" "fig-t25-cp06a"
           "fig-t25-cp06b" "fig-t25-cp08" "fig-t25-cp02" "fig-t25-cp07"
           "fig-t25-cp05" "fig-t25-cp04"))
       ("unit-5B-figs" .
         ("fig-t26-is01" "fig-t26-is02" "fig-t26-is05" "fig-t26-is03"
           "fig-t26-is04" "fig-t26-re01" "fig-t26-re02" "fig-t26-re03"))
       ("unit-6A-figs" .
         ("fig-t30-sr01" "fig-t30-sr02" "fig-t30-sr03" "fig-t30-sr04"
           "fig-t30-sr05" "fig-t30-sr06" "fig-t30-sr06" "fig-t30-sr07"
           "fig-t30-sr08" "fig-t30-sr08"))
       ("unit-6B-figs" .
         ("fig-t31-eq01" "fig-t31-eq02" "fig-t31-eq03" "fig-t31-eq04"
           "fig-t31-eq06" "fig-t31-eq07" "fig-t31-eq05" "fig-t31-eq08"
           "fig-t31-exp02" "fig-t31-clp01" "fig-t31-env08" "fig-t31-clp02"
           "fig-t31-clp03" "fig-t31-exp03" "fig-t31-exp04" "fig-t31-exp05"
           "fig-t31-env20" "fig-t31-env21" "fig-t31-env01" "fig-t31-env02"
           "fig-t31-env03" "fig-t31-env04" "fig-t31-env05" "fig-t31-env06"
           "fig-t31-env07"))))



(setq figs-file-preamble
      "#+STARTUP: indent hidestars content

#+TITLE: %s

#+OPTIONS: header-args: latex :exports source :eval no :mkdirp yes
")


(setq begin-src-block "#+begin_src latex :tangle %s :noweb yes")
(setq end-src-block "#+end_src")

(setq orig-dir (expand-file-name "~/Teaching/courses/EC1004/docs/slides_1004"))
(setq unit-files (car fig-files-list))
(setq figs-file-name (car unit-files))
(setq figure-files (cdr unit-files))

(dolist (item figure-files)
  (message item))

(defun which-file (base-name dir)
  (file-name-completion base-name dir))



(which-file "fig-t15-crc2"
            (expand-file-name "~/Teaching/courses/EC1004/docs/slides_1004/t15"))

(file-name-completion "update" (expand-file-name "~/Teaching/slides_1004/elisp/"))

(file-directory-p (expand-file-name "~/Teaching/courses/EC1004/docs/slides_1004/t10"))
