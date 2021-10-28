function [DAQdata] = link_getDAQDATA(eid)
%%convert eid to p
one = One();
if class(eid) == 'cell'
    if length(eid) == 1
        eid = eid{1};
    else 
        disp('Too many eids supplied')
    end
end
[p] = query_data.create_p(eid);
[DAQdata] = extract_data.getDAQDATA(p);
end