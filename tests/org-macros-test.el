;;; org-macros-test.el --- ERT tests for org-macros -*- lexical-binding: t; -*-

(require 'ert)
(require 'package)
(package-initialize)
(require 'org)
(require 'ox)
(require 'ox-html)
(require 'ox-latex)
(require 'ob-core)
(require 'ob-shell)
(require 'htmlize)

(defconst org-macros-test-root
  (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))

(defun org-macros-test-export (backend body file)
  (with-temp-buffer
    (insert (format "#+INCLUDE: %s\n\n%s\n"
                    (expand-file-name "org/setup/org-macros.setup"
                                      org-macros-test-root)
                    body))
    (org-mode)
    (setq buffer-file-name file)
    (let ((org-confirm-babel-evaluate nil))
      (org-export-as backend nil nil t nil))))

(ert-deftest org-macros-test-redact-latex ()
  (let ((output (org-macros-test-export 'latex
                                         "{{{redact(secret)}}}"
                                         (expand-file-name "README.org"
                                                           org-macros-test-root))))
    (should (string-match-p "\\\\colorbox{black}{\\\\textcolor{black}{secret}}"
                            output))))

(ert-deftest org-macros-test-version-history-babel-reference ()
  (org-macros-test-export 'ascii
                          "{{{version-history}}}"
                          (expand-file-name "README.org"
                                            org-macros-test-root))
  (with-temp-buffer
    (insert-file-contents (expand-file-name "org/setup/org-macros.setup"
                                            org-macros-test-root))
    (org-mode)
    (let* ((org-confirm-babel-evaluate nil)
           (result (org-babel-ref-resolve "version-history")))
      (should (listp result))
      (should (> (length result) 1)))))

(ert-deftest org-macros-test-color-html ()
  (let ((output (org-macros-test-export 'html
                                         "{{{color(red, colored text)}}}"
                                         (expand-file-name "README.org"
                                                           org-macros-test-root))))
    (should (string-match-p "<span style=\"color: red\">[[:space:]]*colored text[[:space:]]*</span>"
                            output))))

(ert-deftest org-macros-test-hex-colors-latex ()
  (let ((output (org-macros-test-export
                 'latex
                 "{{{bgcolor(#E0E0E0, background text)}}}\n{{{color(#FF0000, colored text)}}}"
                 (expand-file-name "README.org" org-macros-test-root))))
    (should (string-match-p "\\\\colorbox\\[HTML\\]{E0E0E0}{ background text}"
                            output))
    (should (string-match-p "\\\\textcolor\\[HTML\\]{FF0000}{ colored text}"
                            output))))

(ert-deftest org-macros-test-dual-backend-chunk-counts ()
  (with-temp-buffer
    (insert-file-contents (expand-file-name "org/setup/org-macros.setup"
                                            org-macros-test-root))
    (let ((html-count 0)
          (latex-count 0))
      (goto-char (point-min))
      (while (re-search-forward "^#\\+MACRO:.*$" nil t)
        (let ((definition (match-string-no-properties 0)))
          (when (and (string-match-p "@@html:" definition)
                     (string-match-p "@@latex:" definition))
            (setq html-count (+ html-count (how-many "@@html:" (line-beginning-position) (line-end-position))))
            (setq latex-count (+ latex-count (how-many "@@latex:" (line-beginning-position) (line-end-position)))))))
      (should (> html-count 0))
      (should (= html-count latex-count)))))

(ert-deftest org-macros-test-git-version ()
  (let ((repository-output
         (org-macros-test-export 'ascii
                                  "{{{git-version}}}"
                                  (expand-file-name "README.org"
                                                    org-macros-test-root)))
        (outside-output
         (org-macros-test-export 'ascii
                                  "{{{git-version}}}"
                                  "/tmp/org-macros-test.org")))
    (should (string-match-p "[[:alnum:]]" repository-output))
    (should (string-match-p "unknown" outside-output))))

;;; org-macros-test.el ends here
