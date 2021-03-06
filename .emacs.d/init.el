;; bug fix gnutls
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; heavily insprired by https://blog.jft.rocks/emacs/emacs-from-scratch.html

;; Minimal UI
(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)

;; Package configs
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"   . "http://orgmode.org/elpa/")
			 ("melpa" . "https://melpa.org/packages/")
			 ("gnu"   . "https://elpa.gnu.org/packages/")
			 ))
;; (package-initialize)

;; Bootstrap `use-package`
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

;; Use a hook so the message doesn't get clobbered by other messages.
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (message "Emacs ready in %s with %d garbage collections."
		     (format "%.2f seconds"
			     (float-time
			      (time-subtract after-init-time before-init-time)))
		     gcs-done)))

;; Set default font
(set-face-attribute 'default nil
		    :family "Inconsolata for Powerline"
		    :height 180
		    :weight 'normal
		    :width 'normal)

;; https://emacs.stackexchange.com/questions/16818/cocoa-emacs-24-5-font-issues-inconsolata-dz
(add-to-list 'default-frame-alist '(height . 44))
(add-to-list 'default-frame-alist '(width . 100))


;; Make startup faster by reducing the frequency of garbage
;; collection.  The default is 800 kilobytes.  Measured in bytes.
(setq gc-cons-threshold (* 50 1000 1000))

;;
;; emacs setup
;;

;; Garbage-collect on focus-out, Emacs /should/ feel snappier.
(add-hook 'focus-out-hook #'garbage-collect)

;; super & meta on mac
(setq mac-command-modifier 'super
      mac-option-modifier  'meta)

;; emacs config hotkey
(defun find-config ()
  "Edit init.el"
  (interactive)
  (find-file "~/.emacs.d/init.el"))

;; make confirmation prompts shorter
(defalias 'yes-or-no-p 'y-or-n-p)

;; save buffers only once on quit
;; https://emacs.stackexchange.com/questions/13662/a-confirmation-after-c-x-c-c-before-exiting-emacs
(defun my-save-buffers-kill-emacs (&optional arg)
  "Offer to save each buffer(once only), then kill this Emacs process.
With prefix ARG, silently save all file-visiting buffers, then kill."
  (interactive "P")
  (save-some-buffers arg t)
  (and (or (not (fboundp 'process-list))
       ;; process-list is not defined on MSDOS.
       (let ((processes (process-list))
	 active)
	 (while processes
	   (and (memq (process-status (car processes)) '(run stop open listen))
	    (process-query-on-exit-flag (car processes))
	    (setq active t))
	   (setq processes (cdr processes)))
	 (or (not active)
	 (progn (list-processes t)
	    (y-or-n-p "Active processes exist; kill them and exit anyway? ")))))
       ;; Query the user for other things, perhaps.
       (run-hook-with-args-until-failure 'kill-emacs-query-functions)
       (or (null confirm-kill-emacs)
       (funcall confirm-kill-emacs "Really exit Emacs? "))
       (kill-emacs)))

;; load-path
(push "~/.emacs.d/elisp/" load-path)


;; @ebaker - comment-or-uncomment-region-or-line
(require 'comment-or-uncomment-region-or-line)

;; @ebaker - global super custom hotkeys
(global-set-key (kbd "s-/") 'comment-or-uncomment-region-or-line)
(global-set-key (kbd "s-'") 'indent-region)
(global-set-key (kbd "s-o") 'other-window)
(global-set-key (kbd "s-0") 'delete-window)
(global-set-key (kbd "s-1") 'delete-other-windows)
(global-set-key (kbd "s-2") 'split-window-below)
(global-set-key (kbd "s-3") 'split-window-right)
(global-set-key (kbd "s-b") 'ido-switch-buffer)
(global-set-key (kbd "s-k") 'ido-kill-buffer)
(global-set-key (kbd "s-a") 'org-agenda)
(global-set-key (kbd "C-x i") 'find-config)
(global-set-key (kbd "C-x C-c") 'my-save-buffers-kill-emacs)

;; @ebaker - remove keybinding eyebrowse
(assq-delete-all 'eyebrowse-mode minor-mode-map-alist)

;; from https://sam217pa.github.io/2016/09/02/how-to-build-your-own-spacemacs/

(setq delete-old-versions -1 )		; delete excess backup versions silently
(setq version-control t )		; use version control
(setq vc-make-backup-files t )		; make backups file even when in version controlled dir
(setq backup-directory-alist `(("." . "~/.emacs.d/backups")) ) ; which directory to put backups file
(setq vc-follow-symlinks t )				       ; don't ask for confirmation when opening symlinked file
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)) ) ;transform backups file name
(setq inhibit-startup-screen t )	; inhibit useless and old-school startup screen
(setq ring-bell-function 'ignore )	; silent bell when you make a mistake
(setq coding-system-for-read 'utf-8 )	; use utf-8 by default
(setq coding-system-for-write 'utf-8 )
(setq sentence-end-double-space nil)	; sentence SHOULD end with only a point.
;; (setq default-fill-column 140)		; toggle wrapping text at the 80th character
(setq initial-scratch-message ";; *scratch*\n\n") ; print a default message in the empty scratch buffer opened at startup

;; https://emacs.stackexchange.com/questions/28736/emacs-pointcursor-movement-lag/28746
(setq auto-window-vscroll nil)

;; custom.el
(setq custom-file (make-temp-file "emacs-custom"))
(setq-default custom-file (expand-file-name ".custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))
;; (setq custom-file (make-temp-file "emacs-custom")) ; custom.el - don't persist changes

;; Make it very easy to see the line with the cursor.
(global-hl-line-mode t)

;; Clean up any accidental trailing whitespace and in other places,
;; upon save.
(add-hook 'before-save-hook 'whitespace-cleanup)

;; remembers minibuffer history between sessions
(save-place-mode t)

;; cursor at the same place it was at before
(savehist-mode t)

;; Show matching parens
(setq show-paren-delay 0)
(show-paren-mode 1)

;; (global-font-lock-mode t)

;; environment variables
(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))

;; Defer Packages you don’t need Immediately with Idle Timers
(use-package recentf
  ;; Loads after 1 second of idle time.
  :defer 1)

(defun ebaker/emacsify-evil-mode ()
  "Remove Evil Normal state bindings and add some Emacs bindings in Evil Normal state."

  ;; remove all keybindings from insert-state keymap
  (setcdr evil-insert-state-map nil)
  ;; but [escape] should switch back to normal state
  (define-key evil-insert-state-map [escape] 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "C-e") 'evil-end-of-line)
  (define-key evil-normal-state-map (kbd "C-u") 'evil-scroll-up)
  (define-key evil-normal-state-map (kbd "[ m") 'beginning-of-defun)
  (define-key evil-normal-state-map (kbd "] m") 'end-of-defun)
  (define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)
  (define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "C-p") 'evil-previous-visual-line)
  (define-key evil-normal-state-map (kbd "C-n") 'evil-next-visual-line)
  (define-key evil-normal-state-map (kbd "C-f") 'evil-forward-char)
  (define-key evil-normal-state-map (kbd "C-n") 'evil-backward-char))

;; Vim mode
(use-package evil
  :ensure t
  :defer 1
  :init
  (setq evil-disable-insert-state-bindings t)
  (setq evil-want-C-u-scroll t)
  :config
  (evil-mode 1)
  (ebaker/emacsify-evil-mode)

  ;; @ebaker - enter normal state after saving
  (add-hook 'after-save-hook #'evil-normal-state))

;;
(defun ebaker/evilify-org-agenda-mode ()
  "Org Agenda use some Evil keybindings."

  (define-key org-agenda-mode-map "j" 'org-agenda-next-line)
  (define-key org-agenda-mode-map "k" 'org-agenda-previous-line)
  ;; (define-key org-agenda-mode-map "gj" 'org-agenda-next-item)
  ;; (define-key org-agenda-mode-map "gk" 'org-agenda-previous-item)
  (define-key org-agenda-mode-map "l" 'forward-char)
  (define-key org-agenda-mode-map "h" 'backward-char)
  (define-key org-agenda-mode-map (kbd "C-j") 'org-agenda-next-item)
  (define-key org-agenda-mode-map (kbd "C-k") 'org-agenda-previous-item)
  (define-key org-agenda-mode-map (kbd "[") 'org-agenda-earlier)
  (define-key org-agenda-mode-map (kbd "]") 'org-agenda-later)
  (define-key org-agenda-mode-map (kbd "f") 'org-agenda-earlier)
  (define-key org-agenda-mode-map (kbd "b") 'org-agenda-later)
  (define-key org-agenda-mode-map (kbd "m") 'org-agenda-bulk-toggle)
  (define-key org-agenda-mode-map (kbd "~") 'org-agenda-bulk-toggle-all)
  (define-key org-agenda-mode-map (kbd "*") 'org-agenda-bulk-mark-all)
  (define-key org-agenda-mode-map (kbd "%") 'org-agenda-bulk-mark-regexp)
  ;; (define-key org-agenda-mode-map (kbd "M") 'org-agenda-bulk-remove-all-marks)
  )


(use-package org
  :ensure t
  :defer 1
  :config
  (add-hook 'org-agenda-mode-hook #'ebaker/evilify-org-agenda-mode)
  (require 'eliot-org))

;; https://emacs.stackexchange.com/questions/22405/after-executing-org-narrow-to-subtree-how-do-i-move-between-subtrees-of-the-sam
(defun my/org-narrow-forward ()
  "Move to the next subtree at same level, and narrow to it."
  (interactive)
  (widen)
  (org-forward-heading-same-level 1)
  (org-narrow-to-subtree))

;; ore pretty bullets
(use-package org-bullets
  :ensure t
  :defer 2
  :after (org)
  :hook (org-mode . org-bullets-mode))

;; Theme
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-one t))

;; ivy
(use-package ivy :demand
  :ensure t
  :defer 1
  :config
  (setq ivy-use-virtual-buffers t
	ivy-count-format "%d/%d "
	ivy-initial-inputs-alist nil)
  (ivy-mode 1))

(use-package counsel
  :ensure t
  :bind (("M-x" . counsel-M-x)))

;; Which Key
(use-package which-key
  :ensure t
  :defer 1
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  :config
  (which-key-mode 1))

;; undo-tree
(use-package undo-tree
  :ensure t
  :diminish undo-tree-mode:
  ;; :config
  ;; (global-undo-tree-mode 1)
  )

(use-package expand-region
  :ensure t
  :bind ("C-=" . er/expand-region))

;; Custom keybinding
(use-package general
  :ensure t
  :defer 1
  :config (general-define-key
  :states '(normal visual insert emacs)
  :prefix "SPC"
  :non-normal-prefix "M-SPC"
  "/"   '(counsel-ag :which-key "ag") ; You'll need counsel package for this
  "TAB" '(switch-to-prev-buffer :which-key "previous buffer")
  "SPC" '(counsel-M-x :which-key "M-x")

  ;; Buffers
  "b" '(:ignore t :which-key "buffer")
  "bb" '(ivy-switch-buffer)

  ;; undo tree
  "u" '(undo-tree-visualize :which-key u)

  ;; describe-
  "d" '(:ignore t :which-key "describe-")
  "dv" '(describe-variable :which-key "describe-variable")
  "df" '(describe-function :which-key "describe-function")
  "dk" '(describe-key :which-key "describe-key")

  ;; eval-
  "e" '(:ignore t :which-key "eval-")
  "eb" '(eval-buffer :which-key "eval-buffer")
  "ex" '(eval-expression :which-key "eval-expression")
  "er" '(eval-region :which-key "eval-region")

  "p" '(:ignore t :which-key "projectile")
  "ps" '(projectile-switch-project :which-key "[s]witch project")

  ;; Window
  "w" '(:ignore t :which-key "windows")
  "wl"  '(windmove-right :which-key "move right")
  "wh"  '(windmove-left :which-key "move left")
  "wk"  '(windmove-up :which-key "move up")
  "wj"  '(windmove-down :which-key "move bottom")
  "w3"  '(split-window-right :which-key "split right")
  "w2"  '(split-window-below :which-key "split bottom")
  "wx"  '(delete-window :which-key "delete window")

  ;; Others
  "a" '(:ignore t :which-key "applications")
  "at"  '(ansi-term :which-key "open terminal")
))


;; Fancy titlebar for MacOS
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(ns-appearance . dark)) ;; light
(setq ns-use-proxy-icon  nil)
(setq frame-title-format nil)

;; Projectile
(use-package projectile
  :ensure t
  :init
  (setq projectile-require-project-root nil)
  :config
  (projectile-mode 1)
  (setq projectile-project-search-path '("~/r")))

    ;; Integration with `projectile'
    (with-eval-after-load 'projectile
      (setq projectile-completion-system 'ivy))


;; All The Icons
(use-package all-the-icons :ensure t)

;; NeoTree
(use-package neotree
  :ensure t
  :init
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow)))

;;
;; Diminish
;;
;; https://alhassy.github.io/init/

;; eldoc diminish working
;; (use-package diminish :ensure t
;;   :config
;;   (eval-after-load "eldoc" '(diminish 'eldoc-mode)))

;; (use-package delight
;;   :ensure t
;;   :config
;;   (delight '((eldoc-mode nil "eldoc"))))

;; ;; ;; Let's hide some markers.
;; ;; (diminish 'org-indent-mode)
;; ;; (diminish 'subword-mode)

;;
;; Flyspell
;;

;; https://emacs.stackexchange.com/questions/20946/generate-mouse-2-event-from-macbook-trackpad
(defun flyspell-mouse-2-macbook ()
  ;; Do things when flyspell enters of leaves flyspell mode.
  ;; Added manually
  ;;
  ;; Magic Mouse Fixes
  (if flyspell-mode (progn
       (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
       (define-key flyspell-mouse-map [mouse-3] #'undefined))
    nil)
  ;; End my-flyspell-mode-hook
  )

(use-package flyspell
  :init
  (setq ispell-program-name "/usr/local/bin/aspell")
  (setq ispell-dictionary "en_US") ;; set the default dictionary
  :diminish flyspell-mode: ;; Don't show it in the modeline.
  :hook
  ((text-mode . flyspell-mode)
   (flyspell-mode . flyspell-mouse-2-macbook)))

;; https://github.com/d12frosted/flyspell-correct/issues/30
;; (use-package flyspell-correct-popup
;;   :bind (("C-M-;" . flyspell-correct-wrapper)
;;	 (:map popup-menu-keymap
;;	      ("TAB" . popup-next)
;;	      ("S-TAB" . popup-previous)))
;;   :init
;;   (setq flyspell-correct-interface #'flyspell-correct-popup))

;; LSP
;; (require 'eliot-lsp)

;;
;; Company mode
;;

(use-package company
  :ensure t
  :init
  (setq company-minimum-prefix-length 2)
  (setq company-auto-complete nil)
  (setq company-idle-delay 0)
  (setq company-require-match 'never)
  (setq company-frontends
	'(
	  company-pseudo-tooltip-unless-just-one-frontend
	  company-preview-frontend
	  company-echo-metadata-frontend
	  )
	)
  (setq tab-always-indent 'complete)
  (defvar completion-at-point-functions-saved nil)
  :config
  (global-company-mode 1)
  ;; (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)
  ;; (define-key company-active-map (kbd "<tab>") 'company-complete-common-or-cycle)
  ;; (define-key company-active-map (kbd "S-TAB") 'company-select-previous)
  ;; (define-key company-active-map (kbd "<backtab>") 'company-select-previous)
  (define-key company-active-map (kbd "<down>") 'company-complete-common-or-cycle)
  (define-key company-active-map (kbd "<up>") 'company-select-previous)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map (kbd "C-n") 'company-complete-common-or-cycle)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "<tab>") 'company-complete-selection)
  (define-key company-active-map (kbd "<right>") 'company-complete-selection)
  (define-key company-active-map (kbd "TAB") 'company-complete-selection)
  (define-key company-active-map (kbd "S-TAB") 'company-abort)
  (define-key company-active-map (kbd "<backtab>") 'company-abort)
  (define-key company-active-map (kbd "ESC") 'company-abort)

  ;; prevent company from completing on its own when we type regular characters
  ;; ("SPC" . company--my-insert-spc)
  ;; ("."   . company--my-insert-dot)

  ;;   (define-key company-mode-map [remap indent-for-tab-command] 'company-indent-for-tab-command)
  ;;   (defun company-indent-for-tab-command (&optional arg)
  ;;     (interactive "P")
  ;;     (let ((completion-at-point-functions-saved completion-at-point-functions)
  ;;	  (completion-at-point-functions '(company-complete-common-wrapper)))
  ;;       (indent-for-tab-command arg)))

  ;; (defun company-complete-common-wrapper ()
  ;;   (let ((completion-at-point-functions completion-at-point-functions-saved))
  ;;     (company-complete-common)))
  )

;;; Elementary textual completion backend.
(setq company-backends
   (add-to-list 'company-backends 'company-dabbrev))

;; Company UI
;; (use-package company-box
;;   :ensure t
;;   :hook (company-mode . company-box-mode))
;; (use-package company-posframe
;;   :ensure t
;;   :config (company-posframe-mode 1))
;; (use-package posframe
;;   :ensure t)
;; (use-package company-quickhelp
;;   :ensure t)

;; (use-package eldoc-box
;; :ensure t)
;; (use-package company-quickhelp
;;   :ensure t)

;; eglot
;; (use-package eglot
;;   :ensure t
;;   )


;; Yasnippet
;; (require 'eliot-yasnippet)

;;
;; Powerline
;;

;; spaceline
(use-package spaceline
  :ensure t
  :init
  (setq powerline-default-separator 'utf-8)
  :config
  (spaceline-emacs-theme)
  (spaceline-toggle-minor-modes-off)
  (spaceline-toggle-buffer-size-off)
  (spaceline-toggle-evil-state-on))

;; doom-modeline
;; (use-package doom-modeline
;;   :ensure t
;;   :defer t
;;   :hook (after-init . doom-modeline-init))

;;;;;;;;;;;;;;;;;;;;;;;
;; Language Supports ;;
;;;;;;;;;;;;;;;;;;;;;;;

;; elisp
(use-package highlight-defined
  :ensure t
  :defer 2
  :config
  (add-hook 'emacs-lisp-mode-hook 'highlight-defined-mode)
  (add-hook 'emacs-lisp-mode-hook 'display-line-numbers-mode))

(add-hook 'emacs-lisp-mode-hook #'eldoc-mode)

;; JavaScript
;; npm i -g typescript typescrypt-language-server
(use-package js2-mode
  :ensure t
  :defer 2
  :init
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  :config
  (add-hook 'js2-mode 'display-line-numbers-mode)
  (setq js2-mode-show-parse-errors nil)
  (setq js2-mode-show-strict-warnings nil))

(add-hook 'js2-mode
	  (lambda ()
	    (setq-local eldoc-documentation-function #'ignore)))

(use-package tern
  :ensure t
  )

;; (use-package company-tern
;;   :ensure t
;;   :config
;; (add-to-list 'company-backends 'company-tern))

;; flymake
;; https://emacs.stackexchange.com/questions/36363/how-to-change-flycheck-symbol-like-spacemacs
(define-fringe-bitmap 'flymake-fringe-bitmap-ball
    (vector #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00111000
	    #b01111100
	    #b11111110
	    #b11111110
	    #b01111100
	    #b00111000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000))

(define-fringe-bitmap 'flymake-fringe-bitmap-ball-medium
    (vector #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00111000
	    #b01111100
	    #b01111100
	    #b00111000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000
	    #b00000000))

(use-package flymake-diagnostic-at-point
  :ensure t
  :after flymake
  :config
  (add-hook 'flymake-mode-hook #'flymake-diagnostic-at-point-mode))

(use-package flymake-eslint
  :ensure t
  :config
  (setq flymake-diagnostic-at-point-timer-delay 0.3)
  (add-hook 'js2-mode-hook ; or whatever the mode-hook is for your mode of choice
	    (lambda ()
	      (flymake-eslint-enable)))
 )

 ;; Typescript
;; (use-package typescript-mode
;;   :ensure t
;;   :defer 2
;;   :init
;;   (add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-mode)))

(use-package prettier-js
  :ensure t
  :config
  (add-hook 'js2-mode-hook 'prettier-js-mode)
  )

(use-package json-mode
  :ensure t
  :mode ("\\.json\\'"))

(use-package rjsx-mode
  :ensure t
  :mode ("/\\(components\\|containers\\|src\\|pages\\)/.*\\.js[x]?\\'")
  ;; (("/\\(containers\\)/[^/]*\\.js" . rjsx-mode)
  ;;  ("/\\(components\\)/[^/]*\\.js" . rjsx-mode)
  ;;  ("\\.jsx\\'" . rjsx-mode))
  ;; :config
  ;; (add-to-list 'lsp-language-id-configuration '(rjsx-mode . "javascript"))
  )

;; Dashboard
;; (require 'eliot-dashboard)

;; Make gc pauses faster by decreasing the threshold.
(setq gc-cons-threshold (* 2 1000 1000))
(global-eldoc-mode -1)
