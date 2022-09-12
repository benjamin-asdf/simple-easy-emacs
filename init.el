;; The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

(defun efs/display-startup-time ()
  (message "Emacs loaded in %s with %d garbage collections."
           (format "%.2f seconds"
                   (float-time
                     (time-subtract after-init-time before-init-time)))
           gcs-done))

(add-hook 'emacs-startup-hook #'efs/display-startup-time)

;; Initialize package sources
;; (require 'package)
;; (package-initialize)
;; (unless package-archive-contents
;;   (package-refresh-contents))
  ;; Initialize use-package on non-Linux platforms
;; TODO: do I need this for winodws?
;; (unless (package-installed-p 'use-package)
;;   (package-install 'use-package))


(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)

(require 'use-package)

(setf
 straight-vc-git-default-protocol 'https
 straight-use-package-by-default t
 use-package-verbose t
 use-package-always-demand t)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")
        ("org" . "https://orgmode.org/elpa/")
        ("elpa" . "https://elpa.gnu.org/packages/")))

(setq inhibit-startup-message t)

(scroll-bar-mode -1)        ; Disable visible scrollbar
(tool-bar-mode -1)          ; Disable the toolbar
(tooltip-mode -1)           ; Disable tooltips
(set-fringe-mode 10)        ; Give some breathing room

(menu-bar-mode -1)            ; Disable the menu bar

(blink-cursor-mode -1)

;; Set up the visible bell
(setq visible-bell t)


(column-number-mode)
(global-display-line-numbers-mode t)

;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
                term-mode-hook
                shell-mode-hook
                treemacs-mode-hook
                eshell-mode-hook))
  (add-hook mode (lambda () (0 display-line-numbers-mode))))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(use-package mood-line
  :straight (:host github :repo "benjamin-asdf/mood-line")
  :config
  (setf mood-line-show-cursor-point t)
  (mood-line-mode))

(use-package vertico
  :init
  (vertico-mode)
  (setq vertico-scroll-margin 0)
  (setq vertico-count 20)
  (setq vertico-cycle t))

(use-package savehist :init (savehist-mode))

(use-package orderless
  :init
  (setq
   completion-styles '(orderless)
   completion-category-defaults nil
   completion-category-overrides '((file (styles partial-completion)))))

(require 'dired)
;; https://github.com/Gavinok/emacs.d
(use-package consult
  :bind (("C-x b"       . consult-buffer)
         ("C-x C-k C-k" . consult-kmacro)
         ("M-y"         . consult-yank-pop)
         ("M-g g"       . consult-goto-line)
         ("M-g M-g"     . consult-goto-line)
         ("M-g f"       . consult-flymake)
         ("M-g i"       . consult-imenu)
         ("M-s l"       . consult-line)
         ("M-s L"       . consult-line-multi)
         ("M-s u"       . consult-focus-lines)
         ("M-s g"       . consult-grep)
         ("M-s M-g"     . consult-grep)
         ("C-x C-SPC"   . consult-global-mark)
         ("C-x M-:"     . consult-complex-command)
         ("C-c n"       . consult-org-agenda)
         :map dired-mode-map
         ("O" . consult-file-externally)
         :map help-map
         ("a" . consult-apropos)
         :map minibuffer-local-map
         ("M-r" . consult-history))
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  :config
  (recentf-mode t))

(use-package emacs
  :config
  (load-theme 'modus-vivendi)
  (defun crm-indicator (args)
    (cons (format "[CRM%s] %s"
		  (replace-regexp-in-string
		   "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
		   crm-separator)
		  (car args))
	  (cdr args)))
  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
	'(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  (setq use-dialog-box nil)
  ;; Give some breathing room
  (set-fringe-mode 10)
  (setq inhibit-startup-message t
	initial-scratch-message "")

;;; Show matching parenthesis
  (show-paren-mode 1)
;;; By default, there’s a small delay before showing a matching parenthesis. Set
;;; it to 0 to deactivate.
  (setq show-paren-delay 0)
  (setq show-paren-when-point-inside-paren t)
  (setq show-paren-style 'parenthesis)

;;; Electric Pairs to auto-complete () [] {} "" etc. It works on regions.
  (electric-pair-mode)
  (setq redisplay-skip-fontification-on-input t)
  (setq fast-but-imprecise-scrolling t)
  (global-so-long-mode 1)

  (defalias 'yes-or-no-p 'y-or-n-p)

  (setq create-lockfiles nil)

  :bind ("<f5>" . modus-themes-toggle))

(use-package cider
  :config
  (setq cider-babashka-parameters "nrepl-server 0"
	clojure-toplevel-inside-comment-form t)

(defun simple-easy-clojure-hello ()
  (interactive)
  (unless
      (executable-find "clj")
    (user-error
     "Install clojure first! browsing to %s"
     (let ((url "https://clojure.org/guides/install_clojure")) (browse-url url) url)))
  (let*
      ((dir "~/simple-easy-clojure-hello")
       (_ (make-directory dir t))
       (default-directory dir))
    (shell-command "echo '{}' > deps.edn")
    (make-directory "src" t)
    (find-file "src/hello.clj")
    (when (eq (point-min) (point-max))
      (insert "(ns hello)\n\n(defn main []\n  (println \"hello world\"))\n\n\n;; this is a Rich comment, use it to try out pieces of code while you develop.\n(comment\n  (def rand-num (rand-int 10))\n  (println \"Here is a random number: \" rand-num))"))
    (call-interactively #'cider-jack-in-clj))))
