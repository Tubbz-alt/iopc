(seq

;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/util.lsp ;;;;;;;;;;
(seq

; test for array -- instanceof doesn't work for arrays
(define isArray (obj) (invoke (invoke obj "getClass") "isArray"))

; collection (array, list, ...) to list of selected elements
(define select (col selectorC)
  (let ((list (object ("java.util.LinkedList"))))
   (seq
    (for elt col (if (apply selectorC elt) (invoke list "add" elt)))
    list
   ))
)


; return the accumulation
(define map (col mfun accum) (seq (for elt col (apply mfun elt accum)) accum))

;; lists as sets
(define setAdd (a x) (if (not (invoke a "contains" x)) (invoke a "add" x)))

(define lsubset (list0 list1 size ix)
  (if (> size ix)
    (if (invoke list1 "contains" (invoke list0 "get" ix))
     (apply lsubset list0 list1 size (+ ix (int 1)))   
     (boolean false))
   (boolean true)
  )
)

(define ljoin (list1 list0 size ix)
  (if (> size ix)
    (seq
      (if (invoke list1 "contains" (invoke list0 "get" ix))
        (boolean false)
        (invoke list1 "add" (invoke list0 "get" ix))
      )
     (apply ljoin list1 list0 size (+ ix (int 1)))   
     ) ; seq
   list1
   ) ; if
)

(define ldiff (list1 list0 size ix)
 (if (> size ix)
    (seq
       (invoke list1 "remove" (invoke list0 "get" ix))
       (apply ldiff list1 list0 size (+ ix (int 1)))   
     )
  list1) 
)

; delete without side effect
(define ldelete (list object)
  (let ((l (invoke list "clone"))) (seq  (invoke l "remove" object) l))
)

; itemPrinter is a printer for the collection item type
;  (apply itemPrinter elt strbuffer) should append print string to passed buffer
(define printCol (col itemPrinter)
  (let ((strb (object ("java.lang.StringBuffer"))) )
    (seq
      (for item col (apply itemPrinter item strb))
       (invoke strb "toString")
     )
  )
)

(define printArr (arr)(apply printCol arr 
    (lambda (elt strb) (invoke strb "append" (concat elt " ")))))


(define listOccs (gname fname chatty?)
  (let ((graph (fetch gname))
        (onodes (apply select (invoke graph "getNodesInArray") 
                       (lambda (node) (= (getAttr node "type") "occ"))))
        (pfun (lambda (node) 
                (getAttr node (if chatty?  "chattylabel" "label")))) 
    )
  (sinvoke "g2d.util.IO" "collection2File" onodes fname pfun (boolean false) )
 )
)


) ; top seq
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/pla.lsp ;;;;;;;;;;
(seq

;;; *********** DEBUG settings *********

; define verbosity
; (supdate "g2d.util.ActorMsg" "VERBOSE" (boolean true))
(supdate "g2d.runtime.ExceptionHandler" "SHUTDOWN_AFTER_ERROR" (boolean false))
(sinvoke "g2d.jlambda.Debugger" "setVerbosity" (boolean true))

 ;;; new tweakage added iam in February 2012 -- only effect currently 
 ;;; is to include/suppress the "Show Info" graph menu item
 ;;; default is false ...
 (supdate "g2d.pla.PLA" "developmental" (boolean true))

;;09july19
;; g2d.runtime vs pla

; if true prints lola retcode and path to GUI output
; and leaves the lola files in /tmp
(define lolaDebug (boolean false))

;;; *********** exception handling *********

; define exception handler
(sinvoke "g2d.jlambda.Debugger" "setHandler" (object ("g2d.runtime.ExceptionHandler")))

; add shutdown hook to send shutdown command to IOP
(invoke (sinvoke "java.lang.Runtime" "getRuntime") 
	"addShutdownHook" 
	(object ("g2d.runtime.ShutdownHook" "shutdown_hook")))

;;; *********** colors *********

;lavendar
(define noneFillColor (object ("java.awt.Color" (int 210) (int 202) (int 255))))
;dklavendar
(define initFillColor (object ("java.awt.Color" (int 150) (int 150) (int 255))))
;ltgreen
(define goalFillColor (object ("java.awt.Color" (int 100) (int 255) (int 90))))
;red
(define ngoalFillColor (object ("java.awt.Color" (int 255) (int 0) (int 0))))
;orangeish
(define avoidFillColor (object ("java.awt.Color" (int 255) (int 136) (int 102))))
;lighter ltgreen
(define usesFillColor (object ("java.awt.Color" (int 180) (int 255) (int 160))))
;bluegreen
(define foundFillColor (object ("java.awt.Color" (int 0) (int 255) (int 255))))
;black
(define nodeBorderColor java.awt.Color.black)
;grey
;(define cxtBorderColor (object ("java.awt.Color" (int 204) (int 204) (int 204))))
(define cxtBorderColor java.awt.Color.gray)
;ltgrey
;(define cxtFillColor (object ("java.awt.Color" (int 204) (int 204) (int 255))))
(define cxtFillColor java.awt.Color.white)
;ltyellow
;(define ruleFillColor (object ("java.awt.Color" (int 251) (int 255) (int 145))))
(define ruleFillColor java.awt.Color.lightGray)
;darker dklavendar
(define bidirEdgeColor (object ("java.awt.Color" (int 50) (int 25) (int 255))))
;black
(define unidirEdgeColor java.awt.Color.black)

; tell Java about the colors
(supdate "g2d.graph.IOPGraph" "cxtBorderColor" cxtBorderColor)

; (supdate "g2d.graph.IOPGraph" "noneFillColor" noneFillColor)
; (supdate "g2d.graph.IOPGraph" "initFillColor" initFillColor)
; (supdate "g2d.graph.IOPGraph" "goalFillColor" goalFillColor)
; (supdate "g2d.graph.IOPGraph" "ngoalFillColor" ngoalFillColor)
; (supdate "g2d.graph.IOPGraph" "avoidFillColor" avoidFillColor)
; (supdate "g2d.graph.IOPGraph" "usesFillColor" usesFillColor)
; (supdate "g2d.graph.IOPGraph" "foundFillColor" foundFillColor)
; (supdate "g2d.graph.IOPGraph" "nodeBorderColor" nodeBorderColor)
; (supdate "g2d.graph.IOPGraph" "cxtFillColor" cxtFillColor)
; (supdate "g2d.graph.IOPGraph" "ruleFillColor" ruleFillColor)
; (supdate "g2d.graph.IOPGraph" "bidirEdgeColor" bidirEdgeColor)
; (supdate "g2d.graph.IOPGraph" "unidirEdgeColor" unidirEdgeColor)

;; remove if nothing breaks
; called whenever node attribute changes to recalculate fill color:
 (define XXXcalcNodeFillColor (nodename)
  (let ((node (fetch nodename)))
    (seq
     (if (= node (object null)) noneFillColor ; unknown node
     (if (= "rule" (getAttr node "type")) 
         (if (= "avoid" (getAttr node "status"))
             avoidFillColor
             ruleFillColor) ; "type" = "rule": look whether "avoid"
     (if (= "true" (getAttr node "context")) cxtFillColor
     (if (= "none" (getAttr node "status"))
         (if (= "true" (getAttr node "init")) 
             initFillColor
             noneFillColor) ; "status" = "none": look at "init"
         (if (= "goal" (getAttr node "status")) ; "status" != "none" 
             goalFillColor
             (if (= "avoid" (getAttr node "status")) avoidFillColor))
     )))) ; 4x if
  )) ; seq;let
) ;calcNodeFillColor	  



;;; *********** interfaces *********

; from ii.maude -----------

; echos messages sent by g2d to GUI output window
(define sendMessage (to from msg)
  (sinvoke "g2d.util.ActorMsg" "send" to from msg)
) ;sendMessage

;(apply displayMessage2G %gname %title %message)
(define displayMessage2G (gname title msg)
  (let (
        (graph (fetch gname))
        (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
        (sep (invoke panel "getSEPanel"))
        )
    (invoke sep "displayText" title msg)
    ) ;let
) ;displayMessage2G




;(apply displayMessage %title %message)
(define displayMessage (title msg)
  (seq
   ; show message in warning dialog:
   (sinvoke "javax.swing.JOptionPane" "showMessageDialog" 
	    (object null)
	    msg
	    title
	    javax.swing.JOptionPane.WARNING_MESSAGE)
   )
)

;(apply lolaRequest %net %task %id %requestor)
;; CLT split in to local request and remote resquest server
(define lolaRequest (net task reqId requestor)
  (let ((res (apply doLolaReq net task reqId)))
     (apply sendMessage requestor "graphics2d"
	    (concat (aget res (int 0)) " " (aget res (int 1))))
	)
)

(define doLolaReq (net task reqId)
  (let ((lolaNetFile (invoke (sinvoke "java.io.File" "createTempFile" 
				      (concat "lola" reqId "_") ".net")
			     "getAbsolutePath")) 
	(lolaTaskFile (invoke (sinvoke "java.io.File" "createTempFile" 
				       (concat "lola" reqId "_") ".task")
			     "getAbsolutePath")) 
	(lolaPathFile (invoke (sinvoke "java.io.File" "createTempFile" 
				       (concat "lola" reqId "_") ".path")
			     "getAbsolutePath")) 
	(command (concat "lola " lolaNetFile 
			 " -a " lolaTaskFile
			 " -p " lolaPathFile))
	(res (mkarray java.lang.String (int 2)))
	)
    (seq
     (sinvoke "g2d.util.IO" "string2File" net lolaNetFile)
     (sinvoke "g2d.util.IO" "string2File" task lolaTaskFile)
; run lola       
; retcode == 0 => SATISFIED
; retcode == 1 => NOT-SAT
; retcode =/= 0 => UNDECIDED
     (try 
      (let ((lolaProc (invoke (sinvoke "java.lang.Runtime" "getRuntime")
			      "exec" command))
	    (dummy
	     (if lolaDebug
		 (invoke java.lang.System.err "println" "lolaProc started")))
	    (retcode (invoke lolaProc "waitFor"))
	    (resPath
	     (if (= retcode (int 0))
		 (sinvoke "g2d.util.IO" "file2String" lolaPathFile)
	       ""))
	    )
	(seq 
	 (if lolaDebug
	     (seq
	      (invoke java.lang.System.err "println" 
		      (concat "retcode: " retcode))
	      (invoke java.lang.System.err "println" 
		      (concat "resPath: " resPath))
	      ))  ; if
	 (aset res (int 0) (concat "" retcode))
	 (aset res (int 1) resPath)
	 )) ; seq;let
    (catch var 
      (seq (apply displayMessage "error" "run lola failed")
	     (aset res (int 0) (concat "" (- (int 1))))
	     (aset res (int 1) "")) 
	  ) ; catch
   ) ;try
   (if (not lolaDebug)
	 (seq
	  (sinvoke "g2d.util.IO" "deleteFile" lolaNetFile)
	  (sinvoke "g2d.util.IO" "deleteFile" lolaTaskFile)
	  (sinvoke "g2d.util.IO" "deleteFile" lolaPathFile)))
     res
     ))  ;seq;let
) ; doLolaReq


; from dg2g2d.maude -----------
;;; --- adding nodes and edges to graph:

(define maxLabLen (int 20))
(define useChattyLabels (boolean false))


;;; *********** begin explorer code *********

;;; 06oct09 clt code for exploring 

(define colorXGraph (graph)
  (let ((nodes (invoke graph "getNodesInArray")))
     (for node nodes
       (if (= (getAttr node "type" "") "rule")
         (invoke node "setFillColor" java.awt.Color.lightGray)
         (let ((xstatus (getAttr node "xstatus" ""))
               (color 
                 (if (= xstatus "seen")
                     java.awt.Color.lightGray
                 (if (= xstatus "oup") initFillColor
                 (if (= xstatus "odn") java.awt.Color.green
                 (if (= xstatus "oboth") java.awt.Color.cyan 
                  java.awt.Color.white)
                 ))))  ; color
             )
          (seq 
            (invoke node "setFillColor" color)
          )
         ) ;let
       ) ;if
     ) ;for
  ) ;let
)

(define redisplay (graph)
  (let ((panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph)))
    (seq
      (invoke graph "resetDotLayout")
      (if (invoke graph "isDotLayout") (invoke graph "doLayout" (object null)))
      (invoke panel "setGraph" graph)
      )
    )
)

; (apply addXOccNode graph %occLab %occLoc %occChattyLab %nodeId %occXInit %occXStatus)
(define addXOccNode (graph lab loc clab nid xinit xstatus)
  (let ((node (apply addOccNodeX graph lab loc clab nid xinit "none" "true"))
	)
    (seq
     (setAttr node "init" "false") ; override setting of "xinit" used for coloring
     (setAttr node "xinit" xinit)
     (setAttr node "xstatus" xstatus)
     node))
) ;addXOccNode



)
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/exploreSelect.lsp ;;;;;;;;;;
(seq
; (apply exploreSelectRules %title %gname %rids %replyto %replyfor)
;                             graphname array[String]
(define exploreSelectRules (title parent ruleids replyto replyfor)
  (let (
        (parentobj (fetch parent))
        (frame (if (instanceof parentobj "g2d.graph.IOPGraph") (sinvoke "g2d.pla.PLAUtils" "getTabFrame" parentobj) (getAttr (fetch "KBManager") "kbframe")))
        (sdialog (object ("g2d.subset.SDialog" frame (boolean true))) )
        (order g2d.util.Orderings.INTEGRAL_PREFIX)
        )
    (seq
     ;this one results in the combobox being ordered correctly
     (sinvoke "java.util.Arrays" "sort" ruleids order)
     (invoke sdialog "setUniverse" ruleids)
     ;this one results in the STree being ordered correctly
     (invoke sdialog "addTab" "Lexical" order)
     (invoke sdialog "setTitle" title)
     (invoke sdialog "setVisible" (boolean true))
     (invoke sdialog "toFront")
     (let ((selected (invoke sdialog "getStrings" (int 1)))
           (ans (if (= selected (object null)) 
                    ""
                  (apply sarray2string  selected 
                         (lookup selected "length") (int 0) "")
                  ))
           )
       (sinvoke "g2d.util.ActorMsg" "send" replyto replyfor ans)
       )      
     ))  ; seq ; let
) ; end exploreSelectRules

(define sarray2string (selected len cur ans)
  (if (>= cur len)
   ans
   (apply sarray2string  selected len (+ cur (int 1))
          (concat ans " " (aget selected cur))      
   ))
)

; (apply sarray2string (array java.lang.String "a" "b" "c") (int 3) (int 0) "")

; (apply exploreSelectOccs %title %gname %occids %replyto %replyfor)
(define exploreSelectOccs (title parent occids replyto replyfor)
  (let (
        (parentobj (fetch parent))
        (frame (if (instanceof parentobj "g2d.graph.IOPGraph") (sinvoke "g2d.pla.PLAUtils" "getTabFrame" parentobj) (getAttr (fetch "KBManager") "kbframe")))
        (sdialog (object ("g2d.subset.SDialog" frame (boolean true))) )
      	;this is new, and is used below
      	(order g2d.util.Orderings.LEXICAL_CASE_INSENSITIVE)
        (four (object ("g2d.subset.StateSpace" )))
        (names (array java.lang.String 
                      "         " 
                      " (both)  "
                      " (up)    "
                      " (dn)    "))
       	;this is new, if we sort them here, they appear nicely in the combobox drop down....
        (dummy (seq (sinvoke "java.util.Arrays" "sort" occids order)
		    (invoke four "setValency" (int 4))
                    (invoke four "setNames" names)))
        (universe (object ("g2d.subset.Universe" occids four)))
       )
    (seq
      (invoke sdialog "setUniverse" universe)
      (invoke sdialog "addTab" "Lexical")
      (invoke sdialog "setTitle" title)
      (invoke sdialog "setVisible" (boolean true))
      (invoke sdialog "toFront")
      (let ((both (invoke sdialog "getStrings" (int 1)))
            (up (invoke sdialog "getStrings" (int 2)))
            (dn (invoke sdialog "getStrings" (int 3)))
            (ansb (if (= both (object null)) 
                   ""
                  (apply occChattySelect2string  both "b" 
                               (lookup both "length") (int 0) "")))
            (ansu (if (= up (object null)) 
                   ansb
                  (apply occChattySelect2string  up "u" 
                               (lookup up "length") (int 0) (concat ansb " "))))
            (ansd (if (= dn (object null)) 
                   ansu
                  (apply occChattySelect2string  dn "d" 
                               (lookup dn "length") (int 0) (concat ansu " "))))
              )
        (sinvoke "g2d.util.ActorMsg" "send" replyto replyfor ansd)
       )      
     ))  ; seq ; let
) ; end exploreSelectRules


(define occChattySelect2string (selected tag len cur ans)
  (if (>= cur len)
   ans
   (apply occChattySelect2string  selected tag len (+ cur (int 1))
          (concat ans  (aget selected cur) " " tag " " )      
   ))
)




(define test (what)
  (let ((parent (object ("g2d.glyph.Attributable")))
        (frame (object ("g2d.swing.IOPFrame" "test")))
        (ids (array java.lang.String
                         "102.def"  "hello" "Src-act-CLi" 
                           "1433-CLc" "213.xyz#a"))
        )
    (seq
      (invoke parent "setUID" "parent") 
      (setAttr parent "frame" frame)
      (if (= what "rules")
        (apply exploreSelectRules "foo" "parent" ids "maude" "maudereq3")
        (apply exploreSelectOccs "foo" "parent" ids "maude" "maudereq3")
      )
    ) ; seq
  ) ; let
)
; (apply test "rules")
; (apply test "occs")
)

;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/query.lsp ;;;;;;;;;;
(seq

(define mkStatusString (graph)
  (let ((nodes (invoke graph "getNodesInArray")))
    (apply nodes2status nodes (int 0) (lookup nodes "length") "")
  ) 
)

(define nodes2status (nodes cur len str)
  (if (>= cur len)
   str
   (let ((node (aget nodes cur))
         (nid (getAttr node "nid" ""))
         (status (getAttr node "status" "none")))
    (apply nodes2status nodes (+ cur (int 1)) len 
         (if (or (= status "none") (= nid ""))
          str 
          (concat str " " nid " " status) 
      ) ) ) ; if app let 
  )  
) ; nodes2status


(define subnetRequest (graph)
  (sinvoke "g2d.util.ActorMsg" "send" 
           "maude"
           (invoke graph "getUID")
           (concat "displaySubnet1" " " (apply mkStatusString graph))
           )
  )

(define pathRequest (graph)
  (sinvoke "g2d.util.ActorMsg" "send" 
           "maude"
           (invoke graph "getUID")
           (concat "displayPath1" " " (apply mkStatusString graph))
           ) 
  )


(define nodeById (nodes id cur len)
  (if (>= cur len)
   (object null)
   (let ((node (aget nodes cur))
         (nid (getAttr node "nid" ""))
        )
     (if (= nid id)
      node
      (apply nodeById nodes id (+ cur (int 1)) len) 
      ) ) ) ; if let if
) ; nodeById

(invoke java.lang.System.err "println"  "query.lsp loaded")
)

;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/kbmanager.lsp ;;;;;;;;;;
(seq

(define mkKBAction (label tip list cmd)
  (let ((closure
           (lambda (self event)
                (let ((selection (invoke list "getSelectedValue")))
                  (if (= selection (object null))
                      (invoke java.lang.System.err "println" 
                           (concat "KBManager no kb selected for " cmd)) 
                      (sinvoke "g2d.util.ActorMsg" 
                               "send" "maude" selection cmd)))))
         )
    (object ("g2d.closure.ClosureAbstractAction"
             label
				 (object null) ; icon
				 tip
             (object null) ; accelerator
				 (object null) ; mnemonic
				 closure     ; action closure
            ))
   )) ;mkKBAction
;                      dish name string array
(define initKBwdo (title kbm dishes)
  (let (
       (frame (object ("g2d.pla.ManagerFrame" title)))
        (isRemote (sinvoke "g2d.Main" "isRemote"))
        (model (object ("javax.swing.DefaultListModel")))
        (list (object ("javax.swing.JList" model) ))
;;;clt 09may23
        (pd (apply makeProgressDialog2 frame (boolean true)))                             
        (toolbar (object ("javax.swing.JToolBar"  
                          javax.swing.JToolBar.VERTICAL)))
;;; added
        (dishbutton (object ("g2d.swing.IOPDropdownButton" "Select Dish")))
        (editDishClosure
           (lambda (self event)
              (let ((selection (invoke list "getSelectedValue")))
                  (sinvoke "g2d.util.ActorMsg" 
                               "send" "maude" selection "newDish"))))
        (predefClosure (lambda (dname) (lambda (s e )
                (let ((kbname  (invoke list "getSelectedValue")))
                  (seq
                    (sinvoke "g2d.util.ActorMsg" 
                    "send" "maude" kbname (concat "displayPetri " dname)) 
;;;clt 09may23
                    (apply showProgressDialog pd "Creating dishnet"))
                    )
                ))
               )
        (exploreOccsAction 
           (apply mkKBAction "Explore(Occs)" 
                           "Explore the selected knowledge base from occurrences" 
                             list "exploreInit occ"))
        (exploreRulesAction 
           (apply mkKBAction "Explore(Rules)" 
                           "Explore the selected knowledge base from rules" 
                             list "exploreInit rule"))
         )
    (seq
      (invoke frame "setSize" (int 200) (int 350))
      (invoke list "setFixedCellHeight" (int 20))
      (invoke toolbar "addSeparator")
      (invoke dishbutton "addMenuItem" "Edit" editDishClosure)
      (if (> (lookup dishes "length") (int 0))
          (invoke dishbutton "addMenu" "PreDefined" dishes predefClosure))
      (invoke toolbar "add" dishbutton (int -1))
;;;
      (invoke toolbar "addSeparator")
      (invoke toolbar "add" exploreOccsAction)
      (invoke toolbar "addSeparator")
      (invoke toolbar "add" exploreRulesAction)
      (invoke toolbar "setFloatable" (boolean false))
      (invoke frame  "add" toolbar java.awt.BorderLayout.EAST)
      (invoke frame  "add" list java.awt.BorderLayout.CENTER)
;;; clt 09july26
      (setAttr kbm "kbnames" model)
      (setAttr kbm "kblist" list)
      (setAttr kbm "kbframe" frame)
;;;clt 09may23
      (invoke pd "setLocation" (int 20) (int 175))
      (setAttr kbm "progressd" pd)
;; redundant
;;      (setAttr kbm "kbfname" (invoke (invoke frame "getID") "getUID"))
;;      (invoke frame "setVisible" (boolean true))
;;;09dec08 clt freezing kbm until the KB is ready
    (if isRemote 
    (sinvoke "g2d.util.ActorMsg" "send" "maude" "iop_remote_actor" "OK") 
    (sinvoke "g2d.util.ActorMsg" "send" "maude" "graphics2d" "OK") 
    )
    (apply showProgressDialog  pd "initializing KB")      
) ) ) ; seq ; let ; initKBwdo

(define defKBManager ()
  (let ((name  "KBManager")
        (kbm0 (fetch name))
        (kbm (if (= kbm0 (object null))  ; **** don't create if exists
                 (object ("g2d.glyph.Attributable"))
                 kbm0))
        (dishes (array java.lang.String ))
     )
    (seq
      (if (= kbm0 (object null)) (invoke kbm "setUID" name))
      (apply initKBwdo "PLA KB Manager" kbm dishes) ;; set kbnames,kbframe attrs.
    )
))

(define defKBManagerD (dishes)
  (let ((name  "KBManager")
        (kbm0 (fetch name))
        (kbm (if (= kbm0 (object null))  ; **** don't create if exists
                 (object ("g2d.glyph.Attributable"))
                 kbm0)))
    (seq
      (if (= kbm0 (object null)) (invoke kbm "setUID" name))
      (apply initKBwdo "PLA KB Manager" kbm dishes) ;; set kbnames,kbframe attrs.
    )
))

(define defKBGraph 
  (kbname occ-labs occ-ids occ-aexps occ-locs rule-labs rule-ids)
  (let ((kbg0 (fetch kbname))
        (kbg (if (= kbg0 (object null))  ; **** don't create if exists
                 (object ("g2d.glyph.Attributable"))
                 kbg0))
        (kbm (fetch "KBManager"))
        (kbnames (if (= kbm (object null)) 
                     (object null)
                     (getAttr kbm "kbnames" (object null))))
        (kbframe (if (= kbm (object null)) 
                     (object null)
                     (getAttr kbm "kbframe" (object null))))
        (kblist (if (= kbm (object null)) 
                     (object null)
                     (getAttr kbm "kblist" (object null))))
         )
    (seq
      (invoke kbnames "addElement" kbname)  ; add element to list
      (if (= kbg0 (object null)) (invoke kbg "setUID" kbname))
      (setAttr kbg "frame" (object ("g2d.swing.IOPFrame" "test")))
      (setAttr kbg "occ-labs" occ-labs)
      (setAttr kbg "occ-ids" occ-ids)
      (setAttr kbg "occ-aexps" occ-aexps)
      (setAttr kbg "occ-locs" occ-locs)
      (setAttr kbg "rule-labs" rule-labs)
      (setAttr kbg "rule-ids" rule-ids)
      (setAttr kbg "occ-bases"   (apply computeBasis occ-aexps))      
      (if (invoke kblist "isSelectionEmpty")
          (invoke kblist "setSelectedIndex" (int 0)))
      (invoke kbframe "setVisible" (boolean true))          
;;; 09dec08 clt unfreeze kbm          
      (apply hideProgressDialog (getAttr kbm "progressd"))
    )
  ))

;; <cr> or red button closes wdo, answer is what ever is in the box, maybe ""
(define askUser (frame title msg)
   (let ((asker (object ("g2d.swing.IOPAskUser" frame title msg (boolean true)))))
      (seq 
        (invoke asker "setVisible" (boolean true))
        (invoke asker "getAnswer")
      )
     )
  )

; (apply initDishEditor %kbname %dishnames)
(define initDishEditor (kbname dishnames)
  (let ((kb0 (fetch kbname))
        (kb (if (instanceof kb0 "g2d.glyph.Attributable") 
             kb0
             (object ("g2d.glyph.Attributable")) ))
        (entries (getAttr kb "occ-labs" (array java.lang.String) ))
        (bases   (getAttr kb "occ-bases" (array java.util.LinkedList) ))
        (locations (getAttr kb "occ-locs" (array java.lang.String) ))
        (frame (object ("javax.swing.JFrame" "DDialog Test")))
;                                                         modal?
        (ddialog (object ("g2d.subset.DDialog" frame (boolean false))))
        (button (object ("g2d.swing.IOPDropdownButton" "Dish")))
      ; the two closures for the drop down button:
        (open (lambda (s e) 
	        (let ((dish (invoke ddialog "getEntriesFromFile"))
            	  (result (invoke ddialog "add2Dish" dish))
            	  ) 
            (if (instanceof result "java.lang.String") 
                (apply displayMessage "Bad dish component" result)	  
            	  result)
            )))
       (save (lambda (s e) (invoke ddialog "saveEntriesToFile")))
       (askmaude (lambda (dname) (lambda (s e )
;;;; 09july19
           (seq 
;            (invoke ddialog "setVisible" (boolean false))
           (sinvoke "g2d.util.ActorMsg" 
                    "send" "maude" kbname (concat "getDish " dname)) )) )
                    )
       (okClosure 
         (lambda (s e)
           (let ((selected (invoke ddialog "getSelected"))
                 (udname (apply askUser frame "AskUser" "Type in a dish name"))
                 (ans (apply sarray2string selected 
                             (lookup selected "length") (int 0) "")))
             (if (= udname "")
               (apply displayMessage "Alert" "No Dish Name")
             (if (= (lookup selected "length") (int 0))
               (apply displayMessage "Alert" "Empty Dish")
               (sinvoke "g2d.util.ActorMsg" "send" "maude" kbname 
                              (concat "displayNewDish " udname " " ans))
              )) ; if if
           )))   ; let lambda okClosure
        ) 
  (seq 
   (invoke ddialog "add2DishToolbar" button)

   (invoke button  "addMenuItem" "Open" open)
   (invoke button  "addMenuItem" "Save" save)
   (invoke button  "addMenu" "Ask Maude" dishnames askmaude)

   (invoke ddialog "setScope" entries bases)

   ;make a  real tab via the agreed API
   (invoke ddialog "classify" "Spatial" entries  locations)
   (invoke ddialog "addTab" "Spatial")

   ;now actually build the trees 
;   (invoke ddialog "fireUpdate")
   (setAttr kb "dishEditor" ddialog)
   (invoke ddialog "setOKClosure" okClosure)
   (invoke ddialog "setVisible" (boolean true))
   ))
) ;initDishEditor

; maude kbname displayNewDish user-dname toks

; want to give disheditor closure to call upon exit

; (apply getDishReply %kbname %dishoccs)
;                      string String[]
(define getDishReply (kbname dishoccs)
  (let ((kb (fetch kbname))
        (editor (if (instanceof kb "g2d.glyph.Attributable")
                    (getAttr kb "dishEditor" )
                    (object null)))
       )                
    (if (instanceof editor "g2d.subset.DDialog")
        (let ((result (invoke editor "add2Dish" dishoccs)))
;;;;09july19  editor crash
          (seq
;            (invoke editor "setVisible" (boolean true))
          (if (instanceof result "java.lang.String") 
              (apply displayMessage "Bad Maude dish component" result)	  
          	  result)
          )
        ))
  ) ;let
)

) ;top seq


; (apply defKBManager)
; (apply defKBGraph "KB0" (array java.lang.String "occ0") (array java.lang.String "0") (array java.lang.String "Out") (array java.lang.String "1.occ.act") (array java.lang.String "1") )

; (define kbl6 (getAttr (fetch "KBManager") "kblist"))
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/info.lsp ;;;;;;;;;;
(seq
 
; *** create a string from an array of strings recursively
;     each string in array is prepended with given prefix, then the given 
;     closure <makeString> is applied (use "ident" if no change desired), 
;     and then given postfix (e.g., a newline character) is appended
; arr: Array of strings
; cur: current index in recursion
; msg: containing string assembled so far
(define printArray (arr prefix makeString postfix cur msg)
  (if (>= cur (lookup arr "length"))
      msg
      (apply printArray arr prefix makeString postfix (+ cur (int 1)) 
	     (concat msg 
		     prefix 
		     (apply makeString (aget arr cur))
		     postfix))
  )
)

; use this for "makeString" if strings in array don't need alteration
(define ident (str) str) ; identity function

;;; ------ requests from Maude -----

(define displayProteinInfo (gname hugosym spnum synonymsArray)
  (let ((message 
           (concat "Hugo: " hugosym "\n" 
                   "SwissProt ID: " spnum "\n"
                   "Synonyms: \n")))
    (apply displayMessage2G gname "ProteinInfo" 
      (apply printArray synonymsArray "    " ident "\n" (int 0) message))
   )
)

(define displayChemicalInfo (gname keggcpd synonymsArray)
  (let ((message 
           (concat "KeggCpd: " keggcpd "\n" 
                   "Synonyms: \n")))
    (apply displayMessage2G gname "ChemicalInfo" 
      (apply printArray synonymsArray "    " ident "\n" (int 0) message))
   )
)

(define displayOtherInfo (gname sort opstr)
  (let ((message 
           (concat "Sort: " sort "\n" 
                   "Occ:  " opstr "\n")))
    (apply displayMessage2G gname "OtherInfo" message)
   )
)

(define ruleEvidence (gname clab refArray)
  (apply displayMessage2G gname 
	 (concat "Evidence for Rule \"" clab "\"")
	 (if (> (lookup refArray "length") (int 0))
	     (concat "<html><br>"
       (if (= evidencePath "")
	     (apply printArray refArray "PubMed ID " makePMIDLink "<br>" (int 0)  " ")
	     (apply printArray refArray "Evidence File " makeEvidenceLink "<br>" (int 0)  " "))
		     "</html>")
	     "\n(none)"))
)
(define makePMIDLink (pmid)
  (concat "<a href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=PubMed&list_uids="
	  pmid
	  "&dopt=Abstract\">"
	  pmid
	  "</a>")
)

(define makeEvidenceLink (link)
  (concat "<a href=\""
    evidencePath
	  link
	  "\">"
	  link
	  "</a>")
)


)
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/infox.lsp ;;;;;;;;;;
(seq
(define displayComponentInfo (gname clab infoArray)
  (apply displayMessage2G gname 
     (concat "About " clab )
     (let ((strb (object ("java.lang.StringBuffer"))))
      (seq 
        (invoke strb "append" "<html><br> ")
        (for item infoArray (apply makeInfoItem item strb ))
        (invoke strb "append" " </html>")
        (invoke strb "toString")
      ) ) ; seq let
  ) ; apply
)


(define makeInfoItem (item strb)
 (if (> (lookup item "length") (int 2))
  (let ((type (aget item (int 0)))
        (tag (aget item (int 1))) )
   (if (= type "val")
     (invoke strb "append" (concat tag  ": "  (aget item (int 2)) " <br><p>"))  
     (if (> (lookup item "length") (int 3))
       (if (= type "link") 
         (invoke strb "append" (concat tag  ": <a href=\""  
                                       (aget item (int 3)) "\">"
                                       (aget item (int 2)) "</a><br><p>" )) 
         (if (= type "list")
           (seq 
             (invoke strb "append" (concat tag  ": <br><ul>"))
             (apply makeListItem (aget item (int 2)) (aget item (int 3)) strb)
             (invoke strb "append" "</ul>")
            ) ; 
           "" ) ; if list
         ) ; if link
      "") ; 3x if len > 3
     ) ; if val
   ) ; let
  ) ; if len > 2
)

(define makeListItem (fun items strb)
  (for item items (invoke strb "append" (concat " <li> " item)))
)


(define displayHistory (gname hstring)
    (apply displayMessage2G gname "Exploration History" hstring)
)


(define saveHistory (gname hstring)
; ask user for filename
; output
  (let ((graph (fetch gname))
        (frame (sinvoke "g2d.pla.PLAUtils" "getTabFrame" graph))
        (chooser (object ("g2d.swing.IOPFileChooser" 
                          g2d.tabwin.TabPreferences.FC_RAW_TEXT_AREA 
                          g2d.tabwin.TabPreferences.FC_RAW_TEXT_FORMAT 
                          g2d.tabwin.TabPreferences.FC_RAW_TEXT_FILE)))
        (retval (invoke chooser "showSaveDialog" frame))
  )
  (if (= retval javax.swing.JFileChooser.APPROVE_OPTION)
     (let ((selectedFile (invoke chooser "getSelectedFile"))
           (fileName (invoke selectedFile "getName") )
       )
       (sinvoke "g2d.util.IO" "string2File" hstring fileName)
     )
   ) ;if
 )
)

) ;top seq

(seq
 (define a1 (array java.lang.String "val" "Name"  "foo"))
 (define a2 (array java.lang.String "link" "KEGG" "C00042"
                 "http://www.genome.jp/dbget-bin/www_bget?compound+C00042"))
 (define a3  (array java.lang.Object "list" "Synonyms"  ident 
              (array java.lang.String  "synonym1" "synonym2" )))
 (define iarr (array java.lang.Object a1 a2 a3))
 (define s1 "Name: foo <br><p>")
 (define s2 (concat "KEGG: "
  "<a href=\"http://www.genome.jp/dbget-bin/www_bget?compound+C00042\">"
	  "C00042 </a>" "<br><p>"
	))
 (define s3 "Synonyms: <br> <ul> <li> s1 <li> s2 </ul><br>")
 (define msg (concat "<html><br> " s1 s2 s3 " </html>"))
)
; (apply displayComponentInfo "graph4" "something" iarr)




;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/nodeColoring.lsp ;;;;;;;;;;
(seq

(define defaultFillColor java.awt.Color.white)

(define colorPnetNode (node)
  (let ((type (getAttr node "type" ""))
        (context? (getAttr node "context" "")) 
       )
    (if (= context? "true") cxtFillColor
    (if (= type "occ")    (apply colorPnetOccNode node)
    (if (= type "rule")    (apply colorPnetRuleNode node)
     java.awt.Color.white
    )))
  )
)


(define colorPnetOccNode (node)
  (let ((init (getAttr node "init" ""))
        (status (getAttr node "status" "none")) 
       )
    (if (= status "goal")  goalFillColor
    (if (= status "avoid") avoidFillColor
    (if (= init "true")  initFillColor
      noneFillColor
     )))  ; 5x if
    ) ; let
)
; trying coloring init with status
;    if (= status "none")  noneFillColor

(define colorPnetRuleNode (node)
  (let ((status (getAttr node "status" "none")))
    (if (= status "none") ruleFillColor
    (if (= status "avoid") avoidFillColor
      ruleFillColor
     ))  ; 2x if
    ) ; let
)

(define colorXnetNode (node)
   (let ((type (getAttr node "type" ""))
         (context? (getAttr node "context" "")) 
         )
    (if (= context? "true") cxtFillColor
    (if (= type "occ")    (apply colorXnetOccNode node)
    (if (= type "rule")    (apply colorXnetRuleNode node)
     java.awt.Color.white
    )))
  )
)


(define colorXnetRuleNode (node)
  (if (=  (getAttr node "xselect" "none") "none")
     ruleFillColor
     java.awt.Color.yellow )
)

(define colorXnetOccNode (node)
   (if (not (= (getAttr node "xselect" "none") "none"))
    ;; dispatch on selection mode
     java.awt.Color.yellow  
   ;; dispatch on xstatus
    (let ((xstatus (getAttr node "xstatus" "none")))
     (if (= xstatus "seen") java.awt.Color.lightGray
     (if (= xstatus "oup") initFillColor
     (if (= xstatus "odn") java.awt.Color.green
     (if (= xstatus "oboth") java.awt.Color.cyan 
      java.awt.Color.white
      )))) ; 4x if xstatus
     ) ;let
   )  ; if selected
)


(define colorCnetNode (node)
  (let ((compare (getAttr node "compare" "both"))
         (context? (getAttr node "context" "")) 
         )
    (if (= context? "true") cxtFillColor
    (if (= compare "left")  initFillColor  ; parent
    (if (= compare "right")
      (object ("java.awt.Color" (int 0) (int 255) (int 255)))
;;      java.awt.Color.white
      java.awt.Color.pink
     )) ) 
    ) ; let
)


(invoke java.lang.System.err "println"  "coloring.lsp loaded")
)
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/defineGraph.lsp ;;;;;;;;;;
;; functions to define / update graphs
;; needs nodeColoring.lsp
(seq

(define setAttrsAVX (obj tags vals)
  (let ((tlen (lookup tags "length"))
        (vlen (lookup vals "length"))
        (len (if (> tlen vlen) vlen tlen))
      )
  (apply setAttrsAV obj tags vals len (int 0))
  )
)

(define setAttrsAV (obj tags vals len cur)
  (if (>= cur len)
   obj
   (seq
    (setAttr obj (aget tags cur) (aget vals cur))
    (apply setAttrsAV obj tags vals len (+ cur (int 1)))))
)

(define extendSEMenu (graph  clist)
  (let (
        (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
        (sep (invoke panel "getSEPanel"))
        )
    (seq
;    (invoke java.lang.System.err "println"  "extendingSEMenu")
     (invoke sep "displayMenu" "" clist (object null) (boolean false))
  )
))

; for explore graph add checkBoxes to context menu tab
(define mkXnetMouseClickedClosure (graph)
  (lambda (self e)
    (seq 
;     (invoke java.lang.System.err "println" 
;          (concat e "\n" "xnet mouse click on " "\n" self))
      (if (instanceof self "g2d.graph.IOPNode")
        (let ((type (getAttr self "type")))
          (seq
          (if (= type "rule") 
            (apply doXnetMouseClickedRuleAction graph self e)             
          (if (= type "occ")
            (apply doXnetMouseClickedOccAction graph self e)
            (object null))) ; not a known node type
          ))
     (object null)  ; not a node
   ) ; if
  ) ;seq
 )
)

(define  doXnetMouseClickedRuleAction (graph node e)  
  (let ((clist (object  ("java.util.ArrayList")))
        (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
        (cbHideRule (object ("javax.swing.JCheckBox" "hideRule")))
        (acHideRule (apply mkXRuleCheckClosure panel node cbHideRule "t"))
        (selection (getAttr node "xselect" "none"))
      )
     (seq
      (invoke cbHideRule "setAction"
         (object ("g2d.closure.ClosureAbstractAction"
                  "hideRule" acHideRule)))
      (if (= selection "t")
          (invoke cbHideRule "setSelected" (boolean true))
       )
      (invoke clist "add" cbHideRule)
;      (invoke java.lang.System.err "println"  "rule calling extendSEMenu")
      (apply extendSEMenu graph clist)
     )
   )
)
; oup  explore up
; odn  explore dn
; oboth explore up dn up/dn
; seen  no options

(define  doXnetMouseClickedOccAction (graph node e)  
  (let ((clist (object ("java.util.ArrayList")))
        (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
        (cbBoth (object ("javax.swing.JCheckBox" "explore Up+Down")))
        (acBoth (apply mkXOccCheckClosure panel node cbBoth clist "b"))
        (cbUp (object ("javax.swing.JCheckBox" "explore Up")))
        (acUp (apply mkXOccCheckClosure panel node cbUp clist "u"))
        (cbDown (object ("javax.swing.JCheckBox" "explore Down")))
        (acDown (apply mkXOccCheckClosure panel node cbDown clist "d"))
        (selection (getAttr node "xselect" "none"))
        (xstatus (getAttr node "xstatus" "none"))
      )
     (seq
      (invoke cbBoth "setAction"
         (object ("g2d.closure.ClosureAbstractAction"
                  "explore Up&Down" acBoth)))
      (invoke cbUp "setAction"
         (object ("g2d.closure.ClosureAbstractAction"
                  "explore up stream" acUp)))
      (invoke cbDown "setAction"
         (object ("g2d.closure.ClosureAbstractAction"
                  "explore down stream" acDown)))
      (if (not (= selection "none"))
          (if (= selection "u")
              (invoke cbUp "setSelected" (boolean true))
          (if (= selection "d")
              (invoke cbDown "setSelected" (boolean true))
          (if (= selection "b")
              (invoke cbBoth "setSelected" (boolean true))
          ))) )
      (if (= xstatus "oboth") (invoke clist "add" cbBoth))
      (if (or (= xstatus "oboth") (= xstatus "oup"))
          (invoke clist "add" cbUp))
      (if (or (= xstatus "oboth") (= xstatus "odn"))          
          (invoke clist "add" cbDown))
      ;(invoke java.lang.System.err "println"  "occ calling extendSEMenu")
      (apply extendSEMenu graph clist)
     )
   )
)


(define mkXOccCheckClosure (panel node cb clist mode)
  (lambda (self e)
     (let ((checked? (invoke cb "isSelected"))
           (xstatus (getAttr node "xstatus" "none"))
           (bordercolor (if checked? java.awt.Color.red nodeBorderColor))
          )
      (seq
        (setAttr node "xselect" (if checked? mode "none"))
        (if checked?
           ; disable others
           (for cb1 clist 
             (if (not (= cb1 cb)) (invoke cb1 "setEnabled" (boolean false))) )
           ; enable all
           (for cb1 clist (invoke cb1 "setEnabled" (boolean true) ))
         )
        (invoke node "setFillColor" (apply colorXnetNode node)) 
        (invoke node "setBorderColor" bordercolor) 
        (invoke panel "repaint")
     )))  ; seq let lambda
)


(define mkXRuleCheckClosure (panel node cb  mode)
  (lambda (self e)
     (let ((checked? (invoke cb "isSelected"))
;          (color (apply colorXRuleNode  checked?))
           (bordercolor (if checked? java.awt.Color.red nodeBorderColor))
          )
      (seq
        (setAttr node "xselect" (if checked? mode "none"))
;; should lookup color function in graph
        (invoke node "setFillColor" (apply colorXnetNode node)) 
        (invoke node "setBorderColor" bordercolor) 
        (invoke panel "repaint")
     )))  ; seq let lambda
)

(define newNode (graph type mouseClickedClosure nid lab clab tags vals colorFun)
  (if (= type "occ")
    (apply newOccNode graph mouseClickedClosure nid lab clab tags vals colorFun)
    (if (= type "rule")
      (apply newRuleNode graph mouseClickedClosure 
                         nid lab clab tags vals colorFun)
      (object null)
    )) ; 2x if
)

(define newOccNode (graph mouseClickedClosure nid lab clab tags vals colorFun)
  (let ((label (if useChattyLabels
                   clab
                	(if (> (invoke lab "length") maxLabLen)
				          (invoke lab "substring" (int 0) maxLabLen) 
				          lab)
                   ))
        (nattrs (object ("g2d.graph.DotNodeAttributes" label "ellipse"  nodeBorderColor defaultFillColor (int 1))))
        (node (sinvoke "g2d.graph.IOPNode" "makeOcc" nid lab clab nattrs))
        )
    (seq 
     (setAttr node "type" "occ")
     (setAttr node "nid" nid)
     (setAttr node "chattylabel" clab)
     (setAttr node "label" lab)
     ;(invoke node "setBaseDimension" (double 10) (double 10))
     (apply setAttrsAVX node tags vals)
     (invoke node "setFillColor" (apply colorFun node))

     (invoke node "setLabel" (if useChattyLabels clab lab))

     (if (instanceof mouseClickedClosure "g2d.jlambda.Closure")
          (invoke node "setMouseAction"
                  java.awt.event.MouseEvent.MOUSE_CLICKED mouseClickedClosure)
      )
     (invoke graph "addNode" node)
     node))
) ;newOccNode

; add a rule node to given graph
(define newRuleNode (graph mouseClickedClosure nid lab clab tags vals colorFun)
  (let (
        (nattrs (object ("g2d.graph.DotNodeAttributes" lab "box"  nodeBorderColor defaultFillColor (int 1))))
        (node (sinvoke "g2d.graph.IOPNode" "makeRule" nid lab clab nattrs))
        )
    (seq 
     (setAttr node "type" "rule")
     (setAttr node "nid" nid)
     (setAttr node "chattylabel" clab)
     (setAttr node "label" lab)
     ;(invoke node "setBaseDimension" (double 10) (double 10))
     ;(invoke node "setLabel" lab)
     ;
     ;<fun zone>
;     (invoke nattrs "setDotAttribute" g2d.graph.DotAttributes.SHAPE  "triangle") 
;     (invoke nattrs "setDotAttribute" g2d.graph.DotAttributes.ORIENTATION  (double 180.0)) 
;     (invoke nattrs "setDotAttribute" g2d.graph.DotAttributes.SIDES  (int 3)) 
;     (invoke nattrs "setDotAttribute" g2d.graph.DotAttributes.FONTSIZE  (int 3)) 
     ;</fun zone>
    
     (apply setAttrsAVX node tags vals)

     (invoke node "setFillColor" (apply colorFun node))

     (if (instanceof mouseClickedClosure "g2d.jlambda.Closure")
         (invoke node "setMouseAction"
                 java.awt.event.MouseEvent.MOUSE_CLICKED mouseClickedClosure))
     (invoke graph "addNode" node) 
     node))
  ) ;newRuleNode


; add a node to given explore graph
(define newXNode (graph type mouseClickedClosure nid lab clab tags vals colorFun)
  (if (invoke graph "isDotLayout")
    (apply newNode graph type mouseClickedClosure 
                   nid lab clab tags vals colorFun)
    (let ((node (invoke graph "getIOPNode" clab)))
      (if (instanceof node "g2d.graph.IOPNode")
        (seq 
          (apply setAttrsAVX node tags vals)
          (setAttr node "context" (object null))
          (invoke node "setFillColor" (apply colorFun node))
          (invoke node "setBorderColor" nodeBorderColor)
          (if (instanceof mouseClickedClosure "g2d.jlambda.Closure")
              (invoke node "setMouseAction"
                  java.awt.event.MouseEvent.MOUSE_CLICKED mouseClickedClosure))
          node
         )
        ;; shouldn't happen
          (apply newNode 
                 graph type mouseClickedClosure nid lab clab tags vals colorFun)
      ) ; if IOPNode 
     ) ;let
  ) ; if isDot
)

(define updateXNode (graph nid xstatus colorFun)
  (let ((node (invoke graph "getNode" nid)))
  (seq
    (setAttr node "xselect" "none")
    (setAttr node "xstatus" xstatus)
    (invoke node "setFillColor" (apply colorFun node))
 ))
)        

(define newEdge (graph srcid tgtid bidir?)
  (let ((src (invoke graph "getNode" srcid))
        (tgt  (invoke graph "getNode" tgtid))
        (color (if (= bidir? "true") bidirEdgeColor  unidirEdgeColor))
        (e (object ("g2d.graph.IOPEdge" src tgt color))) )
    (seq 
      ; can replace "dashed" by "dotted"
     (if (= bidir? "true")  (invoke e "setStyle" "dashed"))
     (invoke e "setDoubleEnded" (boolean false)) 
     (setAttr e "bidir" bidir?)
     (invoke graph "addEdge" e)
     e))
) ;newEdge

(define newXEdge (graph srcid tgtid bidir?)
  (if (invoke graph "isDotLayout")
    (apply newEdge graph srcid tgtid bidir?)
    (let ((edge (invoke graph "getEdge"
                    (invoke graph "getNode" srcid)
                    (invoke graph "getNode" tgtid))
                 )
          )
      (if (instanceof edge "g2d.graph.IOPEdge")
          (seq (setAttr edge "context" (object null)) 
               (invoke edge "setColor" 
                      (if (= bidir? "true") bidirEdgeColor  unidirEdgeColor))
               edge)
          ;; shouldn't happen
          (apply newEdge graph srcid tgtid bidir?)
     ) ; if edge
   ) ; let
  ) ; if Dot
)

; remove a node from a given explore graph
(define delXNode (graph  nid)
  (let ((node  (invoke graph "getNode" nid)))
    (if (instanceof node "g2d.graph.IOPNode")
      (if (invoke graph "isDotLayout")
          (invoke graph "rmNode" node)
          (seq (setAttr node "context" "true")
               (setAttr node "xselect" "none")
               (invoke node "setFillColor" cxtFillColor)
               (invoke node "setBorderColor" cxtBorderColor)
               (invoke node "unsetMouseAction" 
                              java.awt.event.MouseEvent.MOUSE_CLICKED )
          )
      ) ; if isDot
    ) ; if IOPNode 
  ) ;let
)

; remove a node from a given explore graph
(define delXEdge (graph  srcid tgtid)
  (let ((edge (invoke graph "getEdge"
                     (invoke graph "getNode" srcid)
                     (invoke graph "getNode" tgtid)) )
        )
    (if (instanceof edge "g2d.graph.IOPEdge")
      (if (invoke graph "isDotLayout")
          (invoke graph "rmEdge" edge)
          (seq (setAttr edge "context" "true")
               (invoke edge "setColor" cxtBorderColor))          
      ) ; if isDot
    ) ; if IOPEdge
  ) ;let
)


)  ; top level seq
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/showGraph.lsp ;;;;;;;;;;
;;; 07nov25 cleaning up graph display

;; 09july19 pla.toolbar. >> g2d.toolbar.
(seq

;op is dishnet pathnet subnet compare explore
;

 (define makeGraphTitle (gname graph) 
   (let (
         (contention ":")
         (requestor (getAttr graph "requestor"))
         (requestop (getAttr graph "requestop"))
         (requestargs (getAttr graph "requestargs")))
     (if (= requestop "dishnet")
         (concat gname contention requestargs)
       (if (= requestop "subnet")
           (concat gname contention "S(" requestor ")")
        (if (= requestop "pathnet")
            (concat gname contention "P(" requestor ")")
          (if (= requestop "explore")
              (concat gname contention "E(" requestor ")")
          (if (= requestop "compare")
              (concat gname contention "C(" requestor "," requestargs ")")
            "Mystery")))))
     )
   )

 (define getGraphParent (graph) 
   (let ((kb (getAttr graph "kbname"))
         (requestor (getAttr graph "requestor")))
     (seq 
      ;(invoke java.lang.System.err "println" requestor)
      ;(invoke java.lang.System.err "println" kb)
      ;(invoke java.lang.System.err "println" (fetch requestor))
      (if (= kb requestor) (object null) (fetch requestor))
      )
     )
   )

;              

 (define formatquery (query padding) 
   (seq
;    (invoke java.lang.System.err "println"  query)
;    (invoke java.lang.System.err "println"  padding)
    (let 
        (
         (patternstring "goals\\s(.*)\\s*avoids\\s(.*)\\s*hides\\s(.*)\\s*")
;buggy         (patternstring "goals\\s(\\S*)\\s*avoids\\s(\\S*)\\s*hides\\s(\\S*)\\s*")
         (pattern (sinvoke "java.util.regex.Pattern" "compile" patternstring))
         (matcher (invoke pattern "matcher" query))
         )
      (if (invoke matcher "matches") 
          (let (
                (goals  (invoke (invoke matcher "group" (int 1)) "trim"))
                (avoids (invoke (invoke matcher "group" (int 2)) "trim"))
                (hides (invoke (invoke matcher "group" (int 3)) "trim"))
                (sb (object ("java.lang.StringBuffer")))
                )
            (seq
             (if (not (invoke "" "equals" goals)) (invoke sb "append" (concat padding  "Goals:  " goals "\n"))) 
             (if (not (invoke "" "equals" avoids)) (invoke sb "append" (concat padding "Avoids: " avoids "\n"))) 
             (if (not (invoke "" "equals" hides)) (invoke sb "append" (concat padding  "Hides:  " hides "\n"))) 
             (invoke sb "toString")
             )
            )
        (concat "Matching failed! query = \"" query "\"")
        )
      )
    )
   )
 
 
 (define indentation (gname description indent)
   (let ((strings (invoke description "split" "\\n"))
         (sb (object ("java.lang.StringBuffer"))))
     (seq 
;;      (invoke java.lang.System.err "println" (lookup strings "length"))
      (for line strings 
           (seq (invoke sb "append" indent)
                (invoke sb "append" line)
                (invoke sb "append" "\n")))
      (invoke sb "toString"))))
 
 (define makeGraphDescription (gname graph) 
   (let (
         (padding " ")
         (spadding "    ")
         (ppadding "    ")
         (contention ": ")
         ;(kb (getAttr graph "kbname"))
         (requestor (getAttr graph "requestor"))
         (requestop (getAttr graph "requestop"))
         (requestargs (getAttr graph "requestargs")))
     (if (= requestop "dishnet")
         (concat gname contention "DishNet(" requestor ", " requestargs ")")
       (if (= requestop "subnet")
           (let ((gname1 requestor)
                 (descriptor1 (lookup (fetch gname1) "description" ))
                 (child1 (apply indentation gname1 descriptor1 padding))
                 (query (apply formatquery requestargs spadding)))
             (concat gname contention "SubNet(" gname1 ") with \n" query "\n" child1)
             )
         (if (= requestop "pathnet")
           (let ((gname1 requestor)
                 (descriptor1 (lookup (fetch gname1) "description" ))
                 (child1 (apply indentation gname1 descriptor1 padding))
                 (query (apply formatquery requestargs ppadding)))
               (concat gname contention "PathNet(" gname1 ") with \n" query "\n" child1))
           (if (= requestop "explore")
               (concat gname contention "[" requestor "].E(" requestargs ")")
             (if (= requestop "compare")
                 (let ((gname1 requestor)
                       (gname2 requestargs)
                       (descriptor1 (lookup (fetch requestor) "description" ))
                       (descriptor2 (lookup (fetch requestargs) "description" ))
                       (child1 (apply indentation gname1 descriptor1 padding))
                       (child2 (apply indentation gname2 descriptor2 padding))
                       )
                   (concat gname contention "Compare(" gname1 ", " gname2 ")\n\n"  child1 "\n" child2))
               "Mystery")))))
     )
   )
 

; common graph showing code
;;iam 2012 version
;;N.B. Large amount of redundancy in arguments...

;(apply anyShowGraph gname (fetch gname) (object null) (object null) title subtitle selections toolBarFun menuBarFunBase)


(define anyShowGraph (gname graph pname pgraph title subtitle selections toolBarFun menuBarFun)
   (seq
     (invoke graph "setStrokeWidth" (float 1.0))
     ;; do layout with dot by default
     (invoke graph "doLayout" (object null))
     ;;<workzone>
     ;; this block needs to migrate out of here to newGraph ...
     (update graph "name" gname)
     ;;note that parent is now private (must use getters and setters)
     ;;done this way because a graph now knows (and hence "setParent" maintains) its children 
     (invoke graph "setParent" (apply getGraphParent graph))
     (update graph "title"  (apply makeGraphTitle gname graph))
     (update graph "description" (apply makeGraphDescription gname graph))
     ;;</work zone>

     (let ((gname (lookup graph "name"))
           (pgraph (invoke graph "getParent")))
       (seq 
        (update graph "colorClosure" (getAttr graph "colorFun" (object null)))
        (update graph "toolBarClosure" 
                (lambda (panel graph) 
                  (apply toolBarFun (lookup panel "toolBar") gname graph panel pgraph))) 
        (update graph "menuBarClosure" 
                (lambda (panel graph) 
                  (apply menuBarFun gname graph panel)))
        )) ; let

     ;; launch graph in new panel, next to parent graph, or new frame if parent is null
     (sinvoke "g2d.pla.PLAUtils" "launchTab"  graph selections)
     ;; get progressbar attr from KBM, if not null, setvisible false
     (apply closeProgressd)
     graph)
   ) ; anyShowGraph

; showing updated Xnet graph
(define showUXGraph (gname)
  (let ((graph (if (instanceof gname "java.lang.String")
            		 (fetch gname)
                   (object null)))

        )
    (if (instanceof graph "g2d.graph.IOPGraph")
;        (apply redisplay graph)
        (let ((panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph)))
          (seq
            (invoke graph "resetDotLayout")
            (if (invoke graph "isDotLayout") 
               (invoke graph "doLayout" (object null)))
            (invoke panel "setGraph" graph)
;            (invoke frame "repaint") ;; redundant setGraph repaints
          ) ; seq
        ) ;let
     ) ;if
  ) ; let
) ; showUXGraph


; (apply showNewGraph %gname %parent %selections %title %subtitle  %toolBarFun )
;                      str  str or null bool                 id
;;iam 2012 version (still needs work: toolbar and menu stuff pushed into anyShowGraph missing)
;;iam 2012  gname vs graph & pname vs parent  WANTS TO be cleaned up


;   (apply showNewGraph "graph15" (object null) (boolean true) "Subnet of rafUbe213Dish" " "  toolBarFunPnet )
(define showNewGraph (gname pname selections title subtitle toolBarFun)
  (let ((parent (if (instanceof pname "java.lang.String")
                  (fetch pname)
                  (object null)))
        (graph (fetch gname))
	      )
    (seq
     (apply anyShowGraph gname graph pname parent title subtitle selections toolBarFun menuBarFunBase)
     ))
)

;
(invoke java.lang.System.err "println"  "showNewGraph defined")

(define getKBMFrame ()
  (let ((kbm (fetch "KBManager")))
    (if (instanceof kbm "g2d.glyph.Attributable")
     (getAttr kbm "kbframe")
     (object null)
      ))
)

(define menuBarFunBase (gname graph panel) 
  (seq
    (if (not (sinvoke "g2d.Main" "isRemote"))
      (apply menuBarFunBaseX gname graph panel) 
      )
    ;; add compareMenu
    (invoke (lookup panel "menuBar") "add" (lookup panel "compareMenu"))
    (apply addGraphMenuAux gname graph panel)  ;; in graphMenu.lsp
  )
)

(define menuBarFunBaseX (gname graph panel) 
  (let ((exportMenu (lookup panel "exportMenu"))
        (menuItem (object ("javax.swing.JMenuItem"
                  "Export graph..." java.awt.event.KeyEvent.VK_G)))
        (toolkit  (sinvoke "java.awt.Toolkit" "getDefaultToolkit"))
        (keystrokeG (sinvoke "javax.swing.KeyStroke" "getKeyStroke"
                             java.awt.event.KeyEvent.VK_G 
                             (invoke toolkit "getMenuShortcutKeyMask") ))
        (clac
          (lambda (self event) 
            (let ((frame (sinvoke "g2d.pla.PLAUtils" "getTabFrame" panel))
                  (chooser (object ("g2d.swing.IOPFileChooser" 
                                    g2d.tabwin.TabPreferences.FC_RAW_TEXT_AREA 
                                    g2d.tabwin.TabPreferences.FC_RAW_TEXT_FORMAT 
                                    g2d.tabwin.TabPreferences.FC_RAW_TEXT_FILE)))
                  (lspFilter (object ("g2d.swing.FileFilter" 
                                      "JLambda *.lsp" "lsp")))
                  (pnFilter (object ("g2d.swing.FileFilter" 
                                     "Petri net *.pn" "pn")))
                  (sbmlFilter (object ("g2d.swing.FileFilter" 
                                       "Systems Biology Markup Language *.sbml" "sbml")))
                  )
              (seq
               (invoke chooser "setDialogTitle" "Export Graph To File")
               (invoke chooser "setAcceptAllFileFilterUsed" (boolean false))
               (invoke chooser "setMultiSelectionEnabled" (boolean false))
               (invoke chooser "addChoosableFileFilter" pnFilter)
               (invoke chooser "addChoosableFileFilter" sbmlFilter)
               ;last filter set is the default
               (invoke chooser "addChoosableFileFilter" lspFilter)
               ;this will do the preferences magic
               (invoke chooser "situate")
               (if (= (invoke chooser "showDialog" frame "Export") 
                       g2d.swing.IOPFileChooser.APPROVE_OPTION)
                 (let ((selectedFile (invoke chooser "getSelectedFile"))
                       (fileName (invoke selectedFile "getCanonicalPath") )
                       )
                  (seq
                  (sinvoke "g2d.util.ActorMsg" "send" 
                      "maude" gname (concat "exportGraph" " " 
                                " " 
                         (apply fileNameExt fileName))  )
                   )) ; seq let
             ) ;if
             ) ;seq
           )) ;lambda
         ) ;clac
        (cla (object ("g2d.closure.ClosureActionListener"  clac )))
        )
;; (exportGraph graph2 graphics2d foo sbml)
    (seq
     (invoke menuItem "addActionListener" cla)
     (invoke menuItem "setAccelerator" keystrokeG)
     (invoke exportMenu "add" menuItem )
    )
   )
)


 (define fileNameExt (str)
  (let ((ix (invoke str "lastIndexOf" "."))
        (base  (if (< ix (int 0))
                str
                (invoke str "substring" (int 0 ) ix )) )
        (ext  (if (< ix (int 0))
                "lsp"
                (invoke str "substring" (+ ix (int 1)))) )
       )
    (concat base " " ext)
   )
 )

(define toolBarFunBase (toolbar gname graph panel pgraph) 
  (seq
;; incontext button if pgraph non null
     (if (not (= pgraph (object null)))
       (seq
         (invoke toolbar "prepend" 
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
         (invoke toolbar "prepend" (invoke panel "createLayoutButton" pgraph))
      ))
;; add 2kb button
     (invoke toolbar "prepend" 
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
;;     (apply addTreeMgrButton toolbar)
     (invoke toolbar "prepend" 
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
     (invoke toolbar "prepend" 
        (object ("g2d.toolbar.ToolButton"
          (object ("g2d.closure.ClosureAbstractAction"
                   "ToKB" "Save underlying net as a KB" 
              (lambda (self event)
                (let ((frame (sinvoke "g2d.pla.PLAUtils" "getTabFrame" panel))
                      (ukbname (apply askUser  ;; in kbmanager.lsp
                                      frame "AskUser" "Type in a KB name")))
                  (sinvoke "g2d.util.ActorMsg" "send" 
                           "maude" gname (concat "net2KB" " " ukbname)))))
                  ))))
     )
)


(invoke java.lang.System.err "println"  "showGraph.lsp loaded")

)

;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/showGraphFuns.lsp ;;;;;;;;;;
(seq  

(define mtGraphAlert ()
   (seq
    (apply closeProgressd)
   (apply displayMessage "Alert" "Empty Graph")
))   
   
(define closeProgressd ()
  (let ((kbm (fetch "KBManager"))
        (pd (if (instanceof kbm "g2d.glyph.Attributable")
               (getAttr  kbm "progressd")
               (object null)
        )) )
    (if (instanceof pd "javax.swing.JDialog")
         (invoke pd "setVisible" (boolean false))) )
)


(define mkAction (label tip closure)
    (object ("g2d.closure.ClosureAbstractAction"
             label
				 (object null) ; icon
				 tip
             (object null) ; accelerator
				 (object null) ; mnemonic
				 closure     ; action closure
) ) )

(define pnetColorKey ()
  (let (
	     (colorkey (object ("g2d.swing.IOPColorKey")))
	     (colors (array java.awt.Color 
             initFillColor 
             noneFillColor
			    ruleFillColor
			    goalFillColor 
			    avoidFillColor 
			    cxtFillColor 
			    ))
	     (keys (array java.lang.String 
			  "Initial occurrence" 
			  "Occurrence no status" 
			  "Rule no status"
			  "Goal status"
			  "Avoid/hide status"
			  "Context node"
			  ))
			)
	 (seq 
	  (invoke colorkey "add" colors keys)
     colorkey
    )
  )
)

(define toolBarFunPnet (toolbar gname graph panel pgraph)
  (seq 
     (apply toolBarFunBase toolbar gname graph panel pgraph)
  ; prepend buttons and things in tool bar
     (invoke toolbar "add" (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
     (invoke toolbar "add" (apply pnetColorKey))
    (apply addHideEdgesButton toolbar gname)
    (invoke toolbar "prepend" 
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
     (invoke toolbar "prepend" 
        (object ("g2d.toolbar.ToolButton"
          (apply mkAction "FindPath" "find a path to goals" 
             (lambda (self event) (apply pathRequest graph))) ) ) )
     (invoke toolbar "prepend" 
        (object ("g2d.toolbar.ToolButton"
          (apply mkAction "Subnet" "display relevant subnet" 
             (lambda (self event) (apply subnetRequest graph))) ) ) )
     (invoke toolbar "prepend" 
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
   ; explore dropdown button
     (apply addPnetExploreButton toolbar gname)
  )
)


(define mkPnetExploreClosure (gname mode)
   (lambda (self event)
             (sinvoke "g2d.util.ActorMsg" "send" 
                      "maude" gname (concat "exploreInit " mode))) 
)


(define addPnetExploreButton (toolbar gname)
  (let ((button (object ("g2d.swing.IOPDropdownButton" "Explore")))
        (occsC (apply mkPnetExploreClosure gname "occ"))
        (rulesC (apply mkPnetExploreClosure gname  "rule"))
        (ht g2d.toolbar.ToolBar.TOOL_BTN_HEIGHT)
   )
 (seq
   (invoke button "addMenuItem" "Occs" occsC)
   (invoke button "addMenuItem" "Rules" rulesC)
   (invoke button "setHeight" ht)
   (invoke toolbar "prepend"  button )
 ))
) ; addPnetExploreButton

(define mkHideEdgesClosure (gname cb hb hstate)
   (lambda (self event)
     (let ((dot? (invoke cb "isSelected"))
           (state (lookup hstate "booleanValue"))
           )
       (if state
         (seq
         ; unhiding hidden edges
           (invoke hb "setText" "HideEdges")
           (update hstate "booleanValue" (boolean false))
           (invoke cb "setEnabled" (boolean true))
           (apply unHideEdges gname dot?)
          )
         (seq
         ; hiding edges
           (invoke hb "setText" "UnhideEdges")
           (update hstate "booleanValue" (boolean true))
           (invoke cb "setEnabled" (boolean false))
           (apply hideEdges gname dot?)
          )               
        ) ) ; if let
     )
)
(define addHideEdgesButton (toolbar gname)
  (let ((cb (object ("g2d.toolbar.ToolCheckBox" "Redraw?")))
        (hb (object ("g2d.toolbar.ToolButton" "HideEdges")))
        (hideTip  (concat "Hides redundant edges." 
                          "\nRemoves and redraws if box checked."
                          "\nMakes them invisible otherwise."))
        (hstate  (object ("g2d.util.Variable") ))
        (hideClosure  (apply mkHideEdgesClosure gname cb hb hstate))
        )
   (seq
     (invoke toolbar "prepend"
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
     (invoke toolbar "prepend" cb)
     (invoke toolbar "prepend" hb)
     (update hstate "booleanValue" (boolean false))
     (invoke hb "setAction" 
        (apply mkAction "HideEdges" hideTip hideClosure))
     hb
   )  )    
)
; (invoke cb "setEnabled" (boolean false))

(define cnetColorKey ()
  (let (
	     (colorkey (object ("g2d.swing.IOPColorKey")))
	     (colors (array java.awt.Color 
             initFillColor
			    (object ("java.awt.Color" (int 0) (int 255) (int 255)))
			    java.awt.Color.pink
			    cxtFillColor 
			    ))
	     (keys (array java.lang.String 
			  "Requesting graph"
			  "CompareTo graph"
			  "Both graphs"
			  "context"
			  ))
			)
	 (seq 
	  (invoke colorkey "add" colors keys)
     colorkey
    )
  )
)



(define toolBarFunCnet (toolbar gname graph panel pgraph)
  (seq 
     (apply toolBarFunBase toolbar gname graph panel pgraph)
  ; prepend buttons and things in tool bar
     (invoke toolbar "add" (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
     (invoke toolbar "add" (apply cnetColorKey))
     (apply addHideEdgesButton toolbar gname)

))

(define xnetColorKey ()
  (let (
	     (colorkey (object ("g2d.swing.IOPColorKey")))
	     (colors (array java.awt.Color 
             java.awt.Color.lightGray 
             initFillColor
			    java.awt.Color.green
			    java.awt.Color.cyan
			    java.awt.Color.yellow  
			    cxtFillColor 
			    ))
	     (keys (array java.lang.String 
			  "Occ node seen" 
			  "Occ node up OK"
			  "Occ node down OK"
			  "Occ node up and down OK"
			  "selected"
			  "context"
			  ))
			)
	 (seq 
	  (invoke colorkey "add" colors keys)
     colorkey
    )
  )
)

(define mkTTF ()
 (let ((tf (object ("javax.swing.JFormattedTextField" 
                        (object ("java.lang.Integer" (int 1))) )) ))
  (seq
    (invoke tf "setMaximumSize" 
                 (object ("java.awt.Dimension" (int 32) (int 32))))
    tf) ))



(define toolBarFunXnet (toolbar gname graph panel pgraph)
  (let ((cb (object ("g2d.toolbar.ToolCheckBox" "New Tab")))
;        (tf (object ("g2d.toolbar.ToolTextField")))
        (tf (apply mkTTF))
        (gname (invoke graph "getUID"))
        (dnClosure 
           (lambda (self event)
             (let ((new (invoke cb "isSelected"))
                   (steps (invoke (invoke tf "getValue") "intValue"))
                  )
            (seq (sinvoke "g2d.util.ActorMsg" "send" "maude" gname 
                      (concat "explore " new " dn " steps))
                ;  (invoke cb "setSelected" (boolean false))
                ) ))) ; dnClosure
        (downTip "Explore down given steps")
        (upClosure 
           (lambda (self event)
             (let ((new (invoke cb "isSelected"))
                   (steps (invoke (invoke tf "getValue") "intValue")))
             (sinvoke "g2d.util.ActorMsg" "send" "maude" gname 
                      (concat "explore " new " up " steps)))
            )) ; upClosure
        (upTip "Explore up given steps")
       ) ; letbindings
 ; prepend buttons and things in tool bar
    (seq
     (if (try explorerCheckBoxDefault (catch x (boolean false)))
        (invoke cb "setSelected" (boolean true)))
     (apply toolBarFunBase toolbar gname graph panel pgraph)
     (invoke toolbar "add" (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
     (invoke toolbar "add" (apply xnetColorKey))
     (invoke toolbar "prepend"
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeLargeSep"))
     ; check box for new or reuse tabs
     (invoke cb "setToolTipText"
                "Open graph resulting from next explore operation in new tab")
     (invoke toolbar "prepend" cb)
     
     (invoke toolbar "prepend" 
             (sinvoke "g2d.toolbar.SeparatorFactory" "makeSmallSep"))
     ; text field for number of steps
     (invoke tf "setToolTipText" 
                "Specify number of steps to be taken when exploring up or down")
     (invoke toolbar "prepend" tf)
     (invoke toolbar "prepend" 
                     (sinvoke "g2d.toolbar.SeparatorFactory" "makeSmallSep"))
     ; up and down buttons
      (invoke toolbar "prepend"
        (object ("g2d.toolbar.ToolButton" 
                 (apply mkAction "Down" downTip dnClosure))))
      (invoke toolbar "prepend"
        (object ("g2d.toolbar.ToolButton" (apply mkAction "Up" upTip upClosure))))
     (invoke toolbar "prepend" 
        (object ("g2d.toolbar.ToolButton"
          (apply mkAction "Explore Selected" "explore with xselect attributes" 
             (lambda (self event) (apply exploreSelectedRequest graph gname cb))) 
          ) ) ) 
   ; explore dropdown button
     (apply addExploreButton toolbar gname cb)
   ) ;seq
 ) ; let
) ; toolBarFunXnet


(define addExploreButton (toolbar gname cb)
  (let ((button (object ("g2d.swing.IOPDropdownButton" "Explore")))
        (fpsC (apply mkExploreClosure gname cb "fps"))
        (addRC (apply mkExploreClosure gname cb "addR"))
        (hideRC (apply mkExploreClosure gname cb "hideR"))
        (unhideRC (apply mkExploreClosure gname cb "unhideR"))
        (ht g2d.toolbar.ToolBar.TOOL_BTN_HEIGHT)
   )
 (seq
   (invoke button "addMenuItem" "occs" fpsC)
   (invoke button "addMenuItem" "add Rules" addRC)
   (invoke button "addMenuItem" "hide Rules" hideRC)
   (invoke button "addMenuItem" "unhide Rules" unhideRC)
   (invoke button "setHeight" ht)
   (invoke toolbar "add"  button (int 0))
 ))
) ; addExploreButton


(define mkExploreClosure (gname cb cmd)
     (lambda (self event)
        (let ((new (invoke cb "isSelected")))
           (seq (sinvoke "g2d.util.ActorMsg" "send" "maude" gname 
                      (concat "explore " new " " cmd))
              ;  (invoke cb "setSelected" (boolean false))
            )
         )
     ) ; exploreClosure
)


(define exploreSelectedRequest (graph gname cb)
   (let ((new (invoke cb "isSelected")))
     (seq (sinvoke "g2d.util.ActorMsg" "send" "maude" gname 
               (concat "explore " new " " "selected" " "
                       (apply mkXStatusString graph) ))
         ; (invoke cb "setSelected" (boolean false))
     ))
 ) 

(define mkXStatusString (graph)
  (let ((nodes (invoke graph "getNodesInArray")))
    (apply nodes2xselect nodes (int 0) (lookup nodes "length") "")
  ) 
)

(define nodes2xselect (nodes cur len str)
  (if (>= cur len)
   str
   (let ((node (aget nodes cur))
         (chatty (getAttr node "chattylabel" ""))
         (xselect (getAttr node "xselect" "none")))
    (apply nodes2xselect nodes (+ cur (int 1)) len 
         (if (or (= xselect "none") (= chatty ""))
          str 
          (concat str " " chatty " " xselect) 
      ) ) ) ; if app let 
  )  
) ; nodes2xselect

(invoke java.lang.System.err "println"  "showGraphFuns.lsp loaded")

)
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/labels.lsp ;;;;;;;;;;
(seq

(define refreshThumbnail (panel graph)
   (let ((navPanel (invoke panel "getNavPanel"))
         (image (invoke graph "getBufferedImage"))
        )
       (invoke navPanel "setImage" image)
   )
)

(define setNodeLabels (gname type tag)
  (let ((graph (fetch gname))
        (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
        (nodes (invoke graph "getNodesInArray")))
    (seq
      (for node nodes 
         (if (= type (getAttr node "type"))
           (seq
            (invoke node "setBaseDimension" (double 10) (double 10))
            (invoke node "setLabel" (getAttr node tag ""))
            ))  )
      (invoke graph "doLayout")
      (apply refreshThumbnail panel graph)
      (invoke panel "repaint")
   )) ; seq let
)

(define suppressRuleLabels (gname)
  (let ((graph (fetch gname))
        (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
        (nodes (invoke graph "getNodesInArray")))
    (seq
      (for node nodes 
         (if (= "rule" (getAttr node "type"))
          (seq
           (invoke node "setLabel" "")
           (invoke node "setBaseDimension" (double 10) (double 10))
          )))
      (invoke graph "doLayout")
      (invoke panel "repaint")
   )) ; seq let
)

(invoke java.lang.System.err "println"  "labels.lsp loaded")


)
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/graphMenu.lsp ;;;;;;;;;;
(seq

(define addGraphMenu (gname)
  (let ((graph (fetch gname))
        (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
        (graphMenu  (apply mkGraphMenu gname graph panel))
       )
   (seq
     (invoke (lookup panel "menuBar") "add" graphMenu)
     (invoke panel "validate")
  )
))

(define addGraphMenuAux (gname graph panel)
  (invoke (lookup panel "menuBar") "add" (apply mkGraphMenu gname graph panel))
)

;(g2dexe graphics2d (apply setNodeLabels "graph2" "occ" "label"))
;(g2dexe graphics2d (apply setNodeLabels "graph2" "occ" "chattylabel"))
;(g2dexe graphics2d (apply setNodeLabels "graph2" "rule" "label"))
;(g2dexe graphics2d (apply setNodeLabels "graph2" "rule" "chattylabel"))
;(g2dexe graphics2d (apply suppressRuleLabels "graph2"))
;(maude graph displayUnused)

(define mkOccLabelItem (gname)
  (let ((occLabelItem (object ("javax.swing.JMenuItem"                 
                                  "Short Occ Labels" )))
        (occLabelC
          (lambda (self event) (apply setNodeLabels gname "occ" "label")
           ) ;lambda
         ) ; suppressC
        (occLabelCA
           (object ("g2d.closure.ClosureActionListener"  occLabelC )))
       )
     (seq
       (invoke occLabelItem "addActionListener" occLabelCA)
       occLabelItem
    )
))

(define mkOccChattyLabelItem (gname)
  (let ((occChattyLabelItem (object ("javax.swing.JMenuItem"                 
                                  "Chatty Occ Labels" )))
        (occChattyLabelC
          (lambda (self event) (apply setNodeLabels gname "occ" "chattylabel")
           ) ;lambda
         ) ; suppressC
        (occChattyLabelCA
           (object ("g2d.closure.ClosureActionListener"  occChattyLabelC )))
       )
     (seq
       (invoke occChattyLabelItem "addActionListener" occChattyLabelCA)
       occChattyLabelItem
    )
))

(define mkRuleLabelItem (gname)
  (let ((ruleLabelItem (object ("javax.swing.JMenuItem"                 
                                  "Short Rule Labels" )))
        (ruleLabelC
          (lambda (self event) (apply setNodeLabels gname "rule" "label")
           ) ;lambda
         ) ; suppressC
        (ruleLabelCA
           (object ("g2d.closure.ClosureActionListener"  ruleLabelC )))
       )
     (seq
       (invoke ruleLabelItem "addActionListener" ruleLabelCA)
       ruleLabelItem
    )
))
(define mkRuleChattyLabelItem (gname)
  (let ((ruleChattyLabelItem (object ("javax.swing.JMenuItem"                 
                                  "Chatty Rule Labels" )))
        (ruleChattyLabelC
          (lambda (self event) (apply setNodeLabels gname "rule" "chattylabel")
           ) ;lambda
         ) ; suppressC
        (ruleChattyLabelCA
           (object ("g2d.closure.ClosureActionListener"  ruleChattyLabelC )))
       )
     (seq
       (invoke ruleChattyLabelItem "addActionListener" ruleChattyLabelCA)
       ruleChattyLabelItem
    )
))


(define mkSuppressRuleLabelItem (gname)
  (let ((suppressRuleLabelItem (object ("javax.swing.JMenuItem"                 
                                  "Suppress Rule Labels" )))
        (suppressRuleLabelC
          (lambda (self event) (apply suppressRuleLabels gname)
           ) ;lambda
         ) ; suppressC
        (suppressRuleLabelCA
           (object ("g2d.closure.ClosureActionListener"  suppressRuleLabelC )))
       )
     (seq
       (invoke suppressRuleLabelItem "addActionListener" suppressRuleLabelCA)
       suppressRuleLabelItem
    )
))


(define mkShowUnusedItem (gname)
  (let ((showUnusedItem (object ("javax.swing.JMenuItem"                 
                                  "Show Unused" )))
        (showUnusedC
          (lambda (self event) 
            (sinvoke "g2d.util.ActorMsg" "send" "maude" gname "displayUnused")
           ) ;lambda
         ) ; suppressC
        (showUnusedCA
           (object ("g2d.closure.ClosureActionListener"  showUnusedC )))
       )
     (seq
       (invoke showUnusedItem "addActionListener" showUnusedCA)
       showUnusedItem
    )
))


(define mkShowGoalsAvoidsItem (gname)
  (let ((showGoalsAvoidsItem (object ("javax.swing.JMenuItem"                 
                                  "Show Goals & Avoids" )))
        (showGoalsAvoidsC
          (lambda (self event) 
            (apply showGoalsAvoids gname)
           ) ; lambda
         ) ; showGAC
        (showGoalsAvoidsCA
           (object ("g2d.closure.ClosureActionListener"  showGoalsAvoidsC )))
       )
     (seq
       (invoke showGoalsAvoidsItem "addActionListener" showGoalsAvoidsCA)
       showGoalsAvoidsItem
    )
))

(define showGoalsAvoids (gname)
  (let ((graph (fetch gname))
        (gastring (if (= gname (object null)) "" (getAttr graph "subtitle")))
  )
   (apply displayMessage2G gname "Goals&Avoids" gastring)
  )
)


(define mkKOItem (gname)
  (let ((koItem (object ("javax.swing.JMenuItem"                 
                                  "Display KnockOuts" )))
        (koC
          (lambda (self event) (apply displayKOs gname)
           ) ;lambda
         ) ; koC
        (koCA
           (object ("g2d.closure.ClosureActionListener"  koC )))
       )
     (seq
       (invoke koItem "addActionListener" koCA)
       koItem
    )
))

(define mkHistoryItem (gname label fun)
  (let ((dhItem (object ("javax.swing.JMenuItem" label)))
        (dhC
          (lambda (self event) 
              (sinvoke "g2d.util.ActorMsg" "send" "maude" gname 
                     (concat "printHistory " fun ))
           ) ;lambda
         ) ; dhC
        (dhCA
           (object ("g2d.closure.ClosureActionListener"  dhC )))
       )
     (seq
       (invoke dhItem "addActionListener" dhCA)
       dhItem
    )
))

(define mkResetAllItem (gname)
  (let ((resetAllItem (object ("javax.swing.JMenuItem"                 
                                  "Reset All Selections" 
                                  java.awt.event.KeyEvent.VK_R)))
        (toolkit  (sinvoke "java.awt.Toolkit" "getDefaultToolkit"))
        (keystrokeR (sinvoke "javax.swing.KeyStroke" "getKeyStroke"
                             java.awt.event.KeyEvent.VK_R 
                             (invoke toolkit "getMenuShortcutKeyMask") ))
                                  
        (raC
          (lambda (self event) 
            (let ((graph (fetch gname))
                  (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
                  )
              (seq 
               (invoke panel "resetAllSelections")
               )
              ))
          ) ; raC
        (raCA
         (object ("g2d.closure.ClosureActionListener"  raC )))
        )
    (seq
     (invoke resetAllItem "addActionListener" raCA)
     (invoke resetAllItem "setAccelerator" keystrokeR)
     resetAllItem
     )
    )
  )


;; the graph items should be relevant to graph type
(define mkGraphMenu (gname graph panel)
  (let ((graphMenu (lookup panel "graphMenu")))
    (seq
      (if (invoke panel "allowsSelections")
        (seq
          (invoke graphMenu "add" (apply mkShowUnusedItem gname))
          (invoke graphMenu "addSeparator" )
;;only subnet/path
          (invoke graphMenu "add" (apply mkShowGoalsAvoidsItem gname))
          (invoke graphMenu "addSeparator" )
;;only pnet 
          (invoke graphMenu "add" (apply mkKOItem gname))
          (invoke graphMenu "addSeparator" )
          (invoke graphMenu "add" (apply mkResetAllItem gname))
          (invoke graphMenu "addSeparator" )
          )
;; only xnets
        (seq 
          (invoke graphMenu "add" 
               (apply mkHistoryItem gname "Display History" "displayHistory"))
;          (invoke graphMenu "addSeparator" )        
          (invoke graphMenu "add" 
             (apply mkHistoryItem gname "Save History" "saveHistory"))
          (invoke graphMenu "addSeparator" )        
        )
      )
      (invoke graphMenu "add" (apply mkOccLabelItem gname))
      (invoke graphMenu "add" (apply mkOccChattyLabelItem gname))
      (invoke graphMenu "add" (apply mkRuleLabelItem gname))
      (invoke graphMenu "add" (apply mkRuleChattyLabelItem gname))
      (invoke graphMenu "add" (apply mkSuppressRuleLabelItem gname))
      (invoke graphMenu "addSeparator" )        
      (invoke graphMenu "add" (apply mkShowGraphInfoItem gname graph panel))
      graphMenu
    )
   )
)


(define mkShowGraphInfoItem (gname graph panel)
  (let ((menuItemItem (object ("javax.swing.JMenuItem"  "Graph Details" )))
        (menuItemC
          (lambda (self event) 
             (invoke (invoke panel "getGraphPanel") "displayContextMGraph")
            ) ;lambda
          ) ; suppressC
        (menuItemCA
         (object ("g2d.closure.ClosureActionListener"  menuItemC )))
        )
    (seq
     (invoke menuItemItem "addActionListener" menuItemCA)
     menuItemItem
     )
    ))


(invoke java.lang.System.err "println"  "graphMenu.lsp loaded")

)
;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/lola-str.lsp ;;;;;;;;;;
;; Lola net
;; PLACES p0, p1, p2, p3, p4, p5;

;; MARKING p0 : 1, p1 : 0, p4 : 1;

;; TRANSITION t64
;; CONSUME p80 : 1, p30 : 1, p68 : 1, p84 : 1, p1 : 1;
;; PRODUCE p80 : 1, p30 : 1, p68 : 1, p84 : 1, p81 : 1;

(seq

;  op appendLolaPlaces : NodeList StringBuffer -> * .
(define appendLolaPlaces (occNodes strb)
  (seq
    (for node occNodes
      (seq
        (invoke strb "append" "p")
        (invoke strb "append" (getAttr node "nid" ""))
        (invoke strb "append" ", ")
      ))
   ; delete trailing ", "
    (invoke strb "setLength" (- (invoke strb "length") (int 2))) 
  )
)

;  op appendLolaMarking : NodeList StringBuffer -> * .
(define appendLolaMarking (initNodes strb)
  (seq
    (for node initNodes
      (seq
        (invoke strb "append" "p")
        (invoke strb "append" (getAttr node "nid" ""))
        (invoke strb "append" " : 1")
        (invoke strb "append" ", ")
      ))
   ; delete trailing ", "
    (invoke strb "setLength" (- (invoke strb "length") (int 2))) 
  )
)

;  op appendLolaTrans      : NodeList StringBuffer -> * .
;  op mkLolaTrans1         : Node Stringbuffer -> * .
;  op mkLolaPrePost        : Nats -> String .
(define appendLolaTrans (rnodes strb)
  (for node rnodes
   (apply appendLolaTrans1 node strb)
  )
)

(define appendLolaTrans1 (node strb)
  (let ((nid (getAttr node "nid" ""))
        (preids (invoke (getAttr node "pre") "split" "\\s+"))
        (postids (invoke (getAttr node "post") "split" "\\s+"))
        )
    (seq
      (invoke strb "append" "\n")
      (invoke strb "append" "TRANSITION t")
      (invoke strb "append" nid)
      (invoke strb "append" "\n")
      (invoke strb "append" "CONSUME ")
      (apply appendLolaPrePost preids strb)
      (invoke strb "append" ";\n")
      (invoke strb "append" "PRODUCE ")
      (apply appendLolaPrePost postids strb)
      (invoke strb "append" ";\n")
    ) ; concat
  )
)

;; op appendLolaPrePost : NidList StringBuffer -> *
(define appendLolaPrePost (nids strb)
  (seq
    (for nid nids
      (seq
        (invoke strb "append" "p")
        (invoke strb "append" nid)
        (invoke strb "append" " : 1, ")
     ))
     ; delete trailing ", "
    (invoke strb "setLength" (- (invoke strb "length") (int 2))) 
  )
)

;  op mkLolaNetStr : NodeList NodeList NodeList  -> String .

(define mkLolaNetStr (occNodes ruleNodes initNodes)
  (let ((strb (object ("java.lang.StringBuffer"))))
    (seq 
      (invoke strb "append" "PLACE ")
      (apply appendLolaPlaces occNodes strb)
      (invoke strb "append" ";\n\nMARKING ")
      (apply appendLolaMarking initNodes strb)
      (invoke strb "append" ";\n")
      (apply appendLolaTrans ruleNodes strb)
      (invoke strb "toString")
  ))
)


;; FORMULA ( (p72 = 1) AND  (p73 = 1) )

;;  op mkLolaTaskString : NodeList -> String .
;; op appendLolaGoals : NodeList StringBuffer -> * .
  
(define mkLolaTaskStr  (goalNodes) 
  (let ((strb (object ("java.lang.StringBuffer"))))
    (seq 
      (invoke strb "append" "FORMULA ( ")
      (apply appendLolaGoals goalNodes strb)
      (invoke strb "append" " )\n" )
      (invoke strb "toString")
    )
  )
)

(define appendLolaGoals (gnodes strb)
  (for node gnodes
    (seq
      (invoke strb "append" "( p")
      (invoke strb "append" (getAttr node "nid" "") )
      (invoke strb "append" " = 1 )")
    ))
)



) ; top seq

;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/ko.lsp ;;;;;;;;;;
;; Lola net
;; PLACES p0, p1, p2, p3, p4, p5;

;; MARKING p0 : 1, p1 : 0, p4 : 1;

;; TRANSITION t64
;; CONSUME p80 : 1, p30 : 1, p68 : 1, p84 : 1, p1 : 1;
;; PRODUCE p80 : 1, p30 : 1, p68 : 1, p84 : 1, p81 : 1;
; requires lola-str.lsp and pla.lsp (doLolaRequest)

(seq
(define KO-DEBUG (boolean false))
;; candidates are initial occ nodes that appear in the premiss of a rule
;; in pathstr
(define lolaPath2Candidates (pathstr graph)
  (let ((patharr (invoke (aget (invoke pathstr "split" "\\s+" (int 2)) 
                               (int 1)) ;; the cdr of the token string
                         "split" "\\s+"))
        (list (object ("java.util.LinkedList")))
       )
  (seq
    (for elt patharr
      (let ((nid (invoke elt "substring" (int 1) (invoke elt "length"))))
        (apply trans2cand graph nid list)))
    list))
)

;; adds init pre nodes of node to list
(define trans2cand (graph nid list)
  (let ((node (invoke graph "getNode" nid) )
        (pre (invoke (getAttr node "pre" "") "split" "\\s+"))
        )
      (for pnid pre
        (let ((pnode (invoke graph "getNode" pnid)))
          (if (= (getAttr pnode "init" "") "true") 
            (if (not (invoke list "contains" pnode))                    
              (invoke list "add" pnode)
          )))) ; if if let for
    )
)

;; returns true if lolas result code is not 0, means no path ie a ko
;; need to extract lolaRes from lolaRequest 
;; 
(define LolaCheckKO (occNodes ruleNodes initNodes goalNodes occ)
  (let ((netStr (apply mkLolaNetStr occNodes ruleNodes 
                                   (apply ldelete initNodes occ)))
        (taskStr (apply mkLolaTaskStr goalNodes))
        (res (apply doLolaReq netStr taskStr "0"))
        )
   (seq         
    (if KO-DEBUG
      (invoke java.lang.System.err "println" 
       (concat "LolaCheckKO\n" occ "\n" (aget res (int 0)))))
     (not  (= (aget res (int 0)) "0"))
   )
  )
)

;; candidates is a list of nodes
(define searchKOs (occNodes ruleNodes initNodes goalNodes candidates)
  (let ((kos (object ("java.util.LinkedList")))) 
    (seq
      (for occ candidates 
        (if (apply LolaCheckKO occNodes ruleNodes initNodes goalNodes occ)
         (invoke kos "add" occ) ))
      (if KO-DEBUG
        (invoke java.lang.System.err "println" (concat "searchKOs\n" kos)))
     kos)
  )
)

; true if some nid in arr is the id of a node in ndl
(define findArrNdl (ndl graph arr len cur)
  (if (>= cur len) 
   (boolean false)
   (if (invoke ndl "contains" (invoke graph "getNode" (aget arr cur)))
    (boolean true)
    (apply findArrNdl ndl graph arr len (+ cur (int 1)))
   ))
)

; true if (the nid of) no node in avoidNodes appears in the pre or post
; of rnode
;                  rnode nodelist 
(define notHidden (rnode avoidNodes graph)
  (let ((pre (invoke (getAttr rnode "pre" "") "split" "\\s+"))
        (prelen  (lookup pre "length"))
        (post (invoke (getAttr rnode "post" "") "split" "\\s+"))
        (postlen  (lookup post "length"))
        )
    (if (apply findArrNdl avoidNodes graph pre prelen (int 0))
     (boolean false)
     (not (apply findArrNdl avoidNodes graph post postlen (int 0)))
     )    
  )
)

;;                     occs    rules    init
;;  op mkLolaNetStr : NodeList NodeList NodeList  -> String .
;;                          goals
;;  op mkLolaTaskString : NodeList -> String .

;; assume graph has one or more goals
;; may have unprocesses occ or rule avoids
(define displayKOs (gname)
  (let ((graph (fetch gname))
        (nodes (invoke graph "getNodesInArray"))
        (occNodes (apply select nodes 
            (lambda (node) (if (= (getAttr node "type" "") "occ")
                            (not (= (getAttr node "status" "") "avoid"))
                            (boolean false) ))))
; (docc (invoke java.lang.System.err "println" 
;                                  (concat "displayKOs occNodes\n" occNodes)))
        (avoidNodes (apply select nodes 
            (lambda (node) (if (= (getAttr node "type" "") "occ")
                            (= (getAttr node "status" "") "avoid")
                            (boolean false) ))))
; (davoid (invoke java.lang.System.err "println" 
;                              (concat "displayKOs avoidNodes\n" avoidNodes)))
        (initNodes (apply select occNodes
                        (lambda (node) (= (getAttr node "init" "") "true"))))
; (dinit (invoke java.lang.System.err "println" 
;                                (concat "displayKOs initNodes\n" initNodes)))
        (goalNodes (apply select occNodes
                        (lambda (node) (= (getAttr node "status" "") "goal"))))
; (dgoal (invoke java.lang.System.err "println" 
;                                 (concat "displayKOs goalNodes\n" goalNodes)))
        (ruleNodes (apply select nodes 
            (lambda (node) (if (= (getAttr node "type" "") "rule")
                             (if  (= (getAttr node "status") "avoid")
                               (boolean false)
                               (apply notHidden node avoidNodes graph))
                             (boolean false) ))))
; (drule (invoke java.lang.System.err "println" 
;                               (concat "displayKOs ruleNodes\n" ruleNodes)))
        (netStr (apply mkLolaNetStr occNodes ruleNodes initNodes))
        (taskStr (apply mkLolaTaskStr goalNodes))
      )
   (if (= (invoke goalNodes "size") (int 0))
     (apply displayMessage "KOs" "\nNo Goals\n")
     (let ((res (apply doLolaReq netStr taskStr "0"))
        )
   ; res is an array [code, path] where path begins with PATH followed by tids
       (if (not (= (aget res (int 0)) "0"))
        (apply displayMessage "KOs" "\nNo Path to Goals\n")
    ; candidates is a list of initial nodes that appear in a rule premis
        (let (
              (d4a (if KO-DEBUG
                      (invoke java.lang.System.err "println" 
                        (concat "displayKOs lolapath\n" (aget res (int 1)))))
                )
              (candidates (apply lolaPath2Candidates (aget res (int 1)) graph)) 
              (d4 (if KO-DEBUG
                    (invoke java.lang.System.err "println" 
                       (concat "displayKOs candidates\n" candidates)))
                )
              (kos (apply searchKOs occNodes ruleNodes initNodes goalNodes
                          candidates))
             )
          (apply displayMessage2G
              gname
             "KOs"
              (apply printCol kos
                 (lambda (node strb) 
                     (invoke strb "append"  (concat node "" "\n"))))
           )    
      ) )) ) ; let if let if
   ) ; outer let
)

(invoke java.lang.System.err "println"  "ko.lsp loaded")

) ;file seq 

;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/hideEdges.lsp ;;;;;;;;;;
;         (invoke edge "setStyle" g2d.graph.IOPEdge.INVIS)
;         (invoke edge "setStyle" g2d.graph.IOPEdge.DASHED))
(seq
;; "occsOut" maps occ node ids to list of outgoing edges
;;  similarly for "rulesOut"  where bidir edges are not considered outgoing
(define initEdgeTraversal (graph)
  (let ((edges (invoke graph "getEdgesInArray"))
        (nodes (invoke graph "getNodesInArray"))
        (onodes (apply select nodes 
                  (lambda (node) (= (getAttr node "type") "occ"))))
        (rnodes (apply select nodes 
                  (lambda (node) (= (getAttr node "type") "rule"))))
        (occsOut (object ("java.util.HashMap")))                  
        (rulesOut (object ("java.util.HashMap")))                  
                    
  )
  (seq
    (for onode onodes 
      (invoke occsOut "put" (getAttr onode "nid") 
              (apply select edges 
                (lambda (edge) (= (invoke edge "getSource") onode)) )))     
    (for rnode rnodes 
      (invoke rulesOut "put" (getAttr rnode "nid") 
              (apply select edges 
                (lambda (edge)  (= (invoke edge "getSource") rnode)) ) 
      )) ;; invoke for     
     (setAttr graph "occsOut" occsOut)
     (setAttr graph "rulesOut" rulesOut)
    ) ; seq
  ) ; let
) ; define



;; returns a list of rules reachable from rule 
;; by following out edges (not bidir edges)
(define eReach (occsOut rulesOut rule)
   (apply eReach1 occsOut rulesOut  
         (object ("java.util.LinkedList" ))
         rule 
         (object ("java.util.LinkedList"))
   )     
)

(define eReach1 (occsOut rulesOut done rule new)
  (let ((olist (apply map 
                 (invoke rulesOut "get" (getAttr rule "nid"))
                 (lambda (edge accum)
                    (invoke accum "add" (invoke edge "getSink") ) )
                 (object ("java.util.LinkedList"))   ) ; apply
         ) ; olist -- the rule output occs
       )
  (seq
    (invoke done "add" rule)
    (for occ olist
      (for edge (invoke occsOut "get" (getAttr occ "nid"))
        (let ((sink (invoke edge "getSink")))
          (if (not (or (invoke done "contains" sink)
                      (invoke new "contains" sink)))
            (invoke new "add" sink))
         ) ; let          
      ) ) ; for for
    (if (= (invoke new "size" ) (int 0))
      done
      (apply eReach1 occsOut rulesOut done (invoke new "removeFirst") new)    
    )
  ) ) ; seq let
)

(define addRedundantEdges (occsOut rulesOut cand tohide)
;; first associate each edge with reachable rules
;; rch is a list of rule lists, one for each edge in cand
;; then use that to find the non-minimal edges and add them to tohide
  (let ((rch (apply findReach occsOut rulesOut cand)))
;; now partition cand into min and non-min (hidable)
  (apply findHides cand rch tohide)
 )
)

(define findHides (cand rch tohide)
 (let ((len (invoke rch "size"))
       (keep (object ("java.util.LinkedList")))
       (hide? (object ("java.util.LinkedList")))
      )
   (seq
;; put index of edges whose target not reachable from another edge in keep
;; put index of other edges in hide?
      (apply targetSplit rch keep hide? len (int 0))
;; for h in hide? if rch[h][0] in rch/keep add cand[h] to tohide
      (apply checkHide cand rch keep hide? tohide len (int 0))
    )
 )
)

;; rch a list of non-empty rule lists, keep/hide? lists of indices into rch
;; len the size of rch and cur the current rlist
;; modifies keep and hide? returns true
(define targetSplit (rch keep hide? len cur)
  (if (>= cur len)
    (boolean true)
    (let ((rls (invoke rch "get" cur))
          (rl (invoke rls "get" (int 0)))  
         )
     (seq         
       (if (apply findRule rch rl len cur (int 0))
         (invoke hide? "add" (object ("java.lang.Integer" cur)))
         (invoke keep "add" (object ("java.lang.Integer" cur)))
       )  
       (apply targetSplit rch keep hide? len (+ cur (int 1)))
     ) ; seq
  ))  ; let if
)

(define findRule (rch rl len omit cur)
  (if (>= cur len)
    (boolean false)
    (if (= cur omit)
      (apply findRule  rch rl len omit (+ cur (int 1)))
      (if (invoke (invoke rch "get" cur) "contains" rl)
        (boolean true)
        (apply findRule  rch rl len omit (+ cur (int 1)))
      ))) ; if x 3
)

(define findList (krch rl len  cur)
  (if (>= cur len)
    (boolean false)
    (if (invoke (invoke krch "get" cur) "contains" rl)
        (boolean true)
        (apply findList krch rl len (+ cur (int 1)))
      )) ; if x 2
)

;; for box(h) in hide? if rch[h][0] in rch/keep add cand[h] to tohide
(define checkHide (cand rch keep hide? tohide len cur)
  (let ((krch 
          (apply map keep
             (lambda (ix accum) 
               (invoke accum "add" (invoke rch "get" (invoke ix "intValue"))))
             (object ("java.util.LinkedList"))))    ; rch/keep
        (klen (invoke krch "size"))
       )
     (for ixb hide? 
       (let ((ix (invoke ixb "intValue")))
         (if (apply findList krch 
                   (invoke (invoke rch "get" ix) "get" (int 0))
                   klen 
                   (int 0))
           (invoke tohide "add" (invoke cand "get" ix))                   
        )) ; if let
     ) ; for
  )
)

(define findReach (occsOut rulesOut cand)
;; returns a list of rule lists, one for each edge in cand
  (apply map cand 
         (lambda (edge accum) 
           (invoke accum "add" 
                (apply eReach occsOut rulesOut (invoke edge "getSink")) ) )
         (object ("java.util.LinkedList"))  
   )
)

(define findCandidates (occsOut onodes)
  (apply map onodes 
        (lambda (onode accum)
          (let ((edges (invoke occsOut "get" (getAttr onode "nid")))
                (bedges (apply select edges 
                          (lambda (edge)(= (getAttr edge "bidir") "true")))) 
              )
           (if (>= (invoke bedges "size") (int 2))
             (seq
               ; (invoke bedges "addFirst" onode) ; onode is src of each 
               (invoke accum "add" bedges)
             )
            ) ;if
          )) ; let lambda   
        (object ("java.util.LinkedList"))
  )
) ; candidates

;; returns list of edges to hide and caches them under "hiddenEdges"
;; a candidate a list of double ended edges with the same source, 
;; potentially some are hideable.
(define setHiddenEdges (graph)
  (let ((nodes (invoke graph "getNodesInArray"))
        (onodes (apply select nodes 
                       (lambda (node) (= (getAttr node "type") "occ"))))
        (occsOut  (getAttr graph "occsOut"))
        (rulesOut  (getAttr graph "rulesOut") )
      ;; [[e1 .. ek]*]
      (candidates (apply findCandidates occsOut onodes))
      (tohide 
         (apply map 
           candidates 
           (lambda (cand accum) 
             (apply addRedundantEdges occsOut rulesOut cand accum))
          (object ("java.util.LinkedList")))     )
    ) ; let list
   (seq
     (setAttr graph "hiddenEdges" tohide)
     tohide
   ) ;seq
  ) ; let
) ; find

(define getHiddenEdges (graph)
  (let ((edges (getAttr graph "hiddenEdges")))
    (if (instanceof edges "java.util.LinkedList")
      edges
      (object ("java.util.LinkedList"))
    ))
)

; (invoke edge "setStyle" g2d.graph.IOPEdge.INVIS)
; (invoke edge "setStyle" g2d.graph.IOPEdge.DASHED))
(define mkEdgesInvis (graph)
  (let ((panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph)))
    (seq 
     (for e (apply getHiddenEdges graph)
          (invoke e "setStyle" g2d.graph.IOPEdge.INVIS))
     (invoke panel "repaint")  
     )
    )
)

(define mkEdgesDashed (graph)
  (let ((panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph)))
    (seq 
     (for e (apply getHiddenEdges graph)
          (invoke e "setStyle" g2d.graph.IOPEdge.DASHED))
     (invoke panel "repaint")  
     )
    )
)

;; assume "isDotLayout" see defineGraph.lsp delXEdge
(define removeEdges (graph)
  (seq 
    (for e (apply getHiddenEdges graph) (invoke graph "rmEdge" e))
    (apply redisplay graph)
   )
)

(define restoreEdges (graph)
  (seq 
    (for e (apply getHiddenEdges graph) (invoke graph "addEdge" e))
    (apply redisplay graph)
   )
)

;;; TOP LEVEL  only for pnets, maybe comparison, not editable nets
;;; unhideEdges only available if hidden and hidding remembers the mode
;;;
;; if ?dot remove the edges and redisplay, ow just make them invisible
(define hideEdges (gname ?dot)
  (let ((graph (fetch gname)))
   (if (invoke graph "isDotLayout")  
    (seq
      ; only initialize if necessary
      (if (or (= (getAttr graph "occsOut" (object null)) (object null))
              (= (getAttr graph "rulesOut" (object null)) (object null))
           )
       (apply initEdgeTraversal graph) )
      ; used cached edgelist if available
      (if (= (getAttr graph "hiddenEdges" (object null)) (object null))
          (apply setHiddenEdges graph))
      (if ?dot (apply removeEdges graph) (apply mkEdgesInvis graph))
    )
;complain
   (apply displayMessage "hideEdges" "Hiding edges not allowed in Context")
  )) ; if let
)

;; if ?dot restore the removed edges and redisplay, ow just make them visible
(define unHideEdges (gname ?dot) 
  (let ((graph (fetch gname)))
    (if ?dot (apply restoreEdges graph) (apply mkEdgesDashed graph))
  ) ; let
)


(define test (gname)
(seq
  (define g (fetch gname))
  (apply initEdgeTraversal g)
  (define onodes (apply select (invoke g "getNodesInArray") (lambda (node) (= (getAttr node "type") "occ"))))
  (define oOut (getAttr g "occsOut"))
  (define rOut (getAttr g "rulesOut"))
  (define cands (apply findCandidates oOut onodes))
  (define cand0 (invoke cands "get" (int 0)))
  (define cand1 (invoke cands "get" (int 1)))
  (define rch0 (apply findReach oOut rOut cand0) )
  (define rch1 (apply findReach oOut rOut cand1) )
  (define len0 (invoke rch0 "size"))
  (define len1 (invoke rch1 "size"))
  (define keep0 (object ("java.util.LinkedList")))
  (define keep1 (object ("java.util.LinkedList")))
  (define hide0 (object ("java.util.LinkedList")))
  (define hide1 (object ("java.util.LinkedList")))
  (define tohide0 (object ("java.util.LinkedList")))
  (define tohide1 (object ("java.util.LinkedList")))
)
)

(invoke java.lang.System.err "println"  "hideEdges.lsp loaded")
) ; top seq


;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/occs.lsp ;;;;;;;;;;
(seq
; needs util.lsp
;; things as aexps
; base case (array java.lang.Object "base" "Src" "Protein")

; modified (array java.lang.Object "modified" <base> <mod1> ... <modn>)
; mod  is string 
;  or sited  (array java.lang.Object "mod" "phos" "Y"  "395") 
;  or  (array java.lang.Object  "mod" "num"  "2") 

; complex (array java.lang.Object "complex" <o1> ... <on>)
;   (setAttr kbg "occ-aexps" occ-aexps)


(define thing2baselist (thing) 
  (let ((list (object ("java.util.LinkedList"))))  
   (seq
     (if (apply isArray thing) 
       (if (> (lookup thing "length") (int 1)) 
         (apply thing2baselistX thing list)))
     list
  ))
)

;  thing is array of len at least 2
(define thing2baselistX (thing list)
  (let ((tag (aget thing (int 0 ))))
    (if (= tag "base")
      (apply setAdd list (aget thing (int 1)))
      (if (= tag "modified")
        (apply setAdd list  (aget (aget thing (int 1)) (int 1)))
        (if (= tag "complex")
         (apply thing2baselistCX  thing list (int 1) (lookup thing "length"))
      ))) ; if x 3
   ) ;let
)

; thing is complex, cur is
(define thing2baselistCX (thing list cur len)
  (if (> len cur) 
    (seq
     (apply thing2baselistX (aget thing cur) list)
     (apply thing2baselistCX  thing list (+ cur (int 1)) len)
    ))
)    

;; input array of aexps
;; output corresponding array of bases
(define computeBasis (aexp-arr)
  (let (
        (len (lookup aexp-arr "length"))
        (basis-arr (mkArray java.util.LinkedList len))
        )
      (apply computeBasisX aexp-arr basis-arr len (int 0))        
  )
) ; computeBasis

(define computeBasisX (aexp-arr basis-arr len cur)
  (if (> len cur)
   (seq
     (aset basis-arr cur (apply thing2baselist (aget aexp-arr cur)))
     (apply computeBasisX aexp-arr basis-arr len (+ cur (int 1)))        
   )
   basis-arr
  )
)

(define test ()
(seq
(define thing-src  (array java.lang.Object "base" "Src" "Protein"))
(define thing-ras  (array java.lang.Object "base" "Ras" "Protein"))
(define thing2  (array java.lang.Object "modified" thing-src "act"))
(define thing3  (array java.lang.Object "modified" thing-ras 
                     "act" (array java.lang.Object "phos" "Y"  "395") ))
(define thing4  (array java.lang.Object "complex" thing-src thing3)) 
(define thing5  (array java.lang.Object "complex" thing-ras thing2)) 
   
; (apply thing2baselist thing-src)
(define labs (array java.lang.String "Src" "Ras" "Src-act" "Ras-Yphos" 
"Src:Ras" "Src-act:Ras"))
(define aexps (array java.lang.Object thing-src thing-ras thing2 thing3 thing4 thing5))

(define barr (apply computeBasis aexps))
(define frame (getAttr (fetch "KBManager") "kbframe"))
(define ddialog (object ("g2d.subset.DDialog" frame (boolean false))))
(invoke ddialog "setScope" labs barr)
(invoke ddialog "setVisible" (boolean true))
)
)  ; test

(invoke java.lang.System.err "println"  "occs.lsp loaded")
) ; top seq

; (load "~/Maude/Lib/M2.2/PLA1/G2dLib/occs.lsp")
; (apply printArr labs)
; (apply printArr aexps)
; (apply printArr barr)


;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/color-loc.lsp ;;;;;;;;;;
(seq

;; eventually add to graphMenu

(define colorLoc (gname loc)
 (let ((graph (fetch gname))
       (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
       (frame (sinvoke "g2d.pla.PLAUtils" "getTabFrame" panel))
       (chooser (object ("javax.swing.JColorChooser")))
       (color (invoke chooser "showDialog" frame "Color Chooser" 
                      java.awt.Color.white))
       (nodes (apply getLocNodes graph loc))
       )
   (seq
     (for node nodes (invoke node "setFillColor" color))
     (invoke panel "repaint") 
    )
  )
)

(define getLocNodes (graph loc)
  (let ((nodes (invoke graph "getNodesInArray"))
        (list (object ("java.util.ArrayList")))
        )

    (seq
      (for node nodes (if (apply hasLoc node loc) (invoke list "add" node)))
      list
    )
  )    
)

(define hasLoc (node loc)
  (invoke (getAttr node "chattylabel") "endsWith" loc )
)

(define restoreColor (gname)
 (let ((graph (fetch gname))
       (panel (sinvoke "g2d.pla.PLAUtils" "getPLAPanel" graph))
       (colorFun (getAttr graph "colorFun"))
       (nodes (invoke graph "getNodesInArray"))
       )
   (seq
     (for node nodes (invoke node "setFillColor" (apply colorFun node)))
     (invoke panel "repaint") 
    )
  )
)


(define test ()
(seq
  (define g2 (fetch "graph2"))
  (define nout (invoke g2 "getNode" "6"))   ;  "6" "Egf-Out"
  (define nclm (invoke g2 "getNode" "7"))    ; "7" "EgfR" "EgfR-CLm" 
  (define ncli (invoke g2 "getNode" "24"))   ; "24" "Pak1-act" "Pak1-act-CLi"
))

(invoke java.lang.System.err "println"  "color-loc.lsp loaded")
) ; top seq


;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/progress.lsp ;;;;;;;;;;
(seq

  (define makeProgressDialog2 (frame modal) 
    (let ((retval (object  ("javax.swing.JDialog" frame modal)))
	  (cpane (invoke retval "getContentPane"))
	  (layout (object ("java.awt.BorderLayout")))
	  (panel (object ("javax.swing.JPanel" layout)))
	  (dim (object ("java.awt.Dimension" (int 250) (int 25))))
	  (bar (object ("javax.swing.JProgressBar")))
	  )
      (seq 
       (invoke retval "setDefaultCloseOperation"
           javax.swing.WindowConstants.DO_NOTHING_ON_CLOSE)
       (invoke panel "setPreferredSize"  dim)
       (invoke bar "setStringPainted" (boolean false))
       (invoke bar "setIndeterminate" (boolean true))
       (invoke panel "add" bar java.awt.BorderLayout.CENTER)
       (invoke cpane "add" panel java.awt.BorderLayout.CENTER)
       (invoke retval "setLocationRelativeTo" frame)
       (invoke retval "pack")
       retval
       )
      )
    )

  (define showProgressDialog (pdialog title) 
    (seq (invoke pdialog "setTitle" title)
	 (invoke pdialog "setVisible" (boolean true))
	 )
    )

  (define hideProgressDialog (pdialog) 
    (invoke pdialog "setVisible" (boolean false))
    )

  (define testMe () 
    (let ((frame (object ("g2d.swing.IOPFrame" "test")))
	  (pd (apply makeProgressDialog2 frame (boolean false))))
      (seq 
       (invoke frame "setVisible" (boolean true))
       (apply showProgressDialog pd "This will not go away"))
      )
    )
    )


;;;;;;;;;; ../Tools/makeg2dlib loaded G2dLib/exploreRule.lsp ;;;;;;;;;;
(seq

(define mkPnetMouseClickedClosure (graph)
  (lambda (self e)
    (seq 
      (if (instanceof self "g2d.graph.IOPNode")
        (let ((type (getAttr self "type")))
          (seq
          (if (= type "rule") 
            (apply doPnetMouseClickedRuleAction graph self e)             
          (if (= type "occ")
;            (apply doPnetMouseClickedOccAction graph self e)
            (object null))) ; not a known node type
          ))
     (object null)  ; not a node
   ) ; if
  ) ;seq
 ))

(define  doPnetMouseClickedRuleAction (graph node e)  
  (let ((clist (object  ("java.util.ArrayList")))
        (clab (getAttr node "chattylabel"))
        (gname (invoke graph "getUID"))
        (exRuleClosure 
          (lambda (self e)
            (sinvoke "g2d.util.ActorMsg" 
                    "send" "maude" gname (concat "exploreRule " clab)) 
           ))
        (exRule
            (object ("g2d.swing.IOPButton" "Explore Rule" exRuleClosure )))
      )
     (seq
      (invoke clist "add" exRule)
      (apply extendSEMenu graph clist)
      ) ))

 (invoke java.lang.System.err "println" "exploreRule loaded")
)
)