;;; org-macros-test.el --- ERT tests for org-macros -*- lexical-binding: t; -*-

(require 'ert)
(require 'org)
(require 'ox)
(require 'ox-latex)
(require 'ob-core)
(require 'ob-shell)

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
