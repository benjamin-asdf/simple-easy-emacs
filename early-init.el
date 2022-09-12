;; Disable package.el in favor of straight.el
(setq package-enable-at-startup nil)
;; Byte compile warnings are useless for newcomers
;; TODO: straight still ends up loggin the warnings
(setq byte-compile-warnings
      '(not
	free-vars
	unresolved
	callargs
	redefine
	obsolete
	noruntime
	interactive-only
	lexical
	lexical-dynamic
	make-local
	mapcar
	not-unused
	constants
	docstrings
	docstrings-non-ascii-quotes
	suspicious))
