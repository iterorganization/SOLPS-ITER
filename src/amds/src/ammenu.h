/* Menu callbacks */

void CbFileNew(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbFileOpen(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbFileSave(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbFileOutput(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbFileQuit(Widget wg,XtPointer xtpV,XtPointer pcbs);

void CbRestrictInput(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbRestrictOutput(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbRestrictType(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbForbidParticle(Widget wg,XtPointer xtpV,XtPointer pcbs);

void CbEditUndo(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbEditRedo(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbEditRedoAll(Widget wg,XtPointer xtpV,XtPointer pcbs);

void CbCut(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbCopy(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbCrop(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbPasteOr(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbPasteAnd(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbPasteAndNot(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbEditComments(Widget wg,XtPointer xtpV,XtPointer pcbs);

void CbActivate(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbDeactivate(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbShowReactionText(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbShowReactionGraph(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbValidate(Widget wg,XtPointer xtpV,XtPointer pcbs);

void CbOptionsSetup(Widget wg,XtPointer xtpV,XtPointer pcbs);

void CbNewView(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbCloneView(Widget,XtPointer xtpV,XtPointer pcbs);
void CbNewFromTemplate(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbCloseView(Widget wg,XtPointer xtpV,XtPointer pcbs);
void CbCloseSubviews(Widget wg,XtPointer xtpV,XtPointer pcbs);

void CbAbout(Widget wg,XtPointer xtpV,XtPointer pcbs);


