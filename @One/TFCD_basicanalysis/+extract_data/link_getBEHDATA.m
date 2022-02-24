function [SessionOut, FlagsOut, SesFlag] = link_getBEHDATA(eid)
p = query_data.create_p(eid)
load([p.mat_metadata],'fsm','experiment_settings');
[LICKdata] = extract_data.link_extractlicks(p);
[fsmdata] = CDDAB_getfsmdata(fsm);
[legacyfsm] = legacysupport.fsmdev4([p.mat_meta]);

end