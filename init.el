;;; Package --- Sumary
;;; Commentary:
;;; Code:
(require 'package) ;; You might already have this line

;;-----------;
;;  Stuff    ;
;;-----------;
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize) ;; You might already have this line

(package-initialize)
(elpy-enable)
(desktop-save-mode 1)
(setq-default indent-tabs-mode nil)

;;-----------;
;;  Installs ;
;;-----------;

;; (unless (package-installed-p )
;;   (package-install ))
;; (require )

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)

(unless (package-installed-p 'rainbow-delimiters)
  (package-install 'rainbow-delimiters))
(require 'rainbow-delimiters)

(unless (package-installed-p 'smartparens)
  (package-install 'smartparens))
(require 'smartparens)

(unless (package-installed-p 'color-identifiers-mode)
  (package-install 'color-identifiers-mode))
(require 'color-identifiers-mode)

(unless (package-installed-p 'auctex)
  (package-install 'auctex))
(require 'tex)

(unless (package-installed-p 'elpy)
  (package-install 'elpy))

;;-----------;
;;  Themes   ;
;;-----------;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (darkokai)))
 '(custom-safe-themes
   (quote
    ("70403e220d6d7100bae7775b3334eddeb340ba9c37f4b39c189c2c29d458543b" default)))
 '(inhibit-startup-screen t)
 '(initial-frame-alist (quote ((fullscreen . maximized))))
 '(package-selected-packages
   (quote
    (anything-tramp helm-tramp docker-tramp use-package tern-auto-complete smartparens rainbow-delimiters nodejs-repl multi-term magit js2-mode jedi jade-mode helm-swoop helm-descbinds flycheck emmet-mode elpy dockerfile-mode darkokai-theme company-quickhelp color-identifiers-mode ace-jump-helm-line))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;-----------;
;;  window   ;
;;-----------;

(when window-system
  (tooltip-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1))

;;-----------;
;;   docker  ;
;;-----------;

;; Open files in Docker containers like so: /docker:drunk_bardeen:/etc/passwd
(push
 (cons
  "docker"
  '((tramp-login-program "docker")
    (tramp-login-args (("exec" "-it") ("%h") ("/bin/bash")))
    (tramp-remote-shell "/bin/sh")
    (tramp-remote-shell-args ("-i") ("-c"))))
 tramp-methods)

(defadvice tramp-completion-handle-file-name-all-completions
  (around dotemacs-completion-docker activate)
  "(tramp-completion-handle-file-name-all-completions \"\" \"/docker:\" returns
    a list of active Docker container names, followed by colons."
  (if (equal (ad-get-arg 1) "/docker:")
      (let* ((dockernames-raw (shell-command-to-string "docker ps | perl -we 'use strict; $_ = <>; m/^(.*)NAMES/ or die; my $offset = length($1); while(<>) {substr($_, 0, $offset, q()); chomp; for(split m/\\W+/) {print qq($_:\n)} }'"))
             (dockernames (cl-remove-if-not
                           #'(lambda (dockerline) (string-match ":$" dockerline))
                           (split-string dockernames-raw "\n"))))
        (setq ad-return-value dockernames))
    ad-do-it))


;;-----------;
;;    hooks  ;
;;-----------;

(add-hook 'latex-mode-hook #'smartparens-mode)
(add-hook 'LaTeX-mode-hook #'smartparens-mode)
(add-hook 'prog-mode-hook #'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook #'smartparens-mode)
(add-hook 'python-mode-hook 'jedi:setup)
(add-hook 'js-mode-hook (lambda () (tern-mode t)))

;;(add-hook 'js-mode-hook 'js2-minor-mode)
;;(setq jedi:complete-on-dot t)                 ; optional

;;-----------;
;;    Keys   ;
;;-----------;

(elpy-enable)

(global-set-key (kbd "M-S-<left>") 'windmove-left)
(global-set-key (kbd "M-S-<right>") 'windmove-right)
(global-set-key (kbd "M-S-<up>") 'windmove-up)
(global-set-key (kbd "M-S-<down>") 'windmove-down)

(global-set-key (kbd "M-s-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "M-s-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "M-s-<down>") 'shrink-window)
(global-set-key (kbd "M-s-<up>") 'enlarge-window)
(global-unset-key "\C-z")
(global-set-key "\C-z" 'advertised-undo)
;;-----------;
;;    Conf   ;
;;-----------;

;; Cut lines at 80th column
(setq-default fill-column 80)
(add-hook 'org-mode-hook 'turn-on-auto-fill)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'after-init-hook 'global-color-identifiers-mode)

;; utf-8 powaa!!
(set-language-environment 'utf-8)
(prefer-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(set-input-method nil)

;; Maximized!




(unless (package-installed-p 'docker-tramp)
  (package-install 'docker-tramp))
(require 'docker-tramp)

;;-----------;
;;  company  ;
;;-----------;

(use-package company-mode
  :init
  (add-hook 'after-init-hook 'global-company-mode))

(use-package company-quickhelp
  :ensure t
  :init (company-quickhelp-mode 1)
  :config (eval-after-load 'company
'(define-key company-active-map (kbd "C-c h") #'company-quickhelp-manual-begin)))

;;-----------;
;;  Python   ;
;;-----------;
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;;-----------;
;;    js     ;
;;-----------;
(add-to-list 'load-path "~/.emacs.d/config/")
(require 'js-settings)


;;-----------;
;;  helm     ;
;;-----------;
;; By @rockneurotiko
(use-package helm
  :ensure t
  :diminish helm-mode
  :init
  (progn
    (require 'helm-config)
    (setq helm-candidate-number-limit 100)
    ;; From https://gist.github.com/antifuchs/9238468
    (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
          helm-input-idle-delay 0.01  ; this actually updates things
                                        ; reeeelatively quickly.
          helm-yas-display-key-on-candidate t
          helm-quick-update t
          helm-M-x-requires-pattern nil
          helm-ff-skip-boring-files t)
    (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
          helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
          helm-recentf-fuzzy-match              t
          helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
          helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
          helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
          helm-ff-file-name-history-use-recentf t
          helm-M-x-fuzzy-match t)  ;; optional fuzzy matching for helm-M-x
    (helm-mode))
  :config
  (progn
    ;; rebind tab to run persistent action
    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
    ;; make TAB works in terminal
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)
    ;; list actions using C-z
    (define-key helm-map (kbd "C-z")  'helm-select-action))
  :bind (("C-x C-f" . helm-find-files)
         ("C-x C-b" . helm-buffers-list)
         ("C-x b" . helm-mini)
         ("M-y" . helm-show-kill-ring)
         ("M-x" . helm-M-x)
         ("C-h a" . helm-apropos)
         ("C-x c o" . helm-occur)
         ("C-x c y" . helm-yas-complete)
         ("C-x c Y" . helm-yas-create-snippet-on-region)
         ("C-x c SPC" . helm-all-mark-rings)
         ("C-c h g" . helm-google-suggest)))

(ido-mode -1)

(use-package helm-descbinds
  :ensure t
  :bind (("C-h b" . helm-descbinds)
         ("C-h w" . helm-descbinds)))

(use-package helm-swoop
  ;; :disabled t
  :ensure t
  :bind (("M-i" . helm-swoop)
         ("M-I" . helm-swoop-back-to-last-point)
         ("C-c M-i" . helm-multi-swoop)
         ("C-x M-i" . helm-multi-swoop-all)))

(use-package ace-jump-helm-line
  ;; :disabled t
  :ensure t
  :commands helm-mode
  :init (define-key helm-map (kbd "C-'") 'ace-jump-helm-line))


(defun set-helm-swoop ()
  ;; Change the keybinds to whatever you like :)
  )


(defun set-helm-ace-jump ()
)

;; (provide 'init)
;;; init.el ends here

