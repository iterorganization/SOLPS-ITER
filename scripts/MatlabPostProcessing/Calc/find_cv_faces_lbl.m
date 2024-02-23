function [cvs,faces] = find_cv_faces_lbl(lbl,gmtry)

faces = find(gmtry.fcLbl==lbl);
cvs=[];
for iFc = 1:length(faces)
    ic1 = min(gmtry.fcCv(faces(iFc),1),gmtry.fcCv(faces(iFc),2));
    ic2 = max(gmtry.fcCv(faces(iFc),1),gmtry.fcCv(faces(iFc),2));
    if (ic1<=gmtry.nCi)
        icc = ic1;
    elseif (ic2<=gmtry.nCi)
        icc=ic2;
    else
        error('Problem with boundary faces')
    end
 cvs = [cvs;icc]; %% questo e quello che viene in b2
end