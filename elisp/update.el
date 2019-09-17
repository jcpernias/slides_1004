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
