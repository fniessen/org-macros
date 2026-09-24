EMACS ?= emacs
EMACS_BATCH = $(EMACS) --batch --quick
PACKAGE_INIT = --eval "(require 'package)" --eval "(package-initialize)"

.PHONY: all check test export-html export-latex clean

all: check export-html export-latex

check: test
	$(EMACS_BATCH) --eval "(require 'org)" --eval "(dolist (file '(\"README.org\" \"TODO-org-macros.org\" \"tests/all-macros.org\" \"org/setup/org-macros.setup\")) (with-temp-buffer (insert-file-contents file) (org-mode) (org-element-parse-buffer) (princ (format \"%s: clean\\n\" file))))"
	git diff --check

test:
	$(EMACS_BATCH) -l tests/org-macros-test.el -f ert-run-tests-batch-and-exit

export-html:
	$(EMACS_BATCH) $(PACKAGE_INIT) --eval "(require 'htmlize)" --eval "(require 'ox-html)" --eval "(require 'ob-shell)" --eval "(let ((org-confirm-babel-evaluate nil) (root default-directory)) (find-file (expand-file-name \"README.org\" root)) (org-export-to-file 'html (expand-file-name \"README.html\" root) nil nil nil t) (find-file (expand-file-name \"tests/all-macros.org\" root)) (org-export-to-file 'html (expand-file-name \"tests/all-macros.html\" root) nil nil nil t))"

export-latex:
	$(EMACS_BATCH) --eval "(require 'ox-latex)" --eval "(require 'ob-shell)" --eval "(let ((org-confirm-babel-evaluate nil) (root default-directory)) (find-file (expand-file-name \"README.org\" root)) (org-export-to-file 'latex (expand-file-name \"README.tex\" root) nil nil nil t) (find-file (expand-file-name \"tests/all-macros.org\" root)) (org-export-to-file 'latex (expand-file-name \"tests/all-macros.tex\" root) nil nil nil t))"

clean:
	rm -f README.html README.tex tests/all-macros.html tests/all-macros.tex
