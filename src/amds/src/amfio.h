/* File I/O user interface */

Widget OpenFileOpenDlg(View w);
Widget OpenFileSaveDlg(View w,int bAtExit);
Widget OpenFileOutputDlg(View w);
Widget OpenFileUnsavedDlg(View w);
Widget OpenFileTemplateDlg(View w);

void NewView(XApp xap);
void CloseView(View w,int bAskUnsaved);
