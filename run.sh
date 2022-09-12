#!/bin/sh

emacs -Q --eval '(setq user-emacs-directory (expand-file-name "./"))' --load early-init.el --load init.el
