*================================
*Last modified: 7/18/2023
*Master file
*================================

*SPECIFY LOCAL ENVIROMENT
*global LOCALD "...\Replication-folder"
*global LOCALD "D:\Users\manue\Dropbox\AA_Andes\Research\Mexico_FLFP\Submission-WBER\Replication-folder"
global LOCALD "C:\Users\man-fern\Dropbox\AA_Andes\Research\Mexico_FLFP\Submission-WBER\Replication-folder"

*STEP 1.
run "$LOCALD\Code\p0a-shape-maps.do"

*STEP 2.
run "$LOCALD\Code\p1-import-clean-data.do"

*STEP 3.
run "$LOCALD\Code\p2-tables-figures.do"

*STEP 4.
run "$LOCALD\Code\p3-lpm-oaxaca-blinder.do"

*STEP 5.
run "$LOCALD\Code\p4a-shift-share-var.do"

*STEP 6.
run "$LOCALD\Code\p4b-shift-share-estimate.do"